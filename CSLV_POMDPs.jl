using POMDPs
using CSLVProblem_
using CSLV_
using Distributions
using GridInterpolations
using DiscreteValueIteration
using GenerativeModels

import GridInterpolations.interpolate

function Base.start(g::RectangleGrid)
    1
end

function Base.next(g::RectangleGrid, state)
    s = State(ind2x(g, state))
    (s, state+1)
end

function Base.done(g::RectangleGrid, state)
    state == prod(g.cut_counts) + 1
end

POMDPs.iterator(g::RectangleGrid) = g

function POMDPs.states(mdp::CSLVProblem)
    mdp.acGrid
end

function POMDPs.actions(mdp::CSLVProblem)
    mdp.actionArray
end

function POMDPs.actions(mdp::CSLVProblem, s::State)
    valid(a) = CSLV_.reward(mdp, s, a) != -Inf
    filter(valid, mdp.actionArray)
end

type CSLV_Distribution
    states::Array{State}
    d::DiscreteUnivariateDistribution
end

function make_dist(states, probs)
    probs = collect(probs)
    d = Categorical(probs/sum(probs))
    CSLV_Distribution(states, d)
end

function POMDPs.pdf(d::CSLV_Distribution, s::State)
    for (i,sp) in enumerate(d.states)
        if sp == s
            return Distributions.pdf(d.d,i)
        end
    end
end

POMDPs.iterator(d::CSLV_Distribution) = d.states

function Base.rand(rng::AbstractRNG, d::CSLV_Distribution)
    d.states[rand(rng, d.d)]
end

function POMDPs.transition(mdp::CSLVProblem, state::State, action::Action)
    probs,next_states = nextState(mdp, state, action)
    states = [State(s) for s in next_states] # convert to State type
    make_dist(states, probs)
end

function POMDPs.reward(mdp::CSLVProblem, state::State, action::Action, statep::State)
    r = CSLV_.reward(mdp, state, action)
    if r == -Inf
        r = -1e3*1.0
    end
    r
end

POMDPs.isterminal(mdp::CSLVProblem, s::State) = (s.timeRem == 0)
POMDPs.n_states(mdp::CSLVProblem) = mdp.nStates;
POMDPs.n_actions(mdp::CSLVProblem) = mdp.nActions;

POMDPs.discount(mdp::CSLVProblem) = 0.99;

function POMDPs.state_index(mdp::CSLVProblem, state::State)
    inds, weights = interpolants(mdp.acGrid,convert(state))
    maxval, maxind = findmax(weights)

    inds[maxind]
end

function POMDPs.action_index(mdp::CSLVProblem, action::Action)
    ind = findfirst(mdp.actionArray, action)
    if (ind == 0)
        ind = 1
    end
    ind
end

function GenerativeModels.initial_state(mdp::CSLVProblem, rng::AbstractRNG)
    t = 81
    lvt = -1
    x = Base.rand(rng, mdp.acGrid.cutPoints[1])
    y = Base.rand(rng, mdp.acGrid.cutPoints[2])
    h = Base.rand(rng, mdp.acGrid.cutPoints[3])
    s = State(x,y,h,lvt,t)
    s
end

function GridInterpolations.interpolate(ss::RectangleGrid, v::Vector{Float64}, s::State)
    interpolate(ss,v,convert(s))
end

function POMDPs.vec(mdp::CSLVProblem, state::State)
    convert(state)./[10000,10000,100,1,100]
end

function unvec(mdp::CSLVProblem, s_vec::Vector)
    State(s_vec.*[10000,10000,100,1,100])
end

# define initial_state sampling with a distribution
function GenerativeModels.initial_state(mdp::CSLVProblem, s0_dist::Sampleable, rng::AbstractRNG)
    t = 81
    lvt = -1

    s_vec = rand(s0_dist)

    # go through and enforce ranges
    if  s_vec[1] <= mdp.minE/10000 || s_vec[1] >= mdp.maxE/10000
        s_vec[1] = Base.rand(rng, mdp.acGrid.cutPoints[1])/10000
    end

    if s_vec[2] <= mdp.minN/10000 || s_vec[2] >= mdp.maxN/10000
        s_vec[2] = Base.rand(rng, mdp.acGrid.cutPoints[2])/10000
    end

    if abs(s_vec[3]) > 1.80
        s_vec[3] = Base.rand(rng, mdp.acGrid.cutPoints[3])/100
    end

    s_vec[5] = t/100

    s = unvec(mdp, s_vec)

    # discretize
    s_ind = state_index(mdp, s)
    State(ind2x(mdp.acGrid, s_ind))
end

