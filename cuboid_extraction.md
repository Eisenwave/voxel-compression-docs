# Cuboid Extraction

## Motivation

Voxel models of certain types have large volumes of voxels.
These types include extruded heightmaps, medical scans, video game worlds and voxel art.
Other types such as voxelized polygonal models may also be filled up instead of being kept hollow.

The volumes may often be misaligned with the octree structure.
Consider a single 2x2x2 cube in the center of an octree.
All 8 subtrees of the octree would have to encode an individual voxel of this cube, which is far from optimal.
In addition, decoding volumes which are completely filled simplifies the decoding process.
These volumes could be extracted and encoded as cuboids like `{triple<u8> pos, triple<u8> size}` within a container that
has dimensions up to 256^3.

However we extract cuboids, those should be as large in volume as possible.
This way, we cover the most voxels with our pairs of positions.
The highest-volume container should be found, then extracted and the next-highest-volume container
found, etc.
We invest 6 bytes into the extraction, so our volume needs to be 48 to break even (e.g. `4x4x3`).

## Absolutely Stupid Method

- extreme complexity
- but optimal results

Since a cuboid is just a pair of positions, we can simply iterate over all pairs of positions.
We then iterate over all voxels in the cuboid to test whether they exist.
For a `d*d*d` model containing `v` voxels the complexity is thus `O(d^3 * d^3 * d^3)` or `O(d^9)` or `O(v^3)`.
This is some clown-world-tier complexity and should not find its way into any serious implementation.
Due to its simplicity, it could be used to verify the correctness of more complex approaches though.

## XYZ-Merge

- best possible complexity
- not optimal

An XYZ-merge works by merging all neighboring voxels into lines on one axis first.
Then neighboring lines are merged into planes on the second axis.
Then neighboring planes are merged into cuboids on the last axis.
The results are not optimal and may differ depending on the order of axes.

At worst, we can't merge anything and thus iterate over every voxel in each of the steps once.
The complexity is `O(d^3 * 3) = O(d^3)` or `O(v)`. 

## Heightmap-Based Approaches

All following approaches are based on the idea, that we can simplify this problem to a 2-dimensional one.
One axis is being used as a height-axis, ideally the smallest one if the model is not cubical.
We then use a sweeping-plane approach where at each coordinate, we draw a heightmap which extends into our
chosen direction.
Finding the largest volume in the model is reduced to finding the maximum of the largest volumes for all heightmaps.

### Constructing Heightmaps from Voxel-Models

Here is an illustration of how this is done, in 2 dimensions, where "up" in text is the height axis:
```
   0123456789    0123456789
   
7  ###        -> 1110000000
6  #### ## #  -> 2221011010
5  ## ### # # -> 3302120101
4  ##### # ## -> 4413201012
3  ## # # #   -> 5504010100
2  ########   -> 6612121200
1  #########  -> 7726232310
0  ## ## #### -> 8807303420
```
In this illustration, `#` would be encoded as `1` and ` ` would be encoded as `0`
Each slice from `0` to `7` is one histogram in 2 dimensions or a heightmap in 3 dimensions.
We can construct these very efficiently by just taking the heightmap at one height above and incrementing each height,
unless we find an empty voxel (`0`).

### Constructing Bitmaps from Heightmaps

Finding the largest cuboid in a voxel-model has been reduced to finding the largest cuboid in all its heightmaps.
The problem is once again reduced to finding the largest area of `1`s in a bitmap, which can be done in `O(n*n)`.
This is done by looking at all different height-values of the heightmap.
At every height, a bitmap is constructed.
In our bitmap of equal dimensions, `1` represents that the height at the location is `>=` the height.

Example:
```
389200          111000
323350  ------> 101110
500020   (h=3)  100000
211141          000010
```

Finding the largest area of `1` in an `n*n` rectangle has `O(n^2)` complexity or `O(1)` per pixel, when using a
sweeping-line algorithm and searching for the greatest area in the resulting histograms:
https://www.geeksforgeeks.org/maximum-size-rectangle-binary-sub-matrix-1s/

The volume of the greatest cuboid is then the current height multiplied with the size of the greatest area of `1` which
we find.

### Expected values

To understand the following approaches, one must realize that the highest cuboid is not necessarily the largest.
For example, a very flat pyramid may have a shape which is only great in volume towards the base.
For an `n*n` heightmap with `n` height, we can find the cuboid with the largest volume for all heights by finding the
largest cuboid at each individual height.
This forces us to check every single height.

## Naive Method

- high complexity
- optimal results

The naive method simply to iterate over all heights.
We then require `O(d^2 * d^2)` complexity where one `d^2` represents the size of the base and the other `d^2` represents
the amount of pairs of heights.
This would be `O(v^(4/3))`, which is not as bad as the stupid approach but still polynomial.

## Modified Kadane's-Algorithm
```
THIS SECTION IS WIP

- complexity yet unknown
- hopefully optimal results

This can be done by using a sweeping-plane algorithm, where each plane is a heightmap which encodes how many voxels
extrude upwards, starting from each one of its pixels.
The problem is thus reduced to finding the greatest cuboid on a heightmap, which can be done somewhat efficiently using
Kadane's algorithm, where any `0` is treated as negative infinity and the heights are cut-off at some maximum height
dynamically during the search.

For a `n*n` map, Kadane's algorithm has a complexity of `O(n^3)` or `O(n)` per pixel.
Whether this is usable has to be investigated further.
```

## Golden-Section-Search (not sure if this actually works)

- best known complexity
- optimal

We can achieve logarithmic complexity per voxel.

The approach to this is very similar to the naive method, but based on a crucial observation.
The maximum volumes at each minimum height form a unimodal function.
Our search is still based on finding the greatest are of `1` in a bitmap, but we choose our heights in a smarter
way instead of iterating over all heights.

Consider a histogram such as:
```
  ^
 7|   # 
 6|#  #                                       #
 5|#  #    ###     #                          #
 4|#  #    ###  ## ###                ##      #
 3|# ##    ### ### ###             #######   ##
 2|####    ### ### ####    ###     #######  ###
 1|#####  #### ### #####   ############### ####
 -+---------------------------------------------->
  |0123456789abcdefghijklmnopqrstuvwxyzABCDEFGH
```

The greatest areas for each height are:
```
7:     07 (3:1, 3:7)
6:     07 (3:1, 3:7) found by extruding (3:1, 3:6)
>>5:   15 (8:1, a:5)
>>4:   15 (8:1, a:5)
>>>>3: 21 (w:1, C:3)
>>>>2: 21 (w:1, C:3)
>>1:   15 (o:1, C:1)
```
  
  
Note that the maximum volumes at each height only form a unimodal function if we extrude our found area as far up as
possible.
Searching for the maximum or minimum of a unimodal function can be done with logarithmic complexity.
The final complexity would thus be `O(n^2 * log_2 n)` or `O(log_2 n)` per pixel. 
