# Introduction

Volumetric Pixels or voxels are an increasingly popular method of representing 3-dimensional data.
Their uses are plentiful such as representing quantized point cloud data, medical scans, acceleration data structures
for VFX, high resolution sculptures, or 3D models with an intentional voxel art style.
Accessing voxels randomly can even be achieved with constant time complexity, all while using relatively simple data
structures.

However, perhaps because of this simplicity, efficient permanent storage of voxel models is rarely a concern.
Out of more than 20 common voxel file formats, only one
([Qubicle Binary Tree](related/voxel_formats.md#qubicle-binary-tree)) makes a serious attempt at compression
of voxel models by using [zlib](https://zlib.net/).
Some solutions combining general-purpose technologies such as storing a stack of PNG layers can also be found in formats
like [SVX](related/voxel_formats.md#simple-voxels).
The sophistication of widely used voxel software is overall at a pre-1996 level compared to image compression.
This fact promises enormous improvements in compression ratio for a new file format that was designed specifically
for the purpose of efficiently storing voxel models on disk.

The goal of this project was to develop an efficient codec for the purpose of on-disk storage of voxel models.
Compression ratio and performance are equally important.
In addition to the overwhelmingly popular approach of using sparse voxel octrees (SVOs) for compact storage, we also
examine alternative solutions such as a variety of run-length encoding schemes (RLE) using different space-filling
curves, including Nested Iteration, Morton Curves, and Hilbert Curves.

In the following chapters we first examine geometry-only encoding of voxel models.
RLE and SVO techniques are examined thoroughly and compared against each other in compression and performance.
The reference point for compression efficiency is a list of points with quantized coordinates.
This was the size of the input data is directly proportional to the number of voxels.
Based on the findings, we discuss a suitable attribute encoding scheme that can be well combined with our geometry
encoding scheme of choice.
Finally, the FLVC codec which incorporates all our findings is presented.

## Related Work

[Schnabel et al.](related/literature.md#octree-based-point-cloud-compression) first presented in 2006 how sparse voxel
octrees can be used to efficiently store point-cloud data.
A technique is suggested where a single byte is used to encode the existence of a child node, which represents
individual voxels at the bottommost level of the SVO.
While this technique was not its main subject, the suggested approach can be further optimized by encoding recursively
occupied nodes of the octree specially.
The research also shows that the number of child nodes is not uniformly distributed and may show significant
redundancy based on the model, which can be exploited by an arithmetic coder.

[Byrne et al.](related/literature.md#vola) designed an efficient file format named VOLA for storing quantized point
cloud data with no attributes other than geometry.
VOLA stores voxels not as an array -as is often done at runtime- but as an octree where to layers are
combined into one, creating a tree with a branching factor of 64.
The performance of this approach is outdone by our codec, but VOLA was an inspiration.

Most other contemporary research is focused on the use of voxels at runtime.
In part, this is because voxels are being used primarily as VFX accelerators where polygonal models are unsuited to
achieve certain effects in real time, such as global illumination.
This task inherently comes with strict performance requirements.

[Laine et al.](related/literature.md#efficient-svos) presents a sparse voxel octree-based technique for representing 
geometry and shading attributes.
Some techniques found in our implementation are similar to the presented memory layout.
Namely, the use of an 8-bit child mask to encode which children of a parent node exist was inspired by this paper.

[Kämpe et al.](related/literature.md#high-resolution-sparse-voxel-dags) show that SVOs can be further compactified
by merging identical trees and generalizing to sparse voxel directed acyclic graphs (SVDAGs).
This approach was developed for realtime rendering with 32-bit pointers encoding links between nodes.
While a significant reduction in space can be observed, this technique does not provide significant benefits to a
pointerless structure with 8-bit child masks, which is why it was not used in our project.
