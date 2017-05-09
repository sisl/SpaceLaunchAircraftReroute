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

r_total = 0
N_sim = 500
for i in 1:N_sim
    r_total += simulate(sim, mdp, policy, initial_state(mdp, rng))
end
println("\tAvg total reward: $(r_total/N_sim)")

f = open("lambda0.05_pomdps", "w")
writedlm(f, util)
close(f)


