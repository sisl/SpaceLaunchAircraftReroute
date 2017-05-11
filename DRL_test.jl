include("CSLV_POMDPs.jl");
include(joinpath("..","DRL.jl","src","DRL.jl"))
using DRL
using DataFrames

mdp = CSLVProblem()
dqn = rl.DQN(max_steps=100, checkpoint_interval=25, num_epochs=7500, target_refresh_interval=250)
pol = rl.solve(dqn, mdp)

util = zeros(Float32, n_states(mdp))
for (i,s) in enumerate(iterator(states(mdp)))
    util[i] = rl.util(pol, s)
end

df = DataFrame(dqn.stats)
writetable("cslv_dqn.csv", df)

f = open("lambda0.05_drl_pr", "w")
writedlm(f, util)
close(f)
