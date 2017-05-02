N_PROCS = 4

addprocs(N_PROCS-1)                  
@everywhere __PARALLEL__ = true   

@everywhere using ParallelVI_
@everywhere using CSLV_
@everywhere using GridInterpolations

function parallelTest(nProcs::Int; nIter::Int=1, nChunks::Int =82)
    
    problem = CSLVProblem()

    nStates  = prod(problem.acGrid.cut_counts)
    nActions = length(problem.actionArray) 

    order = Array(Vector{Int}, nChunks)
    stride = div(nStates,nChunks)
    for i = 0:(nChunks-1)
        sIdx = i * stride + 1
        eIdx = sIdx + stride - 1
        if i == (nChunks-1) && eIdx != nStates
            eIdx = nStates
        end
        order[i+1] = [sIdx, eIdx] 

    end 

    pvi = ParallelVI("pvi_policy.pol", nIter, 1e-4, nProcs, zeros(2), zeros(2,2), order) 

    @time qp = solve(problem, pvi)

    return qp
end
