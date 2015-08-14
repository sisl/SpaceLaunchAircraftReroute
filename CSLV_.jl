module CSLV_

## to setup grid
using GridInterpolations

## define problem
using CSLVProblem_

import Base.convert

## export Problem, State, Action
export CSLVProblem, State, Action
## export helping functions
export approxEq, unwrap_rad, unwrap_deg
## export reward functions
export velocityReward, stateAtAnomaly, statePostAnomaly, inEllipse, debrisLocations, 
       distanceReward, reward
## export next state function
export nextState
## export value iteration function
export valueIteration
## export post processing functions
export value, action

## use this function to establish approximate equality
function approxEq(x,y,epsilon = 1.e-2)
  abs(x-y) < epsilon
end

## use this function to wrap angles when in radians
function unwrap_rad(a::Float64)
    if (a > pi)
        return mod(a + pi, 2*pi) - pi
    elseif (a < -pi)
        return -(mod(-a + pi, 2*pi) - pi)
    else
        return a
    end
end

## use this function to wrap angles when in degrees
function unwrap_deg(a_deg::Float64)
    unwrap_rad(a_deg*pi/180)*180/pi
end

## setup the velocity reward that depends on heading change
function velocityReward(problem::CSLVProblem, state::State, action::Action)
  ## reward if alert commands current heading
  reward = problem.maintainCost
  ## no alert
  if action.head == problem.noAlert
    reward = 0.
  ## alert with heading change
  elseif state.head != action.head
    ## check if heading change is possible
    if abs(unwrap_deg(state.head-action.head)) > problem.headingLimit
      reward = -Inf
    else
      reward = -1.
    end
  end
  reward
end

## find the launch vehicle state when anomaly occurs
function stateAtAnomaly(problem::CSLVProblem, state::State)
  problem.lvStates[int(state.anomaly)]
end

## find the launch vehicle state at the time step after anomaly if no anomaly had occurred
function statePostAnomaly(problem::CSLVProblem, state::State)
  problem.lvStates[int(state.anomaly + 1)]
end

## find debris ellipse and determine if aircraft within debris ellipse
function inEllipse(problem::CSLVProblem, state::State, cX::Float64, cY::Float64)
  ## find current lv heading (direction of debris ellipse major axis)
  s = stateAtAnomaly(problem, state)
  sp1 = statePostAnomaly(problem, state)
  rad = atan2((s.y - sp1.y), (s.x - sp1.x))
  phi = unwrap_rad(rad)
  ## setup rotation matrix
  cPhi = cos(phi)
  sPhi = sin(phi)
  rotMatrix = [cPhi sPhi;-sPhi cPhi]
  ## find foci length
  a = 2. * sp1.safe
  b = sp1.safe
  fociLength = (a*a-b*b)^0.5
  ## setup foci positions
  cXP = fociLength
  cXM = -fociLength
  fociInit = [cXM 0.;cXP 0.]
  fociRot = fociInit*rotMatrix
  fociFinalX = fociRot[:,1] .+ cX
  fociFinalY = fociRot[:,2] .+ cY
  foci = [fociFinalX fociFinalY]
  ## check if aircraft is within debris ellipse
  if ((state.x-foci[1])^2+(state.y-foci[3])^2)^.5 + ((state.x-foci[2])^2+(state.y-foci[4])^2)^.5 <= (2.*a)
    return 1.
  else
    return 0.
  end
end

## find the locations of the debris 
function debrisLocations(problem::CSLVProblem, state::State)
  ## no active debris
  returnValue = 0
  ## only look if within the time debris hits altitude
  if state.anomaly >= problem.startDebris && state.anomaly <= problem.endDebris 
    ## cycle over every possible piece of debris
    for i = 1:length(problem.debris)/5
      ## reset trigger
      atTime = false
      ## if anomaly is this time step or previous time step or the next time step
      if i > 1 && i < length(problem.debris)/5
        if approxEq(state.anomaly, problem.debris[5*(i-1)+1]) || approxEq(state.anomaly, problem.debris[5*(i-1)+1-5]) || 
           approxEq(state.anomaly, problem.debris[5*(i-1)+1+5])
          atTime = true
        end
      elseif i ==1 
        if approxEq(state.anomaly, problem.debris[5*(i-1)+1]) || approxEq(state.anomaly, problem.debris[5*(i-1)+1+5])
          atTime = true
        end
      else
        if approxEq(state.anomaly, problem.debris[5*(i-1)+1]) || approxEq(state.anomaly, problem.debris[5*(i-1)+1-5])
          atTime = true
        end
      end
      ## if there is a piece of debris
      if atTime == true
        ## if time remain matches the time of the debris falling +/- 20 seconds
        compareValue = problem.timeThres-floor(floor(problem.debris[i*5],-1)/problem.timeStepSeconds)
        if approxEq(compareValue, state.timeRem) || approxEq(compareValue, (state.timeRem+1)) || 
           approxEq(compareValue, (state.timeRem-1)) || approxEq(compareValue, (state.timeRem+2)) || 
           approxEq(compareValue, (state.timeRem-2))
          ## check to see if in debris range 
          if inEllipse(problem, state, problem.debris[5*(i-1)+2], problem.debris[5*(i-1)+3]) > 0.
            returnValue = 1.
          end
        end
      end
    end
  end
  return returnValue
end

## set the distance reward value
function distanceReward(problem::CSLVProblem, state::State, action::Action)
  ## not within safety threshold of debris
  reward = 0.
  ## check if when launch vehicle passes through altitude
  if state.timeRem == problem.intersectTime
    distance = ((state.x - problem.lvStates[6].x)^2+(state.y - problem.lvStates[6].y)^2)^.5
    ## check distance between launch vehicle and aircraft
    if distance <= problem.lvStates[6].safe
      reward = -1.
      return reward
    end
  end
  ## if anomaly, determine if aircraft is at risk from any debris
  if state.anomaly >= 0.
    if debrisLocations(problem, state) > 0.
      reward = -1.
    end
  end
  reward
end

## set overall reward value
function reward(problem::CSLVProblem, state::State, action::Action)
  if velocityReward(problem, state, action) == -Inf
    return -Inf
  else
    return problem.lambda * velocityReward(problem, state, action) + distanceReward(problem, state, action)
  end
end

## find the potential next states
function nextState(problem::CSLVProblem, state::State, action::Action)
  ## if first time step empty
  if state.timeRem == 0.
    return ((0.,0.),(zeros(5),zeros(5)))
  end
  ## setup arrays for valid speeds and positions
  xSpeeds = Float64[]
  ySpeeds = Float64[]
  possibleEast = Float64[]
  possibleNorth = Float64[]
  ## based on action, possible responses and headings
  if action.head != problem.noAlert
    ## does not respond, does respond
    response = [1-problem.response,problem.response]
    headings = [state.head, action.head]
  else
    ## turning probability distribution
    response = problem.turnDist
    headings = [unwrap_deg(state.head-2*problem.stepHeadingState), unwrap_deg(state.head-problem.stepHeadingState), 
                unwrap_deg(state.head), unwrap_deg(state.head+problem.stepHeadingState), 
                unwrap_deg(state.head+2*problem.stepHeadingState)]
  end
  ## setup the speeds and positions
  for i = 1:length(headings)
    push!(xSpeeds, round(problem.acSpeed*cosd(headings[i]), 0))
    push!(ySpeeds, round(problem.acSpeed*sind(headings[i]), 0))
    push!(possibleEast, state.x + xSpeeds[i])
    push!(possibleNorth, state.y + ySpeeds[i])
    ## check within bounds and set to limits if outside
    if possibleEast[i] <= problem.minE || possibleEast[i] >= problem.maxE
      possibleEast[i] = state.x
    end
    if possibleNorth[i] <= problem.minN || possibleNorth[i] >= problem.maxN
      possibleNorth[i] = state.y
    end
  end
  ## next states if anomaly already occurred 
  if state.anomaly >= 0.
    ## only next states with anomaly 
    nextStates = Array(Array, length(headings))
    for i=1:length(headings)
      nextStates[i] = [possibleEast[i], possibleNorth[i], headings[i], state.anomaly, state.timeRem-1.]
    end
    return ((response),(nextStates))
  ## next state if anomaly has not occurred
  else
    nextStatesNoAnom = Array(Array, length(headings))
    nextStatesAnom = Array(Array, length(headings))
    for i = 1:length(problem.lvStates)
      ## check if anomaly can occur and setup potential next states
      if approxEq(problem.lvStates[i].timeLV, (state.timeRem-problem.timeThres))
        for j = 1:length(headings)
          nextStatesNoAnom[j] = [possibleEast[j], possibleNorth[j], headings[j], -1, state.timeRem-1.]
          nextStatesAnom[j] = [possibleEast[j], possibleNorth[j], headings[j], problem.lvStates[i].timeLV, state.timeRem-1.]
        end
        nextStates = Array(Array, length(headings)*2)
        probResponse = Array(Float64, length(headings)*2)
        for j = 1:length(headings)
          if action.head != problem.noAlert
            nextStates[j] = nextStatesNoAnom[j]
            nextStates[j+length(headings)] = nextStatesAnom[j]
            probResponse[j] = response[1]*(1.-problem.lvStates[i].probAnom)
            probResponse[j+length(headings)] = response[2]*(problem.lvStates[i].probAnom)
          else
            nextStates[2*j-1] = nextStatesNoAnom[j]
            nextStates[2*j] = nextStatesAnom[j]
            probResponse[2*j-1] = response[j]*(1.-problem.lvStates[i].probAnom)
            probResponse[2*j] = response[j]*(problem.lvStates[i].probAnom)
          end
        end
        return ((probResponse), (nextStates))
      end
    end
    ## anomaly cannot occur
    for i=1:length(headings)
      nextStatesNoAnom[i] = [possibleEast[i], possibleNorth[i], headings[i], -1, state.timeRem-1.]
    end
    return ((response),(nextStatesNoAnom))
  end
end

## perform value iteration
function valueIteration(problem::CSLVProblem)
  actionIndex = [problem.actionArray[i] => i for i = 1:problem.nActions]
  ## setup policy and utility
  util = zeros(problem.nStates)
  for i = 1:problem.nStates
    state = State(ind2x(problem.acGrid, i))
    ## going to find max so set to min value
    QHi = 0.
    ai = 0
    ## for all possible AC actions
    for action in problem.actionArray
      ai += 1
      ## find the current utility value
      QNow = reward(problem, state, action)
      ## find the next states and their probabilities of occurring
      (probabilities, nextStates) = nextState(problem, state, action)
      ## cycle over all potential next states
      for nextStateIndex = 1:length(nextStates)
        x = nextStates[nextStateIndex] 
        QNow = QNow + probabilities[nextStateIndex] * interpolate(problem.acGrid, util, x)
      end
      ## set maximum utility value 
      if ai == 1 || QNow > QHi
        QHi = QNow
        util[i] = QHi
      end
    end
  end
  return util
end

## during post processing, used to find the utility at a given states
function value(problem::CSLVProblem, util, x)
  interpolate(problem.acGrid, util, x)
end

## during post processing, used to find the optimal action at a given state
function action(problem::CSLVProblem, util, x)
  ## want optimal, so start with min and find max
  QHi = 0.
  ind = 1 
  ## cycle through actions
  for i = 1:problem.nActions
    ## find current utility value
    QNow = reward(problem, State(x), problem.actionArray[i])
    ## find the next states and their probabilities of occurring
    (probabilities, nextStates) = nextState(problem, State(x), problem.actionArray[i])
    ## cycle over all potential next states
    for nextStateIndex = 1:length(nextStates)
      xStar = nextStates[nextStateIndex] 
      QNow = QNow + probabilities[nextStateIndex] * interpolate(problem.acGrid, util, xStar)
    end
    ## set maximum utility value and record corresponding action
    if i == 1 || QNow > QHi
      QHi = QNow
      ind = i
    end
  end
  return ind
end

end ## module
