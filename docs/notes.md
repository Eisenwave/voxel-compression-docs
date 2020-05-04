# Thoughts on Domain-Specific Voxel Compression

## Datasets to test on

* point clouds from medical 3d scanners or general purpose 3d scans
* voxelized polygonal or surface models
* extruded heightmaps
* manually created voxel models
* computer-generated voxel modesl like 3d perlin-noise

## RLE (Run-Length Encoding)

* encode geometry separately from colors
* first use a universal, easy-to-decade format
    * `u32 {u1 bitToEncode, u31 length}`
    * then discuss how that format can be made more efficient
        * compare allocating different amounts of bits for length
    * try encoding more than just a bit with RLE, also try pairs and triplets, up to a maximum of 1 byte
        * compare compression ratios and pick the sweet-spot between length and bits

## Sparse Voxel Octrees

`sum (1/2)^n, n=0 to infinity == 2`
`sum (1/8)^n, n=0 to infinity == 8/7`

* DFE (depth-first encoding) vs BFE (breadth-first encoding)

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

