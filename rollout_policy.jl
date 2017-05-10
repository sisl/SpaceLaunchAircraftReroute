using JLD
using GenerativeModels
using POMDPToolbox


include("CSLV_POMDPs.jl");
mdp = CSLVProblem();

d = load("./valueiterationpolicy.jld")
policy = d["policy"]


sim = RolloutSimulator(max_steps=100)
rng=RandomDevice()
r_total = 0
N_sim = 500
for i in 1:N_sim
    r_total += simulate(sim, mdp, policy, initial_state(mdp, rng))
end
println("\tAvg total reward: $(r_total/N_sim)")