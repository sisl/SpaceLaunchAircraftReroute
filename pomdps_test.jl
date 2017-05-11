using JLD
using GenerativeModels
using POMDPToolbox


include("CSLV_POMDPs.jl");
mdp = CSLVProblem();
solver = ValueIterationWithInterpSolver();
policy = DiscreteValueIteration.create_policy(solver, mdp);

sim = RolloutSimulator(max_steps=100)

policy = solve(solver, mdp, policy, verbose=true);
util = policy.util


save("./valueiterationpolicy.jld", "policy", policy)


f = open("lambda0.05_pomdps", "w")
writedlm(f, util)
close(f)


