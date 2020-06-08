# List of Voxel File Formats

## Binvox

| Stat | Value |
| ----- | ----- |
Pattern        | `*.binvox`
Media-Type     | `model/x-binvox` (unofficial)
Software       | Binvox
Structure      | binary with text header
Volumes        | single
Voxel-Encoding | voxel array
Compression    | run-length encoding
Color Support  | none
Palette        | none

## KVX

| Stat | Value |
| ----- | ----- |
Pattern        | `*.kvx`
Media-Type     | `model/x-kvx` (unofficial)
Software       | Voxlap
Structure      | binary
Volumes        | single
Voxel-Encoding | map of voxel columns per mipmap level
Compression    | none
Color Support  | RGB666
Palette        | global, 256 colors

## KV6

| Stat | Value |
| ----- | ----- |
Pattern        | `*.kv6`
Media-Type     | `model/x-kv6` (unofficial)
Software       | SLAB6
Structure      | binary
Volumes        | single
Voxel-Encoding | map of voxel columns
Compression    | none
Color Support  | RGB666 in palette, RGB24 otherwise
Palette        | optional, global, 256 colors

## Qubicle Exchange Format

| Stat | Value |
| ----- | ----- |
Pattern        | `*.qef`
Media-Type     | `text/x-qef+plain` (unofficial)
Software       | Qubicle
Structure      | text, line-based
Volumes        | single
Voxel-Encoding | voxel list
Compression    | none
Color Support  | floating-point RGB
Palette        | global

## Qubicle Binary

| Stat | Value |
| ----- | ----- |
Pattern        | `*.qb`
Media-Type     | `model/x-qb` (unofficial)
Software       | Qubicle
Structure      | binary
Volumes        | single
Voxel-Encoding | voxel array
Compression    | optional run-length encoding
Color Support  | RGB24
Palette        | none

## Simple Voxels
| Stat | Value |
| ----- | ----- |
Pattern        | `*.svx`
Media-Type     | `application/x-svx+zip` (unofficial)
Software       | Shapeways
Structure      | zip-archive with manifest.xml and images
Volumes        | single
Voxel-Encoding | stack of images
Compression    | depends on image format
Color Support  | depends on image format
Palette        | no global, only within image

## Voxel Model

| Stat | Value |
| ----- | ----- |
Abbreviation   | VOX
Pattern        | `*.vox`
Media-Type     | `model/x-vox` (unofficial)
Software       | MagicaVoxel
Structure      | binary with RIFF-style chunks
Volumes        | multiple, since 0.99.5 with names
Voxel-Encoding | 8-bit voxel lists
Compression    | none
Color Support  | RGB24
Palette        | global, 256 colors of which one is reserved
