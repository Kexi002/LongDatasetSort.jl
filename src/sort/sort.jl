const QuickSort = QuickSortAlg()

# Heap Sort by default
longsort!(ds::AbstractDataset, cols::ColumnIndex; rev = false, mapformats = true, alg::Base.Sort.Algorithm = HeapSortAlg()) = longsort!(ds, [cols], rev = rev, mapformats = mapformats, alg = alg)

function longsort!(ds::AbstractDataset, cols::MultiColumnIndex; rev = false, mapformats = true, alg::Base.Sort.Algorithm = HeapSortAlg())
    # Necessary?
    #_check_consistency(ds)

    # Get numeric index
    colsidx = IMD.index(ds)[cols]

    if Base.length(rev) == 1
        revs = Tuple(repeat([rev], Base.length(colsidx)))
    else
        revs = Tuple(rev)
    end
    @assert Base.length(colsidx) == Base.length(revs) "the reverse argument must be the same length as the length of selected columns"

    if mapformats
        formats = Array{Function}(undef, Base.length(colsidx))
        i = 1
        @inbounds for colidx in colsidx
            formats[i] = getformat(ds, colidx)
            i += 1
        end
        formats = Tuple(formats)
    else
        formats = Tuple(repeat([identity], Base.length(colsidx)))
    end

    t = Tuple(IMD._columns(ds))
    ct = t[colsidx]
    
    longsort!(t, ct, revs, formats, alg)
    return ds
end

# Alias functions

#Heap Sort
heapsort!(ds::AbstractDataset, col::ColumnIndex; rev = false, mapformats = true) = heapsort!(ds, [col], rev = rev, mapformats = mapformats)
heapsort!(ds::AbstractDataset, cols::MultiColumnIndex; rev = false, mapformats = true) = longsort!(ds, cols, rev = rev, mapformats = mapformats, alg = HeapSortAlg())

#Quick Sort
quicksort!(ds::AbstractDataset, col::ColumnIndex; rev = false, mapformats = true) = quicksort!(ds, [col], rev = rev, mapformats = mapformats)
quicksort!(ds::AbstractDataset, cols::MultiColumnIndex; rev = false, mapformats = true) = longsort!(ds, cols, rev = rev, mapformats = mapformats, alg = QuickSortAlg())