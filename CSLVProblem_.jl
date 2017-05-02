module CSLVProblem_

using POMDPs
using GridInterpolations

import Base.convert

export CSLVProblem, LVState, State, Action, convert

## for problem.acGrid
immutable State
  x::Float64
  y::Float64
  head::Float64
  anomaly::Float64
  timeRem::Float64
end
convert(s::State) = [s.x, s.y, s.head, s.anomaly, s.timeRem]
State(x::Vector{Float64}) = State(x...)

## for problem.lvStates
immutable LVState
  x::Float64
  y::Float64
  probAnom::Float64
  safe::Float64
  timeLV::Float64
end

## for problem.actionArray
immutable Action
  head::Float64
end

## to fully define problem and all fields
type CSLVProblem <: MDP{State,Action}
  minE::Float64
  maxE::Float64
  minN::Float64
  maxN::Float64
  stepHeadingState::Float64
  timeThres::Float64
  acGrid::RectangleGrid
  lvStates::Vector{LVState}
  noAlert::Float64
  actionArray::Array{Action}
  debris::Array{Float64}
  nStates::Int64
  nActions::Int64
  maintainCost::Float64
  headingLimit::Float64
  startDebris::Float64
  endDebris::Float64
  timeStepSeconds::Float64
  intersectTime::Float64
  lambda::Float64
  acSpeed::Float64
  response::Float64
  turnDist::Array{Float64}
end

## MAKE the problem
function CSLVProblem()

  #############################################################
  ##          Parameters needed for immutable State          ##
  #############################################################

  ## For Grid: East Position, North Position, Heading, 
  ## Anomaly Time, Launch Vehicle Time ##

  minE = -2.5e4
  maxE = 5.1e4
  stepE = 4000. #2000.

  minN = -4.5e4
  maxN = 6.5e4
  stepN = 4000. #2000.

  stepHeadingState = 15. # degrees

  timeStep = 1. # * 10 seconds (simulation time increments)

  timeThres = 81. # * 10 seconds (total simulation time)

  lvTime = 11. # * 10 seconds (total launch vehicle simulation time)

  ## make acGrid
  acGrid = RectangleGrid(collect(minE:stepE:maxE), collect(minN:stepN:maxN), collect(-180.:stepHeadingState:180.), 
                         collect(-1.:timeStep:lvTime), collect(0.:timeStep:timeThres))
  
  #############################################################
  ##        Parameters needed for immutable LVState          ##
  #############################################################

  ## launch vehicle trajectory ENU, 1 position for every 10 seconds
  eUse = [0.0, 0.0, -0.0, 0.0, 0.0, 107.82, 1147.6, 3484.6, 7397.02, 13321.5, 21715.8, 33305.8]
  nUse = [0.0, -0.0, -11.0859, -11.0899, -11.0955, 44.4101, 722.251, 2269.08, 4911.38, 8967.77,
         14806.3, 23015.7]

  probAnom = 0.052 # probability of anomaly for each time step

  safeThres = 1520.4 # in meters

  ## MAKE lvStates
  prob = fill(0.052,length(eUse))
  safe = fill(safeThres,length(eUse))
  timeLV = collect(0.:timeStep:lvTime)
  # setup LV states with timeRem
  lvStates = [LVState(eUse[i], nUse[i], prob[i], safe[i], timeLV[i]) for i in 1:length(eUse)]

  #############################################################
  ##         Parameters needed for immutable Action          ##
  #############################################################

  noAlert = 3000.

  stepHeadingAction = 15. # degrees

  ## MAKE actionArray
  heading = cat(1,[noAlert],collect(-180.:stepHeadingAction:180.))
  actionArray = [Action(heading[i]) for i = 1:length(heading)]

  #############################################################
  ##              Parameters needed for debris               ##
  #############################################################
  
  debrisFileName = "debrisData.txt"

  ## GET debris data
  debris = float(open(readdlm,debrisFileName))

  #############################################################
  ## Parameters needed for type CSLVProblem ##
  #############################################################

  ## for parallelization and function: valueIteration
  nStates = prod(acGrid.cut_counts)
  nActions = length(actionArray)

  ## function: velocityReward 
  maintainCost = -0.01
  headingLimit = 30.1 # degrees

  ## function: debrisLocations
  ## these values are found from the debris trajectory output
  startDebris = 5. # * 10 seconds
  endDebris = 10. # * 10 seconds
  timeStepSeconds = 10.

  ## function: distanceReward
  intersectTime = 76. # * 10 seconds

  ## function: reward
  lambda = 0.005

  ## function: nextState
  acSpeed = 2900. # m/10 seconds
  ## use minE, maxE, minN, maxN from Grid
  response = 0.5 # how often the pilot responds
  ## no action, turning probability distribution - must be 5 to items to match turns
  ## turns are adding -2*stepHeadingState, -1*stepHeadingState, 0, stepHeadingState, stepHeadingState
  turnDist = [0.05, 0.25, 0.4, 0.25, 0.05]

  ## return
  CSLVProblem(minE, maxE, minN, maxN, stepHeadingState,timeThres, acGrid, lvStates, noAlert, 
              actionArray, debris, nStates, nActions, maintainCost, headingLimit, startDebris, 
              endDebris, timeStepSeconds, intersectTime, lambda, acSpeed, response, turnDist)
end

end # module