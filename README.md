# LongDatasetSort

# Introduction

`LongDatasetSort.jl` is a sort package based on the high-performance data processing package [InMemoryDatasets](https://github.com/sl-solution/InMemoryDatasets.jl) (IMD), which provides in-place `sort!` function for the `Dataset` object of IMD. The package performance only considers avoiding extra allocations created by dataset sorting, enabling the sorting method to take up almost no space when dealing with large datasets with many rows.

# Features

* No extra allocation created by sorting long `Dataset` 
    * Allocation does not increase as the row number of the `Dataset` increases
    * It will be fixed when the column number is less than or equals to 32

* Provides Heap Sort and Quick Sort algorithms
    * Use Heap Sort by default
    * Use Quick Sort may improve computational efficiency on large datasets

* Support sorting by all types of IMD column indexes and multi-column sorting
    * Column name, column index and symbol
    * Pass a `Vector` for multi-column sorting

* Same optional parameters as InMemoryDatasets, including `rev` and `mapformats`
    * Support sorting by different columns in a different order
    * Sort with or without formats

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

julia> sort!(ds, :x)
5×2 Sorted Dataset
 Sorted by: x
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        1        55
   2 │        2         1
   3 │        3         4
   4 │        4        52
   5 │        5        42

julia> sort!(ds, "y", rev = true)
5×2 Sorted Dataset
 Sorted by: y
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

julia> sort!(ds, 1:2)
4×2 Sorted Dataset
 Sorted by: x, y
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        4         1
   2 │        4   missing
   3 │        5         3
   4 │  missing   missing

julia> sort!(ds, [:x, :y], rev = [false, true])
4×2 Sorted Dataset
 Sorted by: x, y
 Row │ x         y
     │ identity  identity
     │ Int64?    Int64?
─────┼────────────────────
   1 │        4   missing
   2 │        4         1
   3 │        5         3
   4 │  missing   missing
```
