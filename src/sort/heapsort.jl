#TODO: which is faster?
#TODO: Fix the type of Tuple

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

# Global variable will cause allocation!
function hsort!(t::Tuple, ct::Tuple, revs::Tuple, formats::Tuple)
    len = Base.length(t[1])

    # Build the heap
    # Start heapify from the first node which is not a leaf (From back to front)
    @inbounds for i = (len >>> 0x01):-1:1
        heapify!(t, ct, len, i, revs, formats)
    end

    # Heap sort
    @inbounds for i = len:-1:2
        swap_df_2!(t, i, 1)
        heapify!(t, ct, i-1, 1, revs, formats)
    end
end

function sort!(t::Tuple{Vararg{AbstractVector}}, ct::Tuple{Vararg{AbstractVector}}, revs::Tuple, formats::Tuple, ::IMD.HeapSortAlg)
    hsort!(t, ct, revs, formats)
end