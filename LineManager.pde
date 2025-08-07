import java.util.HashSet;
import java.util.*;

class LineManager implements Runnable {

  ArrayList<PVector[]> connectedLinesPairs = new ArrayList<>();

  boolean[] connectFloorToFrame = new boolean[1]; // not to be used in presets
  boolean[] connectFloorToFloor = new boolean[1]; // not to be used in presets

  float[] randomLineHeight = new float[1];
  float[] randomLineWidth = new float[1];
  float[] randomDLineAngle = new float[1];
  float[] randomNonDLineAngle = new float[1];
  float[] randomFloorAngle = new float[1];
  float EXTRA_FRAME_WIDTH = 400;


  boolean isFloorsGenerationComplete;

  LineManager() {
    setRandomValues();
    isFloorsGenerationComplete = false;
    lines = new CopyOnWriteArrayList<Line>();
    noPhysicsDuplicateLineMap = new HashMap<>();

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
    } else if (noOfLines > 0)
      createLinesAsync();

    if (settings.addBackground[0])
      addBackground("BG Pattern 01");


    for (Line line : lines) {
      if (!line.noPhysics)
        line.setColors();
    }

    moveLinesForwardOrBackward();
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

    for (int i = 0; i < (int)Math.floor(settings.numOfFloors[0]) && isProcessingLines; ) {


      for (int j = 0; j < loopLimitForEachLine && isProcessingLines; j++) {
        connectFloorToFrame[0] = false;
        connectFloorToFloor[0] = false;

        boolean[] result = {false, false};

        if (existsFloorLine(lines) && isPossibleForFloorsToConnectWithFrames()) {
          result = determineEvent(settings.chancesForFloorsToConnectWithFrames[0], settings.chancesForFloorsAndFloorsToConnect[0]);

          connectFloorToFrame[0] = result[0];
          connectFloorToFloor[0] = result[1];
        } else if (existsFloorLine(lines) && !isPossibleForFloorsToConnectWithFrames()) {

          connectFloorToFloor[0] = random(1) < settings.chancesForFloorsAndFloorsToConnect[0];
        } else if (!existsFloorLine(lines) && isPossibleForFloorsToConnectWithFrames()) {

          connectFloorToFrame[0] = random(1) < settings.chancesForFloorsToConnectWithFrames[0];
        }

        generateBtnManager.updateStatus(i, (int)Math.floor(settings.numOfFloors[0]), j, loopLimitForEachLine, numOfTimesLoopLimitReached, "floor");

        float x, y, w, h, a;
        boolean addLine = true;

        x = random(startOfWidth, endOfWidth);
        y = random(startOfHeight, endOfHeight);

        w = random(settings.minFloorWidth[0], settings.maxFloorWidth[0]);
        h = settings.floorHeight[0];

        a = getFloorAngle();

        Line newLine = new Line(x, y, w, h, a, false);
        newLine.setAsFloor();

        if (connectFloorToFloor[0] || connectFloorToFrame[0]) {
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
    if (settings.addNoPhysicsLineDuplicates[0]) {
      removeNoPhysicsDuplicatesFromLines();
      duplicateAndScaleDownLines(lines);
    }
    if (!settings.addFrames[0]) extendLinesAboveRoof(findLinesCrossingYEqualsZero(lines));


    isProcessingLines = false;  // Indicate floor processing is complete
    isFloorsGenerationComplete = true; // Set flag when done

    println("Floor generation complete.");
  }

  boolean isPossibleForFloorsToConnectWithFrames() {
    return ((settings.connectFloorUp[0] || settings.connectFloorRight[0]
      || settings.connectFloorDown[0] || settings.connectFloorLeft[0]) && existFrames(lines));
  }


  void createDeathFromPathAsync(boolean isDeathOnPath) {
    Thread thread;
    if (isDeathOnPath) {
      thread = new Thread(() -> createLinesFromDrawing());
    } else {

      thread = new Thread(() -> createDeathFromPath(isDeathOnPath));
      //Thread thread = new Thread(() -> createDeathAroundPlayerX());
    }
    thread.start();
  }
  void createLinesFromDrawing() {
    isProcessingLines = true;
    println("Starting line generation in createLinesFromDrawing");

    // Get the clipboard data
    String clipboardData = getClipboardString();
    if (clipboardData == null || clipboardData.isEmpty()) {
      println("Clipboard is empty or contains non-text data.");
      return;
    }

    // Parse the clipboard data into a JSONArray
    JSONArray jsonData = parseJSONArray(clipboardData);
    if (jsonData == null) {
      println("Failed to parse JSON data.");
      return;
    }

    // Clear existing lines if needed
    //lines.clear();

    // Iterate over each JSON object and create a new Line instance
    for (int i = 0; i < jsonData.size(); i++) {
      JSONObject inst = jsonData.getJSONObject(i);

      // Initialize variables with default values
      float x = 0, y = 0, w = 0, h = 0, a = 0;

      if (inst != null) {
        // Safely get "x" and "y"
        if (inst.hasKey("x") && !inst.isNull("x")) {
          x = inst.getFloat("x");
        } else {
          println("Warning: 'x' is missing or null in JSON object " + i);
        }

        if (inst.hasKey("y") && !inst.isNull("y")) {
          y = inst.getFloat("y");
        } else {
          println("Warning: 'y' is missing or null in JSON object " + i);
        }

        float halfMapWidth = (endOfWidth - startOfWidth) / 2.0f;
        float halfMapHeight = (endOfHeight - startOfHeight) / 2.0f;

        float newPosX = x + startOfWidth + halfMapWidth;
        float newPosY = y + startOfHeight + halfMapHeight;

        // Safely get "width", "height", and "angle"
        if (inst.hasKey("width") && !inst.isNull("width")) {
          w = inst.getFloat("width");
        } else {
          println("Warning: 'width' is missing or null in JSON object " + i);
        }

        if (inst.hasKey("height") && !inst.isNull("height")) {
          h = inst.getFloat("height");
        } else {
          println("Warning: 'height' is missing or null in JSON object " + i);
        }

        if (inst.hasKey("angle") && !inst.isNull("angle")) {
          a = inst.getFloat("angle");
        } else {
          println("Warning: 'angle' is missing or null in JSON object " + i);
        }


        // Create a new Line with death set to false
        Line newLine = new Line(newPosX, newPosY, w, h, a, false);
        lines.add(newLine);
      } else {
        println("Warning: JSONObject at index " + i + " is null.");
      }
    }

    // Continue with further processing
    moveLinesForwardOrBackward();
    if (settings.addNoPhysicsLineDuplicates[0]) {
      removeNoPhysicsDuplicatesFromLines();
      duplicateAndScaleDownLines(lines);
    }
    if (!settings.addFrames[0]) extendLinesAboveRoof(findLinesCrossingYEqualsZero(lines));
    removeDuplicateLines();

    isProcessingLines = false;
    println("Generation of lines from drawing complete.");
  }

  void createDeathFromPath(boolean isDeathOnPath) {
    isProcessingLines = true;
    println("Starting death line generation in createDeathFromPath. isDeathOnPath: " + isDeathOnPath);

    // Get the clipboard data
    String clipboardData = getClipboardString();
    if (clipboardData == null || clipboardData.isEmpty()) {
      println("Clipboard is empty or contains non-text data.");
      return;
    }

    // Parse the clipboard data into a JSONObject
    JSONArray jsonData = parseJSONArray(clipboardData);
    if (jsonData == null) {
      println("Failed to parse JSON data.");
      return;
    }

    // Convert JSON points
    ArrayList<PVector> convertedPoints = convertPoints(jsonData);
    ArrayList<Line> deathLines = new ArrayList<>();

    float boxSize = 2;
    float boxWidth = 15;
    float necessaryGapNotSureWhyItsNeeded = 8;
    float minPossibleGap = getSpawnRadius() * 2 + boxSize + necessaryGapNotSureWhyItsNeeded;
    int skipPoints = 1; // Skip every 20 points to reduce lag
    //minPossibleGap = 20;


    for (int i = 0; i < convertedPoints.size() - skipPoints && isProcessingLines; i += skipPoints) {
      generateBtnManager.updateStatus(i, convertedPoints.size(), 0, 0, 0, "path");
      PVector pointA = convertedPoints.get(i);
      PVector pointB = convertedPoints.get(i + skipPoints);
      float pathTightness = minPossibleGap + settings.pathTightness[0];

      if (isDeathOnPath)
        pathTightness = 0;


      // Compute movement direction
      PVector direction = PVector.sub(pointB, pointA).normalize();
      float angle = degrees(atan2(direction.y, direction.x)); // Get angle in degrees
      PVector perpendicular = new PVector(-direction.y, direction.x).mult(pathTightness / 2);

      // Death line positions
      PVector deathLeft = PVector.add(pointA, perpendicular);
      PVector deathRight = PVector.sub(pointA, perpendicular);

      Line leftDeath = new Line(deathLeft.x, deathLeft.y, boxWidth, boxSize, angle, true);
      Line rightDeath = new Line(deathRight.x, deathRight.y, boxWidth, boxSize, angle, true);
      if (!isDeathOnPath) {
        // Ensure valid placement
        if (isValidDeathLineAroundPath(leftDeath, convertedPoints, deathLines)) {
          deathLines.add(leftDeath);
          lines.add(leftDeath);
        };

        if (isValidDeathLineAroundPath(rightDeath, convertedPoints, deathLines)) {
          deathLines.add(rightDeath);
          lines.add(rightDeath);
        }
      } else {
        if (isValidDeathLineOnPath(leftDeath, convertedPoints, deathLines)) {
          deathLines.add(leftDeath);
          lines.add(leftDeath);
        };
      }
    }

    //lines.addAll(deathLines);
    moveLinesForwardOrBackward();
    if (settings.addNoPhysicsLineDuplicates[0]) {
      removeNoPhysicsDuplicatesFromLines();
      duplicateAndScaleDownLines(lines);
    }
    if (!settings.addFrames[0]) extendLinesAboveRoof(findLinesCrossingYEqualsZero(lines));
    removeDuplicateLines();

    isProcessingLines = false;
    println("Death line generation complete.");
  }

  boolean isValidDeathLineAroundPath(Line newLine, ArrayList<PVector> points, ArrayList<Line> existingDeathLines) {
    for (PVector point : points) {
      if (
        isPointInLine(newLine, point)
        ||
        distanceBetweenPointAndLine(newLine, point) < getSpawnRadius() * 2
        //distanceBetweenPointAndLine(newLine, point) < pathTightness / 5
        ) {
        return false;
      }
    }
    for (Line existingLine : lines) {
      if (!existingLine.noPhysics && isOverlapping(newLine, existingLine)) {
        return false;
      }
    }
    for (Line deathLine : existingDeathLines) {
      if (distanceBetweenLines(newLine, deathLine) < getSpawnRadius() || isOverlapping(newLine, deathLine)) {
        return false;
      }
    }
    return !isLineOutOfFrame(newLine);
  }


  boolean isValidDeathLineOnPath(Line newLine, ArrayList<PVector> points, ArrayList<Line> existingDeathLines) {
    for (PVector point : points) {
      //if (
      //isPointInLine(newLine, point)
      //||
      //distanceBetweenPointAndLine(newLine, point) < getSpawnRadius()
      //) {
      //return false;
      //}
    }
    for (Line existingLine : lines) {
      if (!existingLine.noPhysics && isOverlapping(newLine, existingLine)) {
        return false;
      }
    }
    for (Line deathLine : existingDeathLines) {
      if (distanceBetweenLines(newLine, deathLine) < getSpawnRadius() || isOverlapping(newLine, deathLine)) {
        return false;
      }
    }
    return !isLineOutOfFrame(newLine);
  }


  boolean isValidNonDeathLineAroundPath(Line newLine, ArrayList<PVector> points, float pathTightness) {
    for (PVector point : points) {
      if (isPointInLine(newLine, point) || distanceBetweenPointAndLine(newLine, point) < pathTightness) {
        return false;
      }
    }
    return !isLineOutOfFrame(newLine);
  }



  void createDeathAroundPlayerX() {
    isProcessingLines = true;
    println("Starting death line generation...");

    // Get the clipboard data
    String clipboardData = getClipboardString();

    if (clipboardData == null || clipboardData.isEmpty()) {
      println("Clipboard is empty or contains non-text data.");
      return;
    }

    // Parse the clipboard data into a JSONObject
    JSONArray jsonData = parseJSONArray(clipboardData); // Use parseJSONArray for arrays

    if (jsonData == null) {
      println("Failed to parse JSON data.");
      return;
    }

    float boxSize = 7;
    float spacing = 2; // Space between boxes

    float neccessarySubtractionFigureOutWhyThenDeleteThis = 7;
    float minDistanceBtwBoxes = (getSpawnRadius() * 2) - neccessarySubtractionFigureOutWhyThenDeleteThis + 5;
    minDistanceBtwBoxes = 1;
    // List to store the converted points
    ArrayList<PVector> convertedPoints = convertPoints(jsonData);

    ArrayList<ArrayList<Line>> gridRows = createGridLines(startOfWidth, startOfHeight, endOfWidth, endOfHeight, convertedPoints, boxSize, spacing, minDistanceBtwBoxes);

    ArrayList<ArrayList<Line>> horizontallyMergedLines = mergeAdjacentBoxes(gridRows, boxSize, spacing);

    ArrayList<Line> verticallyMergedLines = mergeVerticalLines(horizontallyMergedLines, boxSize, spacing);

    ArrayList<Line> finalLines = splitLinesIntoCubes(verticallyMergedLines, boxSize, spacing, getSpawnRadius());



    // Remove nearby duplicate lines
    //finalLines = removeNearbyDuplicateLines(finalLines, boxSize, getSpawnRadius());

    lines.addAll(finalLines);

    // After the grid is generated, you can perform other necessary actions
    //moveLinesForwardOrBackward();
    if (settings.addNoPhysicsLineDuplicates[0]) {
      removeNoPhysicsDuplicatesFromLines();
      duplicateAndScaleDownLines(lines);
    }
    if (!settings.addFrames[0]) extendLinesAboveRoof(findLinesCrossingYEqualsZero(lines));

    removeDuplicateLines();


    isProcessingLines = false;
    println("Death line generation complete.");
  }

  // Function to remove nearby duplicate lines
  ArrayList<Line> removeNearbyDuplicateLines(ArrayList<Line> linesList, float boxSize, float spawnRadius) {
    ArrayList<Line> filteredLines = new ArrayList<>();
    HashSet<Line> toRemove = new HashSet<>();

    for (int i = 0; i < linesList.size(); i++) {
      Line lineX = linesList.get(i);

      // Check only if width and height match boxSize
      if (lineX.width == boxSize && lineX.height == boxSize) {
        for (int j = i + 1; j < linesList.size(); j++) {
          Line lineY = linesList.get(j);

          if (lineY.width == boxSize && lineY.height == boxSize) {
            float distance = PVector.dist(new PVector(lineX.centerX, lineX.centerY),
              new PVector(lineY.centerX, lineY.centerY));

            if (distance <= spawnRadius * 2) {
              toRemove.add(lineY);
            }
          }
        }
      }
    }

    // Add only non-removed lines
    for (Line line : linesList) {
      if (!toRemove.contains(line)) {
        filteredLines.add(line);
      }
    }

    return filteredLines;
  }


  void removeDuplicateLines() {
    HashSet<String> uniqueLines = new HashSet<>();
    ArrayList<Line> filteredLines = new ArrayList<>();

    for (Line line : lines) {
      String key = getLineKey(line);
      if (uniqueLines.add(key)) {
        filteredLines.add(line);
      }
    }

    lines.clear();
    lines.addAll(filteredLines);
  }

  // Generates a unique key for a line based on its attributes
  private String getLineKey(Line line) {
    return line.centerX + "," + line.centerY + "," + line.width + "," + line.height + "," + line.angle + "," + line.isDeath;
  }

  ArrayList<PVector> convertPoints(JSONArray jsonData) {
    ArrayList<PVector> convertedPoints = new ArrayList<PVector>();

    for (int i = 0; i < jsonData.size(); i++) {
      JSONObject point = jsonData.getJSONObject(i);
      // Ensure x and y are defined
      if (!point.hasKey("x") || !point.hasKey("y")) {
        println("Invalid point data at index " + i);
        continue;
      }

      float pointX = point.getFloat("x");
      float pointY = point.getFloat("y");
      // Convert the point
      float halfMapWidth = (endOfWidth - startOfWidth) / 2;
      float halfMapHeight = (endOfHeight - startOfHeight) / 2;

      float newPosX = pointX + startOfWidth + halfMapWidth;
      float newPosY = pointY + startOfHeight + halfMapHeight;
      // Store the converted point
      convertedPoints.add(new PVector(newPosX, newPosY));
    }

    return convertedPoints;
  }


  ArrayList<ArrayList<Line>> createGridLines(float startOfWidth, float startOfHeight, float endOfWidth, float endOfHeight, ArrayList<PVector> convertedPoints, float boxSize, float spacing, float minDistanceBtwBoxes) {
    float boxWidth = boxSize;
    float boxHeight = boxSize;

    int numCols = floor((endOfWidth - startOfWidth) / (boxWidth + spacing));
    int numRows = floor((endOfHeight - startOfHeight) / (boxHeight + spacing));

    int count = 0;
    ArrayList<ArrayList<Line>> gridRows = new ArrayList<>();

    for (int row = 0; row < numRows; row++) {
      ArrayList<Line> rowLines = new ArrayList<>();
      for (int col = 0; col < numCols; col++) {

        // Calculate position based on the row and column
        float x = startOfWidth + col * (boxWidth + spacing);
        float y = startOfHeight + row * (boxHeight + spacing);

        Line newLine = new Line(x, y, boxWidth, boxHeight, 0, true);

        // Check if the current line contains any of the points
        boolean containsPoint = false;
        for (PVector point : convertedPoints) {
          // Check if the current death line contains the point
          if (isPointInLine(newLine, point)) {
            containsPoint = true;
            break;
          }
        }

        // Check if the current line is too close to any point
        boolean isTooClose = false;
        for (PVector point : convertedPoints) {
          float distance = distanceBetweenPointAndLine(newLine, point);
          if (distance < minDistanceBtwBoxes) {
            isTooClose = true;
            break;
          }
        }

        boolean isOverlapping = false;
        for (Line existingLine : lines) {
          if (existingLine.noPhysics) continue;
          if (isOverlapping(newLine, existingLine)) {
            isOverlapping = true;
            break;
          }
        }

        // Check if it's too close to other lines (if needed)
        if (!isOverlapping && !containsPoint && !isLineOutOfFrame(newLine) && !isTooClose) {
          rowLines.add(newLine);
          //lines.add(newLine); // Add to lines immediately for UI update
          count++; // Track the number of added boxes
        }
      }
      gridRows.add(rowLines);
    }

    // Remove the last added lines, as per the original code
    for (int i = 0; i < count; i++) {
      //lines.remove(lines.size() - 1);
    }

    return gridRows;
  }



  ArrayList<ArrayList<Line>> mergeAdjacentBoxes(ArrayList<ArrayList<Line>> gridRows, float boxSize, float spacing) {
    ArrayList<ArrayList<Line>> mergedLines = new ArrayList<>(); // Now a 2D array

    for (ArrayList<Line> row : gridRows) {
      if (row.isEmpty()) continue;
      ArrayList<Line> mergedRow = new ArrayList<>();

      Line currentLine = row.get(0); // Start merging from the first box

      for (int i = 1; i < row.size(); i++) {
        Line nextLine = row.get(i);

        // Check if the boxes are adjacent
        float expectedX = currentLine.centerX + currentLine.width / 2 + spacing + boxSize / 2;
        if (abs(nextLine.centerX - expectedX) < 0.1) { // Small tolerance for floating point precision
          // Merge: Increase width instead of adding a new box
          currentLine.width += boxSize + spacing;
          currentLine.centerX += (boxSize + spacing) / 2;
        } else {
          //println("in else of row " + i);
          // Not adjacent: Save the current merged box and start a new one
          mergedRow.add(currentLine);
          currentLine = nextLine;
        }
      }
      mergedRow.add(currentLine); // Add the last merged box
      mergedLines.add(mergedRow);
    }

    return mergedLines;
  }

  ArrayList<Line> mergeVerticalLines(ArrayList<ArrayList<Line>> mergedLines, float boxHeight, float spacing) {
    ArrayList<Line> finalMergedLines = new ArrayList<>();
    int numRows = mergedLines.size();

    // Determine the maximum number of columns in any row to size mergedFlags correctly
    int maxCols = 0;
    for (ArrayList<Line> row : mergedLines) {
      maxCols = Math.max(maxCols, row.size());
    }
    boolean[][] mergedFlags = new boolean[numRows][maxCols]; // Track merged lines

    // Iterate over columns
    for (int col = 0; col < maxCols; col++) {
      for (int row = 0; row < numRows; row++) {
        if (col >= mergedLines.get(row).size() || mergedFlags[row][col]) continue; // Skip out-of-bounds or merged lines

        Line currentLine = mergedLines.get(row).get(col);
        if (currentLine == null) continue;

        // Try merging downwards
        for (int nextRow = row + 1; nextRow < numRows; nextRow++) {
          if (col >= mergedLines.get(nextRow).size()) break; // Avoid out-of-bounds access

          Line nextLine = mergedLines.get(nextRow).get(col);
          if (nextLine == null || mergedFlags[nextRow][col]) break;

          // Check if they have the same width and centerX
          if (currentLine.width == nextLine.width && currentLine.centerX == nextLine.centerX) {
            // Merge vertically
            currentLine.height += boxHeight + spacing;
            currentLine.centerY += (boxHeight + spacing) / 2;
            mergedFlags[nextRow][col] = true; // Mark the next line as merged
          } else {
            break; // Stop merging if conditions aren't met
          }
        }
        finalMergedLines.add(currentLine); // Store the merged line
      }
    }

    // Add unmerged remaining lines (only within valid column bounds)
    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < mergedLines.get(row).size(); col++) { // Ensure col is within bounds
        if (!mergedFlags[row][col] && mergedLines.get(row).get(col) != null) {
          finalMergedLines.add(mergedLines.get(row).get(col));
        }
      }
    }

    return finalMergedLines;
  }
  ArrayList<Line> splitLinesIntoCubes(ArrayList<Line> finalMergedLines, float boxHeight, float spacing, float spawnRadius) {
    ArrayList<Line> updatedLines = new ArrayList<>();
    HashSet<String> uniqueLines = new HashSet<>(); // Track unique lines

    for (Line lineX : finalMergedLines) {
      boolean shouldSplit = false;
      boolean useOverlappingSplit = false;
      float leftBoundary = lineX.centerX - lineX.width / 2;
      float rightBoundary = lineX.centerX + lineX.width / 2;
      float splitLeftEnd = leftBoundary; // Default for normal split
      float splitRightStart = rightBoundary; // Default for normal split

      // Skip small lines
      if (lineX.width < boxHeight * 2) {
        updatedLines.add(lineX);
        continue;
      }

      // Check if there's a lineY directly above lineX
      for (Line lineY : finalMergedLines) {
        float expectedY = lineX.centerY - lineX.height / 2 - spacing - lineY.height / 2;

        if (lineY.centerY == expectedY) {
          float leftCornerDiff = (lineX.centerX - lineX.width / 2) - (lineY.centerX - lineY.width / 2);
          float rightCornerDiff = (lineX.centerX + lineX.width / 2) - (lineY.centerX + lineY.width / 2);

          if (Math.abs(leftCornerDiff) <= spawnRadius * 2 && Math.abs(rightCornerDiff) <= spawnRadius * 2) {
            shouldSplit = true;
            break;
          }

          if (leftCornerDiff > 0 && rightCornerDiff < 0) {
            shouldSplit = true;
            break;
          }

          // Check if lineX is wider than and overlapping lineY
          if ((lineY.centerX - lineY.width / 2 >= leftBoundary) && (lineY.centerX + lineY.width / 2 <= rightBoundary)) {
            useOverlappingSplit = true;
            splitLeftEnd = lineY.centerX - lineY.width / 2; // Adjust split point to lineY's left corner
            splitRightStart = lineY.centerX + lineY.width / 2; // Adjust split point to lineY's right corner
            break;
          }
        }
      }

      if (shouldSplit) {
        // Regular split into two equal boxHeight squares
        Line leftChild = new Line(
          lineX.centerX - lineX.width / 2 + boxHeight / 2,
          lineX.centerY,
          boxHeight,
          boxHeight,
          0,
          true
          );

        Line rightChild = new Line(
          lineX.centerX + lineX.width / 2 - boxHeight / 2,
          lineX.centerY,
          boxHeight,
          boxHeight,
          0,
          true
          );

        if (uniqueLines.add(getLineKey(leftChild))) updatedLines.add(leftChild);
        if (uniqueLines.add(getLineKey(rightChild))) updatedLines.add(rightChild);
      } else if (useOverlappingSplit) {
        // Overlapping split where leftChild and rightChild align with lineY's edges
        float leftWidth = splitLeftEnd - leftBoundary;
        float rightWidth = rightBoundary - splitRightStart;

        if (leftWidth >= boxHeight) {
          Line leftChild = new Line(
            leftBoundary + leftWidth / 2,
            lineX.centerY,
            leftWidth,
            boxHeight,
            0,
            true
            );
          if (uniqueLines.add(getLineKey(leftChild))) updatedLines.add(leftChild);
        }

        if (rightWidth >= boxHeight) {
          Line rightChild = new Line(
            rightBoundary - rightWidth / 2,
            lineX.centerY,
            rightWidth,
            boxHeight,
            0,
            true
            );
          if (uniqueLines.add(getLineKey(rightChild))) updatedLines.add(rightChild);
        }
      } else {
        // If not splitting, add the original line
        if (uniqueLines.add(getLineKey(lineX))) updatedLines.add(lineX);
      }
    }

    return updatedLines;
  }



  ArrayList<Line> removeUnwantedLines(ArrayList<Line> finalMergedLines, float boxHeight, float spacing) {
    ArrayList<Line> updatedLines = new ArrayList<>(finalMergedLines);

    for (int i = 0; i < updatedLines.size(); i++) {
      Line lineX = updatedLines.get(i);
      Line firstLineBelowX = null;
      Line secondLineBelowX = null;

      for (int j = i + 1; j < updatedLines.size(); j++) {
        Line lineY = updatedLines.get(j);

        // 2.3 - Check if lineY is exactly one row below lineX
        float expectedY1 = lineX.centerY + lineX.height / 2 + spacing + boxHeight / 2;
        if (lineY.centerY != expectedY1) {
          if (lineY.centerY > expectedY1) {
            break; // 2.4 - Skip lineX if lineY is too far below
          }
          continue; // Skip if not at the correct height
        }

        // 2.5 - Check horizontal alignment for first line below
        if (lineY.centerX - lineY.width / 2 < lineX.centerX - lineX.width / 2 ||
          lineY.centerX + lineY.width / 2 > lineX.centerX + lineX.width / 2) {
          continue;
        }

        if (lineY.centerX < lineX.centerX - lineX.width / 2 ||
          lineY.centerX > lineX.centerX + lineX.width / 2) {
          continue;
        }

        firstLineBelowX = lineY; // Found first line below
        for (int k = j + 1; k < updatedLines.size(); k++) {
          Line lineZ = updatedLines.get(k);

          // 2.7 - Check if lineZ is exactly one row below firstLineBelowX
          float expectedY2 = firstLineBelowX.centerY + firstLineBelowX.height / 2 + spacing + lineZ.height / 2;
          if (lineZ.centerY != expectedY2) {
            if (lineZ.centerY > expectedY2) {
              break; // 2.8 - Skip lineX if lineZ is too far below
            }
            continue;
          }

          // 2.9 - Check horizontal alignment for second line below
          if (firstLineBelowX.centerX - firstLineBelowX.width / 2 < lineZ.centerX - lineZ.width / 2 ||
            firstLineBelowX.centerX + firstLineBelowX.width / 2 > lineX.centerX + lineZ.width / 2) {
            continue;
          }


          if (lineZ.centerX < firstLineBelowX.centerX - firstLineBelowX.width / 2 ||
            lineZ.centerX > firstLineBelowX.centerX + firstLineBelowX.width / 2) {
            continue;
          }

          secondLineBelowX = lineZ; // Found second line below
          break; // Exit loop once second line is found
        }

        updatedLines.remove(firstLineBelowX);
        break; // Move on to the next lineX
      }
    }

    return updatedLines;
  }


  float distanceBetweenPointAndLine(Line line, PVector point) {
    // Number of points to sample along the line
    int numSamples = 100;

    // Generate points along the line
    PVector[] pointsOnLine = generatePointsAlongLine(line, numSamples);

    float minDistance = Float.MAX_VALUE;

    // Find the minimum distance between the point and sampled points on the line
    for (PVector p : pointsOnLine) {
      float distance = PVector.dist(p, point);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }

  // Function to check if a point is within a line
  boolean isPointInLine(Line line, PVector point) {
    // Basic check: does the point lie within the bounds of the line's x and y coordinates?
    // You can enhance this if you want to check if the point intersects the line's exact path (e.g., using line equations).
    float lineX = line.centerX;
    float lineY = line.centerY;
    float lineW = line.width;
    float lineH = line.height;

    // Check if the point is within the bounds of the line's rectangle
    if (point.x >= lineX && point.x <= (lineX + lineW) && point.y >= lineY && point.y <= (lineY + lineH)) {
      return true;
    }
    return false;
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

      //println("i in loop: " + i);
      for (int j = 0; j < loopLimitForEachLine && isProcessingLines; j++) {
        generateBtnManager.updateStatus(i, noOfLines, j, loopLimitForEachLine, numOfTimesLoopLimitReached, "line");

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
    if (settings.addNoPhysicsLineDuplicates[0]) {
      removeNoPhysicsDuplicatesFromLines();
      duplicateAndScaleDownLines(lines);
    }
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

    boolean valid;

    do {
      // 1) Pick a candidate at random
      x = random(startOfWidth, endOfWidth);
      y = random(startOfHeight, endOfHeight);

      valid = true;

      // 2) Test against each forbidden line‐region
      for (Line l : lines) {
        if (l.isSelectableNoPhysics) {
          if (pointInRotatedRect(x, y, l.centerX, l.centerY, l.width, l.height, l.angle)) {
            valid = false;
            break;
          }
        }
      }

      // 3) Repeat until our point is valid
    } while (!valid);

    // at this point, pickX/pickY is guaranteed to lie outside all forbidden regions


    w = getWidthOfLine();
    h = getHeightOfLine();
    a = getLineAngle(isDeath);

    Line newLine = new Line(x, y, w, h, a, isDeath);

    if (!newLine.isDeath && !newLine.hasGrapple && !newLine.isBouncy && random(1) < settings.chancesOfNoJump[0])
      newLine.setAsNoJump();

    connectCornerToAnExistingLine(newLine);
    //println("isoutofframe: " + isLineOutOfFrame(newLine));

    JSONArray jsonData = null;

    //try {
    //  // Get the clipboard data
    //  String clipboardData = getClipboardString();
    //  if (clipboardData == null || clipboardData.isEmpty()) {
    //    println("Clipboard is empty or contains non-text data.");
    //    //return;
    //  }

    //  // Parse the clipboard data into a JSONObject
    //  jsonData = parseJSONArray(clipboardData);
    //  if (jsonData == null) {
    //    println("Failed to parse JSON data.");
    //  }
    //}
    //catch (Exception e) {
    //  // Handle the exception (you can log it or print the stack trace)
    //  println("An error occurred: " + e.getMessage());
    //  e.printStackTrace();
    //}

    boolean isValidLine = true;
    if (jsonData != null) {// Convert JSON points
      ArrayList<PVector> convertedPoints = convertPoints(jsonData);

      float necessaryGapNotSureWhyItsNeeded = 8;
      float minPossibleGap = getSpawnRadius() * 2 + necessaryGapNotSureWhyItsNeeded;
      float pathTightness = minPossibleGap + 20;
      isValidLine = isValidNonDeathLineAroundPath(newLine, convertedPoints, pathTightness);
    }

    if (!isTooCloseToOtherLines(newLine) && !isLineOutOfFrame(newLine) && isValidLine) {
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
      if (existingLine.noPhysics && !existingLine.isSelectableNoPhysics) continue;

      //  println("in isTooCloseToOtherLines: " + ++counterForTrackingControl);
      //  println("length of 'lines': " + lines.size());


      if (areLinesConnected(existingLine, newLine)) continue;

      if (!settings.canLinesOverlap[0] || existingLine.isSelectableNoPhysics) {
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


    while (true) {

      //println("in connectCornerToAnExistingLine: " + ++counterForTrackingControl);
      Line lineToConnectWith = chooseLineToConnectWith(lineToMove, connectFloorToFrame[0], connectFloorToFloor[0]);

      if (lineToConnectWith == null) return;


      PVector randomPoint = getRandomPointOnLine(lineToConnectWith, lineToMove);
      if (isPointWithinCanvas(randomPoint)) {

        updateLineAngle(lineToMove, lineToConnectWith, randomPoint);
        moveLineToTouch(lineToMove, randomPoint, lineToConnectWith);
        addConnectedLinePair(lineToMove, lineToConnectWith);
        break;
      }
    }
  }

  Line chooseLineToConnectWith(Line lineToMove, boolean connectFloorToFrame, boolean connectFloorToFloor) {
    // Pre-filter lines into categories, excluding lines with noPhysics or flagged as only for the program.
    ArrayList<Line> floorLines   = new ArrayList<Line>();
    ArrayList<Line> frameLines   = new ArrayList<Line>();
    ArrayList<Line> dLines       = new ArrayList<Line>();
    ArrayList<Line> nonDLines    = new ArrayList<Line>();

    for (Line l : lines) {
      if (l.noPhysics || l.isOnlyForProgram) continue;

      if (l.isFloor) {
        floorLines.add(l);
      } else if (l.isFrame) {
        frameLines.add(l);
      } else if (l.isDeath) {
        dLines.add(l);
      } else {
        nonDLines.add(l);
      }
    }

    // Build a list of available categories.
    ArrayList<ArrayList<Line>> categories = new ArrayList<ArrayList<Line>>();
    if (!floorLines.isEmpty())  categories.add(floorLines);
    if (!frameLines.isEmpty())  categories.add(frameLines);
    if (!dLines.isEmpty())      categories.add(dLines);
    if (!nonDLines.isEmpty())   categories.add(nonDLines);


    for (ArrayList<Line> cat : categories) {
      Collections.shuffle(cat);  // Shuffle the entire category (list of lines).
    }

    // Now loop until we either find an acceptable candidate or run out.
    while (!categories.isEmpty()) {
      // Choose a random non-empty category.
      int catIndex = (int) random(categories.size());
      ArrayList<Line> chosenCategory = categories.get(catIndex);
      // Remove the first candidate from the chosen category.
      Line lineToConnectWith = chosenCategory.remove(0);
      // If the chosen category becomes empty, remove it from categories.
      if (chosenCategory.isEmpty()) {
        categories.remove(catIndex);
      }

      if (lineToMove.isFloor) {


        if (connectFloorToFrame && lineToConnectWith.isFrame) {
          if (!areFramesAngled()) {
            if (connectToThisSpecificFrame(lineToConnectWith)) {
              return lineToConnectWith;
            }
          } else
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

          if (lineToConnectWith.isFloor && random(1) < settings.chancesForDLinesToConnectWithFloors[0]) {
            return lineToConnectWith;
          }

          if (lineToConnectWith.isDeath && random(1) < settings.chancesForDLinesToConnect[0]) {
            return lineToConnectWith;
          }
        } else if (!lineToMove.isDeath) {

          if (lineToConnectWith.isFloor && random(1) < settings.chancesForNonDLinesToConnectWithFloors[0]) {
            return lineToConnectWith;
          }

          if (!lineToConnectWith.isDeath && random(1) < settings.chancesForNonDLinesToConnect[0]) {
            return lineToConnectWith;
          }
        }


        //

        //if (lineToMove.isDeath) {
        //  //println("lineToMove.isDeath");
        //  boolean[] result =  new boolean[2];
        //  boolean connectDLinesWithFloor = false;
        //  boolean connectDLinesWithDLines = false;

        //  if (settings.addFloors[0] && settings.numOfFloors[0] > 0) {
        //    result = determineEvent(settings.chancesForDLinesToConnectWithFloors[0], settings.chancesForDLinesToConnect[0]);
        //    connectDLinesWithDLines = result[1];
        //  } else
        //    connectDLinesWithDLines = settings.chancesForDLinesToConnect[0] > random(1);

        //  connectDLinesWithFloor = result[0];

        //  if (lineToConnectWith.isFloor && connectDLinesWithFloor) {
        //    //println("lineToConnectWith.isFloor && connectDLinesWithFloor");
        //    return lineToConnectWith;
        //  }
        //  if (!lineToConnectWith.isFloor && lineToConnectWith.isDeath && connectDLinesWithDLines) {
        //    //println("!lineToConnectWith.isFloor && lineToConnectWith.isDeath && connectDLinesWithDLines");
        //    return lineToConnectWith;
        //  }
        //} else if (!lineToMove.isDeath) {
        //  //println("!lineToMove.isDeath");

        //  boolean[] result =  new boolean[2];
        //  boolean connectNonDLinesWithFloor = false;
        //  boolean connectNonDLinesWithNonDLines = false;

        //  if (existsFloorLine(lines)) {

        //    result = determineEvent(settings.chancesForNonDLinesToConnectWithFloors[0], settings.chancesForNonDLinesToConnect[0]);
        //    connectNonDLinesWithNonDLines = result[1];
        //  } else
        //    connectNonDLinesWithNonDLines = settings.chancesForNonDLinesToConnect[0] > random(1);

        //  connectNonDLinesWithFloor = result[0];

        //  if (lineToConnectWith.isFloor && connectNonDLinesWithFloor) {
        //    //println("lineToConnectWith.isFloor && connectNonDLinesWithFloor");
        //    return lineToConnectWith;
        //  }
        //  if (!lineToConnectWith.isFloor && !lineToConnectWith.isDeath && connectNonDLinesWithNonDLines) {
        //    //println("!lineToConnectWith.isFloor && !lineToConnectWith.isDeath && connectNonDLinesWithNonDLines");
        //    return lineToConnectWith;
        //  }
        //}
      }
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

  boolean areFramesAngled() {
    for (Line line : lines) {
      if (line.isFrame && !(line.angle == 0 || line.angle == 90)) {
        return true;
      }
    }
    return false;
  }


  boolean connectToThisSpecificFrame(Line lineToConnectWith) {
    final float HALF_EXTRA_FRAME = EXTRA_FRAME_WIDTH / 2;
    final float CONNECTION_TOLERANCE = 1;  // tweak as needed

    // Precompute the center positions of the 4 frame lines
    float topY    = startOfHeight - HALF_EXTRA_FRAME;
    float bottomY = endOfHeight   + HALF_EXTRA_FRAME;
    float leftX   = startOfWidth  - HALF_EXTRA_FRAME;
    float rightX  = endOfWidth    + HALF_EXTRA_FRAME;

    // Check individual conditions
    boolean connectUp    = settings.connectFloorUp[0]    && almostEqual(lineToConnectWith.centerY, topY, CONNECTION_TOLERANCE);
    boolean connectRight = settings.connectFloorRight[0] && almostEqual(lineToConnectWith.centerX, rightX, CONNECTION_TOLERANCE);
    boolean connectDown  = settings.connectFloorDown[0]  && almostEqual(lineToConnectWith.centerY, bottomY, CONNECTION_TOLERANCE);
    boolean connectLeft  = settings.connectFloorLeft[0]  && almostEqual(lineToConnectWith.centerX, leftX, CONNECTION_TOLERANCE);

    boolean result = connectUp || connectRight || connectDown || connectLeft;

    return result;
  }


  // helper:
  boolean almostEqual(float a, float b, float tol) {
    return abs(a - b) <= tol;
  }



  // Helper: rotates a vector by a given angle (in radians)
  PVector rotateVector(PVector v, float angle) {
    float cosA = cos(angle);
    float sinA = sin(angle);
    return new PVector(v.x * cosA - v.y * sinA, v.x * sinA + v.y * cosA);
  }

  // Helper: returns a random offset angle between given start and end values.
  float getRandomAngleOffset(float angleStart, float angleEnd) {
    return random(angleStart, angleEnd);
  }

  // Updated updateLineAngle function that uses randomPoint

  void updateLineAngle(Line lineToMove, Line lineToConnectWith, PVector randomPoint) {

    float[] lineConnectAngleStart = settings.lineConnectAngleStart;
    float[] lineConnectAngleEnd = settings.lineConnectAngleEnd;

    float floorConnectAngleStart = settings.floorConnectAngleStart[0];
    float floorConnectAngleEnd = settings.floorConnectAngleEnd[0];


    // Get the center and rotation angle of the connecting line.
    PVector center = new PVector(lineToConnectWith.centerX, lineToConnectWith.centerY);
    float angleRad = radians(lineToConnectWith.angle);

    // Convert the randomPoint into the local coordinate system of lineToConnectWith.
    PVector localRandom = PVector.sub(randomPoint, center);
    // Rotate by the negative angle so that lineToConnectWith is axis-aligned.
    localRandom = new PVector(
      localRandom.x * cos(-angleRad) - localRandom.y * sin(-angleRad),
      localRandom.x * sin(-angleRad) + localRandom.y * cos(-angleRad)
      );

    // Get half dimensions. (Assumes lineToConnectWith's width and height match those used in its getEdgePoints.)
    float halfW = lineToConnectWith.width / 2.0;
    float halfH = lineToConnectWith.height / 2.0;

    // Use a small tolerance to check closeness to the edges.
    float tol = 0.001;

    // Determine if the random point lies on a horizontal edge (top or bottom)
    if (abs(abs(localRandom.y) - halfH) < tol) {
      // The edge is parallel to lineToConnectWith's axis.
      // Add an offset angle chosen from the settings.

      if (lineToMove.isFloor && settings.limitFloorAngleAfterConnect[0]) {
        lineToMove.angle = getRandomAngle(lineToConnectWith.angle, floorConnectAngleStart, floorConnectAngleEnd);
      } else if (!lineToMove.isFloor && settings.limitLineAngleAfterConnectingItsCorner[0]) {
        lineToMove.angle = getRandomAngle(lineToConnectWith.angle, lineConnectAngleStart[0], lineConnectAngleEnd[0]);
      }
    }
    // Else if it lies on a vertical edge (left or right)
    else if (abs(abs(localRandom.x) - halfW) < tol) {
      if (lineToMove.isFloor && settings.limitFloorAngleAfterConnect[0]) {
        lineToMove.angle = getRandomAngle(lineToConnectWith.angle, floorConnectAngleStart, floorConnectAngleEnd) + 90;
      } else if (!lineToMove.isFloor && settings.limitLineAngleAfterConnectingItsCorner[0]) {
        lineToMove.angle = getRandomAngle(lineToConnectWith.angle, lineConnectAngleStart[0], lineConnectAngleEnd[0]) + 90;
      }
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
    float angle = random(chosenAngle + angleStart, chosenAngle + angleEnd);
    return random(1) < 0.5 ? angle : angle + 180;
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
      } else if ((lineToConnectWith.isFloor && lineToMove.isDeath && !lineToMove.isFloor && connectDLinesAndFloorsAtCorner[0]) ||
        (lineToConnectWith.isFloor && !lineToMove.isFloor && !lineToMove.isDeath && connectNonDLinesAndFloorsAtCorner[0]) ||
        (lineToConnectWith.isFloor && lineToMove.isFloor) && connectFloorsAtCorner[0]) {
        isPointAtCorner = true;
      }
    }
    if (isPointAtCorner) {
      if (random(1) < 0.5) // randommly choose one corner
        t = buffer / lineToConnectWith.width;
      else
        t = 1 - buffer / lineToConnectWith.width;
    } else {
      t = random(buffer / lineToConnectWith.width, 1 - buffer / lineToConnectWith.width);
    }

    return t;
  }

  PVector getRandomPointOnLine(Line lineToConnectWith, Line lineToMove) {

    PVector[] edgePoints = lineToConnectWith.getEdgePoints(false);
    float t = getPointOfConnection(lineToConnectWith, lineToMove);
    //return new PVector(edgePoints[0].x + t * (edgePoints[1].x - edgePoints[0].x),
    //  edgePoints[0].y + t * (edgePoints[1].y - edgePoints[0].y));
    return new PVector(edgePoints[0].x + t * (edgePoints[1].x - edgePoints[0].x),
      edgePoints[0].y + t * (edgePoints[1].y - edgePoints[0].y));
  }


  boolean isPointWithinCanvas(PVector point) {
    return point.x >= startOfWidth && point.x <= endOfWidth && point.y >= startOfHeight && point.y <= endOfHeight;
  }

  // New helper: returns the minimal overlap (penetration depth)
  // Returns 0 if there is no overlap.
  float computeOverlap(Line line1, Line line2) {
    PVector[] corners1 = line1.getCorners();
    PVector[] corners2 = line2.getCorners();

    // Compute normals (axes) for both rectangles
    PVector[] axes = new PVector[4];
    axes[0] = PVector.sub(corners1[1], corners1[0]).normalize();
    axes[1] = PVector.sub(corners1[2], corners1[1]).normalize();
    axes[2] = PVector.sub(corners2[1], corners2[0]).normalize();
    axes[3] = PVector.sub(corners2[2], corners2[1]).normalize();

    float minOverlap = Float.MAX_VALUE;

    // Test each axis
    for (int i = 0; i < axes.length; i++) {
      // Get the projection intervals on this axis.
      float[] proj1 = projectOntoAxis(corners1, axes[i]);
      float[] proj2 = projectOntoAxis(corners2, axes[i]);

      // If there is a gap, then there is no overlap.
      if (proj1[1] < proj2[0] || proj2[1] < proj1[0]) {
        return 0;
      }

      // Calculate the overlap distance on this axis.
      float overlapOnAxis = min(proj1[1] - proj2[0], proj2[1] - proj1[0]);
      if (overlapOnAxis < minOverlap) {
        minOverlap = overlapOnAxis;
      }
    }

    return minOverlap;
  }

  // Modified moveLineToTouch that chooses the candidate edge with least overlap.
  void moveLineToTouch(Line lineToMove, PVector randomPoint, Line lineToConnectWith) {
    PVector[] moveEdgePoints = lineToMove.getEdgePoints(true);
    float distanceOffset = 0.1;  // Extra offset to avoid direct contact.
    float originalX = lineToMove.centerX;
    float originalY = lineToMove.centerY;

    float bestOverlap = Float.MAX_VALUE;
    PVector bestMoveVector = null;

    // Try each candidate edge point.
    for (int i = 0; i < moveEdgePoints.length; i++) {
      // Reset to original center before testing candidate.
      lineToMove.centerX = originalX;
      lineToMove.centerY = originalY;

      // Calculate the movement vector from the candidate edge to the random point.
      PVector candidateVector = PVector.sub(randomPoint, moveEdgePoints[i]);
      // Adjust the vector length to include the offset.
      if (candidateVector.mag() > distanceOffset) {
        candidateVector.setMag(candidateVector.mag() + distanceOffset);
      } else {
        candidateVector.setMag(distanceOffset);
      }

      // Calculate a new candidate center for lineToMove.
      PVector candidateCenter = new PVector(originalX + candidateVector.x, originalY + candidateVector.y);
      lineToMove.centerX = candidateCenter.x;
      lineToMove.centerY = candidateCenter.y;

      // Compute how much overlap results from this candidate connection.
      float overlap = computeOverlap(lineToMove, lineToConnectWith);

      // If there is no overlap, choose this candidate immediately.
      if (overlap == 0) {
        bestMoveVector = candidateVector;
        bestOverlap = overlap;
        break;
      }
      // Otherwise, keep the candidate with the minimal (least problematic) overlap.
      else if (overlap < bestOverlap) {
        bestOverlap = overlap;
        bestMoveVector = candidateVector;
      }
    }

    // Finally, if we found a best candidate, set the line's center to its new position.
    if (bestMoveVector != null) {
      lineToMove.centerX = originalX + bestMoveVector.x;
      lineToMove.centerY = originalY + bestMoveVector.y;
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


  boolean existFrames(CopyOnWriteArrayList<Line> lines) {

    for (Line line : lines) {
      if (line.isFrame) {
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

  void moveBLinesToBack() {
    CopyOnWriteArrayList<Line> bouncyLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> otherLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into death and non death
    for (Line line : lines) {
      if (line.isBouncy) {
        bouncyLines.add(line);
      } else {
        otherLines.add(line);
      }
    }


    //synchronized (lines) {
    lines.clear();
    lines.addAll(bouncyLines);
    lines.addAll(otherLines);
    //}
  }


  void moveSelectableNoPhysicsToBack() {
    CopyOnWriteArrayList<Line> selectableLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> otherLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into selectableNoPhysics and others
    for (Line line : lines) {
      if (line.isSelectableNoPhysics) {
        selectableLines.add(line);
      } else {
        otherLines.add(line);
      }
    }

    // Rebuild the list: non-selectable lines first, selectableNoPhysics lines last
    lines.clear();
    lines.addAll(selectableLines);
    lines.addAll(otherLines);
  }

  void moveBLinesToFront() {
    CopyOnWriteArrayList<Line> bouncyLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> otherLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into death and non death
    for (Line line : lines) {
      if (line.isBouncy) {
        bouncyLines.add(line);
      } else {
        otherLines.add(line);
      }
    }

    // Clear the original list and add death lines first
    lines.clear();
    lines.addAll(otherLines);
    lines.addAll(bouncyLines);
  }

  void moveFramesToFront() {
    CopyOnWriteArrayList<Line> frameLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> otherLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into frame and non-frame
    for (Line line : lines) {
      if (line.isFrame) {
        frameLines.add(line);
      } else {
        otherLines.add(line);
      }
    }

    // Clear the original list and add frame lines first
    lines.clear();
    lines.addAll(otherLines);
    lines.addAll(frameLines);
  }



  void moveFloorsToFront() {
    CopyOnWriteArrayList<Line> floorLines = new CopyOnWriteArrayList<Line>();
    CopyOnWriteArrayList<Line> otherLines = new CopyOnWriteArrayList<Line>();

    // Separate lines into floor and non-floor
    for (Line line : lines) {
      if (line.isFloor) {
        floorLines.add(line);
      } else {
        otherLines.add(line);
      }
    }

    // Clear the original list and add floor lines first
    lines.clear();
    lines.addAll(otherLines);

    lines.addAll(floorLines);
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
    }
    if (patternName.equals("BG Pattern 02")) {
      bgPatternNestedSquares();
    }
    if (patternName.equals("BG Pattern 03")) {
      bgPattern01();
    }
    if (patternName.equals("BG Pattern 04")) {
      bgPattern04();
    }
    if (patternName.equals("BG Pattern 05")) {
      bgPattern05();
    }
    if (patternName.equals("BG Pattern 06")) {
      bgPatternUniformSquaresGrid();
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

  void bgPattern04() {
    int numBackgroundLines = (int)random(50, 100); // Random number of background lines, very dense

    int[] specificSchemes = new int[]{};

    if (settings.rndlyChooseOneSchemeForBg[0]) {
      specificSchemes = new int[]{(int)random(numOfColorSchemesAvailable)};
    }
    float angle1 = random(0, 180);
    float angle2 = angle1 + 90;

    int scheme;
    if (specificSchemes.length > 0) {
      scheme = specificSchemes[(int)random(specificSchemes.length)];
    } else {
      scheme = (int)random(numOfColorSchemesAvailable); // Assuming getRandomColor has 53 cases
    }
    for (int i = 1; i <= numBackgroundLines; i++) {
      // Randomize the position of the line (within the width and height)
      float centerX = random(startOfWidth, endOfWidth);
      float centerY = random(startOfHeight, endOfHeight);

      // Randomize the width and height to make the lines thin (very small width or height)
      float lineWidth = 1;  // Thin line width
      float lineHeight = 2000; // Thin line height

      // Randomly choose one of two perpendicular angles: 0 or 90 degrees
      float angle = random(0, 360); // Randomly choose between horizontal (0) or vertical (90)

      boolean isDeath = false; // Background lines are not death lines

      color lineColor;



      lineColor = getRandomColor(scheme);

      // Create the Line object for the background
      Line backgroundLine = new Line(centerX, centerY, lineWidth, lineHeight, angle, isDeath);

      // Set the color for the line
      backgroundLine.lineColor = lineColor;
      backgroundLine.setAsBgLine();

      // Add the line to the LineManager
      lines.add(0, backgroundLine);
    }

    //Line backgroundLine = new Line(endOfWidth - startOfWidth, endOfHeight - startOfHeight, 2000, 2000, 0, false);

    ////int scheme = (int)random(numOfColorSchemesAvailable);
    //backgroundLine.lineColor = getRandomColor(scheme);
    //backgroundLine.setAsBgLine();
    //lines.add(0, backgroundLine);
  }

  void bgPattern05() {
    int numBackgroundLines = (int)random(50, 100); // Random number of background lines, very dense

    int[] specificSchemes = new int[]{};

    if (settings.rndlyChooseOneSchemeForBg[0]) {
      specificSchemes = new int[]{(int)random(numOfColorSchemesAvailable)};
    }
    float angle = random(0, 180);

    int scheme;
    if (specificSchemes.length > 0) {
      scheme = specificSchemes[(int)random(specificSchemes.length)];
    } else {
      scheme = (int)random(numOfColorSchemesAvailable); // Assuming getRandomColor has 53 cases
    }


    for (int i = 1; i <= numBackgroundLines; i++) {
      // Randomize the position of the line (within the width and height)
      float centerX = random(startOfWidth, endOfWidth);
      float centerY = random(startOfHeight, endOfHeight);

      // Randomize the width and height to make the lines thin (very small width or height)
      float lineWidth = 1;  // Thin line width
      float lineHeight = 2000; // Thin line height

      boolean isDeath = false; // Background lines are not death lines

      color lineColor;

      lineColor = getRandomColor(scheme);

      // Create the Line object for the background
      Line backgroundLine = new Line(centerX, centerY, lineWidth, lineHeight, angle, isDeath);

      // Set the color for the line
      backgroundLine.lineColor = lineColor;
      backgroundLine.setAsBgLine();

      // Add the line to the LineManager
      lines.add(0, backgroundLine);
    }

    angle += 90;
    if (random(1) < 0.5) {
      for (int i = 1; i <= numBackgroundLines; i++) {
        // Randomize the position of the line (within the width and height)
        float centerX = random(startOfWidth, endOfWidth);
        float centerY = random(startOfHeight, endOfHeight);

        // Randomize the width and height to make the lines thin (very small width or height)
        float lineWidth = 1;  // Thin line width
        float lineHeight = 2000; // Thin line height

        boolean isDeath = false; // Background lines are not death lines

        color lineColor;

        lineColor = getRandomColor(scheme);

        // Create the Line object for the background
        Line backgroundLine = new Line(centerX, centerY, lineWidth, lineHeight, angle, isDeath);

        // Set the color for the line
        backgroundLine.lineColor = lineColor;
        backgroundLine.setAsBgLine();

        // Add the line to the LineManager
        lines.add(0, backgroundLine);
      }
    }
    //Line backgroundLine = new Line(endOfWidth - startOfWidth, endOfHeight - startOfHeight, 2000, 2000, 0, false);

    ////int scheme = (int)random(numOfColorSchemesAvailable);
    //backgroundLine.lineColor = getRandomColor(scheme);
    //backgroundLine.setAsBgLine();
    //lines.add(0, backgroundLine);
  }

  void bgPatternUniformSquaresGrid() {
    int gridRows = (int) random(3, 8);
    int gridCols = gridRows;


    // Determine the width and height of each grid cell
    float gridWidth = (endOfWidth - startOfWidth + 200) / gridCols;
    //float gridHeight = (endOfHeight - startOfHeight + 200) / gridRows;

    float gridHeight;
    float minSquareSize;
    if (random (1) < 0.5) {
      gridHeight = gridWidth;
      minSquareSize = min(gridWidth, gridHeight) - 30;
    } else {
      gridHeight = (endOfHeight - startOfHeight + 200) / gridRows;
      minSquareSize = min(gridWidth, gridHeight) - 10;
    }

    // Define maxSquareSize as 10 units less than the cell size
    float maxSquareSize = min(gridWidth, gridHeight);

    int[] specificSchemes = new int[]{};

    // Check if a specific color scheme should be used
    if (settings.rndlyChooseOneSchemeForBg[0]) {
      specificSchemes = new int[]{(int)random(numOfColorSchemesAvailable)};
    }

    float squareWidth = random(minSquareSize, maxSquareSize);
    float squareHeight = squareWidth;

    // Randomly select a color scheme if needed
    int scheme;
    if (specificSchemes.length > 0) {
      scheme = specificSchemes[(int)random(specificSchemes.length)];
    } else {
      scheme = (int)random(numOfColorSchemesAvailable); // Assuming getRandomColor has 53 cases
    }
    // Loop through the grid to create squares
    for (int row = 0; row < gridRows; row++) {
      for (int col = 0; col < gridCols; col++) {


        // Calculate the random size for the current square


        // Directly position the square within its grid cell (centered)
        float posX = startOfWidth - 100 + col * gridWidth + gridWidth / 2;
        float posY = startOfHeight - 100 + row * gridHeight + gridHeight / 2;

        // Randomly move the square a little bit
        //posX += random(-40, 40);
        //posY += random(-40, 40);



        // Get the color for the square
        color squareColor = getRandomColor(scheme);
        float angle = 0;
        // Create the square using the Line class
        Line squareLine = new Line(posX, posY, squareWidth, squareHeight, angle, false); // 0 degrees (no rotation)

        // Set the color of the square
        squareLine.lineColor = squareColor;
        squareLine.setAsBgLine();

        // Add the square to the LineManager
        lines.add(0, squareLine);
      }
    }
    Line backgroundLine = new Line(endOfWidth - startOfWidth, endOfHeight - startOfHeight, 2000, 2000, 0, false);

    //int scheme = (int)random(numOfColorSchemesAvailable);
    backgroundLine.lineColor = getRandomColor(scheme);
    backgroundLine.setAsBgLine();
    lines.add(0, backgroundLine);
  }

  void bgPatternNonUniformSquaresGrid() {
    int gridRows = (int) random(3, 8);
    int gridCols = gridRows;

    // Determine the width and height of each grid cell
    float gridWidth = (endOfWidth - startOfWidth + 200) / gridCols;
    //float gridHeight = (endOfHeight - startOfHeight + 200) / gridRows;

    float gridHeight;
    float minSquareSize;

    gridHeight = gridWidth;
    minSquareSize = min(gridWidth, gridHeight) - 100;

    // Define maxSquareSize as 10 units less than the cell size
    float maxSquareSize = min(gridWidth, gridHeight);

    int[] specificSchemes = new int[]{};

    // Check if a specific color scheme should be used
    if (settings.rndlyChooseOneSchemeForBg[0]) {
      specificSchemes = new int[]{(int)random(numOfColorSchemesAvailable)};
    }


    // Randomly select a color scheme if needed
    int scheme;
    if (specificSchemes.length > 0) {
      scheme = specificSchemes[(int)random(specificSchemes.length)];
    } else {
      scheme = (int)random(numOfColorSchemesAvailable); // Assuming getRandomColor has 53 cases
    }

    float angle = random(360);
    // Loop through the grid to create squares
    for (int row = 0; row < gridRows; row++) {
      for (int col = 0; col < gridCols; col++) {

        float squareWidth = random(minSquareSize, maxSquareSize);
        //float squareHeight = random(minSquareSize, maxSquareSize);
        float squareHeight = squareWidth;

        // Directly position the square within its grid cell (centered)
        float posX = startOfWidth - 100 + col * gridWidth + gridWidth / 2;
        float posY = startOfHeight - 100 + row * gridHeight + gridHeight / 2;

        // Randomly move the square a little bit
        //posX += random(-40, 40);
        //posY += random(-40, 40);


        // Get the color for the square
        color squareColor = getRandomColor(scheme);

        // Create the square using the Line class
        Line squareLine = new Line(posX, posY, squareWidth, squareHeight, angle, false); // 0 degrees (no rotation)

        // Set the color of the square
        squareLine.lineColor = squareColor;
        squareLine.setAsBgLine();

        // Add the square to the LineManager
        lines.add(0, squareLine);
      }
    }
    //Line backgroundLine = new Line(endOfWidth - startOfWidth, endOfHeight - startOfHeight, 2000, 2000, 0, false);

    ////int scheme = (int)random(numOfColorSchemesAvailable);
    //backgroundLine.lineColor = getRandomColor(scheme);
    //backgroundLine.setAsBgLine();
    //lines.add(0, backgroundLine);
  }

  void bgPatternNestedSquares() {
    int numLayers = (int)random(10, 30); // Number of nested square layers
    float maxSize = random (1100, 1400);
    float centerX = (startOfWidth + endOfWidth) / 2;
    float centerY = (startOfHeight + endOfHeight) / 2;

    centerX = random(startOfWidth, endOfWidth);
    centerY = random (startOfHeight, endOfHeight);

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
    float angle = random(0, 360);
    for (int l = 1; l <= numLayers; l++) {
      float size = maxSize * (1 - (float)l / (numLayers + 1));
      if (l == 1) size = 1500;

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

  void removeNoPhysicsDuplicatesFromLines() {
    if (noPhysicsDuplicateLineMap == null || noPhysicsDuplicateLineMap.isEmpty())  return;
    // Iterate through the noPhysicsDuplicateLineMap and remove lines that are considered duplicates
    for (Map.Entry<Line, Line> entry : noPhysicsDuplicateLineMap.entrySet()) {
      Line duplicateLine = entry.getValue();
      lines.remove(duplicateLine);
    }
    for (Line line : lines) { // this is useful if let's say a map pasted from bonk io has its own noPhysics shapes.
      if (line.noPhysics && !line.isBgLine && !line.isOnlyForProgram)
        lines.remove(line);
    }
  }


  void updateNoPhysicsDuplicatesColor() {
    if (!settings.addNoPhysicsLineDuplicates[0] || noPhysicsDuplicateLineMap == null)  return;
    removeNoPhysicsDuplicatesFromLines();
    duplicateAndScaleDownLines(lines);

    //    for (Map.Entry<Line, Line> entry : noPhysicsDuplicateLineMap.entrySet()) {
    //      Line duplicateLine = entry.getValue();
    //      Line originalLine = entry.getKey();
    //      float brightnessAdjustment = random(-120, 120);
    //      duplicateLine.lineColor = adjustBrightness(originalLine.lineColor, brightnessAdjustment);
    //    }
  }



  void duplicateAndScaleDownLines(CopyOnWriteArrayList<Line> lines) {
    //removeNoPhysicsDuplicatesFromLines();

    // Create a map to track the relationship between physics lines and their duplicates

    noPhysicsDuplicateLineMap = new HashMap<>();
    CopyOnWriteArrayList<Line> duplicates = new CopyOnWriteArrayList<Line>();

    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (!line.noPhysics && !line.isCapzone) {
        // Create a duplicate of the original line
        float gapBetweenOuterAndInnersEdges = line.height > line.width ? line.width * 0.2 : line.height * 0.2;
        Line duplicate = new Line(line.centerX, line.centerY, line.width - gapBetweenOuterAndInnersEdges, line.height - gapBetweenOuterAndInnersEdges, line.angle, line.isDeath);

        // Set noPhysics to true for the duplicate
        duplicate.noPhysics = true;

        // Adjust the color of the duplicate to be slightly brighter or darker
        float brightnessAdjustment = random(-120, 120);
        duplicate.lineColor = adjustBrightness(line.lineColor, brightnessAdjustment);

        // Add the duplicate to the list of duplicates
        noPhysicsDuplicateLineMap.put(line, duplicate);

        // Insert the duplicate right after the original line in the 'lines' list
        lines.add(i + 1, duplicate);
      }
    }
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
    float frameWidth = EXTRA_FRAME_WIDTH + settings.frameWidth[0];
    boolean isDeath = settings.areFramesDeath[0];
    float angle = random(settings.frameAngleStart[0], settings.frameAngleEnd[0]);

    // Calculate the center of the frame
    float centerX = (startOfWidth + endOfWidth) / 2;
    float centerY = (startOfHeight + endOfHeight) / 2;

    float horizontalFrameHeight = endOfWidth - startOfWidth + EXTRA_FRAME_WIDTH;
    float verticalFrameHeight = endOfHeight - startOfHeight + EXTRA_FRAME_WIDTH;

    float differenceBtwHorAndVerFrames = 0;

    if (angle != 0) {
      differenceBtwHorAndVerFrames = horizontalFrameHeight - verticalFrameHeight;
      horizontalFrameHeight = verticalFrameHeight;
    }

    // Convert angle to radians
    float angleRad = (float) Math.toRadians(angle);

    // Create and rotate each frame line
    lines.add(createRotatedFrameLine(centerX, centerY, (startOfWidth + endOfWidth) / 2, startOfHeight - EXTRA_FRAME_WIDTH / 2, horizontalFrameHeight, frameWidth, 0, angleRad, isDeath)); // Ceiling
    lines.add(createRotatedFrameLine(centerX, centerY, endOfWidth - differenceBtwHorAndVerFrames / 2 + EXTRA_FRAME_WIDTH / 2, (startOfHeight + endOfHeight) / 2, verticalFrameHeight, frameWidth, 90, angleRad, isDeath)); // Right wall
    lines.add(createRotatedFrameLine(centerX, centerY, (startOfWidth + endOfWidth) / 2, endOfHeight + EXTRA_FRAME_WIDTH / 2, horizontalFrameHeight, frameWidth, 0, angleRad, isDeath)); // Floor
    lines.add(createRotatedFrameLine(centerX, centerY, startOfWidth + differenceBtwHorAndVerFrames / 2 - EXTRA_FRAME_WIDTH / 2, (startOfHeight + endOfHeight) / 2, verticalFrameHeight, frameWidth, 90, angleRad, isDeath)); // Left wall
  }

  // Helper method to rotate and create a line
  Line createRotatedFrameLine(float centerX, float centerY, float x, float y, float width, float height, float baseRotation, float angleRad, boolean death) {
    // Apply rotation transformation
    float rotatedX = (float) ((x - centerX) * Math.cos(angleRad) - (y - centerY) * Math.sin(angleRad) + centerX);
    float rotatedY = (float) ((x - centerX) * Math.sin(angleRad) + (y - centerY) * Math.cos(angleRad) + centerY);

    // Create the line with the new rotated position and adjusted rotation
    Line line = new Line(rotatedX, rotatedY, width, height, baseRotation + (float) Math.toDegrees(angleRad), death);
    line.setAsFrame(death); // If death is not passed here, then removeBounceAndDeathIfHasGrapple() in Line can sometimes remove death.
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

  void clearDeathLines() {
    for (int i = lines.size() - 1; i >= 0; i--) {
      Line line = lines.get(i);
      if (!line.isBgLine && !line.isFrame && !line.isOnlyForProgram && !line.isFloor && line.isDeath) {
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

  color getRandomColorWithCheck(HashSet<Integer> usedColors) {
    color colorX;
    do {
      colorX = getRandomColor((int) random(numOfColorSchemesAvailable)); // Get a random color
    } while (usedColors.contains(colorX)); // Check if the color has already been used

    usedColors.add(colorX); // Add the color to the set
    return colorX; // Return the unique color
  }

  void setRandomValues() {

    HashSet<Integer> usedColors = new HashSet<Integer>();

    // Assign unique colors
    settings.deathColor = getRandomColorWithCheck(usedColors);
    settings.nonDeathColor = getRandomColorWithCheck(usedColors);
    settings.bouncyColor = getRandomColorWithCheck(usedColors);
    settings.grappleColor = getRandomColorWithCheck(usedColors);
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
    if (settings.areDLinesAtBack[0]) moveDLinesToBack();
    else moveDLinesToFront();
  }

  void moveBLinesToFrontOrBack() {
    if (settings.areBLinesAtBack[0]) moveBLinesToBack();
    else moveBLinesToFront();
  }

  void moveLinesForwardOrBackward() {
    moveDLinesToFrontOrBack();
    moveBLinesToFrontOrBack();
    moveSelectableNoPhysicsToBack();
    moveFloorsToFront();
    moveFramesToFront();
    moveBgLinesToBack();

    moveLinesForProgramToFront();
  }

  /**
   * Returns true if (px,py) lies inside the rectangle centered at (cx,cy),
   * of dimensions w×h, rotated by angle θ (radians).
   */
  boolean pointInRotatedRect(float px, float py,
    float cx, float cy,
    float w, float h,
    float angleDeg) {
    // Build world-space corners
    float theta = radians(angleDeg);
    float cosT = cos(theta), sinT = sin(theta);
    float hw = w/2, hh = h/2;
    PVector[] corners = {
      new PVector(-hw, -hh),
      new PVector( hw, -hh),
      new PVector( hw, hh),
      new PVector(-hw, hh)
    };
    for (int i = 0; i < 4; i++) {
      float x = corners[i].x * cosT - corners[i].y * sinT + cx;
      float y = corners[i].x * sinT + corners[i].y * cosT + cy;
      corners[i].set(x, y);
    }

    // Cross-product sign test
    boolean hasNeg = false, hasPos = false;
    for (int i = 0; i < 4; i++) {
      PVector a = PVector.sub(corners[(i+1)%4], corners[i]);
      PVector b = PVector.sub(new PVector(px, py), corners[i]);
      float cross = a.cross(b).z;
      if (cross < 0) hasNeg = true;
      else if (cross > 0) hasPos = true;
      if (hasNeg && hasPos) return false;  // point is outside
    }
    return true;  // all crosses same sign → inside
  }
}
