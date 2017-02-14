include("CSLV_POMDPs.jl");
mdp = CSLVProblem();
solver = ValueIterationWithInterpSolver();
policy = create_policy(solver, mdp);
policy = solve(solver, mdp, policy, verbose=true);
util = policy.util

f = open("lambda0.05_pomdps", "w")
writedlm(f, util)
close(f)