# FLVC Data Stream

The FLVC file format consists of a container format and a zlib-compressed data stream as explained in [FLVC](flvc.md).
The data stream stores a Sparse Voxel Octree, optimized in multiple ways.
Due to the FLVC format allowing arbitrary attributes, the exact structure of the data stream is also variable.
Attribute definitions in the container specify the structure of the attribute data per voxel.
This structural information is crucial for certain optimizations performed in the FLVC codec.



## General Structure

Generally, the FLVC data stream consists of nodes of an SVO, ordered in
[*Accelerated Depth First*](../svo/svo.md#acc-depth-first) order.
For the FLVC data stream, this order has the advantage that multiple child nodes can be compressed and decompressed at
the same time, compared to *Depth First* order, where only one node can be read at a time.
Accelerated Depth First order allows for optimizations that rely on all *neighbor nodes* being known to the decoder
at the same time.

Each node is structured as illustrated under [SVO Serialization](../svo/svo.md#serialization).
There are two types of nodes: 
*Leaf nodes* store a *child mask* of voxels and attribute data for each voxel.
*Branch nodes* only store a mask of other nodes, which can be either *leafs* or *branches*.


Without any optimization steps, a typical data stream with mask $m$ one two-byte attribute $a$ would look like:
\[
(m_0, m_1, m_2, m_3, a^\text{lo}_3, a^\text{hi}_3, \ldots, m_n , a^\text{lo}_n, a^\text{hi}_n)
\]
In this example, $0..2$ are branch nodes, $3$ is the first leaf node.

FLVC data streams encode all attributes in little-endian byte order.
This byte order is not only the standard for x86 architectures, but is also easier to perform optimization steps such
as bitwise interleaving on.

## Encoding and Decoding Complexity

The encoder needs to construct the SVO in its entirety before writing anything to disk.
Even the very last voxel which is read from the input could change the SVO structurally.
For example, a voxel that lies outside the current capacity of the SVO will require (unilateral) growth of the tree
structure, meaning that the tree receives a new root node.

Depth-first encoded trees can be read using only a stack, resulting in $O(\log{v})$ space complexity for the decoder.
Accelerated depth-first requires $O(b \log_b{v} )$ space complexity, where $b$ is the branching factor of the tree,
which is eight in this case.
FLVC only allows 21 SVO layers because the [Octree Node Index](../svo/construction.md#octree-node-index) needs to fit
a 64-bit integer.
So in practice, the decoder can simply allocate $8 \cdot 21 \cdot x$ bytes of memory, where x is the size of
attribute data, child masks, and internal data stored per node.

In summary:

| Complexity | Encoder | Decoder |
| ----- | ----- | ----- |
| Space | $O(v)$ | $O(8 \log_8{v})$
| Time  | $O(v)$ | $O(v)$

In practice, decoding is about twice as fast as encoding due to the lower memory requirements.
Computationally, all following optimizations have linear complexity.
Some steps require propagating information from the bottom to the top of the SVO, but as explained in
[SVO - Extreme Cases And Limits](../svo/svo.md#extreme-cases-and-limits), this results in an additional cost of at worst
$\frac{1}{7}$.

## Optimizations Overview

There are three layers of optimizations applied to the SVO before writing to disk:

1. SVO Optimizations
2. Delta Coding
3. Attribute De-Interleaving
4. Bitwise Interleaving

The first step consists of the two SVO optimizations [Single-Octant Optimization](../svo/optimization.md#single-octant)
and [Complete Branch Trimming](../svo/optimization.md#complete).

All three further optimizations require all children to be available to the encoder/decoder.
These optimizations steps do not decrease the size of the data stream whatsoever.
Delta Coding even increases it.
However, they turn *geometric redundancy* into *bitwise redundancy*.
In short, this means that redundancies such as *clustering* of voxels in one region of space, as well as the
*clustering* of attributes are converted into a redundancy at the bit level.
This can then be exploited by an entropy coder.
In the case of FLVC, the whole data stream is compressed using zlib.

## Delta Coding

### Idea

Delta Coding is a popular method of eliminating redundancy from data where the numerical difference between consecutive
elements most often falls into a limited range.
Take the following example:

\[\begin{align}
n_i =& (0, 1, 2, 3, 4, 5, ...) \\
\frac{\Delta n_i}{\Delta i} =& (1, 1, 1, ...) \\
\frac{\Delta\Delta n_i}{\Delta i} =& (0, 0, 0, ...)
\end{align}\]

Here, it may be obvious to the viewer that the $n_i$ follows a very predictable pattern.
However, at the bit level, this sequence would be $(00_2, 01_2, 10_2, 11_2, \ldots)$.
We can see that there is a lot of variation in the lowest two bits.
The first derivative has no variation at all and the second derivative is simply an infinite zero-sequence.
In conclusion, we turn our knowledge that the sequence follows a predictable pattern into a *bitwise redundancy*.

### FLVC Delta Coding

Delta Coding in FLVC takes place between child and parent, meaning that the attributes of the children are converted to
a delta from the parent attribute.
At this point you may be confused, because parents don't have any attributes.
Only voxels, which are the leaf nodes of the tree, have attributes such as color; their parents do not.

As part of this optimization step, we must assign values to the parents depending on their children.
This occurs in a *mipmapping* or *reduction* step where the values of children are propagated towards the root of the
tree using the $min$ operator.
The parents thus receive the minimum attribute of their children and the children are stored as deltas to this common
minimum.

Such a *reduction* step is performed bottom-up for the entire tree by the encoder after the last voxel has been stored
in the SVO.
This step exploits *attribute locality*, meaning that voxels close to each other also tend to have similar attributes.
When all attributes fall into a similar range, the deltas will all be low as well.

!!! note
    The reason for using the $min$ operator in particular is that deltas are always representable as unsigned integers
    without relying on specific overflow semantics.
    Deltas must be unsigned to avoid problems such as the delta between the 8-bit unsigned integers `0` and `200` not
    being representable by an 8-bit signed integer.

##### Example
```cpp
// original attribute values of the child nodes
child[0] = 200 = 0b1100'1000
child[1] = 205 = 0b1100'1101
child[2] = 210 = 0b1101'0010
child[3] = 215 = 0b1101'0010

// minimum assigned to parent
parent   = 200 = min(child[0..3])

// deltas to parent computed and stored in each child node
child[0] - parent =  0  = 0b0000'0000
child[1] - parent =  5  = 0b0000'1001
child[2] - parent = 10  = 0b0000'1010
child[3] - parent = 15  = 0b0000'1111
```

As can be seen in this example, the attribute values started out as having differences both in the upper and lower
nibble (half-byte).
After the optimization step, there is only variation in the lower nibble.
The upper nibble is completely zeroed out.

## Attribute De-Interleaving

In the next step, attributes are de-interleaved.
Remember, our data stream currently looks like this, where $m$ is a child mask and $a$ is an attribute:
\[
(m_0, a_0, m_1, (a_1-a_0), m_2, (a_2-a_0), m_3, (a_3-a_0), \ldots)
\]
Attributes which might have no correlation with each other are stored right next to each other in the stream.
For example, high-entropy child masks are stored right next to attributes, which are delta coded and potentially
all zeroed out.
By de-interleaving these attributes and storing one list per attribute instead, we can bring correlated bytes closer
together in the byte stream:
\[
(m_0, a_0, m_1, m_2, m_3, (a_1-a_0), (a_2-a_0), (a_3-a_0), \ldots)
\]
We can only do this for at most eight neighboring nodes at a time.
In a breadth-first stream, we could also perform this for an entire layer of the tree, but we use *Accelerated
Depth-First*.

This optimization is almost trivial computationally, because we can simply create a permutation for each possible
number of child nodes for our specific attribute layout.
Decoding (interleaving) can be performed just as easily by computing the inverse of the pre-computed permutation.

## Bitwise Interleaving

The motivation of this is to clump together all less significant bits and all more significant bits, per child.
After Delta Coding, the more significant bits will often consist of only zeros.
Grouping together those bits is helpful to entropy coders, which can then perform RLE or other compression steps.
An example of how bit-interleaving works can be found under [SVO Optimization](../svo/optimization.md#examples).

After this final optimization step, the data stream looks as follows:
\[
(m_0, a_0, m_1, m_2, m_3, \text{ileave}(a_1-a_0, a_2-a_0, a_3-a_0), \ldots)
\]

!!! note
    Attribute De-Interleaving and Bitwise Interleaving together are actually equivalent to bitwise interleaving of
    the raw data of each node.
