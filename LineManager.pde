class LineManager implements Runnable {

  ArrayList<PVector[]> connectedLinesPairs = new ArrayList<>();

  boolean[] connectFloorToFrame = new boolean[1]; // not to be used in presets
  boolean[] connectFloorToFloor = new boolean[1]; // not to be used in presets

  float[] randomLineHeight = new float[1];
  float[] randomLineWidth = new float[1];
  float[] randomDLineAngle = new float[1];
  float[] randomNonDLineAngle = new float[1];
  float[] randomFloorAngle = new float[1];

  boolean isFloorsGenerationComplete;

  LineManager() {
    setRandomValues();
    isFloorsGenerationComplete = false;
    lines = new CopyOnWriteArrayList<Line>();

    createFrameForProgram();
    if (settings.addFrames[0]) createFrames();
    if (settings.addFloors[0]) {

      createFloorsAsync();

      // Check if floor generation is complete before starting lines
      new Thread(() -> {
        while (!isFloorsGenerationComplete) {
          // Wait until floors are complete
          try {
            Thread.sleep(50);
          }
          catch (InterruptedException e) { /* handle */
          }
        }
        if (noOfLines > 0) createLinesAsync();
      }
      ).start();
    } else if (noOfLines > 0) createLinesAsync();
    if (settings.addBackground[0]) addBackground("BG Pattern 01");
  }

  // Method to start the asynchronous generation of floors
  void createFloorsAsync() {
    Thread floorGenerationThread = new Thread(() -> runFloors()); // Create a thread for floors using lambda
    floorGenerationThread.start(); // Start the thread to run the floor generation in the background
  }

  // This method will handle the floor creation logic in a separate thread
  void runFloors() {
    println("Starting floor generation.");
    isProcessingLines = true;  // Indicate floor processing has started
    int loopLimitForEachLine = 1000;
    int numOfTimesLoopLimitReached = 0;

    int numOfFloors = (int)Math.floor(settings.numOfFloors[0]);

    for (int i = 0; i < numOfFloors && isProcessingLines; ) {


      for (int j = 0; j < loopLimitForEachLine && isProcessingLines; j++) {

        boolean[] result = determineEvent(settings.chancesForFloorsToConnectWithFrames[0], settings.chancesForFloorsAndFloorsToConnect[0]);
        connectFloorToFrame[0] = result[0] && (settings.connectFloorUp[0] || settings.connectFloorRight[0] || settings.connectFloorDown[0] || settings.connectFloorLeft[0]) && settings.addFrames[0];
        connectFloorToFloor[0] = result[1];
        generateBtnManager.updateStatus(i, (int) numOfFloors, j, loopLimitForEachLine, numOfTimesLoopLimitReached, true);

        float x, y, w, h, a;
        boolean addLine = true;

        x = random(startOfWidth, endOfWidth);
        y = random(startOfHeight, endOfHeight);

        w = random(settings.minFloorWidth[0], settings.maxFloorWidth[0]);
        h = settings.floorHeight[0];

        a = getFloorAngle();

        Line newLine = new Line(x, y, w, h, a, false);
        newLine.setAsFloor();

        if ((connectFloorToFloor[0] && existsFloorLine(lines)) || connectFloorToFrame[0]) {
          connectCornerToAnExistingLine(newLine);
        }

        if (isTooCloseToOtherLines(newLine) || isLineOutOfFrame(newLine)) {
          addLine = false;
        }

        if (addLine) {
          //synchronized (lines) { // Synchronize access to shared resource
          lines.add(newLine);
          //}
          i++;
          break;
        }

        int size = 0;
        if (j == loopLimitForEachLine - 1) {
          numOfTimesLoopLimitReached++;
          //synchronized (lines) { // Synchronize access to shared resource
          size = lines.size();
          if (i > 0 && size > 0)
            lines.subList(size - i, size).clear();
          i = 0;
          //}
          break;
        }
      }
    }
    moveLinesForwardOrBackward();
    if (settings.addNoPhysicsLineDuplicates[0]) duplicateAndScaleDownLines(lines);
    if (!settings.addFrames[0]) extendLinesAboveRoof(findLinesCrossingYEqualsZero(lines));


    isProcessingLines = false;  // Indicate floor processing is complete
    isFloorsGenerationComplete = true; // Set flag when done

    println("Floor generation complete.");
  }

  // Method to start the asynchronous generation of lines
  void createLinesAsync() {
    Thread lineGenerationThread = new Thread(this);
    lineGenerationThread.start();
  }

  // This is the method that will be called in a separate thread
  @Override
    public void run() {
    isProcessingLines = true;
    int loopLimitForEachLine = 2000;
    int numOfTimesLoopLimitReached = 0;

    println("Starting line generation...");


    int i = 0;

    if (!clearExistingLines) {
      i = countNonFloorAndNonFrameLines();
      println("countNonFloorAndNonFrameLines = " + countNonFloorAndNonFrameLines());
    }
    for (i = i; i < noOfLines && isProcessingLines; ) {

      println("i in loop: " + i);
      for (int j = 0; j < loopLimitForEachLine && isProcessingLines; j++) {
        generateBtnManager.updateStatus(i, noOfLines, j, loopLimitForEachLine, numOfTimesLoopLimitReached, false);

        boolean lineAdded = generateRandomLine();
        if (lineAdded) {
          i++;
          break;
        }
        int size = 0;
        if (j == loopLimitForEachLine - 1) {
          numOfTimesLoopLimitReached++;
          //synchronized (lines) {
          size = lines.size();
          println ("line size in loop: " + size);
          if (i > 0 && size > 0) clearLines();
            //lines.subList(size - i, size).clear();
          i = 0;
          //}
        }
      }
    }
    moveLinesForwardOrBackward();
    if (settings.addNoPhysicsLineDuplicates[0]) duplicateAndScaleDownLines(lines);
    if (!settings.addFrames[0]) extendLinesAboveRoof(findLinesCrossingYEqualsZero(lines));

    isProcessingLines = false;
    println("Line generation complete.");
  }

  void removeBgLines() {
    List<Line> linesToRemove = new ArrayList<>();

    for (Line line : lines) {
      if (line.isBgLine) {
        linesToRemove.add(line);
      }
    }

    lines.removeAll(linesToRemove);  // Remove all collected lines
  }


  boolean generateRandomLine() {

    //println("in generate rnd lines: " + ++counterForTrackingControl);

    float x, y, w, h, a;
    boolean isDeath;
    boolean lineAdded = false;

    // Randomly determine if the line is a death line
    isDeath = random(1) < settings.chancesOfDeath[0];

    x = random(startOfWidth, endOfWidth);
    y = random(startOfHeight, endOfHeight);
    w = getWidthOfLine();
    h = getHeightOfLine();
    a = getLineAngle(isDeath);

    Line newLine = new Line(x, y, w, h, a, isDeath);

    if (!isDeath && random(1) < settings.chancesOfNoJump[0]) newLine.setAsNoJump();

    connectCornerToAnExistingLine(newLine);
    //println("isoutofframe: " + isLineOutOfFrame(newLine));

    if (!isTooCloseToOtherLines(newLine) && !isLineOutOfFrame(newLine)) {
      //synchronized (lines) {
      lines.add(newLine);
      //}
      lineAdded = true;
    }

    return lineAdded;
  }

  boolean isTooCloseToOtherLines(Line newLine) {
    //println("counterForIsTooClose: " + counterForIsTooClose++);

    for (Line existingLine : lines) {
      if (existingLine.noPhysics) continue;

      //  println("in isTooCloseToOtherLines: " + ++counterForTrackingControl);
      //  println("length of 'lines': " + lines.size());


      if (areLinesConnected(existingLine, newLine)) continue;

      if (!settings.canLinesOverlap[0]) {
        if (isOverlapping(newLine, existingLine)) {
          //println("is overlapping: " + counterForOverlap++);
          return true;
        }
      }

      if (existingLine.isFrame) {
        if (newLine.isFloor & distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwFloorsAndFrames[0]) {
          return true;
        } else if (!newLine.isFloor && !newLine.isDeath && distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwNonDLinesAndFrames[0]) {
          return true;
        } else if (!newLine.isFloor && newLine.isDeath && distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwDLinesAndFrames[0]) {
          return true;
        }
      } else if (existingLine.isFloor) {

        if (newLine.isFloor) {
          if ((distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwFloors[0])) {
            //println("should not bw here2");
            return true;
          }
        } else if (newLine.isDeath) {
          if ((distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwDLinesAndFloors[0])) {
            //println("should not bw here3");
            return true;
          }
        } else if (!newLine.isDeath) {
          if ((distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwNonDLinesAndFloors[0])) {
            //println("should not bw here4");
            return true;
          }
        }
      } else { // If existingLine is neither a frame or a floor

        if ((!newLine.isDeath && existingLine.isDeath) || (newLine.isDeath && !existingLine.isDeath)) {
          if (distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwNonDLinesAndDLines[0]) {
            //println("should not bw here5");
            return true;
          }
        }

        if (newLine.isDeath) {
          if (distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwDLines[0]) {
            //println("should not bw here6");
            return true;
          }
        } else if (!newLine.isDeath && !existingLine.isDeath) {
          //println("should be here1");
          if (distanceBetweenLines(newLine, existingLine) < settings.minDistanceBtwNonDLines[0]) {
            //println("should be here2 (returning true)");
            return true;
          }
        }
      }
    }
    //println("returning false");
    return false;
  }

  boolean areLinesConnected(Line existingLine, Line newLine) {
    for (PVector[] pair : connectedLinesPairs) {
      if (isSamePair(pair, existingLine, newLine)) {
        return true;
      }
    }
    return false;
  }

  boolean isSamePair(PVector[] pair, Line line1, Line line2) {
    return (pair[0].x == line1.centerX && pair[0].y == line1.centerY &&
      pair[1].x == line2.centerX && pair[1].y == line2.centerY) ||
      (pair[0].x == line2.centerX && pair[0].y == line2.centerY &&
      pair[1].x == line1.centerX && pair[1].y == line1.centerY);
  }


  boolean isOverlapping(Line line1, Line line2) {
    // Get the corners of both lines
    PVector[] corners1 = line1.getCorners();
    PVector[] corners2 = line2.getCorners();

    // Get the axes to test (normals of the edges of both rectangles)
    PVector[] axes = new PVector[4];
    axes[0] = PVector.sub(corners1[1], corners1[0]).normalize(); // Line 1 edge 1
    axes[1] = PVector.sub(corners1[2], corners1[1]).normalize(); // Line 1 edge 2
    axes[2] = PVector.sub(corners2[1], corners2[0]).normalize(); // Line 2 edge 1
    axes[3] = PVector.sub(corners2[2], corners2[1]).normalize(); // Line 2 edge 2

    // Loop through all axes
    for (int i = 0; i < 4; i++) {
      // Project both rectangles onto the axis
      float[] projection1 = projectOntoAxis(corners1, axes[i]);
      float[] projection2 = projectOntoAxis(corners2, axes[i]);

      // Check for a gap between the projections
      if (projection1[1] < projection2[0] || projection2[1] < projection1[0]) {
        return false; // Found a gap, so no overlap
      }
    }

    // If no gaps are found, the rectangles overlap
    return true;
  }

  float[] projectOntoAxis(PVector[] corners, PVector axis) {
    float min = PVector.dot(corners[0], axis);
    float max = min;

    // Loop through all corners and project them onto the axis
    for (int i = 1; i < corners.length; i++) {
      float projection = PVector.dot(corners[i], axis);
      if (projection < min) {
        min = projection;
      }
      if (projection > max) {
        max = projection;
      }
    }

    return new float[]{min, max}; // Return the min and max projections
  }

  float distanceBetweenLines(Line l1, Line l2) {
    // Number of points to sample along each line
    int numSamples = 100;

    // Generate points along the first line
    PVector[] pointsOnL1 = generatePointsAlongLine(l1, numSamples);
    // Generate points along the second line
    PVector[] pointsOnL2 = generatePointsAlongLine(l2, numSamples);

    float minDistance = Float.MAX_VALUE;

    // Calculate the minimum distance between all points on l1 and l2
    for (PVector p1 : pointsOnL1) {
      for (PVector p2 : pointsOnL2) {
        float distance = PVector.dist(p1, p2);
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
    }
    return minDistance;
  }

  PVector[] generatePointsAlongLine(Line line, int numSamplesPerEdge) {
    PVector[] corners = line.getCorners();
    ArrayList<PVector> points = new ArrayList<>();

    // For each edge (from corner[i] to corner[(i+1)%4]), interpolate points
    for (int i = 0; i < 4; i++) {
      PVector start = corners[i];
      PVector end = corners[(i + 1) % 4];

      for (int j = 0; j < numSamplesPerEdge; j++) {
        float t = map(j, 0, numSamplesPerEdge - 1, 0, 1);
        points.add(PVector.lerp(start, end, t));
      }
    }

    return points.toArray(new PVector[0]);
  }

  void connectCornerToAnExistingLine(Line lineToMove) {

    float[] lineConnectAngleStart = settings.lineConnectAngleStart;
    float[] lineConnectAngleEnd = settings.lineConnectAngleEnd;

    while (true) {
      //println("in connectCornerToAnExistingLine: " + ++counterForTrackingControl);
      Line lineToConnectWith = chooseLineToConnectWith(lineToMove, connectFloorToFrame[0], connectFloorToFloor[0]);

      if (lineToConnectWith == null) return;

      updateLineAngle(lineToMove, lineToConnectWith, lineConnectAngleStart, lineConnectAngleEnd);

      PVector randomPoint = getRandomPointOnLine(lineToConnectWith, lineToMove);
      if (isPointWithinCanvas(randomPoint)) {
        moveLineToTouch(lineToMove, randomPoint, lineToConnectWith);
        addConnectedLinePair(lineToMove, lineToConnectWith);
        break;
      }
    }
  }

  Line chooseLineToConnectWith(Line lineToMove, boolean connectFloorToFrame, boolean connectFloorToFloor) {

    ArrayList<Integer> lineToConnectWithIds = new ArrayList<>(); // To keep track of which lineToConnectWiths have already been checked for the given lineToMove
    Line lineToConnectWith;
    int numOfPhysicsLines = getPhysicsShapesSize(lines);

    for (int i = 0; i < numOfPhysicsLines; ) {

      //println("in chooseLineToConnectWith: " + ++counterForTrackingControl);

      do {
        lineToConnectWith = lines.get((int) random(lines.size()));
      } while (lineToConnectWith.noPhysics);

      if (lineToConnectWithIds.contains(lineToConnectWith.id)) {
        //println("lineToConnectWithIds.contains(lineToConnectWith.id");
        continue; // Skip this candidateLine and don't increment i
      }

      lineToConnectWithIds.add(lineToConnectWith.id); // Add the ID to the list of chosen lines

      if (lineToMove.isFloor) {

        //println("lineToMove.isFloor");

        if (connectFloorToFrame && lineToConnectWith.isFrame && connectToThisSpecificFrame(lineToConnectWith)) {
          return lineToConnectWith;
        }

        if (connectFloorToFloor && lineToConnectWith.isFloor) {
          return lineToConnectWith;
        }
      } else if (!lineToMove.isFloor && lineToConnectWith.isFrame) {

        if (lineToMove.isDeath && random(1) < settings.chancesForDLinesToConnectWithFrames[0]) {
          return lineToConnectWith;
        }
        if (!lineToMove.isDeath && random(1) < settings.chancesForNonDLinesToConnectWithFrames[0]) {
          return lineToConnectWith;
        }
      } else if (!lineToMove.isFloor && !lineToConnectWith.isFrame) {


        if (connectNonDLinesAndDlines(lineToConnectWith, lineToMove)) { // lineToMove is either death or non-death

          return lineToConnectWith;
        }
        if (lineToMove.isDeath) {
          //println("lineToMove.isDeath");
          boolean[] result =  new boolean[2];
          boolean connectDLinesWithFloor = false;
          boolean connectDLinesWithDLines = false;

          if (settings.addFloors[0] && settings.numOfFloors[0] > 0) {
            result = determineEvent(settings.chancesForDLinesToConnectWithFloors[0], settings.chancesForDLinesAndDLinesToConnect[0]);
            connectDLinesWithDLines = result[1];
          } else
            connectDLinesWithDLines = settings.chancesForDLinesAndDLinesToConnect[0] > random(1);

          connectDLinesWithFloor = result[0];

          if (lineToConnectWith.isFloor && connectDLinesWithFloor) {
            //println("lineToConnectWith.isFloor && connectDLinesWithFloor");
            return lineToConnectWith;
          }
          if (!lineToConnectWith.isFloor && lineToConnectWith.isDeath && connectDLinesWithDLines) {
            //println("!lineToConnectWith.isFloor && lineToConnectWith.isDeath && connectDLinesWithDLines");
            return lineToConnectWith;
          }
        } else if (!lineToMove.isDeath) {
          //println("!lineToMove.isDeath");

          boolean[] result =  new boolean[2];
          boolean connectNonDLinesWithFloor = false;
          boolean connectNonDLinesWithNonDLines = false;

          if (settings.addFloors[0] && settings.numOfFloors[0] > 0) {

            result = determineEvent(settings.chancesForNonDLinesToConnectWithFloors[0], settings.chancesForNonDLinesAndNonDLinesToConnect[0]);
            connectNonDLinesWithNonDLines = result[1];
          } else
            connectNonDLinesWithNonDLines = settings.chancesForNonDLinesAndNonDLinesToConnect[0] > random(1);

          connectNonDLinesWithFloor = result[0];

          if (lineToConnectWith.isFloor && connectNonDLinesWithFloor) {
            //println("lineToConnectWith.isFloor && connectNonDLinesWithFloor");
            return lineToConnectWith;
          }
          if (!lineToConnectWith.isFloor && !lineToConnectWith.isDeath && connectNonDLinesWithNonDLines) {
            //println("!lineToConnectWith.isFloor && !lineToConnectWith.isDeath && connectNonDLinesWithNonDLines");
            return lineToConnectWith;
          }
        }
      }
      i++;
    }
    //println("returning null from chooseLineToConnectWith");
    return null;
  }

  boolean connectNonDLinesAndDlines(Line lineToConnectWith, Line lineToMove) {

    if ((lineToConnectWith.isDeath && !lineToMove.isDeath) || (!lineToConnectWith.isDeath && lineToMove.isDeath)) { // both can't have same death status

      if (!lineToConnectWith.isFloor && !lineToConnectWith.isFrame && random(1) < settings.chancesForDLinesAndNonDLinesToConnect[0]) { // lineToMove is either death or non-death

        return true;
      }
    }
    return false;
  }
  boolean connectToThisSpecificFrame(Line lineToConnectWith) {
    return (settings.connectFloorUp[0] && lineToConnectWith.centerY == startOfHeight) ||
      (settings.connectFloorRight[0] && lineToConnectWith.centerX == endOfWidth) ||
      (settings.connectFloorDown[0] && lineToConnectWith.centerY == endOfHeight) ||
      (settings.connectFloorLeft[0] && lineToConnectWith.centerX == startOfWidth);
  }

  void updateLineAngle(Line lineToMove, Line lineToConnectWith, float[] lineConnectAngleStart, float[] lineConnectAngleEnd) {
    if (lineToMove.isFloor && settings.limitFloorAngleAfterConnect[0]) {

      float tempFloorConnectAngleStart = settings.floorConnectAngleStart[0];
      float tempFloorConnectAngleEnd = settings.floorConnectAngleEnd[0];

      if (lineToConnectWith.isFrame) { // used because otherwise floors can connect to floor but extend in the outwards direction of the frame

        float midpointX = (startOfWidth + endOfWidth) / 2;
        float midpointY = (startOfHeight + endOfHeight) / 2;

        //Left Frame
        if (lineToConnectWith.centerX < midpointX) {
          tempFloorConnectAngleStart = constrainAngleToRange(settings.floorConnectAngleStart[0], 0, 180);
          tempFloorConnectAngleEnd = constrainAngleToRange(settings.floorConnectAngleEnd[0], 0, 180);
        }

        // Right Frame
        if (lineToConnectWith.centerX > midpointX) {
          tempFloorConnectAngleStart = constrainAngleToRange(settings.floorConnectAngleStart[0], 180, 360);
          tempFloorConnectAngleEnd = constrainAngleToRange(settings.floorConnectAngleEnd[0], 180, 360);
        }

        // Ceiling Frame
        if (lineToConnectWith.centerY < midpointY) {
          tempFloorConnectAngleStart = constrainAngleToRange(settings.floorConnectAngleStart[0], 180, 360);
          tempFloorConnectAngleEnd = constrainAngleToRange(settings.floorConnectAngleEnd[0], 180, 360);
        }

        // Floor Frame
        if (lineToConnectWith.centerY > midpointY) {
          tempFloorConnectAngleStart = constrainAngleToRange(settings.floorConnectAngleStart[0], 0, 180);
          tempFloorConnectAngleEnd = constrainAngleToRange(settings.floorConnectAngleEnd[0], 0, 180);
        }
      }
      lineToMove.angle = getRandomAngle(lineToConnectWith.angle, tempFloorConnectAngleStart, tempFloorConnectAngleEnd);
    } else if (!lineToMove.isFloor && settings.limitLineAngleAfterConnectingItsCorner[0]) {
      lineToMove.angle = getRandomAngle(lineToConnectWith.angle, lineConnectAngleStart[0], lineConnectAngleEnd[0]);
    }
  }

  float constrainAngleToRange(float angle, float minRange, float maxRange) {
    if (minRange == 180 && maxRange == 360) {
      if (angle >= 0 && angle <= 180) {
        return angle + 180; // Shift [0, 180) to [180, 360]
      } else {
        return angle; // Direct mapping for [180, 360]
      }
    }

    return angle; // Fallback, should not reach here
  }


  float getRandomAngle(float chosenAngle, float angleStart, float angleEnd) {
    //return random(1) < 0.5 ? random(chosenAngle + angleStart, chosenAngle + angleEnd) : random(chosenAngle - angleEnd, chosenAngle - angleStart);
    return random(chosenAngle + angleStart, chosenAngle + angleEnd);
  }

  float getPointOfConnection(Line lineToConnectWith, Line lineToMove) {

    boolean[] connectDLinesAtCorner = new boolean[1];
    connectDLinesAtCorner[0] = random(1) < settings.chancesForDLinesToConnectAtCorner[0];

    boolean[] connectNonDLinesAtCorner = new boolean[1];
    connectNonDLinesAtCorner[0] = random(1) < settings.chancesForNonDLinesToConnectAtCorner[0];

    boolean[] connectDLinesAndFloorsAtCorner = new boolean[1];
    connectDLinesAndFloorsAtCorner[0] = random(1) < settings.chancesForDLinesAndFloorsToConnectAtCorner[0];

    boolean[] connectNonDLinesAndFloorsAtCorner = new boolean[1];
    connectNonDLinesAndFloorsAtCorner[0] = random(1) < settings.chancesForNonDLinesAndFloorsToConnectAtCorner[0];

    boolean[] connectDLinesAndNonDLinesAtCorner = new boolean[1];
    connectDLinesAndNonDLinesAtCorner[0] = random(1) < settings.chancesForDLinesAndNonDLinesToConnectAtCorner[0];

    boolean[] connectFloorsAtCorner = new boolean[1];
    connectFloorsAtCorner[0] = random(1) < settings.chancesForFloorsToConnectAtCorner[0];

    boolean isPointAtCorner = false;
    float t = 0;
    float minLength = lineToMove.width < lineToMove.height ? lineToMove.width : lineToMove.height;
    float buffer = minLength / 1.8;
    //float buffer = 0;

    if (!lineToConnectWith.isFrame && !lineToMove.isFrame) {

      if (!lineToConnectWith.isFloor && !lineToMove.isFloor) {

        if ((lineToConnectWith.isDeath && lineToMove.isDeath) && connectDLinesAtCorner[0] ||
          (!lineToConnectWith.isDeath && !lineToMove.isDeath) && connectNonDLinesAtCorner[0] ||
          ((lineToConnectWith.isDeath && !lineToMove.isDeath) || (!lineToConnectWith.isDeath && lineToMove.isDeath)) && connectDLinesAndNonDLinesAtCorner[0]) {
          isPointAtCorner = true;
        }
      } else if (((lineToConnectWith.isFloor && lineToMove.isDeath) || (lineToConnectWith.isDeath && lineToMove.isFloor)) && connectDLinesAndFloorsAtCorner[0] ||
        ((lineToConnectWith.isFloor && !lineToMove.isFloor) || (!lineToConnectWith.isFloor && lineToMove.isFloor)) && connectNonDLinesAndFloorsAtCorner[0] ||
        (lineToConnectWith.isFloor && lineToMove.isFloor) && connectFloorsAtCorner[0]) {
        isPointAtCorner = true;
      }
    }
    if (isPointAtCorner) {
      if (random(1) < 0.5) // randommly choose one corner
        t = buffer / lineToConnectWith.width;
      else
        t = 1 - buffer / lineToConnectWith.width;
    } else
      t = random(buffer / lineToConnectWith.width, 1 - buffer / lineToConnectWith.width);

    return t;
  }

  PVector getRandomPointOnLine(Line lineToConnectWith, Line lineToMove) {

    PVector[] edgePoints = lineToConnectWith.getEdgePoints(false);
    float t = getPointOfConnection(lineToConnectWith, lineToMove);
    return new PVector(edgePoints[0].x + t * (edgePoints[1].x - edgePoints[0].x),
      edgePoints[0].y + t * (edgePoints[1].y - edgePoints[0].y));
  }

  boolean isPointWithinCanvas(PVector point) {
    return point.x >= startOfWidth && point.x <= endOfWidth && point.y >= startOfHeight && point.y <= endOfHeight;
  }

  void moveLineToTouch(Line lineToMove, PVector randomPoint, Line lineToConnectWith) {
    PVector[] moveEdgePoints = lineToMove.getEdgePoints(true);
    boolean tryFirstEdgePoint = true;

    // Used to add some distance to identify the edge point of lineToMove that won't cause an
    // overlap after connection.
    float distanceBtwLineToMoveAndRndPoint = 0.1;
    float origonalLineToMoveXPos = lineToMove.centerX;
    float origonalLineToMoveYPos = lineToMove.centerY;

    for (int j = 0; j < 2; j++) {
      distanceBtwLineToMoveAndRndPoint *= -1;
      //for (int i = moveEdgePoints.length - 1; i >= 0; i--) { // these two for loops each fails under different conditions
      for (int i = 0; i <= moveEdgePoints.length - 3; i++) {

        //println("distanceBtwLineToMoveAndRndPoint: " + distanceBtwLineToMoveAndRndPoint);
        //println("tryFirstEdgePoint: " + tryFirstEdgePoint);

        lineToMove.centerX = origonalLineToMoveXPos;
        lineToMove.centerY = origonalLineToMoveYPos;
        PVector moveVector = new PVector(0, 0);
        moveVector = PVector.sub(randomPoint, moveEdgePoints[i]);

        // Adjust the length of the vector to maintain the specified distance
        if (moveVector.mag() > distanceBtwLineToMoveAndRndPoint) {
          moveVector.setMag(moveVector.mag() + distanceBtwLineToMoveAndRndPoint); // Set the magnitude to the desired distance
        } else {
          moveVector.setMag(distanceBtwLineToMoveAndRndPoint); // Keep distance even if the point is already within the range
        }

        // In case the line is angled
        PVector newCenter = new PVector(lineToMove.centerX + moveVector.x, lineToMove.centerY + moveVector.y);
        lineToMove.centerX = newCenter.x;
        lineToMove.centerY = newCenter.y;

        if (isOverlapping(lineToMove, lineToConnectWith)) {
          //tryFirstEdgePoint = !tryFirstEdgePoint;
          //println("Error in iteration (j = " + j + ", i = " + i +") : Lines are overlapping after connecting.");
          //if (j == 1 && i == 1)
          // ellipse(lineToMove.centerX + 100, lineToMove.centerY + 100, 100, 100);
        } else {
          //("Lines are not overlapping after connecting");
          j = 2;
          break;
        }
      }
    }
  }

  void addConnectedLinePair(Line lineToMove, Line lineToConnectWith) {
    connectedLinesPairs.add(new PVector[]{new PVector(lineToConnectWith.centerX, lineToConnectWith.centerY),
      new PVector(lineToMove.centerX, lineToMove.centerY)});
  }


  boolean existsNonDeathLine(CopyOnWriteArrayList<Line> lines) {
    for (Line line : lines) {
      if (!line.isDeath) {
        return true; // Found a non death line
      }
    }
    return false; // No non death line found
  }

  boolean existsFloorLine(CopyOnWriteArrayList<Line> lines) {
    for (Line line : lines) {
      if (line.isFloor) {
        return true; // Found a non death line
      }
    }
    return false; // No non death line found
  }

  void moveBouncyLinesToBack() {
    CopyOnWriteArrayList<Line> bouncyLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> nonDLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into death and non death
    for (Line line : lines) {
      if (line.isBouncy) {
        bouncyLines.add(line);
      } else {
        nonDLines.add(line);
      }
    }


    //synchronized (lines) {
    lines.clear();
    lines.addAll(bouncyLines);
    lines.addAll(nonDLines);
    //}
  }

  void moveDLinesToFront() {
    CopyOnWriteArrayList<Line> deathLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> nonDLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into death and non death
    for (Line line : lines) {
      if (line.isDeath) {
        deathLines.add(line);
      } else {
        nonDLines.add(line);
      }
    }

    // Clear the original list and add death lines first
    lines.clear();
    lines.addAll(nonDLines);
    lines.addAll(deathLines);
  }


  void addBackground(String patternName) {
    if (patternName.equals("BG Pattern 01")) {
      bgPattern01();
    }
    if (patternName.equals("BG Pattern 02")) {
      bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 03")) {
    }
    if (patternName.equals("BG Pattern 04")) {
      //bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 05")) {
      //bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 06")) {
      //bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 07")) {
      //bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 08")) {
      //bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 09")) {
      //bgPatternNestedSquares();
    }
    plainBg();





    //bgPatternLightning();
  }

  void plainBg() {
    Line backgroundLine = new Line(endOfWidth - startOfWidth, endOfHeight - startOfHeight, 2000, 2000, 0, false);

    int scheme = (int)random(numOfColorSchemesAvailable);
    backgroundLine.lineColor = getRandomColor(scheme);
    backgroundLine.setAsBgLine();
    lines.add(0, backgroundLine);
  }

  void bgPattern01() {
    int numBackgroundLines = (int)random(20, 40); // Random number of background lines

    int[] specificSchemes = new int[]{};

    if (settings.rndlyChooseOneSchemeForBg[0])
      specificSchemes = new int[]{(int)random(numOfColorSchemesAvailable)};

    for (int i = 1; i <= numBackgroundLines; i++) {
      // Randomize position, width, height, angle, and color
      float centerX = random(startOfWidth, endOfWidth);
      float centerY = random(startOfHeight, endOfHeight);
      float lineWidth = random(100, 400); // Random width
      float lineHeight = random(100, 400); // Random height
      float angle = random(360); // Random angle
      boolean isDeath = false; // Background lines are not death lines
      color lineColor;

      int scheme;
      if (specificSchemes.length > 0) {
        scheme = specificSchemes[(int)random(specificSchemes.length)];
      } else {
        scheme = (int)random(numOfColorSchemesAvailable); // Assuming getRandomColor has 53 cases
      }

      lineColor = getRandomColor(scheme);

      // Create the Line object for the background
      Line backgroundLines = new Line(centerX, centerY, lineWidth, lineHeight, angle, isDeath);

      // Set additional artistic properties (you can add more creative features here)
      backgroundLines.lineColor = lineColor;
      backgroundLines.setAsBgLine();

      // Add the line to the LineManager
      lines.add(0, backgroundLines);
    }
  }

  void bgPatternWithSquaresAndLines() {
    int numSquares = (int) random(1, 1);  // Number of squares
    int[] specificSchemes = new int[]{};

    if (settings.rndlyChooseOneSchemeForBg[0])
      specificSchemes = new int[]{(int) random(numOfColorSchemesAvailable)};

    // Generate squares
    for (int i = 0; i < numSquares; i++) {
      // Randomize position, size, and color of squares
      float centerX = random(startOfWidth, endOfWidth);
      float centerY = random(startOfHeight, endOfHeight);
      float squareSize = random(50, 200);  // Random size of squares

      int scheme;
      if (specificSchemes.length > 0) {
        scheme = specificSchemes[(int) random(specificSchemes.length)];
      } else {
        scheme = (int) random(numOfColorSchemesAvailable); // Random color scheme
      }
      color squareColor = getRandomColor(scheme);

      // Create the square object
      Line square = new Line(centerX, centerY, squareSize, squareSize, 0, false);
      square.lineColor = squareColor;
      square.setAsBgLine();  // Mark it as a background line
      lines.add(0, square);  // Add square to the list

      // Connect lines to the corners of the square
      float[] cornersX = new float[]{
        centerX - squareSize / 2, centerX + squareSize / 2, // Left-Right X coordinates
      };
      float[] cornersY = new float[]{
        centerY - squareSize / 2, centerY + squareSize / 2   // Top-Bottom Y coordinates
      };

      for (float x : cornersX) {
        for (float y : cornersY) {
          // Create lines from each corner of the square
          float lineLength = random(50, 300);  // Varying length of lines
          float lineAngle = random(TWO_PI);    // Random direction

          // Calculate the endpoint of the line based on the angle and length
          float endX = x + cos(lineAngle) * lineLength;
          float endY = y + sin(lineAngle) * lineLength;

          color lineColor = getRandomColor(scheme);  // Get random color for lines
          Line connectingLine = new Line(x, y, 5, endY - y, degrees(lineAngle), false);
          connectingLine.lineColor = lineColor;
          connectingLine.setAsBgLine();  // Mark as background line
          lines.add(0, connectingLine);  // Add the line to the list
        }
      }
    }
  }


  void bgPatternLightning() {
    int numBolts = (int)random(2, 5); // Number of lightning bolts
    for (int b = 0; b < numBolts; b++) {
      // Starting point at top or random x across the top
      float startX = random(startOfWidth, endOfWidth);
      float startY = startOfHeight;

      generateLightningBolt(startX, startY, random(50), (int)random(3, 3));
    }
  }

  // Recursive function to create branching lightning
  void generateLightningBolt(float x, float y, float length, int branches) {
    if (length < 10) return; // Base case to stop recursion

    // Main bolt segment
    float endX = x + random(-20, 20);
    float endY = y + length;

    float angle = atan2(endY - y, endX - x);

    Line bolt = new Line(x, y, dist(x, y, endX, endY), 1, degrees(angle), false);
    bolt.lineColor = color(255, 255, 255, 200); // Semi-transparent white
    bolt.noPhysics = true;
    lines.add(bolt);

    // Create branches
    for (int i = 0; i < branches; i++) {
      float branchLength = length * random(10);
      float branchAngle = angle + radians(random(-45, 45));
      float branchEndX = endX + cos(branchAngle) * branchLength;
      float branchEndY = endY + sin(branchAngle) * branchLength;

      Line branch = new Line(endX, endY, dist(endX, endY, branchEndX, branchEndY), 1, degrees(branchAngle), false);
      branch.lineColor = color(255, 255, 255, 150); // More transparent for branches
      branch.noPhysics = true;
      lines.add(branch);

      // Recursively add smaller branches
      generateLightningBolt(endX, endY, branchLength, branches - 1);
    }
  }


  void bgPatternNestedSquares() {
    int numLayers = (int)random(3, 6); // Number of nested square layers
    float maxSize = random (900, 1000);
    float centerX = (startOfWidth + endOfWidth) / 2;
    float centerY = (startOfHeight + endOfHeight) / 2;

    color lineColor;
    int[] specificSchemes = new int[]{};

    if (settings.rndlyChooseOneSchemeForBg[0])
      specificSchemes = new int[]{(int)random(numOfColorSchemesAvailable)};

    int scheme;
    if (specificSchemes.length > 0) {
      scheme = specificSchemes[(int)random(specificSchemes.length)];
    } else {
      scheme = (int)random(numOfColorSchemesAvailable); // Assuming getRandomColor has 53 cases
    }

    for (int l = 1; l <= numLayers; l++) {
      float size = maxSize * (1 - (float)l / (numLayers + 1));
      float angle = random(0, 360); // Align squares or rotate for variation

      Line squareLine = new Line(centerX, centerY, size, size, angle, false);

      lineColor = getRandomColor(scheme);
      squareLine.lineColor = lineColor;
      squareLine.noPhysics = true;
      squareLine.setAsBgLine();

      lines.add(l - 1, squareLine);
    }
  }


  CopyOnWriteArrayList<Line> findLinesCrossingYEqualsZero(CopyOnWriteArrayList<Line> lines) {
    CopyOnWriteArrayList<Line> crossingLines = new CopyOnWriteArrayList<Line>();

    for (Line line : lines) {
      float angle = line.angle % 360; // Normalize the angle between 0-359 degrees

      // Check if the angle is within the specified ranges

      if (((angle >= 30 && angle <= 150) || (angle >= 210 && angle <= 330)) && !line.noPhysics) {

        // Calculate the y-coordinates of the top and bottom corners of the line
        PVector[] corners = line.getCorners();

        // Check if the line crosses the y = 0 axis
        if (corners[0].y <= startOfHeight || corners[1].y <= startOfHeight || corners[2].y <= startOfHeight || corners[3].y <= startOfHeight) {

          crossingLines.add(line);
        }
      }
    }

    return crossingLines;
  }
  void extendLinesAboveRoof(CopyOnWriteArrayList<Line> crossingLines) {

    for (Line line : crossingLines) {

      //println("in extndlinesabveroof: " + counterForTrackingControl);

      PVector[] corners = line.getCorners();

      // Find the topmost corner
      PVector topmostCorner = corners[0];
      for (int i = 1; i < corners.length; i++) {
        if (corners[i].y < topmostCorner.y) {
          topmostCorner = corners[i];
        }
      }

      // Create a new line starting from the topmost corner, extending upwards
      float newLineWidth = 5;
      float newLineHeight = 1000;

      Line newLine = new Line(topmostCorner.x, topmostCorner.y - newLineHeight / 2, newLineWidth, newLineHeight, 0, true);
      newLine.lineColor = settings.deathColor;

      // Add the new line to the list of lines
      lines.add(newLine);
    }
  }

  void duplicateAndScaleDownLines(CopyOnWriteArrayList<Line> lines) {
    // Create a map to track the relationship between physics lines and their duplicates

    noPyhsicsDuplicateLineMap = new HashMap<>();
    CopyOnWriteArrayList<Line> duplicates = new CopyOnWriteArrayList<Line>();

    for (Line line : lines) {
      if (!line.noPhysics) {
        // Create a duplicate of the original line
        float gapBetweenOuterAndInnersEdges = line.height > line.width ? line.width * 0.2 : line.height * 0.2;
        Line duplicate = new Line(line.centerX, line.centerY, line.width - gapBetweenOuterAndInnersEdges, line.height - gapBetweenOuterAndInnersEdges, line.angle, line.isDeath);

        // Set noPhysics to true for the duplicate
        duplicate.noPhysics = true;

        // Adjust the color of the duplicate to be slightly brighter or darker
        float brightnessAdjustment = random(-200, 200);
        duplicate.lineColor = adjustBrightness(line.lineColor, brightnessAdjustment);

        // Add the duplicate to the list of duplicates
        duplicates.add(duplicate);
        noPyhsicsDuplicateLineMap.put(line, duplicate);
      }
    }

    // Add all duplicates to the original lines list
    lines.addAll(duplicates);
  }

  void createFrameForProgram() {
    // Create ceiling, walls, and floor covers
    Line ceilingCover = createFrameLineForProgram((startOfWidth + endOfWidth) / 2, startOfHeight - 500, endOfWidth - startOfWidth, 1001, 0, color(0), false);
    ceilingCover.setAsOnlyForProgram();
    lines.add(ceilingCover); // Ceiling Cover

    Line rightWallCover = createFrameLineForProgram(endOfWidth + 500, (startOfHeight + endOfHeight) / 2, 1001, endOfHeight - startOfHeight + 1000, 0, color(0), false);
    rightWallCover.setAsOnlyForProgram();
    lines.add(rightWallCover); // Right Wall Cover

    Line floorCover = createFrameLineForProgram((startOfWidth + endOfWidth) / 2, endOfHeight + 500, endOfWidth - startOfWidth, 1001, 0, color(0), false);
    floorCover.setAsOnlyForProgram();
    lines.add(floorCover); // Floor Cover

    Line leftWallCover = createFrameLineForProgram(startOfWidth - 500, (startOfHeight + endOfHeight) / 2, 1001, endOfHeight - startOfHeight + 1000, 0, color(0), false);
    leftWallCover.setAsOnlyForProgram();
    lines.add(leftWallCover); // Left Wall Cover

    boolean addYellowFrame = false;
    if (addYellowFrame) {
      // Create main ceiling, walls, and floor
      Line ceiling = createFrameLineForProgram((startOfWidth + endOfWidth) / 2, startOfHeight, endOfWidth - startOfWidth, 2, 0, color(255, 255, 0), false);
      ceiling.setAsOnlyForProgram();
      lines.add(ceiling); // Ceiling

      Line rightWall = createFrameLineForProgram(endOfWidth, (startOfHeight + endOfHeight) / 2, 2, endOfHeight - startOfHeight, 0, color(255, 255, 0), false);
      rightWall.setAsOnlyForProgram();
      lines.add(rightWall); // Right Wall

      Line floor = createFrameLineForProgram((startOfWidth + endOfWidth) / 2, endOfHeight, endOfWidth - startOfWidth, 2, 0, color(255, 255, 0), false);
      floor.setAsOnlyForProgram();
      lines.add(floor); // Floor

      Line leftWall = createFrameLineForProgram(startOfWidth, (startOfHeight + endOfHeight) / 2, 2, endOfHeight - startOfHeight, 0, color(255, 255, 0), false);
      leftWall.setAsOnlyForProgram();
      lines.add(leftWall); // Left Wall
    }
  }


  Line createFrameLineForProgram(float x, float y, float width, float height, float rotation, color lineColor, boolean isDeath) {
    Line line = new Line(x, y, width, height, rotation, isDeath);
    line.lineColor = lineColor;  // Set the color
    line.noPhysics = true;   // Disable physics
    return line;
  }


  void createFrames() {
    float frameWidth = settings.frameWidth[0];
    boolean isDeath = settings.areFramesDeath[0];

    // Create lines with common logic
    lines.add(createFrameLine((startOfWidth + endOfWidth) / 2, startOfHeight, endOfWidth - startOfWidth, frameWidth, 0, isDeath)); // Ceiling
    lines.add(createFrameLine(endOfWidth, (startOfHeight + endOfHeight) / 2, endOfHeight - startOfHeight, frameWidth, 90, isDeath)); // Right wall
    lines.add(createFrameLine((startOfWidth + endOfWidth) / 2, endOfHeight, endOfWidth - startOfWidth, frameWidth, 0, isDeath)); // Floor
    lines.add(createFrameLine(startOfWidth, (startOfHeight + endOfHeight) / 2, endOfHeight - startOfHeight, frameWidth, 90, isDeath)); // Left wall
  }

  // Helper method to create lines
  Line createFrameLine(float x, float y, float width, float height, float rotation, boolean death) {
    Line line = new Line(x, y, width, height, rotation, death);
    line.setAsFrame();
    return line;
  }

  boolean[] determineEvent(float var1, float var2) { // To choose btw two mutually exclusive events, each of which hs some probability var1 and var2
    boolean[] result = new boolean[2]; // [connectFloorToFrame, connectFloorToFloor]

    if (var1 == var2) {
      if (random(1) < 0.5) {
        if (random(1) < var1) {
          result[0] = true;
        } else {
          // Event default: both false
        }
      } else {
        if (random(1) < var2) {
          result[1] = true; // Event B
        } else {
          // Event default: both false
        }
      }
    } else if (var1 == 1) {
      result[0] = true;
    } else if (var2 == 1) {
      result[1] = true;
    } else if (var1 == 0) {
      if (random(1) < var2) {
        result[1] = true;
      }
    } else if (var2 == 0) {
      if (random(1) < var1) {
        result[0] = true;
      }
    } else { // When the probabilities of both events are different and neither is equal to 0 or 1
      if (random(1) < 0.5) {
        if (random(1) < var1) {
          result[0] = true;
        } else {
        }
      } else {
        if (random(1) < var2) {
          result[1] = true;
        } else {
        }
      }
    }
    //double total = var1 + var2;
    //double pA = var1 / total;
    //double pB = var2 / total;
    //double r = random(1);

    //if (r < pA) {
    //  result[0] = true;
    //} else {
    //  result[1] = true;
    //}


    return result;
  }

  float getWidthOfLine() {
    float w;
    if (settings.sameWidthForAllLines[0]) {
      if (settings.widthOfLine.get(0) == -1)
        w = randomLineWidth[0];
      else
        w = settings.widthOfLine.get((int)random(settings.widthOfLine.size()));
    } else {
      w = random(settings.minLineWidth[0], settings.maxLineWidth[0]);
    }
    return w;
  }

  float getHeightOfLine() {
    float h;
    if (settings.sameHeightForAllLines[0]) {
      if (settings.heightOfLine.get(0) == -1)
        h = randomLineHeight[0];
      else
        h = settings.heightOfLine.get((int)random(settings.heightOfLine.size()));
    } else {
      h = random(settings.minLineHeight[0], settings.maxLineHeight[0]);
    }
    return h;
  }

  float getLineAngle(boolean isDeath) {
    float a;
    if (settings.setSpecificLineAngles[0]) {
      if (isDeath) {
        if (settings.dLineAngle.get(0) == -1)
          a = randomDLineAngle[0];
        else
          a = settings.dLineAngle.get((int)random(settings.dLineAngle.size()));
      } else {
        if (settings.nonDLineAngle.get(0) == -1)
          a = randomNonDLineAngle[0];
        else
          a = settings.nonDLineAngle.get((int)random(settings.nonDLineAngle.size()));
      }
      a = Math.abs(a);
    } else {
      a = random(settings.lineAngleStart[0], settings.lineAngleEnd[0]);
      a = random(1) < 0.5 ? -a : a;
    }
    return a;
  }

  float getFloorAngle() {
    float a;
    if (settings.setSpecificFloorAngles[0]) {
      if (settings.floorAngle.get(0) == -1)
        a = randomFloorAngle[0];
      else
        a = settings.floorAngle.get((int)random(settings.floorAngle.size()));
      a = Math.abs(a);
    } else {
      a = random(settings.floorAngleStart[0], settings.floorAngleEnd[0]);
      a = random(1) < 0.5 ? -a : a;
    }
    return a;
  }

  boolean isLineOutOfFrame(Line line) {
    // Get the four edge points of the line
    PVector[] edgePoints = line.getEdgePoints(true);

    // Find the leftmost, rightmost, topmost, and bottommost points
    float leftmostX = Float.MAX_VALUE;
    float rightmostX = Float.MIN_VALUE;
    float topmostY = Float.MAX_VALUE;
    float bottommostY = Float.MIN_VALUE;

    for (PVector point : edgePoints) {
      if (point.x < leftmostX) {
        leftmostX = point.x;
      }
      if (point.x > rightmostX) {
        rightmostX = point.x;
      }
      if (point.y < topmostY) {
        topmostY = point.y;
      }
      if (point.y > bottommostY) {
        bottommostY = point.y;
      }
    }

    // Calculate the total horizontal and vertical spans of the line
    float totalHorizontalSpan = rightmostX - leftmostX;
    float totalVerticalSpan = bottommostY - topmostY;

    // Variables to track how much of the line is outside the boundaries
    float outOfLeft = 0;
    float outOfRight = 0;
    float outOfTop = 0;
    float outOfBottom = 0;

    // Check how much of the line is outside each boundary
    for (PVector point : edgePoints) {
      // Left boundary
      if (point.x < startOfWidth) {
        outOfLeft += (startOfWidth - point.x);
      }
      // Right boundary
      if (point.x > endOfWidth) {
        outOfRight += (point.x - endOfWidth);
      }
      // Top boundary
      if (point.y < startOfHeight) {
        outOfTop += (startOfHeight - point.y);
      }
      // Bottom boundary
      if (point.y > endOfHeight) {
        outOfBottom += (point.y - endOfHeight);
      }
    }

    // Check if 50% or more of the line is out of bounds horizontally or vertically
    if (outOfLeft >= totalHorizontalSpan / 2 || outOfRight >= totalHorizontalSpan / 2 ||
      outOfTop >= totalVerticalSpan / 2 || outOfBottom >= totalVerticalSpan / 2) {
      return true;
    }

    // If less than 50% of the line is out of bounds in all directions, return false
    return false;
  }

  void clearAllLinesExceptProgramLines() {
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (!line.isOnlyForProgram) {
        lines.remove(i); // Safe removal by index
      }
    }
  }

  void clearFloorsAndLines() {
    clearFloors();
    clearLines();
  }


  void clearFloors() {
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (line.isFloor) {
        lines.remove(i); // Safe removal by index
      }
    }
  }


  void clearLines() {
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (!line.isBgLine && !line.isFrame && !line.isOnlyForProgram && !line.isFloor) {
        lines.remove(i); // Safe removal by index
      }
    }
  }

  void clearFrames() {
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (line.isFrame) {
        lines.remove(i); // Safe removal by index
      }
    }
  }

  int countNonFloorAndNonFrameLines() {
    int count = 0;

    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (!line.isBgLine && !line.isFrame && !line.isOnlyForProgram && !line.isFloor) {
        count++;
      }
    }
    return count;
  }

  void setRandomValues() {

    settings.deathColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    settings.nonDeathColor = getRandomColor((int)random(numOfColorSchemesAvailable));

    //nonDeathColor = getRandomColor(53);
    settings.bouncyColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    settings.grappleColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    randomLineHeight[0] = random(0, 500);
    randomLineWidth[0] = random(0, 500);
    randomDLineAngle[0] = random(0, 360);
    randomNonDLineAngle[0] = random(0, 360);
    randomFloorAngle[0] = random(0, 360);
  }

  void moveLinesForProgramToFront() {
    CopyOnWriteArrayList<Line> linesForProgram = new CopyOnWriteArrayList<Line>();

    // Collect lines with isOnlyForProgram set to true
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (line.isOnlyForProgram) {
        linesForProgram.add(line);
        lines.remove(i); // Remove it from the original list
      }
    }

    // Add collected lines to the end of the original list
    lines.addAll(linesForProgram);
  }

  void moveBgLinesToBack() {

    CopyOnWriteArrayList<Line> bgLines = new CopyOnWriteArrayList<Line>();

    // Collect lines with isOnlyForProgram set to true
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (line.isBgLine) {
        bgLines.add(0, line);
        lines.remove(line); // Remove it from the original list
      }
    }

    // Add collected lines to the end of the original list
    lines.addAll(0, bgLines);
  }

  void moveDLinesToBack() {
    CopyOnWriteArrayList<Line> deathLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> nonDLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into death and non death
    for (Line line : lines) {
      if (line.isDeath) {
        deathLines.add(line);
      } else {
        nonDLines.add(line);
      }
    }

    // Clear the original list and add death lines first
    lines.clear();
    lines.addAll(deathLines);
    lines.addAll(nonDLines);
  }

  void moveDLinesToFrontOrBack() {
    if (settings.moveDLinesToBack[0]) moveDLinesToBack();
    if (settings.moveDLinesToFront[0]) moveDLinesToFront();
  }

  void moveLinesForwardOrBackward() {
    moveBouncyLinesToBack();
    moveDLinesToFrontOrBack();
    moveBgLinesToBack();
    moveLinesForProgramToFront();
  }
}
