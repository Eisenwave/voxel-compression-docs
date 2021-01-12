# Compression of Voxel Models

## Abstract

This website contains the documentation of my research project at TU Dresden.
The goal of the project is to develop an efficient algorithm for compressing voxel models.
As an input format, an unsorted list of 3D integer coordinates and attribute data is used.
Multiple methods for encoding geometry data including
Cuboid Extraction (CE),
Sparse Voxel Octrees (SVOs) with Space-Filling Curves, and
Run-Length Encoding (RLE)
are explained and then compared in terms of complexity, compression ratio, and real life performance.
CE fails based on its high complexity, SVOs and RLE perform almost identically in terms of compression ratio and
complexity.
SVOs are the clear winner because of their lower real life memory requirements when reading the input data, resulting
in better performance.

The Free Lossless Voxel Compression (FLVC) codec is developed based on these findings.
Its advantages include arbitrary attribute information per voxel, high performance, streamability, and very low memory
requirements for decoding.
The codec is made available through a FOSS command-line utility which can convert between various common voxel model
formats and the new FLVC format.


##### Relevant Links

- [FLVC Command-Line Interface](https://github.com/Eisenwave/flvc)
- [This documentation on GitHub](https://eisenwave.github.io/voxel-compression-docs/)

##### Notes

This documentation was written using [MkDocs](https://www.mkdocs.org/).
^^`
!!! warning
    Many functions such as searching or syntax highlighting won't work when opening this project with a `file://`
    scheme.
    You can browse this site offline by hosting it as a static web page on a local server.

    To name an example, use `python3 -m http.server 8000` in the root directory to host this page locally on port 8000.
    Then connect to <http://127.0.0.1:8000/>
