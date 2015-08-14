# Optimal Aircraft Rerouting During Commercial Space Launches

This repository contains the supplementary code for the paper titled “Optimal Aircraft Rerouting During Commercial Space Launches” by Rachael E. Tompa, Mykel J. Kochenderfer, Rodney Cole, and James K. Kuchar, in the 2015 Digital Avionics Systems Conference. 

Here you will find the code to perform the following:
*	Implement and solve the MDP using parallelized value iteration
  *	runMDP.ipynb
  * MDPSolver_.jl
  * ParallelV_.jl
  * lvtest.jl
  * CSLV_.jl
  * CSLVProblem_.jl
*	Data Files
  * debrisData.txt
  * flightPaths.jl
*	Visualize the MDP solution
  * visualizeUtilityAndPolicy.ipynb
*	Run simulations of the airspace to analyze historic, nominal, and proposed aircraft flights
  * proposedSimulation.ipynb
  * nominalAndHistoricSimulation.ipynb

## Dependencies

The software is implemented entirely in Julia. For the best results, the user should use a notebook. An example notebook is provided for the reader's convenience in the example subdirectory. The following Julia packages are required for running all code and notebooks:
*	[GridInterpolations.jl](https://github.com/sisl/GridInterpolations.jl)
*	[PGFPlots.jl](https://github.com/sisl/PGFPlots.jl) (Note: additional dependencies)
*	[Interact.jl](https://github.com/JuliaLang/Interact.jl) 

