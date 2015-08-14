module MDPSolver_

export MDPSolver, selectAction, solve

abstract MDPSolver

solve(alg::MDPSolver) = error("$(typeof(alg)) does not implement solve()")
selectAction(alg::MDPSolver) = error("$(typeof(alg)) does not implement selectAction()")

end # module