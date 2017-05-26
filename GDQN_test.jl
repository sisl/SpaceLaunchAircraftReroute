push!(LOAD_PATH, ".");
include("CSLV_POMDPs.jl");
include(joinpath("..","DRL.jl","src","DRL.jl"))
using DRL
using PDMats
using DataFrames

mdp = CSLVProblem()

N = 11 # number of modes to use
weights = 1./N*ones(N)
rng = RandomDevice()
x_means = (rand(rng, Float64, N)*(mdp.maxE - mdp.minE) + mdp.minE)/10000
y_means = (rand(rng, Float64, N)*(mdp.maxN - mdp.minN) + mdp.minN)/10000
h_means = (rand(rng, Float64, N)*360 - 180)/100
means = collect([x, y, h, -1, -0.81] for (x,y,h) in zip(x_means, y_means, h_means))
Sigmas = collect(PDMat(full(Diagonal([1.4, 1.4, 0.4, 0.01, 0.01]))) for i in 1:N)

s0_dist = rl.GMM(N,5,weights,means,Sigmas);
dqn = rl.GDQN(max_steps=100, checkpoint_interval=25, num_epochs=5000, target_refresh_interval=500)
pol = rl.solve(dqn, mdp, s0_dist=Nullable{rl.GMM}(s0_dist))

df = DataFrame(dqn.stats)
writetable("cslv_gdqn.csv", df)

util = zeros(Float32, n_states(mdp))
for (i,s) in enumerate(iterator(states(mdp)))
    util[i] = rl.util(pol, s)
end

f = open("lambda0.05_gdqn_sanity2", "w")
writedlm(f, util)
close(f)
