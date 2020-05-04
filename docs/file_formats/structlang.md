# Structure Language (StructLang)

StructLang is a data specification language used within the scope of this project.
It uses a syntax similar to Rust and C to mathematically specify a syntax for binary data.

## Syntax

### Comments

Comments begin with a `//` and continue until the end of the line.
Alternatively, a comment block which begins with `/*` and ends with `*/` can be used.

### Definitions

Definitions define data types.

```python
def <type> = <description>
```

- `type` is the identifier of the type
- `description` is an unambiguous description of a type
