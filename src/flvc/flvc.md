# Free Lossless Voxel Compression (FLVC)

FLVC is the file format produced based on the results of the presented research.

**Extension:** `.flvc`<br>
**Media Type:** `model/x-flvc`

## Specification

### StructLang Type Definitions

```rust
def u8 = unsigned integer<8>
def u16 = big_endian unsigned integer<16>
def u32 = big_endian unsigned integer<32>
def u64 = big_endian unsigned integer<64>

def i8 = twos_complement integer<8>
def i16 = big_endian twos_complement integer<16>
def i32 = big_endian twos_complement integer<32>
def i64 = big_endian twos_complement integer<64>

def ascii = unsigned hi_pad integer<7>
```

### File Structure

```rust

struct main {
    ascii[6] magic = "\xF1\xECflvc"
    u16 version_number
    u16 attribute_count
    attribute_definition[attribute_count] atributes
    
}

struct attribute_definition {
    u16 modifier_count
    attribute_modifier[modifier_count] modifiers
    attribute_type atype
    u8 cardinality
    string16 identifier
}

enum attribute_modifier : u8 {
    LOCALIZED = 1
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

struct string16 {
    u16 size
    ascii[size] content
}
```
