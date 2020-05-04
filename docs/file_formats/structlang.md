# Structure Language (StructLang)

StructLang is a data specification language used within the scope of this project.
It uses a syntax similar to Rust and C to mathematically specify a syntax for binary data.


## Comments

Comments begin with a `//` and continue until the end of the line.
Alternatively, a comment block which begins with `/*` and ends with `*/` can be used.

## Settings

Some global settings may be necessary to write a proper specification.

### Syntax
```rust
set <identifier> = <value>
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
```python
def <type> = [modifier...] <base_type>
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

## Structures

Defines a structure of other types.

### Syntax

```rust
struct <identifier> {
    <type> [identifier]
    ...
}
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

```rust
enum <identifier> : <type> {
    <identifier> = <value>
    ...
}
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
