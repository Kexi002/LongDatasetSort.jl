module LongDatasetSort

using InMemoryDatasets

const LMS = LongDatasetSort

import
    InMemoryDatasets,
    InMemoryDatasets.ColumnIndex,
    InMemoryDatasets.MultiColumnIndex,
    InMemoryDatasets.Dataset

export 
    heapsort!,
    quicksort!,
    Dataset

include("sort/heapsort.jl")
include("sort/quicksort.jl")

end