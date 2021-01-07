# Uncompressed Format

The uncompressed format used for reference in this project is a 32-bit list of voxels.
In this case a voxel is a triple of coordinates and an ARGB integer, meaning that voxels can be partially transparent.

## Example Implementation

Here is a simple example implementation of a 32-bit voxel list in C++.

```cpp
struct voxel {
    int32_t x;
    int32_t y;
    int32_t z;
    uint8_t a;
    uint8_t r;
    uint8_t g;
    uint8_t b;
}

std::vector<voxel> voxel_list;
```

## Justification - Voxel Arrays vs. Voxel Lists

There are at least two popular methods of representing voxels in an uncompressed way:

- 3D-array of colors, aka. voxel array
- array of coordinate/color pairs, aka. voxel list

The first method is often used in software on a small scale.
Arrays allow for random access in $O(1)$.
They are also used in other research, such as [High Resolution Sparse Voxel DAGs](
related/literature.md#high-resolution-sparse-voxel-dags).
Despite its popularity, arrays are unsuitable for measuring compression ratios because the entropy of the voxel data
poorly correlates with the size of this representation.
For instance, two voxels at $(1, 1, 1)$ and $(1000, 1000, 1000)$ require 1 gigavoxel of space due to all the empty space
between the two voxels.
However, in the best case where all voxels are present, this method has only constant overhead: that which is necessary
to store the dimensions of the array.

The second representation -which is the one used here- will require space that linearly scales with the amount of
non-empty voxels.
Note that in the worst case, this could require four times the space of the first method due to the coordinates
being stored explicitly.
This kind of overhead is still preferable to the potential (near) complete waste of space of the first method.

To summarize, here is a quick overview:

| | Voxel Array | Voxel List |
| ----- | ----- | ----- |
worst case overhead (space) | $O(\infty)$[^1] | $O(4n)$[^2] 
best case overhead (space) | $\Omega(1)$ | $\Omega(4n)$[^2]
random access (time) | $O(1)$ | $O(n)$

[^1]: Unbounded because two voxels can be infinitely far apart, creating infinite wasted space / overhead
[^2]: The constant factor of 4 is irrelevant in this notation, but illustrates the extent of the overhead

## Serialization

Serialization of the [VL32](file_formats/vl32.md) representation is trivial because the data structure in memory is
similar, if not identical to its serialized counterpart.
To serialize it, we must simply write each element of the array from first to last to disk.
