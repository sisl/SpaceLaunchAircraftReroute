##             old boundary              ##
###########################################
xEllipse = [32610.88497258722,30853.99592752435,29057.704761250094,27229.33503304424,25376.343013902104,23506.28617405547,21626.7912302343,19745.52190490307,17870.146551020538,16008.305796264774,14167.580360012316,12355.459194864128,10579.308101915387,8846.338965604977,7163.579749630955,5537.845390253171,3975.709717337977,2483.4785268145206,1067.1639208089123,-267.5399762868733,-1515.279826060004,-2671.0643179137182,-3730.283763122764,-4688.727969425025,-5542.602334315005,-6288.5421052050115,-6923.624764668075,-7445.380508886214,-7851.800797312318,-8141.344961155005,-8312.944867592018,-8366.007645636153,-8300.416488072515,-8116.529552030744,-7815.176988252454,-7397.656136188917,-6865.724928481132,-6221.593554217985,-5467.914435659689,-4607.770577742124,-3644.662353807057,-2582.4927945171826,-1425.5514499223755,-178.4968972175875,1153.6620312353057,2565.5862232976624,4051.627388199705,5605.850204688275,7222.055436563639,8893.803935313143,10614.441448928032,12377.124155542544,14174.844839930884,16000.459630456664,17846.71521339642,19706.2764408959,21571.754248044763,23435.733793566855,25290.802737645066,27129.57956920241,28944.741893729555,30729.054591402302,32475.39775388257,34176.79430683963,35826.4372238931,37417.71623651487,38944.243943324815,40399.88122143921,41778.76184195975,43075.31619148867,44284.294001756745,45400.7859901298,46420.244314903364,47338.50175106481,48151.78949452399,48856.75350581243,49450.46930788998,49930.455157049226,50294.683510916286,50541.59072330905,50670.0849020629,50679.55187308848,50569.859201532345,50341.358229298996,49994.88409700164,49531.75372773057,48953.76175985904,48263.17442618091,47462.721387133766,46555.5855364754,45545.39080854966,44436.18802706139,43232.4388460543,41938.997844384685,40561.092845408355,39104.303543697235,37574.538530288664,35978.01081726969,34321.2119711453,32610.88497258722]
yEllipse = [-42015.98153097936,-42421.75880334291,-42623.74221286279,-42621.10240012086,-42413.83678976857,-42002.769815624226,-41389.549768805475,-40576.64227872794,-39567.320451082574,-38365.651701128685,-36976.4813347578,-35405.41294369066,-33658.78569483763,-31743.64860719278,-29667.731922570216,-27439.415689005556,-25067.695687571224,-22562.1468448131,-19932.884283692452,-17190.522176031445,-14346.130568726625,-11411.190364534312,-8397.546645889388,-5317.360537017996,-2183.0598054973225,992.7115906331392,4197.144800104517,7417.318006871828,10640.248774614889,13852.946591017611,17042.46539551829,20195.955875022162,23300.717313955665,26344.24878771806,29314.299492261383,32198.918007042663,34986.500293857214,37665.83624026132,40226.15456306555,42657.165895006656,44949.10388582663,47092.76415785339,49079.540965470114,50901.46141770683,52551.21713346866,54022.19320959485,55308.494392919485,56404.96835888342,57307.226010722276,58011.65872510339,58515.452481949214,58816.598828293725,58913.90263810055,58806.98664220726,58496.29271472147,57983.07991439459,57269.41929162918,56358.18548378413,55253.04513344257,53958.44217600689,52479.58005469212,50822.40093234199,48993.56198071178,47000.408838779746,44850.946342275754,42553.8066369653,40118.21479813949,37553.95208838532,34871.31699484315,32081.08419587529,29194.46161528362,26223.04572992782,23178.775303739687,20073.88372766525,16920.850151064962,13732.349595327922,10521.202245093256,7300.322116374256,4082.6653040241704,881.178013369582,-2291.2554175128776,-5421.864297634352,-8498.042957786953,-11507.40151365305,-14437.815812603065,-17277.476361917958,-20014.936039556946,-22639.156392758283,-25139.552334783006,-27506.035055941575,-29729.052971653844,-31799.630537734927,-33709.40477121732,-35450.65932392704,-37016.35596562714,-38400.16334373695,-39596.482897531234,-40600.47181613879,-41408.06294163991,-42015.98153097936]
## set ellipse properties
xFoci = [12152.975231141812,30169.987627709863]
yFoci = [47656.58674620234,-31389.09003724606]
## 2 * focal length
threshold = 102909

##          general parameters           ##
###########################################
flightNum = 10100
flightUni = 101

##                weights                ##
###########################################
weight = [0.5,0.061069089,0.057339656,0.053837975,0.050550139,0.047463088,0.04456456,0.041843043,0.039287727,0.036888461,0.034635716,0.032520545]

##              flight data              ##
###########################################
include("flightPaths.jl")
xArray = xAll
yArray = yAll
nameArray = nameAll

##              Speed Setup              ##
###########################################
function directionSpeedsRad(acSpeed, head)
    xSpeed = round(acSpeed*cos(head), 0)
    ySpeed = round(acSpeed*sin(head), 0) 
    return xSpeed, ySpeed
end
function directionSpeedsDeg(acSpeed, head)
    xSpeed = round(acSpeed*cosd(head), 0)
    ySpeed = round(acSpeed*sind(head), 0) 
    return xSpeed, ySpeed;
end

##          nominal simulation           ##
###########################################
function nominal(problem, xArray, yArray, nameArray, xEllipse, yEllipse, weight)
	##       setup final result vectors      ##
	###########################################
	## list of average distance traveled
	finalNomDist = Float64[]
	## number of flights traverse 10X safety threshold
	finalNumThru = Float64[]
	##          nominal simulations          ##
	###########################################
	@showprogress 1 "Computing..." for k = -1:10 
		sleep(0.1)
	    ## list of average distance traveled
	    nomDistFinal = Float64[]
	    ## list of number through unsafe region
	    nomThru = Float64[]
	    ## L denotes which flight in array of flight data
	    for L = 1:length(xArray)
	        x = xArray[L]
	        y = yArray[L]
	        numPositions = length(x)
	        distList = Float64[]
	        countUnsafe = 0.
	        ## j denotes offset time
	        for j = 1:100
	            ## clear all the parameters and vectors for NOMINAL
	            unsafeZone = Float64[]
	            xListNom = Float64[]
	            yListNom = Float64[]
	            actList = Float64[]
	            push!(xListNom,x[1])
	            push!(yListNom,y[1])
	            position = 1
	            for t = 1:1000
	                timeRemaining = 81 - t + j
	                ## find current heading
	                rad = atan2((y[position+1]-yListNom[t]), (x[position+1]-xListNom[t]))
	                phi = unwrap_rad(rad)
	                phiDeg = phi*180/pi
	                speeds = directionSpeedsRad(problem.acSpeed, phi)
	                ## update list of unsafe
	                if distanceReward(problem, State(xListNom[t], yListNom[t], phiDeg, k, timeRemaining)) < 0.
	                    push!(unsafeZone, 1)
	                end
	                ## add position to trajectory to xList and yList
	                push!(xListNom, xListNom[t]+speeds[1])
	                push!(yListNom, yListNom[t]+speeds[2])
	                ## find next way-point and see if past all available way-points
	                radNew = atan2((yListNom[t+1] - y[position+1]), (xListNom[t+1] - x[position+1]))
	                phiNew = unwrap_rad(radNew)
	                if sign(phi) == sign(phiNew)
	                    position = position + 1
	                    if position + 1 > numPositions
	                        break
	                    end
	                    # extra check
	                    radNewNew = atan2((yListNom[t+1] - y[position+1]), (xListNom[t+1] - x[position+1]))
	                    phiNewNew = unwrap_rad(radNew)
	                    if sign(phi) == sign(phiNewNew)
	                        position = position + 1
	                        if position + 1 > numPositions
	                            break
	                        end
	                    end
	                ## end of check
	                end 
	            ## end of t, end of 1 flight path iteration (1 time of anomaly, 1 offset)
	            end
	            ## have an active xListNom and yListNom
	            ## find distances of each path
	            distance = 0.
	            for i = 1:(length(xListNom)-1)
	                dist = ((xListNom[i]-xListNom[i+1])^2+(yListNom[i]-yListNom[i+1])^2)^.5
	                distance = dist + distance
	            end
	            push!(distList, distance)
	            if length(unsafeZone) >= 1
	                countUnsafe = countUnsafe + 1
	            end
	        end
	        ## add values to result lists
	        push!(nomDistFinal, mean(distList))
	        push!(nomThru, countUnsafe)
	    end
	    ## add to final lists to weight and then display
	    push!(finalNomDist,mean(nomDistFinal))
	    push!(finalNumThru,sum(nomThru))
	end
	println()
	println("RESULTS:")
	##       weight and output results       ##
	###########################################
	FINALNomDist = sum(finalNomDist.*weight)
	FINALNumThru = sum(finalNumThru.*weight)
	println("weighted number nominally rerouted")
	println(round(0,2))
	println("% nominally rerouted")
	println(round(0,2))
	println("average weighted nominal distance")
	println(round(FINALNomDist,2))
	println("average added nominal distance (m)")
	println(round(0,2))
	println("weighted number nominally traverse 10x safety  region")
	println(round(FINALNumThru,2))
	println("percent nominally traverse 10x safety  region")
	println(round(FINALNumThru/flightUni,2))
	return (round(FINALNomDist,2))
end

##          historic simulation          ##
###########################################
function historic(problem, xArray, yArray, nameArray, xEllipse, yEllipse, xFoci, yFoci, threshold, weight, distNom)
	##       setup final result vectors      ##
	###########################################
	## list of average distance traveled
	finalAvgOldDist = Float64[]
	## number of flights rerouted
	finalOldNumR = Float64[]
	## number of flights traverse 10X safety threshold
	finalOldThru = Float64[]
	##   nominal and historic simulations    ##
	###########################################
	@showprogress 1 "Computing..." for k = -1:10 
		sleep(0.1)
	    ## list of average distance traveled
	    avgOldDist = Float64[]
	    ## list of number rerouted
	    oldNumR = Float64[]
	    ## list of number through unsafe region
	    oldThru = Float64[]
	    ## used to determine above or below safety region
	    distListOld = Float64[]
	    ## L denotes which flight in array of flight data
	    for L = 1:length(xArray)
	        x = xArray[L]
	        y = yArray[L]
	        numPositions = length(x)
	        distList = Float64[]
	        countUnsafe = 0.
	        countUnsafeOld = 0.
	        ## j denotes offset time
	        for j = 1:100
	            ## clear all the parameters and vectors for NOMINAL
	            xListNom = Float64[]
	            yListNom = Float64[]
	            actList = Float64[]
	            push!(xListNom,x[1])
	            push!(yListNom,y[1])
	            position = 1
	            # clear all the parameters and vectors for HISTORIC
	            inInd = 0.
	            outInd = 0.
	            bad = 0.
	            inLoc = 0.
	            outLoc = 0.
	            xListOldA = Float64[]
	            yListOldA = Float64[]
	            xListOldB = Float64[]
	            yListOldB = Float64[]
	            extXell = cat(1,xEllipse,xEllipse)
	            extYell = cat(1,yEllipse,yEllipse)
	            distListOld = Float64[]
	            unsafeZoneOld = 0.
	            for t = 1:1000
	                ##               NOMINAL                 ##
	                ###########################################
	                timeRemaining = 81 - t + j
	                ## find current heading
	                rad = atan2((y[position+1]-yListNom[t]), (x[position+1]-xListNom[t]))
	                phi = unwrap_rad(rad)
	                phiDeg = phi*180/pi
	                speeds = directionSpeedsRad(problem.acSpeed, phi)
	                ## add position to trajectory to xList and yList
	                push!(xListNom, xListNom[t]+speeds[1])
	                push!(yListNom, yListNom[t]+speeds[2])
	                ## find next way-point and see if past all available way-points
	                radNew = atan2((yListNom[t+1] - y[position+1]), (xListNom[t+1] - x[position+1]))
	                phiNew = unwrap_rad(radNew)
	                if sign(phi) == sign(phiNew)
	                    position = position + 1
	                    if position + 1 > numPositions
	                        break
	                    end
	                    # extra check
	                    radNewNew = atan2((yListNom[t+1] - y[position+1]), (xListNom[t+1] - x[position+1]))
	                    phiNewNew = unwrap_rad(radNew)
	                    if sign(phi) == sign(phiNewNew)
	                        position = position + 1
	                        if position + 1 > numPositions
	                            break
	                        end
	                    end
	                ## end of check
	                end 
	            ## end of t, end of 1 flight path iteration (1 time of anomaly, 1 offset)
	            end
	            ## have an active xListNom and yListNom
	            ## find distances of each path
	            ##               HISTORIC                ##
	            ###########################################
	            ## use nominal paths to find the historic paths (adjust around static ellipse)
	            for i = 1:length(xListNom)
	                if ((xListNom[i]-xFoci[1])^2+(yListNom[i]-yFoci[1])^2)^.5 + ((xListNom[i]-xFoci[2])^2+(yListNom[i]-yFoci[2])^2)^.5 < threshold
	                   	outInd = i+1
	                end
	            end
	            if bad == 0.
	                for i = length(xListNom):-1:1
	                    if ((xListNom[i]-xFoci[1])^2+(yListNom[i]-yFoci[1])^2)^.5 + ((xListNom[i]-xFoci[2])^2+(yListNom[i]-yFoci[2])^2)^.5 < threshold
	                       	inInd = i+1
	                    end
	                end
	            end
	            ## find when hits restricted region and move around it (check each direction around it)
	            inEllipseDist = Float64[]
	            outEllipseDist = Float64[]
	            if inInd != 0. && outInd != 0. 
	                ## length until hit unsafe region
	                for i = 1:inInd
	                    push!(xListOldA, xListNom[i])
	                    push!(yListOldA, yListNom[i])
	                    push!(xListOldB, xListNom[i])
	                    push!(yListOldB, yListNom[i])
	                end
	                ## find region of safety region that needs to be avoided
	                for i = 1:length(xEllipse)
	                    inDist = ((xListNom[inInd]-xEllipse[i])^2 + (yListNom[inInd]-yEllipse[i])^2)^0.5
	                    outDist = ((xListNom[outInd]-xEllipse[i])^2 + (yListNom[outInd]-yEllipse[i])^2)^0.5
	                    push!(inEllipseDist, inDist)
	                    push!(outEllipseDist, outDist)
	                end
	                ## move around the safety region until out of unsafe region
	                inLoc = indmin(inEllipseDist)
	                outLoc = indmin(outEllipseDist)
	                if inLoc > outLoc
	                    outLoc = outLoc + length(xEllipse)
	                end
	                for i = inLoc:outLoc
	                    push!(xListOldA, extXell[i])
	                    push!(yListOldA, extYell[i])
	                end
	                for i = inLoc+length(xEllipse):-1:outLoc
	                    push!(xListOldB, extXell[i])
	                    push!(yListOldB, extYell[i])
	                end
	                for i = outInd:length(xListNom)
	                    push!(xListOldA, xListNom[i])
	                    push!(yListOldA, yListNom[i])
	                    push!(xListOldB, xListNom[i])                        
	                    push!(yListOldB, yListNom[i])
	                end
	            end
	            ## find which rerouted distance is shorter and use that distance
	            distanceA = 0.
	            distanceB = 0.
	            for i = 1:(length(xListOldA)-1)
	                dist = ((xListOldA[i]-xListOldA[i+1])^2+(yListOldA[i]-yListOldA[i+1])^2)^.5
	                distanceA = dist + distanceA
	            end
	            for i = 1:(length(xListOldB)-1)
	                dist = ((xListOldB[i]-xListOldB[i+1])^2+(yListOldB[i]-yListOldB[i+1])^2)^.5
	                distanceB = dist + distanceB
	            end
	            if distanceA <= distanceB
	                push!(distListOld, distanceA)
	                for i = 1:(length(xListOldA)-1)
	                    ## check if goes into an unsafe region
	                    phiDeg = atan2((yListOldA[i+1]-yListOldA[i]),(xListOldA[i+1]-xListOldA[i]))
	                    if distanceReward(problem,State(xListOldA[i], yListOldA[i], phiDeg, k, 0.)) < 0.
	                        unsafeZoneOld = unsafeZoneOld + 1
	                    end
	                end
	            else
	                push!(distListOld, distanceB)
	                for i = 1:(length(xListOldB)-1)
	                    ## check if it goes in an unsafe region
	                    phiDeg = atan2((yListOldB[i+1]-yListOldB[i]),(xListOldB[i+1]-xListOldB[i]))
	                    if distanceReward(problem,State(xListOldB[i], yListOldB[i], phiDeg, k, 0.)) < 0.
	                        unsafeZoneOld = unsafeZoneOld + 1
	                    end
	                end
	            end
	            if unsafeZoneOld >= 1
	                countUnsafeOld = countUnsafeOld + 1
	            end
	        end
	        ## add values to result lists
	        push!(avgOldDist, mean(distListOld))
	        push!(oldNumR, length(distListOld))
	        push!(oldThru, countUnsafeOld)
	    end
	    ## add to final lists to weight and then display
	    push!(finalAvgOldDist,mean(avgOldDist))
	    push!(finalOldNumR,sum(oldNumR))
	    push!(finalOldThru,sum(oldThru))
	end
	println()
	println("RESULTS:")
	##       weight and output results       ##
	###########################################
	FINALAvgOldDist = sum(finalAvgOldDist.*weight)
	FINALOldNumR = sum(finalOldNumR.*weight)
	FINALOldThru = sum(finalOldThru.*weight)
	println("weighted number histrically rerouted")
	println(round(FINALOldNumR,2))
	println("% historically rerouted")
	println(round(FINALOldNumR*100/flightUni,2))
	println("average weighted historic distance")
	println(round(FINALAvgOldDist,2))
	println("average added historic distance")
	println(round(FINALAvgOldDist-distNom,2))
	println("weighted number historically traverse 10x safety region")
	println(round(FINALOldThru,2))
	println("percent historically traverse 10x safety  region")
	println(round(FINALOldThru/flightUni,2))
end

##          proposed simulation          ##
###########################################
function proposed(problem, h, xArray, yArray, nameArray, xEllipse, yEllipse, weight, distNom)
	##      Setup final result vectors       ##
	###########################################
	## list of average distance traveled
	avgDistFinal = Float64[]
	## number of flights rerouted
	numRFinal = Float64[]
	## number of flights traverse 10X safety threshold
	thruFinal = Float64[]
	## k is the time of anomaly, -1 means no anomaly
	@showprogress 1 "Computing..." for k = -1:10 
		sleep(0.1)
	    ## list of average distance traveled
	    avgNewDistFinal = Float64[]
	    ## number of flights rerouted
	    newR = Float64[]
	    ## number of flights traverse 10X safety threshold
	    newThru = Float64[]
	    ## L denotes which flight in array of flight data
	    for L = 1.:length(xArray)
	        ## initialize x positions, y positions, and positions in flight L trajectory
	        x = xArray[L]
	        y = yArray[L]
	        numPositions = length(x)
	        ## define or reset distance list, count rerouted, count thru 10X safety threshold
	        distList = Float64[]
	        countR = 0.
	        countThru = 0.
	        ## j denotes offset time
	        for j = 1.:100.
	            ## clear or define xList and yList which defines proposed trajectories
	            xList = Float64[]
	            yList = Float64[]
	            ## proposed trajectory starts at first position of nominal trajectory
	            ## checked that all start outside of historic safety regions
	            push!(xList,x[1])
	            push!(yList,y[1])
	            ## define or reset when flight is rerouted or in 10X safety threshold
	            actList = Float64[]
	            inZone = Float64[]
	            ## reset position (only continue to simulate when additional positions to visit)
	            position = 1
	            ## t denotes possible time steps, 1000 makes sure it completes the trajectory 
	            ## but the terminates when no more positions to visit
	            for t = 1:1000
	                ## find desired heading
	                radDes = atan2((y[position+1]-yList[t]), (x[position+1]-xList[t]))
	                phiDes = unwrap_rad(radDes)
	                phiDegDes = phiDes*180/pi
	                ## find current heading
	                if t > 1
	                    rad = atan2((yList[t]-yList[t-1]), (xList[t]-xList[t-1]))
	                    phi = unwrap_rad(rad)
	                    phiDeg = phi*180/pi
	                else 
	                    rad = radDes
	                    phi = phiDes
	                    phiDeg = phiDegDes
	                end
	                ## set time remaining with offset
	                timeRemaining = 81 - t + j
	                ## only have actions for state space
	                if timeRemaining < 0 || timeRemaining > 81
	                    act = 1
	                else
	                    act = action(problem, h, [xList[t], yList[t], phiDeg, k, timeRemaining])
	                end
	                ## act == 1 means NIL and simulated to continue on same heading
	                if act == 1
	                    if abs(phiDegDes - phiDeg)>30.1
	                        if abs(phiDeg+30-phiDegDes) > abs(phiDeg-30-phiDegDes)
	                            phiDeg = phiDeg-30
	                            phi = phiDeg*pi/180
	                        else
	                            phiDeg = phiDeg+30
	                            phi = phiDeg*pi/180
	                        end
	                    end
	                    speeds = directionSpeedsRad(problem.acSpeed, phi)
	                else 
	                    speeds = directionSpeedsDeg(problem.acSpeed, phiDeg+problem.actionArray[act].head)
	                end
	                ## update list of rerouted
	                if act != 1
	                    push!(actList, 1.)
	                end
	                ## update list of in 10X safety threshold
	                if distanceReward(problem, State(xList[t], yList[t], phiDeg, k, timeRemaining)) < 0.
	                    push!(inZone, 1.)
	                end
	                # add the next position to xList and yList based on selected heading
	                push!(xList, xList[t]+speeds[1])
	                push!(yList, yList[t]+speeds[2])
	                # find next way-point and see if past all available way-points
	                radNew = atan2((yList[t+1] - y[position+1]), (xList[t+1] - x[position+1]))
	                phiNew = unwrap_rad(radNew)
	                if sign(phi) == sign(phiNew)
	                    position = position + 1
	                    if position + 1 > numPositions
	                        break
	                    end
	                    # extra check
	                    radNewNew = atan2((yList[t+1] - y[position+1]), (xList[t+1] - x[position+1]))
	                    phiNewNew = unwrap_rad(radNew)
	                    if sign(phi) == sign(phiNewNew)
	                        position = position + 1
	                        if position + 1 > numPositions
	                            break
	                        end 
	                    end ## end of extra check
	                end ## end of check
	            end ## end of t, one flight path iteration for one time of anomaly and offset
	            ## update count of rerouted flights
	            if length(actList) >= 1
	                countR = countR + 1
	            end
	            ## update count of flights thru 10X safety threshold
	            if length(inZone) >= 1
	                countThru = countThru + 1
	            end
	            ## update distance list
	            distance = 0.
	            for i = 1:(length(xList)-1)
	                dist = ((xList[i]-xList[i+1])^2+(yList[i]-yList[i+1])^2)^.5
	                distance = dist + distance
	            end
	            push!(distList, distance)
	        end ## end of offset
	        ## push results
	        push!(avgNewDistFinal, mean(distList))
	        push!(newR, countR)
	        push!(newThru, countThru)  
	    end ## end of flight
	    ## push to result arrays for likelihood weighting
	    push!(avgDistFinal,mean(avgNewDistFinal))
	    push!(numRFinal,sum(newR))
	    push!(thruFinal,sum(newThru))
	end ## end of time of anomaly
	println()
	println("RESULTS:")
	##       weight and output results       ##
	###########################################
	FINALAvgNewDist = sum(avgDistFinal.*weight)
	FINALNewR = sum(numRFinal.*weight)
	FINALNewThru = sum(thruFinal.*weight)
	println("weighted number proposed rerouted")
	println(round(FINALNewR,2))
	println("% proposed rerouted")
	println(round(FINALNewR*100/flightNum,2))
	println("average weighted proposed distance")
	println(round(FINALAvgNewDist,2))
	println("average added proposed distance")
	println(round(FINALAvgNewDist-distNom,2))
	println("weighted number proposed traverse 10x safety region")
	println(round(FINALNewThru,2))
	println("percent propsed traverse 10x safety  region")
	println(round(FINALNewThru/flightUni,2))
end




