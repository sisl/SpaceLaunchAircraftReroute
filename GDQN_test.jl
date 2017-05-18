include("CSLV_POMDPs.jl");
include(joinpath("..","DRL.jl","src","DRL.jl"))
using DRL
using PDMats
using DataFrames

mdp = CSLVProblem()
s0_dist = rl.GMM(3,5,
			    [0.3,0.3,0.4],
			    [[4.5,6.0,-1.35,-1.,0.81],
					 [3.0,-4.0,1.35,-1.,0.81],
					 [6.5,-4.5,-0.45,-1.,0.81]],
			    [PDMat(full(Diagonal([1.4, 1.4, 0.4, 0.01, 0.01]))),
			       PDMat(full(Diagonal([1.4, 1.4, 0.4, 0.01, 0.01]))),
			       PDMat(full(Diagonal([1.4, 1.4, 0.4, 0.01, 0.01])))]
			    );
dqn = rl.GDQN(max_steps=100, checkpoint_interval=25, num_epochs=2500, target_refresh_interval=250)
pol = rl.solve(dqn, mdp, s0_dist=Nullable{rl.GMM}(s0_dist))

df = DataFrame(dqn.stats)
writetable("cslv_gdqn.csv", df)

util = zeros(Float32, n_states(mdp))
for (i,s) in enumerate(iterator(states(mdp)))
    util[i] = rl.util(pol, s)
end

f = open("lambda0.05_gdqn", "w")
writedlm(f, util)
close(f)
