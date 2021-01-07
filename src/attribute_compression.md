# SVO Attribute Compression

Geometry is the most important attribute, as it gives the model shape.
A model can exist without color attributes but not without a shape.
However, geometry does not inherently make up the majority of a model's
information in bytes.
Whether a voxel exists or not is only single-bit information, whereas color is
often 24-bit information.
Also consider alpha channels, weights, and many other attributes and it becomes
plain to see that other attributes comprise the vast majority of information.

## Requirements

We have already decided to use SVOs as the form of geometry compression.
It is essential that whatever method we design, it must work well with an
existing SVO structure.
In total, we have the following requirements:

- good SVO interoperability
- low memory/time complexity when encoding/decoding models
- streamability
- exploiting redundancies in typical models
- high compression ratio
- acceptable real world performance


## Inspiration: Image-Based Approach

Storing a 24-bit RGB color for every voxel would be very expensive.
What some formats such as PNG instead do is store a delta between neighboring colors.
Instead of storing deltas we could also store whether neighboring colors are exactly identical, but such a naive
approach would become very ineffective when introducing small amounts of noise into the colors.

## Primer on PNG Filtering

```plain
c|b
-+-
a|x
```
`x` is the color to encode and `a, b, c` are its neighbors.
In the [Filtering Section](https://www.w3.org/TR/2003/REC-PNG-20031110/#9Filters) of the PNG specification we can
see that the colors are converted to a delta-based representation relative to their neighbors.

This step however does not reduce the size of the data as "both the inputs and outputs fit into a byte".
It is merely a pre-processing step which increases redundancy in the image bytes and thus improves
[DEFLATE compression, the next step](https://www.w3.org/TR/2003/REC-PNG-20031110/#10Compression).
The data will be turned into mostly low values, often times exactly zero,
assuming that the deltas from the prediction are low in magnitude.

## Applying The Approach to Three Dimensions

The PNG-style approach is already very promising but needs to be heavily modified
so that we can apply it to 3D models.
It meets all requirements in terms of performance and streamability.
An added bonus is that the entropy coder can be treated as a black box and easily
swapped out by a different algorithm.
We are not in any way restricted to using zlib specifically.

However, it is not obvious how to extend this approach to work well with an SVO.
The greatest problems arise during the decoding process:

1. We might not always have a neighbor, unlike in an image where we only need to
   store the previous and the current line of pixels.
   Voxels can be surrounded by vast quantities of empty space.
2. Making it possible to access already read neighbors randomly would require
   reading the entire SVO into memory when decoding.
3. Random access to neighbors in an SVO would have logarithmic complexity.
   In an image, it would be constant.
4. We don't make any use of the hierarchical structure of the SVO when referencing
   direct neighbors.

There is a simple solution that solves every single one of these problems:
Referencing parent nodes and encoding deltas to parents instead of deltas to
direct neighbors.
Since every node has a parent (except for the root node) and parents are very
easy to access during encoding and decoding, we resolve almost all problems
regarding space/time/memory requirements.
The center of parent nodes is also located half a voxel away from the center of
its child nodes, which is why their attributes are typically similar.

In an SVO which encodes voxel models, only the leaf nodes have any attribute values.
The leaf nodes represent the voxels, all layers above are just subdivisions of space.
Before we can compute a delta from the parents, we must propagate the values of
children upwards in the tree in a mipmapping step.
For example, the parent could be assigned the minimum, maximum, average, etc. of
all its children.
See the [FLVC Data Stream](flvc/flvc_optimizations.md) for how this was
implemented in practice.
This mipmapping step does increase the size of the model initially, but if the
values of the  children are all very similar, there will be a net benefit for
the entropy coder.



