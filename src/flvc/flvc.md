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
    // 8-bit unsigned integer were any nonzero value is interpreted as true
    BOOL       = 0x01
    
    INT_8      = 0x11    // see i8 type
    INT_16     = 0x12    // see i16 type
    INT_32     = 0x14    // see i32 type
    INT_64     = 0x18    // see i64 type
    
    UINT_8     = 0x21    // see u8 type
    UINT_16    = 0x22    // see u16 type
    UINT_32    = 0x24    // see u32 type
    UINT_64    = 0x28    // see u64 type
    
    FLOAT_32   = 0x41    // 32-bit floating point
    FLOAT_64   = 0x42    // 64-bit floating point
}

enum builtin_identifiers : string8 {
    // attributes will be used as the color of the voxel
    COLOR = "color"
    // attributes will be used as the normal of the voxel
    NORMAL = "normal"
}

// HELPER STRUCTS ==============================================================

struct string8 {
    nonzero u8 size
    // ASCII-encoded
    max<127> u8[size] content
}

// HEADER ======================================================================

struct main {
    // 8 bytes of file magic
    u64 magic = 0xff11_33cc_666c_7663
    
    // major version and minor version, currently 0.1
    u8 version_major = 0
    u8 version_minor = 1
    
    // The offset of the volume from the origin
    i32[3] volume_offset
    // The exact dimensions of the voxel volume.
    // The SVO has to contain these dimensions, but may be larger internally.
    // (SVOs can only have power-of-two dimensions)
    u32[3] volume_size
    
    // 1 if the volume contains no voxels, else 0
    u8 empty
    
    // pads the fixed-size header content to a total length of 40 bytes
    u8[5] padding = "(def)"
    
    u16 definitions_size
    attribute_definition[definitions_size] definitions
    
    // A visual separator between header and content, visible when opening files
    // in a hex editor.
    // Also useful to detect reading past the header in implementations.
    u8 reserved = '|'
    
    // Only store a zlib-encoded stream for non-empty SVOs.
    // Emptyness is indicated by the "empty" variable above.
    if (!header.empty) {
        // (extern because can't be fully defined in StructLang)
        extern zlib_stream content
    }
}

struct attribute_definition {
    // unique identifier of the attribute
    // certain values such as "color" are builtin and reserved
    // (see enum builtin_identifiers)
    string8 identifier
    
    // type of the attribute
    attribute_type atype
    
    // If zero, the type is a variable sized-array.
    // If not zero, this indicates that the type is a fixed-size array-type or
    // vector-type.
    // The position attribute must have a cardinality of 3!
    u8 cardinality
    
    // bitmap storing all modifiers
    u16 modifiers
}
```
`header.size` is not strictly necessary for decoding, but it can be helpful when converting directly to a 3D array
or other format which requires a size upon construction.

The attribute definitions allow us to practically store any data we want inside the format.
For example, store an RGB24 value:

```rust
modifiers = 0
atype = UINT_8
cardinality = 3
identifier = "color"
```

The actual `content` is too complex to be expressed in StructLang.
