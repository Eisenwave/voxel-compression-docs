# Structure Language (StructLang)

StructLang is a data specification language used within the scope of this project.
It uses a syntax similar to Rust and C to mathematically specify a syntax for binary data.


## Comments

Comments begin with a `//` and continue until the end of the line.
Alternatively, a comment block which begins with `/*` and ends with `*/` can be used.

## Settings

Some global settings may be necessary to write a proper specification.

### Syntax
```ebnf
set = "set" identifier "=" value;
```

### Examples
```rust
set byte_bits = 32
set default_byte_order = big_endian
set default_signed_representation = twos_complement
```

### List of Settings

| Identifier | Type | Description |
| ----- | ----- | ----- |
| `byte_bits` | `unsigned integer` | number of bits in one byte
| `default_byte_order` | `modifier ` |  default byte order (endianness) of types
| `default_signed_representation` | `modifier ` | default representation of signed integers

## Type Definitions

Definitions define data types.

### Syntax
```ebnf
def = "def" type "=" {modifier} base_type;
```

- `type` is the identifier of the type
- `modifier` a type modifier
- `base_type` the base type which this type is specializing

### Example
```python
def i32 = signed 32_bit twos_complement integer
def u8 = unsigned 8_bit integer
def string = null_terminated u8[]
```

## Arrays

Arrays are blocks of one type which are stored using a single variable.

### Syntax

```ebnf
array_type = type "[" size | "" "]";
```

### Examples

```rust
u8[4096] buffer     // a constant-sized array

u32 size
u8[size] var_buffer // a variable-sized array

u8[] endless_buffer // an array which extends until the end of the data
```

## Structures

Defines a structure of other types.
These types can also be structures.
The first (uppermost) type in a struct is also the first element in the serialized data.

### Syntax

```ebnf
struct = "struct" identifier "{"
    type identifier
    ...
"}";
```

### Example

```rust
struct Color {
    u8 red
    u8 green
    u8 blue
}
```

## Enumerations

Defines a list of constants of some type.

### Syntax

```ebnf
enum = "enum", identifier, ":", type, "{",
    {identifier, "=", value},
"}";
```

### Examples

```rust
enum Size : string {
    SMALL = "S"
    MEDIUM = "M"
    LARGE = "L"
    EXTRA_LARGE = "XL"
}

enum ArgbColor : u32 {
    RED   = 0xffff0000
    GREEN = 0xff00ff00
    BLUE  = 0xff0000ff
}
```

## Templated Structures

Sometimes a structure depends on content found in a header or other structures.
Templates can change how a structure is laid out using variables.

### Syntax

```ebnf
struct = "struct" type "<" type {identifier ","} ">" "{"
    ...
"}";
```

### Example

```rust
struct varint<u8 bits> {
    if bits == 8 {
        u8 data
    }
    else if bits == 16 {
        u16 data
    }
    else if bits == 32 {
        u32 data
    }
    else {
        error "Invalid bits variable"
    }
}
```
