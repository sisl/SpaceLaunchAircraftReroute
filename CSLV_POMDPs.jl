using POMDPs
using CSLVProblem_
using CSLV_
using Distributions
using GridInterpolations
using DiscreteValueIteration

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

function rand(rng::AbstractRNG, d::CSLV_Distribution)
    d.states[rand(rng, d.d)]
end

function POMDPs.transition(mdp::CSLVProblem, state::State, action::Action)
    probs,next_states = nextState(mdp, state, action)
    states = [State(s) for s in next_states] # convert to State type
    make_dist(states, probs)
end

function POMDPs.reward(mdp::CSLVProblem, state::State, action::Action, statep::State)
    CSLV_.reward(mdp, state, action)
end

POMDPs.isterminal(mdp::CSLVProblem, s::State) = (s.timeRem == 0)
POMDPs.n_states(mdp::CSLVProblem) = mdp.nStates;
POMDPs.n_actions(mdp::CSLVProblem) = mdp.nActions;

POMDPs.discount(mdp::CSLVProblem) = 1;

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

function GridInterpolations.interpolate(ss::RectangleGrid, v::Vector{Float64}, s::State)
    interpolate(ss,v,convert(s))
end






