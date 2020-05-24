# Run-Length Encoding

Run-Length Encoding (RLE) is a form of lossless data compression which stores elements of said data using a single
value and a count or "run-length".

## Viability for Voxel Compression

RLE is viable in those cases, where there are long runs of identical or very similar data.
Due to [voxel arrays](../uncompressed.md) often containing huge amounts of empty space, they also contain long runs of
`0x0` RGB values (or whatever other value represents empty voxels) which could be run-length-compressed.
This mitigates their greatest downside compared to [voxel lists](../uncompressed.md), their empty-space-overhead.

### Existing Implementation: Qubicle Binary File Format

The [Qubicle Binary](//getqubicle.com/learn/article.php?id=22) (QB) file format has an option for compressing models
using RLE.
It is still in use, although it has been superseded by the
[Qubicle Binary Tree](//getqubicle.com/learn/article.php?id=47) (QBT) file format which uses [zlib](//www.zlib.net/)
instead of custom RLE.

Models are mode of *matrices*, which are arrays, usually sized 128<sup>3</sup> or smaller[^matrix_size].
When compressing *matrices*, each *slice* (xy-plane) is being run-length-encoded.
The RLE implementation uses [in-band-signaling](#in-band-signaling).
The `CODEFLAG = 2` escape sequence signals a following pair of count and data, whereas the `NEXTSLICEFLAG = 6` signals
the end of the current *slice*.

[^matrix_size]: For most of its lifetime, Qubicle did not support matrices greater than 128 in each dimension.
However, the file format technically allows for greater sizes due to a 32-bit integer being used for each dimension.

#### Criticism

This implementation is deeply flawed, in that it fails to exploit an obvious non-conflicting escape sequence:
A color with an alpha of zero is invisible, regardless of its other components.
In the QB format, the escape sequences correspond due pitch black colors with an alpha of `2` or `6` respectively,
which is almost invisible.
Alpha channels can also be used to store visibility maps instead, where such values would be far more common.
Such a problem could have been easily mitigated by using different values for the escape sequences or by not storing
colors in RGBA or BGRA format.


## In-Band- vs Out-Of-Band- Signaling

The main distinction in RLE methods can be made between *In-Band Signaling* And *Out-Of-Band Signaling*.

### In-Band Signaling

This method uses the alphabet of the data which it attempts to compress.
For instance, if the data consists of only alphabetic ASCII characters, then digits could be used to encode the counts.
Or for ASCII characters which are stored in 8-bit integers, the uppermost, unused bit could be used to signal that the
remaining seven bits are the count.

In any case, this method is best when the addition of the count does not conflict with the existing data.
Otherwise, an *escape sequence* is necessary.
For instance, to encode any 8-bit integer sequence, the value `0xff` could be used to "escape" the data and be followed
up by the count and the actual byte to be encoded, including `0xff`.

$$\text{aaabbbcfdeef} \rightarrow \text{3a3bcfd2ef}$$

### Out-Of-Band Signaling

This method encodes all of the data in pairs of count and data instead of leaving single characters intact.
Its main advantage is the simplicity of parsing and an identical effect for all types of data.
While a particular escape sequence might be a poor choice for some specific data set, this method does not require an
escape sequence and thus doesn't suffer from the problem.

To avoid bloating the data in size, further measures must be taken such as having a sequence which can signal a
sequence of different characters as well as a sequence of identical characters.
For instance, negative counts could be used to signal multiple different characters.

$$\text{aaabbbcfdeef} \rightarrow \text{3a3b1c1f1d2e1f}$$

### Summary

In-Band signaling should be used in cases where certain values in the data are unused, allowing for an escape sequence
with no conflicts with other data.
If there are not just a handful of values but an entire bit per byte which is unused (such as in
[ASCII](//en.wikipedia.org/wiki/ASCII)), then this method becomes especially viable.

Otherwise, OOB signaling is preferable, as it gives much more flexibility to the implementing developer and doesn't 
produce any conflicts with the data to be compressed.
