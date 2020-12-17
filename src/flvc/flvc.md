# Free Lossless Voxel Compression (FLVC)

FLVC is the file format produced based on the results of the presented research.

**Extension:** `.flvc`<br>
**Media Type:** `model/x-flvc`<br>
**Magic Bytes:** `"\xff\x11\x33\xccflvc"` = `ff 11 33 cc 66 6c 76 63`

## Container Format Specification

```rust
// TYPE DEFINITIONS ============================================================

type u8  = unsigned integer<8>
type u16 = little_endian unsigned integer<16>
type u32 = little_endian unsigned integer<32>
type u64 = little_endian unsigned integer<64>

type i8  = twos_complement integer<8>
type i16 = little_endian twos_complement integer<16>
type i32 = little_endian twos_complement integer<32>
type i64 = little_endian twos_complement integer<64>

type bool8 = max<1> u8
type ascii = max<127> u8

// CONSTANTS ===================================================================

enum attribute_modifier : u16 {
    // this attribute has no spatial locality
    // should be used for random unique ids etc.
    NON_LOCAL = 1
    // only applicable to the "color" attribute
    // whatever color model is used, alpha will be appended to it last
    // ARGB is the default, in which alpha is first
    ALPHA_LAST = 2
}

enum attribute_type : u8 {
    BOOL       = 0x00
    INT_8      = 0x11
    INT_16     = 0x12
    INT_32     = 0x13
    INT_64     = 0x14
    UINT_8     = 0x21
    UINT_16    = 0x22
    UINT_32    = 0x23
    UINT_64    = 0x24
    FLOAT_32   = 0x41
    FLOAT_64   = 0x42
}

enum builtin_identifiers : string16 {
    // attributes will be used as the color of the voxel
    COLOR = "color"
    // attributes will be used as the normal of the voxel
    NORMAL = "normal"
}

// HELPER STRUCTS ==============================================================

struct vec3<T> {
    T x
    T y
    T z
}

struct string8 {
    nonzero u8 size
    ascii[size] content
}

struct string16 {
    nonzero u16 size
    ascii[size] content
}

// HEADER ======================================================================

struct main {
    // 8 bytes of file magic
    u64 magic = 0xff11_33cc_666c_7663
    
    // major version and minor version, currently 0.1
    u8 version_major = 0
    u8 version_minor = 1
    
    // header and zlib-encoded data
    // (extern because can't be fully defined in StructLang)
    header header
    
    // only store a zlib-encoded stream for non-empty SVOs.
    if (!header.empty) {
        extern zlib_stream content
    }
}

struct header {
    u16 attribute_count
    attribute_definition[attribute_count] attributes
    // Global offset which is applied to all voxels which we read.
    vec3<i32> offset
    // The exact dimensions of the voxel volume.
    // The SVO has to contain these dimensions, but may be larger internally.
    // (SVOs can only have power-of-two dimensions)
    vec3<u32> size
    // If true (1), the volume is empty.
    bool8 empty
}

struct attribute_definition {
    // bitmap storing all modifiers
    u16 modifier_map
    // type of the attribute
    attribute_type atype
    // If not zero, this indicates that the type is a fixed-size array-type or
    // vector-type.
    // If zero, the type is a variable sized-array.
    u8 cardinality
    // unique identifier of the attribute
    // certain values such as "color" are builtin and reserved
    // (see enum builtin_identifiers)
    string8 identifier
}
```
`header.size` is not strictly necessary for decoding, but it can be helpful when converting directly to a 3D array
or other format which requires a size upon construction.

The attribute definition allows us to practically store any data we want inside of the format.
For example, store an RGB24 value:

- `modifier_map` = `SERIAL`
- `atype` = `UINT_8`
- `cardinality` = `3`
- `identifier` = `"color"`

```rust
struct content {
    u64 node_count
    extern svo_data svo_data
}
```

The actual `svo_data` is too complex to be expressed in StructLang.
