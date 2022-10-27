module LongDatasetSort

using InMemoryDatasets

import
    InMemoryDatasets,
    InMemoryDatasets.ColumnIndex,
    InMemoryDatasets.MultiColumnIndex,
    InMemoryDatasets.Dataset,
    InMemoryDatasets.HeapSortAlg,
    InMemoryDatasets.setformat!,
    InMemoryDatasets.removeformat!,
    InMemoryDatasets.getformat,
    Base.Sort.QuickSortAlg

const LDS = LongDatasetSort

export
    LDS,
    longsort!,
    heapsort!,
    quicksort!,
    Dataset,
    setformat!,
    removeformat!,
    getformat

include("sort/sort.jl")
include("sort/heapsort.jl")
include("sort/quicksort.jl")

end