function heapify!(t::Tuple, ct::Tuple, len::Integer, i::Integer, revs::Tuple, formats::Tuple)
    # largest =  i
    # lson = i * 2
    # rson = lson + 1

    # while lson <= len
    #     if lson <= len && smaller(ct, largest, lson, revs)
    #         largest = lson
    #     end
    #     if rson <= len && smaller(ct, largest, rson, revs)
    #         largest = rson
    #     end
    #     if largest != i
    #         swap_df_2!(t, largest, i)
    #     else
    #         break
    #     end

    #     i = largest
    #     lson = i * 2
    #     rson = lson + 1
    # end

    son = i * 2
    while son <= len
        if son+1 <= len && smaller(ct, son, son+1, revs, formats)
            son += 1
        end
        if smaller(ct, son, i, revs, formats)
            return
        else
            swap_df_2!(t, son, i)
            i = son
            son = i * 2
        end
    end
end

function hsort!(t::Tuple, ct::Tuple, revs::Tuple, formats::Tuple)
    len = Base.length(t[1])
    @inbounds for i = (len >>> 0x01):-1:1
        heapify!(t, ct, len, i, revs, formats)
    end

    # Heap sort
    @inbounds for i = len:-1:2
        swap_df_2!(t, i, 1)
        heapify!(t, ct, i-1, 1, revs, formats)
    end
end

# TODO MultiColumnIndex, mapformats, multi revs
# Apply the format first, or pass format tuple?
heapsort!(ds::AbstractDataset, col::ColumnIndex; rev = false, mapformats::Bool = true) = heapsort!(ds, [col]; rev = rev, mapformats = mapformats)
function heapsort!(ds::AbstractDataset, cols::MultiColumnIndex; rev = false, mapformats = true)
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
        for colidx in colsidx
            formats[i] = getformat(ds, colidx)
            i += 1
        end
        formats = Tuple(formats)
    else
        formats = Tuple(repeat([identity], Base.length(colsidx)))
    end

    # Build the heap
    # Start heapify from the first node which is not a leaf (From back to front)
    t = Tuple(IMD._columns(ds))
    ct = t[colsidx]

    # Global variable will cause allocation!
    hsort!(t, ct, revs, formats)
    return ds
end