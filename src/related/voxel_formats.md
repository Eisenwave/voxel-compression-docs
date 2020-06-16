# List of Voxel File Formats

###### Binvox

| Stat | Value |
| ----- | ----- |
Pattern        | `*.binvox`
Media-Type     | `model/x-binvox` (unofficial)
Magic          | `#binvox 1` (of which 1 is version)
Software       | Binvox
Structure      | binary with text header
Volumes        | single1
Voxel-Encoding | voxel array
Compression    | run-length encoding
Color Support  | none
Palette        | none

##### KVX

| Stat | Value |
| ----- | ----- |
Pattern        | `*.kvx`
Media-Type     | `model/x-kvx` (unofficial)
Magic          | none
Software       | Voxlap
Structure      | binary
Volumes        | single
Voxel-Encoding | map of voxel columns per mipmap level
Compression    | none
Color Support  | RGB666
Palette        | global, 256 colors

##### KV6

| Stat | Value |
| ----- | ----- |
Pattern        | `*.kv6`
Media-Type     | `model/x-kv6` (unofficial)
Magic          | `Kvxl`
Software       | SLAB6
Structure      | binary
Volumes        | single
Voxel-Encoding | map of voxel columns
Compression    | none
Color Support  | RGB666 in palette, RGB24 otherwise
Palette        | optional, global, 256 colors

##### PNG Stack

| Stat | Value |
| ----- | ----- |
Pattern        | `*.png`
Media-Type     | `image/png`
Magic          | `\x89PNG`
Software       | various
Structure      | binary
Volumes        | single
Voxel-Encoding | stack of images
Compression    | PNG
Color Support  | PNG
Palette        | PNG

##### Minecraft Schematic

| Stat | Value |
| ----- | ----- |
Pattern        | `*.schematic`
Media-Type     | `application/x-schematic+nbt` (unofficial)
Magic          | `\x10` (Compound Tag)
Software       | various Minecraft-related
Structure      | binary, based on NBT
Volumes        | single
Voxel-Encoding | voxel array
Compression    | none
Color Support  | MC block-based
Palette        | implicit, global, MC blocks

##### Minecraft Structure

| Stat | Value |
| ----- | ----- |
Pattern        | `*.mcstructure`
Media-Type     | `application/x-minecraft-structure+nbt`
Magic          | `\x10` (Compound Tag)
Software       | Minecraft
Structure      | binary, based on NBT
Volumes        | single
Voxel-Encoding | voxel list
Compression    | none
Color Support  | MC block-based
Palette        | global, MC blocks

##### Qubicle Exchange Format

| Stat | Value |
| ----- | ----- |
Pattern        | `*.qef`
Media-Type     | `text/x-qef+plain` (unofficial)
Magic          | `Qubicle Exchange Format`... (copyright header)
Software       | Qubicle
Structure      | text, line-based
Volumes        | single
Voxel-Encoding | voxel list
Compression    | none
Color Support  | floating-point RGB
Palette        | global

##### Qubicle Binary

| Stat | Value |
| ----- | ----- |
Pattern        | `*.qb`
Media-Type     | `model/x-qb` (unofficial)
Magic          | none
Software       | Qubicle
Structure      | binary
Volumes        | multiple, named
Voxel-Encoding | voxel array
Compression    | optional run-length encoding
Color Support  | RGB24
Palette        | none

##### Qubicle Binary Tree

| Stat | Value |
| ----- | ----- |
Pattern        | `*.qb`
Media-Type     | `model/x-qb` (unofficial)
Magic          | `QB 2`
Software       | Qubicle
Structure      | binary
Volumes        | multiple, named, hierarchical
Voxel-Encoding | voxel array
Compression    | zlib
Color Support  | RGB24, RGBA32 with palette
Palette        | optional, global

##### Simple Voxels
| Stat | Value |
| ----- | ----- |
Pattern        | `*.svx`
Media-Type     | `application/x-svx+zip` (unofficial)
Magic          | `PK`...
Software       | Shapeways
Structure      | zip-archive with manifest.xml and images
Volumes        | single
Voxel-Encoding | stack of images
Compression    | depends on image format
Color Support  | depends on image format
Palette        | no global, only within image

##### Sproxel CSV
| Stat | Value |
| ----- | ----- |
Pattern        | `*.csv`
Media-Type     | `text/x-sproxel+csv` (unofficial)
Magic          | `VOX `
Software       | Sproxel
Structure      | CSV-based
Volumes        | single
Voxel-Encoding | voxel array
Compression    | none
Color Support  | RGBA32
Palette        | none

##### Sproxel Enhanced PNG
| Stat | Value |
| ----- | ----- |
Pattern        | `*.csv`
Media-Type     | `image/x-sproxel+png` (unofficial)
Magic          | `\x89 PNG`
Software       | Sproxel
Structure      | PNG-based
Volumes        | single
Voxel-Encoding | stack of slices within single PNG
Compression    | PNG
Color Support  | PNG
Palette        | PNG

##### Voxel Model

| Stat | Value |
| ----- | ----- |
Pattern        | `*.vox`
Media-Type     | `model/x-vox` (unofficial)
Magic          | `VOX `
Software       | MagicaVoxel
Structure      | binary with RIFF-style chunks
Volumes        | multiple, since 0.99.5 with names, hierarchical, links
Voxel-Encoding | 8-bit voxel lists
Compression    | none
Color Support  | RGB24
Palette        | global, 256 colors of which one is reserved

##### Zoxel

| Stat | Value |
| ----- | ----- |
Pattern        | `*.zox`
Media-Type     | `text/x-zoxel+json` (unofficial)
Magic          | none
Software       | Zoxel
Structure      | text, JSON-based
Volumes        | single
Voxel-Encoding | voxel list
Compression    | none
Color Support  | RGBA32
Palette        | none
