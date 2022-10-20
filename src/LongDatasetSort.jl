module LongDatasetSort

using InMemoryDatasets

import
    InMemoryDatasets,
    InMemoryDatasets.ColumnIndex,
    InMemoryDatasets.MultiColumnIndex,
    InMemoryDatasets.Dataset,
    InMemoryDatasets.HeapSortAlg,
    Base.Sort.QuickSortAlg

const LDS = LongDatasetSort

export
    LDS,
    heapsort!,
    quicksort!,
    Dataset

include("sort/sort.jl")
include("sort/heapsort.jl")
include("sort/quicksort.jl")

end