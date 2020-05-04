# Analyzed Methods

## RLE (Run-Length Encoding)

* encode geometry separately from colors
* first use a universal, easy-to-decade format
    * `u32 {u1 bitToEncode, u31 length}`
    * then discuss how that format can be made more efficient
        * compare allocating different amounts of bits for length
    * try encoding more than just a bit with RLE, also try pairs and triplets, up to a maximum of 1 byte
        * compare compression ratios and pick the sweet-spot between length and bits

## Sparse Voxel Octrees

