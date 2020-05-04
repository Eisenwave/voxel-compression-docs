# Run-Length Encoding

Run-Length Encoding (RLE) is a form of lossless data compression which stores elements of said data using a single
value and a count or "run-length".

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

```
aaabbbcfdeef -> 3a3bcfd2ef
```

### Out-Of-Band Signaling

This method encodes all of the data in pairs of count and data instead of leaving single characters intact.
Its main advantage is the simplicity of parsing and an identical effect for all types of data.
While a particular escape sequence might be a poor choice for some specific data set, this method does not require an
escape sequence and thus doesn't suffer from the problem.

To avoid bloating the data in size, further measures must be taken such as having a sequence which can signal a
sequence of different characters as well as a sequence of identical characters.
For instance, negative counts could be used to signal multiple different characters.

```
aaabbbcfdeef -> 3a3b1c1f1d2e1f
```
