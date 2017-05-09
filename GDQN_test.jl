include("CSLV_POMDPs.jl");
include(joinpath("..","DRL.jl","src","DRL.jl"))
using DRL
using PDMats

mdp = CSLVProblem()
s0_dist = rl.GMM(3,5,
			    [0.3,0.3,0.4],
			    [[0.,0.,0.,-1.,0.81], [0.1,0.1,0.,-1.,0.81], [0.5,0.5,0,-1.,0.81]],
			    [PDMat(full(Diagonal([0.4, 0.4, 0.4, 0.01, 0.01]))),
			       PDMat(full(Diagonal([0.4, 0.4, 0.4, 0.01, 0.01]))),
			       PDMat(full(Diagonal([0.4, 0.4, 0.4, 0.01, 0.01])))]
			    );
dqn = rl.GDQN(max_steps=100, checkpoint_interval=25, num_epochs=10000, target_refresh_interval=250)
pol = rl.solve(dqn, mdp, s0_dist=Nullable{rl.GMM}(s0_dist))

util = zeros(Float32, n_states(mdp))
for (i,s) in enumerate(iterator(states(mdp)))
    util[i] = rl.util(pol, s)
end

f = open("lambda0.05_gdqn", "w")
writedlm(f, util)
close(f)
