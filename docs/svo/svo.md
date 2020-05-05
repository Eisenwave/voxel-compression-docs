# Sparse Voxel Octree

![Octree](https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Octree2.svg/1280px-Octree2.svg.png)
Source: [Wikipedia](https://en.wikipedia.org/wiki/Octree#/media/File:Octree2.svg)

A sparse voxel octree is a data structure which stores voxels in a tree with a branching factor of 8, with its branches
being potentially absent.
Missing branches typically represent empty volumes where no voxels exist.
The greater these volumes are, the closer to a the root of the tree can the branches be pruned.

This results in a very efficient representation of models with a significant portion of empty space.
Unlike with a voxel list, all positioning is implicit and results from the tree structure, meaning that no space has
to be used for the storage of coordinates during serialization.
Thus, octrees combine the two greatest advantages of voxel lists and voxel arrays:

- like lists, they waste little space on encoding empty voxels
- like for arrays, voxel coordinates are implicit and little space is wasted

## Limitations

#### Best Case
Entirely empty models can be encoded using just the root note, which then encodes that no subtrees exist.

#### Worst Case
Entirely filled models will have some overhead compared to an array of voxels.
For every eight nodes, there is one parent node.
We can calculate the maximum possible overhead by summing up this $\frac{1}{8}$ overhead infinitely:
$$\sum_{n=1}^\infty{\frac{1}{8}^n} = \frac{1}{7}$$
So at worst, our data will increase by $\frac{1}{7}$, which is much better than a 100% increase such as for binary
trees.

## Construction

How an octree can be constructed from a list voxels is thorougly explained in [[construction.md]].

## Serialization

To be used in a serial data format, octrees must first be serialized.
Nodes will no longer be laid out "randomly" in memory but instead be arranged one after another.
There are two well-known strategies for traversing trees completely:

- Depth-First-Search (DFS)
- Breadth-First-Search (BFS)

DFS can be performed using only a stack to keep track of the node number at each level.
On the deepest level, the next node is chosen until the end is reached and the next parent node is chosen.
This low memory cost (which is in fact $O(\log{n})$ where n is the number of nodes) is highly advantageous when encoding
enormous models. 

BFS comes with a higher cost since a typical algorithm appends all branches to a queue for every traversed node.
This means that in the worst case, which is at the beginning of serialization eight nodes are appended on every level
before any node is popped from the queue, resulting in a higher memory cost.

### Single-Bit Format

* `0` stands for air-subtree
* `1` stands for partially or entirely filled voxel-subtree

8 Bits per octree-node, thus this format is byte-aligned.

### 1.5-Bit Format

* `00` stands for air-subtree
* `01` stands for solid subtree
* `1`  stands for partially filled subtree

Variable amount of bits per octree-node, neither bit- nor byte-aligned.
On the last level (node = voxel), the single-bit format is used because there are no subtrees.

### 2-Bit Format

* `00` stands for air-subtree
* `01` stands for solid subtree
* `10` stands for partially filled subtree
* `11` variable purpose

#### `11` for Raw/Array Subtrees

Useful to encode subtrees completely filled with high-entropy content.
On the second-to-last level, `11` for raw-subtrees there is no difference between `10` and `11`, so reverting to
the 1.5-bit format is viable.
On the last level, the single-bit format should be used.

As long as the 1.5-bit format is not used, this encoding is completely byte-aligned:
* alignment to `16`-bit boundaries on most levels
* alignment to `8`-bit boundaries on last level

#### `11` for Pointers to Subtrees on the Same Level

Useful for encoding multiple similar subtrees.
Similarities between structures could be effectively exploited.
Verifying whether subtrees are equal down to the base level has very high complexity: `O(n^2 * 8^n)`.
The comparison depth could be reduced down to a limited number of levels or the level number could be encoded next to
the pointer: `{u32 indexOfOtherTree, u8 depth}`.

Instead of the pointer, a tree could instead encode all the places where it is additionally used.
This would make decoding easier, since remembering trees on the same level is not necessary.

## Tetrahexacontrees

This term comes from "tetrahexaconta" (Greek for 64) and "tree".
It builds on the idea of octrees but expands the branching factor from 8 to 8<sup>2</sup>, or 64.
A use of this concept can be seen in the
[VOLA](../related/literature.md#vola-a-compact-volumetric-format-for-3d-mapping-and-embedded-systems) file format.

64-bit architectures established themselves as the de-facto standard for desktop operating systems.
Anecdotally, "macOS Mojave would be the last version of macOS to run 32-bit apps"
-[Apple](https://support.apple.com/en-us/HT208436).
Thus, optimization of algorithms in the present day can be performed for 64-bit architectures without worrying about
32-bit users.

### Comparison to Octrees

Tetrahexacontrees encode two octree layers of depth in a single layer.
CPU-performance wise, they fill exactly one 64-bit register with one node, using the architecture's capacities
optimally unlike octrees.

However, they sacrifice potential compression efficiency.
In the best case which is an entirely empty node, an octree requires only one byte of space to encode that each of the
8 child-nodes are empty.
A hexacontree will however require eight times the space, meaning 64 bits that are all `0`.
In the worst case, which is noise that requires all nodes to be present, a tetrahexacontree is slightly more efficient
because it requires only 8 bytes for two octree layers instead of 8+1 such as an octree.

In conclusion, tetrahexacontrees can come with a significant space cost, while making better use of modern
architectures.
