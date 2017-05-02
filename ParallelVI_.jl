module ParallelVI_

export ParallelVI
export solve, solve2
export solveChunk, solveChunkTest

using MDPSolver_
using CSLV_
using GridInterpolations

import MDPSolver_.solve

import Base.pmap # for parallel work

type ParallelVI

    policyFile::String

    maxIterations::Int

    tolerance::Float64

    nProcs::Int

    valU::Vector
    valQ::Matrix

    stateOrder::Vector

end

function solve(mdp::CSLVProblem, alg::ParallelVI)

    nStates  = mdp.nStates
    nActions = mdp.nActions

    maxIter = alg.maxIterations
    tol     = alg.tolerance

    valU = alg.valU
    valQ = alg.valQ

    nProcs = alg.nProcs
    nChunks = length(alg.stateOrder)
    order = alg.stateOrder

    if nProcs > Sys.CPU_CORES
        error("Requested too many processors")
    end

    # start and end indeces
    chunks = Array(Vector{Tuple{Int64, Int64}}, nChunks) 
    for i = 1:nChunks
        co = order[i]
        sIdx = co[1]
        eIdx = co[2]
        ns = eIdx - sIdx
        # divide the work among the processors
        stride = div(ns, (nProcs-1))
        temp = Tuple{Int64, Int64}[]
        for j = 0:(nProcs-2)
            si = j * stride + sIdx
            ei = si + stride - 1
            if j == (nProcs-2) 
                ei = eIdx
            end
            push!(temp, (si ,ei))
        end
        chunks[i] = temp
    end


    # shared array for utility
    util = SharedArray(Float64, (nStates), init = S -> S[localindexes(S)] = 0.0, pids = 1:nProcs)

    # loop over chunks 
    results = 1
    uCount = 0
    for i = 1:maxIter
        # utility array update indeces 
        for c = 1:nChunks
            lst = chunks[c]

            uIdx1 = uCount % 2 + 1
            uIdx2 = (uCount+1) % 2 + 1

            tic()
            # update q-val only on the last iteration
            results = pmap(x -> (idxs = x; solveChunk(mdp, util, idxs)), lst)
            t = toc()
            println("Chunk: $c, time: $t")

            uCount += 1
        end # chunk loop 

    end # main iteration loop
    return util
end

function solveChunk(mdp::CSLVProblem, valOld::SharedArray, valNew::SharedArray, valQ::SharedArray, stateIndices::Tuple{Int64, Int64})

    sStart = stateIndices[1]
    sEnd   = stateIndices[2]
    nActions = mdp.nActions

    for si = sStart:sEnd
        qHi = -Inf
        ai = 0

        s = State(ind2x(mdp.acGrid, si))

            for a in mdp.actionArray
                ai += 1
                probs, states = nextState(mdp, s, a) 
                qNow = reward(mdp, s, a)

                for sp = 1:length(states)
                    x = states[sp]
                    qNow += probs[sp] * interpolate(mdp.acGrid, valOld, x) 
                end # sp loop
                valQ[ai, si] = qNow
                if ai == 1 || qNow > qHi
                    qHi = qNow
                    valNew[si] = qHi
                end
            end # action loop
    end # state loop

    return stateIndices 
end

function solveChunk(mdp::CSLVProblem, util::SharedArray, valQ::SharedArray, stateIndices::Tuple{Int64, Int64})

    sStart = stateIndices[1]
    sEnd   = stateIndices[2]
    nActions = mdp.nActions

    for si = sStart:sEnd
        qHi = -Inf
        ai = 0

        s = State(ind2x(mdp.acGrid, si))

            for a in mdp.actionArray
                ai += 1
                probs, states = nextState(mdp, s, a) 
                qNow = reward(mdp, s, a)

                for sp = 1:length(states)
                    x = states[sp]
                    qNow += probs[sp] * interpolate(mdp.acGrid, util, x) 
                end # sp loop
                valQ[ai, si] = qNow
                if ai == 1 || qNow > qHi
                    qHi = qNow
                    util[si] = qHi
                end
            end # action loop
    end # state loop

    return stateIndices 
end

function solveChunk(mdp::CSLVProblem, util::SharedArray, stateIndices::Tuple{Int64, Int64})

    sStart = stateIndices[1]
    sEnd   = stateIndices[2]
    nActions = mdp.nActions

    for si = sStart:sEnd
        qHi = -Inf
        ai = 0

        s = State(ind2x(mdp.acGrid, si))

            for a in mdp.actionArray
                ai += 1
                probs, states = nextState(mdp, s, a) 
                qNow = reward(mdp, s, a)

                for sp = 1:length(states)
                    x = states[sp]
                    qNow += probs[sp] * interpolate(mdp.acGrid, util, x) 
                end # sp loop
                if ai == 1 || qNow > qHi
                    qHi = qNow
                    util[si] = qHi
                end
            end # action loop
    end # state loop

    return stateIndices 
end

end # module
