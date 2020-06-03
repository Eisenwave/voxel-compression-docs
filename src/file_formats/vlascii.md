# ASCII Voxel List (VLASCII)

VLASCII is a simple, text-based, intermediate file format used in the code of this research project.

**Extension:** `.vlascii`<br>
**Media Type:** `model/x-vlascii`

## Specification

Here the specification, in [EBNF](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form).

```ebnf
vlascii = { line };
(* lines can be empty *)
line = [comment | voxel], {" "}, nl; (* trailing space allowed *)

comment = "#", { ?any character? } - nl;
voxel = xyz, space, color, space;
xyz = integer, space, integer, space, integer;
color = (h, h, h, h, h, h) | (h, h, h);

h = ?hexadecimal digit?;
integer = ["-"], ?decimal digit?, { ?decimal digit? };
nl = ?newline character?;
space = " ", { " " };
```

## Example

```sh
# red voxel at 0, 0, 0
0 0 0 ff0000
# white voxel at 0, 1, 0
0 1 0 fff
# black voxel at 0, 0, 1
0 0 1 000
```
