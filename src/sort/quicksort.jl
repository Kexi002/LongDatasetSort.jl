# midpoint(low::T, high::T) where T<:Integer = low + ((high - low) >>> 0x01)

# Compare two rows by cols and revs
# If col[a] < col[b], rerturn true
# If want col[a] > col[b], use (b, a)
# a: row1 index
# b: row2 index

# Use the Tuple only contains the sorting columns to compare
# All equal, returen false
@inline smaller(t::Tuple{}, i::Integer, j::Integer, revs::Tuple, formats::Tuple) = false
@inline function smaller(t::Tuple, i::Integer, j::Integer, revs::Tuple, formats::Tuple)
    @inbounds begin
        col = first(t)
        rev = first(revs)
        format = first(formats)
        ti = format(col[i])
        tj = format(col[j])
        isless(ti, tj) && return true ⊻ rev
        isless(tj, ti) && return false ⊻ rev
    end
    return smaller(Base.tail(t), i, j, Base.tail(revs), Base.tail(formats))
end

@inline smaller_or_equal(t::Tuple{}, i::Integer, j::Integer, revs::Tuple, formats::Tuple) = true
@inline function smaller_or_equal(t::Tuple, i::Integer, j::Integer, revs::Tuple, formats::Tuple)
    @inbounds begin
        col = first(t)
        rev = first(revs)
        format = first(formats)
        ti = format(col[i])
        tj = format(col[j])
        isless(ti, tj) && return true ⊻ rev
        isless(tj, ti) && return false ⊻ rev
    end
    return smaller_or_equal(Base.tail(t), i, j, Base.tail(revs), Base.tail(formats))
end

# Use the Tuple of all columns to swap
@inline function swap_df_2!(t::Tuple{AbstractVector}, i, j)
    @inbounds t[1][j], t[1][i]= t[1][i], t[1][j]
    return nothing
end
@inline function swap_df_2!(t::Tuple{Vararg{AbstractVector}}, i, j)
    swap_df_2!((first(t),), i, j)
    swap_df_2!(Base.tail(t), i, j)
    return nothing
end

@inline function swap_df_3!(t::Tuple{AbstractVector}, lo, mi, hi)
    @inbounds t[1][hi], t[1][lo], t[1][mi] = t[1][lo], t[1][mi], t[1][hi]
    return nothing
end
@inline function swap_df_3!(t::Tuple{Vararg{AbstractVector}}, lo, mi, hi)
    swap_df_3!((first(t),), lo, mi, hi)
    swap_df_3!(Base.tail(t), lo, mi, hi)
    return nothing
end

@inline function swap_with_pv!(t::Tuple{AbstractVector}, pv, j, lo)
    @inbounds t[1][j], t[1][lo] = t[1][pv], t[1][j]
    return nothing
end

@inline function swap_with_pv!(t::Tuple{Vararg{AbstractVector}}, pv, j, lo)
    swap_with_pv!((first(t),), pv, j, lo)
    swap_with_pv!(Base.tail(t), pv, j, lo)
    return nothing
end

@inline function selectpivot!(t::Tuple{Vararg{AbstractVector}}, ct::Tuple{Vararg{AbstractVector}}, lo::Integer, hi::Integer, revs::Tuple, formats::Tuple)
    @inbounds begin
        mi = IMD.midpoint(lo, hi)

        # sort t[mi] <= t[lo] <= t[hi] such that the pivot is immediately in place
        if smaller(ct, lo, mi, revs, formats)
            swap_df_2!(t, lo, mi)
        end

        if smaller(ct, hi, lo, revs, formats)
            if smaller(ct, hi, mi, revs, formats)
                swap_df_3!(t, lo, mi, hi)
            else
                swap_df_2!(t, lo, hi)
            end
        end

        # return the pivot location
        return lo
    end
end

# partition!
#
# select a pivot, and partition v according to the pivot

function partition!(t::Tuple{Vararg{AbstractVector}}, ct::Tuple{Vararg{AbstractVector}}, lo::Integer, hi::Integer, revs::Tuple, formats::Tuple)
    pivot = selectpivot!(t, ct, lo, hi, revs, formats)
    # pivot == t[lo], t[hi] > t[pivot]
    i, j = lo, hi
    @inbounds while true
        i += 1; j -= 1
        while smaller(ct, i, pivot, revs, formats)
            i += 1
        end
        while smaller(ct, pivot, j, revs, formats)
            j -= 1
        end
        i >= j && break
        swap_df_2!(t, j, i)
    end
    swap_with_pv!(t, pivot, j, lo)

    # t[j] == t[pivot]
    # t[k] >= t[pivot] for k > j
    # t[i] <= t[pivot] for i < j
    return j
end

function qsort!(t::Tuple{Vararg{AbstractVector}}, ct::Tuple{Vararg{AbstractVector}}, lo::Integer, hi::Integer, revs::Tuple, formats::Tuple)
    @inbounds while lo < hi
        # hi-lo <= SMALL_THRESHOLD && return sort!(v, lo, hi, SMALL_ALGORITHM)

        j = partition!(t, ct, lo, hi, revs, formats)
        if j-lo < hi-j
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            lo < (j-1) && qsort!(t, ct, lo, j-1, revs, formats)
            lo = j+1
        else
            j+1 < hi && qsort!(t, ct, j+1, hi, revs, formats)
            hi = j-1
        end
    end
end

quicksort!(ds::AbstractDataset, col::ColumnIndex; rev = false, mapformats::Bool = true) = quicksort!(ds, [col]; rev = rev, mapformats = mapformats)
function quicksort!(ds::AbstractDataset, cols::MultiColumnIndex; rev = false, mapformats::Bool = true)
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
    len = Base.length(t[1])
    # 1 allocation less than nrow(ds)? If pass a fixed value, allocation will not increase
    # len = nrow(ds)
    # For example, qsort!(t, ct, 1, 200, revs, formats)
    
    qsort!(t, ct, 1, len, revs, formats)
    return ds
end
