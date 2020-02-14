# Statistical Tests to Determine Voxel Model Properties

The following list should give an overview over possible properties which voxel models are suspected to have.
A description of an algorithm and/or pseudocude is used to provide a potential test.


## Spatial Locality of Different Methods of Iteration Over Voxel Models

There are various different ways of iterating over a voxel model.
We will consider only two or three, which are relevant to us.

#### Nested Loop Iteration
This is the traditional method of iterating over multi-dimensional arrays.
```c
char data[SIZE_X][SIZE_Y][SIZE_Z];
for (size_t x = 0; x < SIZE_X; ++x)
    for (size_t y = 0; y < SIZE_Y; ++y)
        for (size_t z = 0; z < SIZE_Z; ++z)
            data[x][y][z];
```
It is extremely efficient for traversing memory because it seemlessly iterates over memory locations, as long as the
axes of iteration are in the right order.
The distances between two positions are at best `1` and at worst `SIZE_X + SIZEY`.
However, the spatial locality is much worse when looking at more than one position.
For say, 10 positions the distance between the first and last will be 10, which is comparably far.

#### Z-Order Iteration
Z-Order iteration traverses space with much higher locality.
It works by traversing all nodes of an octree depth-first.
3D-Vectors can be converted into "octree positions" by interleaving the bits of the coordinates into a single number.
```c
char data[SIZE_X][SIZE_Y][SIZE_Z];
for (size_t x = 0; x < SIZE_X; ++x)
    for (size_t y = 0; y < SIZE_Y; ++y)
        for (size_t z = 0; z < SIZE_Z; ++z)
            data[interleave_bits(x, y, z)];
)
```

#### Hilbert-Curve Iteration
Hilbert-Curves have even higher locality than Z-Order iterations, but are considerably better in locality.
See https://slideplayer.com/slide/3370293/ for construction.
In short, space is filled in the following order, which is a Gray Code.
```json
[[0, 0, 0], [0, 0, 1], [0, 1, 1], [0, 1, 0], [1, 1, 0], [1, 1, 1], [1, 0, 1], [1, 0, 0]]
```
The entry direction for one of these pieces is +Z and the exit-direction is -Y.
This pattern is repeated recursively, but the smaller building blocks have to be mirrored and rotated to fit together
seemlessly into a larger block.
The tremendously useful property here is that the distance between two points in the iteration is at most `1`.

### Testing Spatial Locality
Spatial locality can simply be tested by comparing the average distance between each pair of points, triple of points,
etc. within an iteration.
When more than two points are tested, the distances of each unique pair of points can be summed up or averaged.
Hilber-Curve Iteration is expected to deliver the best results on most, if not all scales.


## Correlation of Color and Geometry Deltas

It is expected that color correlates with positions.
This means that positions which are close to each other should also have similar colors.
To verify this property, each unique pair of points can be iterated over.
The euclidean distance in geometry-space (scaled down to a unit-cube) as well as the euclidean distance in the RGB
color space should be plotted.
The correlation can then be calculated from all data entries.
```cpp
struct Entry {
    double geoDistance;
    double colDistance;
};
struct ColoredPoint {
    vec3 geo;
    vec3 col;
}
std::vector<double[2]> entries;
for (const std::pair<ColoredPoint, ColoredPoint> &pair : allPoints) {
    double geoDistance = pair.first.geo.distanceTo(pair.second.geo);
    double colDistance = pair.first.col.distanceTo(pair.second.col);
    entries.emplace_back(geoDistance, colDistance);
}
```
