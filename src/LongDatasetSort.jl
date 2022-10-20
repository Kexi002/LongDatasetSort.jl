module LongDatasetSort

using InMemoryDatasets

const LMS = LongDatasetSort

import
    InMemoryDatasets,
    InMemoryDatasets.ColumnIndex,
    InMemoryDatasets.MultiColumnIndex,
    InMemoryDatasets.Dataset

const LDS = LongDatasetSort

export
    LDS,
    heapsort!,
    quicksort!,
    Dataset

include("sort/heapsort.jl")
include("sort/quicksort.jl")

end