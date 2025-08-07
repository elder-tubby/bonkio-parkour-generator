class Line {

  ArrayList<Integer> usedIds = new ArrayList<>();
  int id = 0;
  float centerX, centerY;
  float width, height;
  float angle;
  boolean isDeath;
  boolean isDeathOgValue; // used so if, after lines are drawn, one of the lines is toggled to bouncy then back to non-bouncy, then it should become death again instead of non-death.
  boolean isBouncy;
  String bounciness;
  boolean hasGrapple;
  boolean noPhysics;
  float friction;
  color lineColor;
  boolean[] cornersConnected = new boolean[2]; // Keeps track of the connection state of each corner
  boolean isFrame;
  boolean isFloor;
  boolean isBgLine;
  boolean isOnlyForProgram;
  boolean isCapzone;
  boolean isNoJump;
  boolean isSelectableNoPhysics;

  Line(float x, float y, float w, float h, float a, boolean death) {
    centerX = x;
    centerY = y;
    width = w;
    height = h;
    angle = a;
    isDeath = death;
    isDeathOgValue = isDeath;
    isBouncy = !isDeath && random(1) < settings.chancesOfBounciness[0];
    bounciness = isBouncy ? settings.globalBounciness : "-1";
    hasGrapple = random(1) < settings.chancesOfGrapple[0];
    noPhysics = false;
    friction = 0;
    isCapzone = false;
    isNoJump = false;

    removeBounceAndDeathIfHasGrapple();

    if (!settings.sameColorForAllDLines[0]) {
      settings.deathColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    }

    if (!settings.sameColorForAllNonDLines[0]) {
      settings.nonDeathColor = getRandomColor((int)random(numOfColorSchemesAvailable));
      //nonDeathColor = getRandomColor((int)random(53));
    }

    if (!settings.sameColorForAllBLines[0]) {
      settings.bouncyColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    }

    if (!settings.sameColorForAllGLines[0]) {
      settings.grappleColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    }
    setColors();

    // Initialize cornersConnected array
    for (int i = 0; i < cornersConnected.length; i++) {
      cornersConnected[i] = false;
    }

    id = generateUniqueId();
  }

  void removeBounceAndDeathIfHasGrapple() {

    if (hasGrapple) {
      isDeath = false;
      isBouncy = false;
    }
  }

  void setColors() {
    //lineColor = getRandomColor((int)random(numOfColorSchemesAvailable));
    if (isSelectableNoPhysics) {
      lineColor = color(50, 100, 90);
    } else if (isDeath && !hasGrapple)
      lineColor = settings.deathColor;
    else if (isBouncy && !hasGrapple)
      lineColor = settings.bouncyColor;
    else if (hasGrapple)
      lineColor = settings.grappleColor;
    else
      lineColor = settings.nonDeathColor;
  }

  int generateUniqueId() {
    int newId;
    do {
      newId = (int)random(Integer.MAX_VALUE - 1) + 2; // Avoid 1 as a possible ID
    } while (usedIds.contains(newId));
    usedIds.add(newId);
    return newId;
  }

  void drawLine(boolean isSelected) {
    if (!noPhysics || isSelectableNoPhysics)
      setColors();

    pushMatrix();
    translate(centerX, centerY);
    rotate(radians(angle));
    if (isSelected) {
      stroke(255, 0, 0);  // Red outline for selected line
      strokeWeight(3);
    } else {
      noStroke();  // No outline for unselected lines
    }
    if (isNoJump || isCapzone) {


      stroke(255);  // Set border to white
      strokeWeight(2);  // Set desired stroke weight for the border
      noFill();  // Fully transparent fill
      if (isSelected) {
        stroke(255, 0, 0);  // Red outline for selected line
        strokeWeight(3);
      }
    } else {
      fill(lineColor);
    }
    rectMode(CENTER);
    rect(0, 0, width, height);
    popMatrix();
  }

  PVector[] getCorners() {
    PVector[] corners = new PVector[4];

    float halfW = width / 2;
    float halfH = height / 2;

    corners[0] = new PVector(-halfW, -halfH);
    corners[1] = new PVector(halfW, -halfH);
    corners[2] = new PVector(halfW, halfH);
    corners[3] = new PVector(-halfW, halfH);


    for (int i = 0; i < corners.length; i++) {
      PVector corner = corners[i];
      float tempX = corner.x * cos(radians(angle)) - corner.y * sin(radians(angle));
      float tempY = corner.x * sin(radians(angle)) + corner.y * cos(radians(angle));
      corners[i] = new PVector(tempX + centerX, tempY + centerY);
    }
    return corners;
  }

  PVector[] getEdgePoints(boolean forLineToMove) {
    PVector[] edgePoints = new PVector[4];

    // Calculate the half width and height
    float halfW = width / 2;
    float halfH = height / 2;

    PVector edge0 = new PVector(0, 0);
    PVector edge1 = new PVector(0, 0);
    PVector edge2 = new PVector(0, 0);
    PVector edge3 = new PVector(0, 0);

    fill(255);
    stroke(1);

    // Define the points on the edge of the line segment

    if (forLineToMove) { // the edgepoints returned for lineToMove are at the center   of the edges
      edge0 = new PVector(-halfW, 0); // Left edge point in local coordinates
      edge1 = new PVector(halfW, 0); // Right edge point in local coordinates
      edge2 = new PVector(0, -halfH);
      edge3 = new PVector(0, halfH);

      if (settings.lineToMoveConnectPointStart[0] == 0 && settings.lineToMoveConnectPointEnd[0] == 0) {
        settings.lineToMoveConnectPointStart[0] = 0.01;
      }

      float distanceFactor = random(settings.lineToMoveConnectPointStart[0], settings.lineToMoveConnectPointEnd[0]);
      //distanceFactor = 0.01;
      //distanceFactor = random(1) < 0.5 ? distanceFactor * (-1) : distanceFactor; // Don't think this is needed

      edge0 = new PVector(-halfW * distanceFactor, 0); // Left edge point in local coordinates
      edge1 = new PVector(halfW * distanceFactor, 0); // Right edge point in local coordinates
      edge2 = new PVector(0, -halfH * distanceFactor);
      edge3 = new PVector(0, halfH * distanceFactor);
    } else { // the edgepoints returned for lineToConnectWith are at the corners of the edges
      float randomChoice = random(1);
      if (randomChoice < 0.25) { // randomly choose the side of the corners
        edge0 = new PVector(-halfW, -halfH);
        edge1 = new PVector(halfW, -halfH);
      } else if (randomChoice >= 0.25 && randomChoice < 0.5) {
        edge0 = new PVector(-halfW, halfH);
        edge1 = new PVector(halfW, halfH);
      } else if (randomChoice >= 0.5 && randomChoice < 0.75) {
        edge0 = new PVector(-halfW, halfH);
        edge1 = new PVector(-halfW, -halfH);
      } else if (randomChoice >= 0.75 && randomChoice < 1) {
        edge0 = new PVector(halfW, -halfH);
        edge1 = new PVector(halfW, halfH);
      }
    }

    // Rotate and translate the edge points
    float angleRad = radians(angle); // Convert angle to radians
    PVector edge0Rotated = new PVector(
      edge0.x * cos(angleRad) - edge0.y * sin(angleRad) + centerX,
      edge0.x * sin(angleRad) + edge0.y * cos(angleRad) + centerY
      );

    PVector edge1Rotated = new PVector(
      edge1.x * cos(angleRad) - edge1.y * sin(angleRad) + centerX,
      edge1.x * sin(angleRad) + edge1.y * cos(angleRad) + centerY
      );

    PVector edge2Rotated = new PVector(
      edge2.x * cos(angleRad) - edge2.y * sin(angleRad) + centerX,
      edge2.x * sin(angleRad) + edge2.y * cos(angleRad) + centerY
      );

    PVector edge3Rotated = new PVector(
      edge3.x * cos(angleRad) - edge3.y * sin(angleRad) + centerX,
      edge3.x * sin(angleRad) + edge3.y * cos(angleRad) + centerY
      );

    // Assign to the edgePoints array
    edgePoints[0] = edge0Rotated; // Leftmost point
    edgePoints[1] = edge1Rotated; // Rightmost point
    edgePoints[2] = edge2Rotated;
    edgePoints[3] = edge3Rotated;

    //ellipse(edgePoints[0].x, edgePoints[0].y, 5, 5); // Draw circle at edge0 with radius 25
    //ellipse(edgePoints[1].x, edgePoints[1].y, 5, 5); // Draw circle at edge1 with radius 25
    //ellipse(edgePoints[2].x, edgePoints[2].y, 5, 5); // Draw circle at edge0 with radius 25
    //ellipse(edgePoints[3].x, edgePoints[3].y, 5, 5); // Draw circle at edge1 with radius 25

    return edgePoints;
  }

  boolean isMouseOver(float mouseX, float mouseY) {
    // Translate the mouse position to the rectangle's local coordinate system
    float localX = mouseX - centerX;
    float localY = mouseY - centerY;

    // Rotate the mouse coordinates in the opposite direction of the rectangle's rotation
    float angleRad = radians(-angle);  // Invert the rotation
    float rotatedX = localX * cos(angleRad) - localY * sin(angleRad);
    float rotatedY = localX * sin(angleRad) + localY * cos(angleRad);

    // Check if the rotated mouse coordinates are within the bounds of the rectangle
    return abs(rotatedX) <= width / 2 && abs(rotatedY) <= height / 2;
  }

  void setAsFrame(boolean areFramesDeath) {
    isFrame = true;
    isDeath = areFramesDeath;
    isBouncy = settings.areFramesBouncy[0];
    hasGrapple = false;
    if (isBouncy) {
      makeBouncy();
    } else {
      makeNonBouncy();
    }

    if (isDeath)
      lineColor = settings.deathColor;
    else if (isBouncy)
      lineColor = settings.bouncyColor;
    else if (hasGrapple)
      lineColor = settings.grappleColor;
    else
      lineColor = settings.nonDeathColor;
  }

  void setAsFloor() {
    isFloor = true;
    isBouncy = settings.areFloorsBouncy[0];
    if (isBouncy) {
      makeBouncy();
    } else {
      makeNonBouncy();
    }

    removeBounceAndDeathIfHasGrapple();
    if (isDeath)
      lineColor = settings.deathColor;
    else if (isBouncy)
      lineColor = settings.bouncyColor;
    else if (hasGrapple)
      lineColor = settings.grappleColor;
    else
      lineColor = settings.nonDeathColor;
  }

  void setAsSelectableNoPhysics() {
    isSelectableNoPhysics = true;
    noPhysics = true;

    isDeath = false;
    isDeathOgValue = false;
    isBouncy = false;
    hasGrapple = false;
    isFrame = false;
    isFloor = false;
    isBgLine = false;
    isOnlyForProgram = false;
    isCapzone = false;
    isNoJump = false;
  }


  void makeDeath() {
    isCapzone = false;
    isNoJump = false;
    isDeathOgValue = true;
    isBouncy = false;
    isDeath = true;
    if (!hasGrapple)
      lineColor = settings.deathColor;
  }

  void makeNonDeath() { // for changing from death to eiter bouncy or non bouncy
    isDeathOgValue = false;
    isDeath = false;
    if (!isBouncy)
      lineColor = settings.nonDeathColor;
  }

  void makeBouncy() {
    isCapzone = false;
    isNoJump = false;
    isDeath = false;
    isBouncy = true;
    bounciness = settings.globalBounciness;
    if (!hasGrapple)
      lineColor = settings.bouncyColor;
  }

  void makeNonBouncy() { // for changing from bouncy to non bouncy
    isBouncy = false;
    bounciness = "-1";
    if (isDeathOgValue) {
      isDeath = isDeathOgValue;
      lineColor = settings.deathColor;
    } else if (!isDeath) {
      lineColor = settings.nonDeathColor;
    }
  }

  void makeGrapplable() {
    hasGrapple = true;
    lineColor = settings.grappleColor;
    isCapzone = false;
    isNoJump = false;
  }

  void makeNonGrapplable() {
    hasGrapple = false;
    if (isDeath)
      lineColor = settings.deathColor;
    else if (isBouncy)
      lineColor = settings.bouncyColor;
    else if (!isDeath)
      lineColor = settings.nonDeathColor;
  }

  void setAsOnlyForProgram() {
    isOnlyForProgram = true;
    noPhysics = true;
  }

  void setAsBgLine() {
    isBgLine = true;
    noPhysics = true;
  }

  void setAsNoJump() {
    hasGrapple = false;
    isNoJump = true;
    isCapzone = false;
    isDeath = false;
    isBouncy = false;
    bounciness = "-1";
  }

  void setAsCapzone() {
    hasGrapple = false;
    isCapzone = true;
    isDeath = false;
    isNoJump = false;
    isBouncy = false;
    bounciness = "-1";
  }
}
