# Uncompressed Format

The uncompressed format used for reference in this project is a 32-bit list of voxels.
In this case a voxel is a triple of coordinates and an ARGB integer, meaning that voxels can be partially transparent.

## Example Representation
```c
struct voxel {
    int32_t x;
    int32_t y;
    int32_t z;
    int8_t a;
    int8_t r;
    int8_t g;
    int8_t b;
}
```

## Justification

There are at least two popular methods of representing voxels in an uncompressed way:

- 3D-array of colors
- array of coordinate/color pairs

The first method is often used in software on a small scale.
Arrays allow for random access in `O(n)`.
It is also used in other research, such as [High Resolution Sparse Voxel DAGs](
related/literature.md#high-resolution-sparse-voxel-dags).
Despite its popularity, it is unsuitable for measuring compression ratios because the entropy of the voxel data poorly
correlates with the size of this representation.
For instance, two voxels at `(1, 1, 1)` and `(1000, 1000, 1000)` require 1 gigavoxel space due to all the empty space
between them.
However, in the best case this method has only constant overhead, that which is necessary to store the dimensions
of the array.

The second representation -which is the one used here- will require space that linearly scales with the amount of
non-empty voxels.
Note that in the worst case, this could require four times the space of the first method due to the coordinates
being stored explicitly.
This kind of overhead is still preferable to the potential (near) complete waste of space of the first method.

## Serialization

Serialization of this representation is trivial.
Here, the [VL32](file_formats/vl32.md) file format is used.
