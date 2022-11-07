# LongDatasetSort

# Introduction

`LongDatasetSort.jl` is a sort package based on the high-performance data processing package [InMemoryDatasets.jl](https://github.com/sl-solution/InMemoryDatasets.jl) (IMD), which provides in-place sorting function `longsort!` for the `Dataset` object of IMD. The package performance only considers avoiding extra allocations created by dataset sorting, enabling the sorting method to take up almost no space when dealing with large datasets with many rows.

# Features

* No extra allocation created by sorting long `Dataset` 
    * Allocation does not increase as the row number of the dataset increases
    * It will be fixed when the column number is less than or equals to 32

* Provide Heap Sort and Quick Sort algorithms
    * Use Heap Sort by default
    * Use Quick Sort may improve computational efficiency on large datasets

* Support sorting by all types of IMD column indexes and multi-column sorting
    * Column name, column index and symbol
    * Pass a `Vector` for multi-column sorting

* Same optional parameters as InMemoryDatasets, including `rev` and `mapformats`
    * Support sorting by different columns in a different order
    * Sort with or without formats

* Provide alias functions
    * Can use `heapsort!` and `quicksort!` function to specify algorithms instead of `alg` parameter
    * The result of `quicksort!` will be equal to `longsort!(ds, cols, alg = QuickSort)`

# Examples

```julia
julia> using LongDatasetSort
julia> ds = Dataset(x = [5,4,3,2,1], y = [42,52,4,1,55])
5×2 Dataset
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        5        42
   2 │        4        52
   3 │        3         4
   4 │        2         1
   5 │        1        55

julia> longsort!(ds, :x)
5×2 Dataset
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        1        55
   2 │        2         1
   3 │        3         4
   4 │        4        52
   5 │        5        42

julia> longsort!(ds, "y", rev = true)
5×2 Dataset
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        1        55
   2 │        4        52
   3 │        5        42
   4 │        3         4
   5 │        2         1

julia> ds = Dataset(x = [5, 4, missing, 4],
                    y = [3, missing, missing , 1])
4×2 Dataset
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        5         3
   2 │        4   missing
   3 │  missing   missing
   4 │        4         1

julia> longsort!(ds, 1:2)
4×2 Dataset
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        4         1
   2 │        4   missing
   3 │        5         3
   4 │  missing   missing

julia> longsort!(ds, [:x, :y], rev = [false, true])
4×2 Dataset
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        4   missing
   2 │        4         1
   3 │        5         3
   4 │  missing   missing
```

Examples of sorting with or without formats:

```julia
julia> using Dates
julia> ds = Dataset(state = ["CA", "TX", "IL", "IL", "IL", "CA", "TX", "TX"],
                           date = [Date("2020-01-01"), Date("2020-03-01"), Date("2020-01-01"),
                                   Date("2020-03-01"), Date("2020-02-01"), Date("2021-03-01"),
                                   Date("2021-02-01"), Date("2020-02-01")],
                             qt = [123, 143, 144, 199, 153, 144, 134, 188])
8×3 Dataset
 Row │ state     date        qt
     │ identity  identity    identity
     │ String?   Date?       Int64?
─────┼────────────────────────────────
   1 │ CA        2020-01-01       123
   2 │ TX        2020-03-01       143
   3 │ IL        2020-01-01       144
   4 │ IL        2020-03-01       199
   5 │ IL        2020-02-01       153
   6 │ CA        2021-03-01       144
   7 │ TX        2021-02-01       134
   8 │ TX        2020-02-01       188

julia> setformat!(ds, :date=>month)
8×3 Dataset
 Row │ state     date   qt
     │ identity  month  identity
     │ String?   Date?  Int64?
─────┼───────────────────────────
   1 │ CA        1           123
   2 │ TX        3           143
   3 │ IL        1           144
   4 │ IL        3           199
   5 │ IL        2           153
   6 │ CA        3           144
   7 │ TX        2           134
   8 │ TX        2           188

julia> longsort!(ds, [2,1])
8×3 Dataset
 Row │ state     date   qt
     │ identity  month  identity
     │ String?   Date?  Int64?
─────┼───────────────────────────
   1 │ CA        1           123
   2 │ IL        1           144
   3 │ IL        2           153
   4 │ TX        2           134
   5 │ TX        2           188
   6 │ CA        3           144
   7 │ IL        3           199
   8 │ TX        3           143

julia> longsort!(ds, [2,1], mapformats = false)
8×3 Dataset
 Row │ state     date   qt
     │ identity  month  identity
     │ String?   Date?  Int64?
─────┼───────────────────────────
   1 │ CA        1           123
   2 │ IL        1           144
   3 │ IL        2           153
   4 │ TX        2           188
   5 │ IL        3           199
   6 │ TX        3           143
   7 │ TX        2           134
   8 │ CA        3           144

julia> longsort!(ds, [1,2], mapformats = false)
8×3 Dataset
 Row │ state     date   qt
     │ identity  month  identity
     │ String?   Date?  Int64?
─────┼───────────────────────────
   1 │ CA        1           123
   2 │ CA        3           144
   3 │ IL        1           144
   4 │ IL        2           153
   5 │ IL        3           199
   6 │ TX        2           188
   7 │ TX        3           143
   8 │ TX        2           134
```

# Benchmark

* Compare the running time and allocation with the `sort!` function of IMD. A computer with Windows system, 4 cores i5-7500 CPU and 16GB memory is used for the test. 

* The testing `Dataset` is of type `Int64` with 1e2-1e7 rows and 32 columns. Randomly select 10 columns and convert them to Float type, and sort the dataset in ascending order according to the first three columns.

* The result is given by the macro `@benchmarkable` from package [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl). The copy of the testing `Dataset` has been set up before running the test to avoid extra time and allocations. The test result of running time takes the median value returned by `@benchmarkable`.

## Heap Sort
### Running Time
| nrow\function |         LDS.longsort!          |             IMD.sort!              |
|:-------------:|:------------------------------:|:----------------------------------:|
|      1e2      |            46.600 μs           |             246.900 μs             |
|      1e3      |           867.800 μs           |             375.800 μs             |
|      1e4      |            28.397 ms           |               1.492 ms             |
|      1e5      |           340.060 ms           |              11.174 ms             |
|      1e6      |             9.283 s            |             391.984 ms             |
|      1e7      |           148.782 s            |               4.440 s              |

### Allocations
| nrow\function |         LDS.longsort!          |             IMD.sort!              |
|:-------------:|:------------------------------:|:----------------------------------:|
|      1e2      |    12 allocations: 1.06 KiB    |    1227 allocations: 163.12 KiB    |
|      1e3      |    12 allocations: 1.06 KiB    |    1402 allocations: 477.20 KiB    |
|      1e4      |    12 allocations: 1.06 KiB    |    1537 allocations:   3.43 MiB    |
|      1e5      |    12 allocations: 1.06 KiB    |    1422 allocations:  32.94 MiB    |
|      1e6      |    12 allocations: 1.06 KiB    |   11405 allocations: 328.65 MiB    |
|      1e7      |    12 allocations: 1.06 KiB    |    2162 allocations:   3.20 GiB    |

## Quick Sort
### Running Time
| nrow\function |         LDS.longsort!          |             IMD.sort!              |
|:-------------:|:------------------------------:|:----------------------------------:|
|      1e2      |            20.900 μs           |             244.500 μs             |
|      1e3      |           378.300 μs           |             381.300 μs             |
|      1e4      |             7.603 ms           |               1.505 ms             |
|      1e5      |            86.040 ms           |              11.189 ms             |
|      1e6      |             1.723 s            |             502.890 ms             |
|      1e7      |            20.808 s            |               4.331 s              |

### Allocations
| nrow\function |         LDS.longsort!          |             IMD.sort!              |
|:-------------:|:------------------------------:|:----------------------------------:|
|      1e2      |    12 allocations: 1.06 KiB    |    1221 allocations: 162.80 KiB    |
|      1e3      |    12 allocations: 1.06 KiB    |    1399 allocations: 477.03 KiB    |
|      1e4      |    12 allocations: 1.06 KiB    |    1435 allocations:   3.42 MiB    |
|      1e5      |    12 allocations: 1.06 KiB    |    1412 allocations:  32.94 MiB    |
|      1e6      |    12 allocations: 1.06 KiB    |    1404 allocations: 328.20 MiB    |
|      1e7      |    12 allocations: 1.06 KiB    |    1455 allocations:   3.20 GiB    |
