# SVO Construction

When constructing an SVO from a list of voxels, the complexity of this process depends on the data fed to the
constructing algorithm.
Within the scope of this project, the [uncompressed format is a list of voxels](../uncompressed.md), but there are
further subtle differences.

## Special Case Where Voxel Coordinates Are Positive

A voxel from this list can be defined as a tuple $(x, y, z, c)$ of coordinates and a color $x, y, z, c \in \mathbb{Z}$. 
If the voxels are sorted with the first voxel being the most negative corner of the model, it can be treated as the
origin of the model $(x_0, y_0, z_0)$.
All voxels can then be translated by $(-x_0, -y_0, -z_0)$.
In such a case, after the translation we work with simplified voxels $(x, y, z, c) \in \mathbb{N}^4$.
If $x, y, z$ are already guaranteed to be positive, this condition is obviously also met.

## Octree Node Index

The conventional method of addressing positions within a 3D-container would be by using a vector
$v = (x, y, z) \in \mathbb{Z}^3$.
Finding a voxel within an octree using $v$ would cumbersome, since it requires recursively testing whether
each coordinate is in the lower or the upper half of current subtree.
As long as the tree's dimensions are a power of 2, this is actually simplified since this test can be reduced to
checking whether a bit is set.
For example, 128 is in the upper half of the 256-tree, because the most 128-bit is set, which is not the case for 127.

### Idea

Binary numbers can generally be interpreted as locations in binary trees:
```
     _**_
    /    \
  0*     1*
  / \    / \
00  01  10  11
```
As we can see, the lower bit indicates whether the position is left or right in the lower subtree and the higher bit
indicates whether the position is left or right in the upper subtree.
The same pattern occurs for octal digits and octrees.
$(x, y, z)$ can thus be seen as three positions in separate binary trees which we want to combine into an octree.

To convert $(x, y, z)$ to a position in an octree, the bits of $(x, y, z)$ can simply be interleaved.
The result will be a single number of octal digits, each of which represents the position within one octree node.

### Examples

This is how coordinates can be mapped to octree indices:
$$\begin{align}
& (6, 8, 9) = (0101_2, 1000_2, 1001_2) \\
\xrightarrow{\text{interleave}} \quad& (0,1,1),(1,1,1),(0,0,0),(1,0,1) \\
\xrightarrow{\text{concatenate}} \quad& 011,111,000,101_2 = 3705_8 = 1989
\end{align}$$

Note that in the above example, $x$ is used as the most significant bit of each octal digit, followed by $y$ and $z$.
This is how octree node indices can be mapped to coordinates:

$$\begin{align}
&25 = 31_8 = 011,001_2 \\ 
\xrightarrow{\text{to vectors}} \quad& (0, 1, 1), (0, 0, 1) \\
\xrightarrow{\text{deinterleave}} \quad& (00_2, 10_2, 11_2) = (0, 2, 3)
\end{align}$$

### Implementation

The following C++17 implementation shows how three coordinates $(x, y, z)$ can be efficiently interleaved using
binary Magic Numbers.
The implementation expands upon one of the
[Bit Twiddling Hacks by Sean Eron Anderson](https://graphics.stanford.edu/~seander/bithacks.html#InterleaveBMN).

```cpp
// interleaves a given number with two zero-bits after each input bit
// the first insertion occurs between the least significant bit and the next higher bit
constexpr uint64_t ileave_two0(uint32_t input) {
    constexpr size_t numInputs = 3;
    constexpr uint64_t masks[] = {
      0x9249'2492'4924'9249,
      0x30C3'0C30'C30C'30C3,
      0xF00F'00F0'0F00'F00F,
      0x00FF'0000'FF00'00FF,
      0xFFFF'0000'0000'FFFF
    };

    uint64_t n = input;
    for (int i = 4; i != 1; --i) {
        const auto shift = (numInputs - 1) * (1 << i);
        n |= n << shift;
        n &= masks[i];
    }

    return n;
}

constexpr uint64_t ileave3(uint32_t x, uint32_t y, uint32_t z)
{
    return (ileave_two0(x) << 2) | (ileave_two0(y) << 1) | ileave_two0(z);
}

```

!!! note
    An implementation for a variable amount of inputs is equally possible, but would significantly increase the code
    complexity.
    Most notably, the `masks` lookup table would need to be generated computationally.
    
    C++ was chosen due to its `constexpr` compile-time context.
