push!(LOAD_PATH, ".");
include("CSLV_POMDPs.jl");
include(joinpath("..","DRL.jl","src","DRL.jl"))
using DRL
using PDMats
using DataFrames
using JLD
using MXNet

mdp = CSLVProblem(distRes=16000.)

# Solve with DVI first
println("Solving with DVI")
solver = ValueIterationWithInterpSolver();
policy = DiscreteValueIteration.create_policy(solver, mdp);
policy = solve(solver, mdp, policy, verbose=true);
save("./valueiterationpolicy.jld", "policy", policy)

# Load DVI policy from file
# data = load("./valueiterationpolicy.jld")
# policy = data["policy"]


# extract q function
function qhat(s_vec)
    s = unvec(mdp, s_vec)
    s_idx = state_index(mdp, s)
    q_vec = policy.qmat[s_idx,:]
end

println("Solving with DQN, seeded with DVI")
dqn = rl.DQN(nn=rl.build_partial_mlp(ctx=mx.cpu(), hidden_sizes=[512,256,128,64,32]), max_steps=100, checkpoint_interval=25, num_epochs=0, target_refresh_interval=25, q_hat=Nullable{Function}(qhat), q_hat_bias=0.)
dqnpol = rl.solve(dqn, mdp)

dqnutil = zeros(Float32, n_states(mdp))
for (i,s) in enumerate(iterator(states(mdp)))
    dqnutil[i] = rl.util(dqnpol, s)
end

f = open("util_dvi", "w")
writedlm(f, policy.util)
close(f)

f = open("util_dqn", "w")
writedlm(f, dqnutil)
close(f)
