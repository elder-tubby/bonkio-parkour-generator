class MoreOptionsPage {

  List<Controller> elements = new ArrayList<>();

  float startingYPos = 100;
  float xPos = 22;
  float verticalGap = 40;
  int elementWidth = 400;
  int elementHeight = 30;

  int uiIndexInColumn;

  MoreOptionsPage() {

    initialize();
  }

  List<Controller> initialize() {
    uiIndexInColumn = 0;
    createDeathAroundPathButton();
    createPathTightnessSlider();
    //createDeathOnPathButton();
    createClearLinesToggle();
    createSettingsRandomizerBtn();
    createExchangeBAndDLinesBtn();
    createZoomBtns();
    createToggleScriptManagerBtn();
    return elements;
  }

  void createDeathAroundPathButton() {
    
    println("uiIndexInColumn " + uiIndexInColumn);

    elements.add(cp5.addButton("deathAroundPathButton")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setLabel("create death around copied player path (x)")
      .setFont(defaultFont)
      .setSize(elementWidth, elementHeight)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleCreateDeathFromPathClick(false);
      }
    }
    ));
    uiIndexInColumn++;
  }

  void createPathTightnessSlider() {
    Slider slider = cp5.addSlider("pathTightnessslider")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setRange(0, 200)
      .setValue(settings.pathTightness[0])
      .setFont(defaultFont)
      .setSize(elementWidth, elementHeight)
      .setLabel("path tighness")
      .onChange((e) -> {
      settings.pathTightness[0] = e.getController().getValue();
    }
    );
    slider.getCaptionLabel()
      .align(ControlP5.CENTER, ControlP5.CENTER);
    //slider.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
    elements.add(slider);
    uiIndexInColumn++;
  }


  void createDeathOnPathButton() {

    elements.add(cp5.addButton("deathOnPathButton")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setLabel("create lines on copied player path")
      .setFont(defaultFont)
      .setSize(elementWidth, elementHeight)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleCreateDeathFromPathClick(true);
      }
    }
    ));
    uiIndexInColumn++;
  }

  void createClearLinesToggle() {
    Toggle toggle = cp5.addToggle("clearExistingLinesToggle")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setValue(clearExistingLines)
      .setLabel("clear existing lines when generating new ones")
      .setFont(defaultFont)
      .setSize(elementWidth, elementHeight)
      .onChange((e) -> {
      clearExistingLines = !clearExistingLines;
    }
    );
    toggle.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(10);

    elements.add(toggle);
    uiIndexInColumn++;
  }

  void createSettingsRandomizerBtn() {

    elements.add(cp5.addButton("settingsRandomizerBtn")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setLabel("set random values for all settings")
      .setFont(defaultFont)
      .setSize(elementWidth, elementHeight)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        setRandomSettingsValues();
      }
    }
    ));
    uiIndexInColumn++;
  }

  void createExchangeBAndDLinesBtn() {
    elements.add(cp5.addButton("exchangeBAndDLinesBtn")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setSize(elementWidth, elementHeight)
      .setFont(defaultFont)
      .setLabel("exchange B And D Lines")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        exchangeBAndDLines();
      }
    }
    ));
    uiIndexInColumn++;
  }

  void createZoomBtns() {

    elements.add(cp5.addButton("zoomInBtn")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setLabel("zoom in 1.25x")
      .setFont(defaultFont)
      .setSize(elementWidth / 2 - 20, elementHeight)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        zoomLines(1.25);
      }
    }
    ));


    elements.add(cp5.addButton("zoomOutBtn")
      .setPosition(xPos + 220, startingYPos + verticalGap * uiIndexInColumn)
      .setLabel("zoom Out 0.8x")
      .setFont(defaultFont)
      .setSize(elementWidth / 2 - 20, elementHeight)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        zoomLines(0.8);
      }
    }
    ));
    uiIndexInColumn++;
  }

  void createToggleScriptManagerBtn() {
    elements.add(cp5.addButton("toggleScriptManagerBtn")
      .setPosition(xPos, startingYPos + verticalGap * uiIndexInColumn)
      .setSize(elementWidth, elementHeight)
      .setFont(defaultFont)
      .setLabel("toggle script manager (ctrl + s)")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        scriptManager.toggleVisibility();
      }
    }
    ));
    uiIndexInColumn++;
  }

  void exchangeBAndDLines() {
    // Iterate through the lines list to find all lines that are death
    for (int i = 0; i < lines.size(); i++) {
      Line line = lines.get(i);

      if (line.noPhysics) continue;

      if (line.isDeath) {
        // Set the death line to be bouncy
        line.makeBouncy();
      } else if (line.isBouncy) {
        // Set the bouncy line to be death
        line.makeDeath();
      }
    }

    cp5.getController("lineDataCopiedLabel").hide();
  }

  void handleCreateDeathFromPathClick(boolean isDeathOnPath) {

    if (!settings.addFloors[0]) {
      //lineManager.clearFloors();
    }
    if (clearExistingLines)
      lineManager.clearDeathLines();
    //if (!settings.addFrames[0])
    //lineManager.clearFrames();
    if (noOfLines > 0) {
      cp5.getController("lineDataCopiedLabel").hide();
    }
    lineManager.createDeathFromPathAsync(isDeathOnPath);
  }

  void zoomLines(float zoomFactor) {
    // Calculate the canvas center
    float canvasCenterX = (startOfWidth + endOfWidth) / 2.0f;
    float canvasCenterY = (startOfHeight + endOfHeight) / 2.0f;

    List<Line> targetLines = (multiSelectedLines != null && !multiSelectedLines.isEmpty())
      ? multiSelectedLines
      : lines;

    for (Line line : targetLines) {
      if (line.isOnlyForProgram) continue;
      // Calculate offset from the canvas center
      float offsetX = line.centerX - canvasCenterX;
      float offsetY = line.centerY - canvasCenterY;

      // Scale the offset by the zoom factor and update the center position
      line.centerX = canvasCenterX + offsetX * zoomFactor;
      line.centerY = canvasCenterY + offsetY * zoomFactor;

      // Scale width and height by the zoom factor; enforce a minimum of 1
      float newWidth = line.width * zoomFactor;
      float newHeight = line.height * zoomFactor;
      line.width = (newWidth < 1) ? 1 : newWidth;
      line.height = (newHeight < 1) ? 1 : newHeight;
    }
  }


  public void setRandomSettingsValues() {

    // Random boolean for each field
    settings.sameHeightForAllLines[0] = random(0, 1) < 0.5;
    settings.sameWidthForAllLines[0] = random(0, 1) < 0.5;
    settings.setSpecificLineAngles[0] = random(0, 1) < 0.5;
    settings.limitLineAngleAfterConnectingItsCorner[0] = random(0, 1) < 0.5;

    settings.heightOfLine.set(0, random(1f, 50f)); // Random angle between 0 and 360
    settings.widthOfLine.set(0, random(1f, 200f)); // Random angle between 0 and 360


    //settings.sameColorForAllNonDLines[0] = random(0, 1) < 0.5;
    //settings.sameColorForAllDLines[0] = random(0, 1) < 0.5;
    //settings.sameColorForAllBLines[0] = random(0, 1) < 0.5;
    //settings.sameColorForAllGLines[0] = random(0, 1) < 0.5;
    //settings.canLinesOverlap[0] = random(0, 1) < 0.5;
    settings.addFrames[0] = true;
    settings.areFramesDeath[0] = random(0, 1) < 0.2;
    settings.areFramesBouncy[0] = random(0, 1) < 0.2;
    settings.addFloors[0] = random(0, 1) < 0.5;
    settings.areFloorsBouncy[0] = random(0, 1) < 0.5;
    settings.setSpecificFloorAngles[0] = random(0, 1) < 0.5;
    settings.connectFloorUp[0] = random(0, 1) < 0.5;
    settings.connectFloorDown[0] = random(0, 1) < 0.5;
    settings.connectFloorLeft[0] = random(0, 1) < 0.5;
    settings.connectFloorRight[0] = random(0, 1) < 0.5;

    // Random values for min-max pairs
    settings.minLineHeight[0] = random(1, 40); // Min value between 20 and 70
    settings.maxLineHeight[0] = random(settings.minLineHeight[0], 500); // Max value between 101 and 200
    settings.minLineWidth[0] = random(1, 40); // Min value between 10 and 100
    settings.maxLineWidth[0] = random(settings.minLineWidth[0], 500); // Max value between 101 and 300
    settings.minDistanceBtwNonDLinesAndDLines[0] = random(20, 60); // Min value between 19 and 49
    settings.minDistanceBtwNonDLines[0] = random(20, 60); // Min value between 19 and 49
    settings.minDistanceBtwDLines[0] = random(20, 60); // Min value between 19 and 49
    settings.minDistanceBtwFloors[0] = random(20, 60); // Min value between 30 and 50
    settings.minDistanceBtwNonDLinesAndFloors[0] = random(20, 60); // Min value between 19 and 49
    settings.minDistanceBtwDLinesAndFloors[0] = random(20, 60); // Min value between 19 and 49
    settings.minDistanceBtwNonDLinesAndFrames[0] = random(10, 60); // Min value between 10 and 20
    settings.minDistanceBtwDLinesAndFrames[0] = random(10, 60); // Min value between 10 and 20
    settings.minDistanceBtwFloorsAndFrames[0] = random(10, 60); // Min value between 30 and 50
    settings.frameWidth[0] = random(1) < 0.5 ? random(1, 50) : random(51, 200); // Min value between 10 and 20
    settings.numOfFloors[0] = random(5, 30); // Min value between 10 and 15

    // Random values for chances (between 0 and 1)
    settings.chancesOfDeath[0] = random(0f, 1f);
    settings.chancesOfBounciness[0] = random(0f, 1f);
    settings.chancesOfGrapple[0] = 0;
    settings.chancesOfNoJump[0] = random(1) < 0.9 ? 0 : 1;

    settings.chancesForDLinesAndNonDLinesToConnect[0] = random(0f, 0.1f);
    settings.chancesForNonDLinesToConnect[0] = random(0f, 0.1f);
    settings.chancesForDLinesToConnect[0] = random(0f, 0.1f);
    settings.chancesForFloorsAndFloorsToConnect[0] = random(0f, 0.1f);
    settings.chancesForNonDLinesToConnectWithFloors[0] = random(0f, 0.1f);
    settings.chancesForDLinesToConnectWithFloors[0] = random(0f, 0.1f);
    settings.chancesForFloorsToConnectWithFrames[0] = random(0f, 0.1f);
    settings.chancesForDLinesToConnectWithFrames[0] = random(0f, 0.1f);
    settings.chancesForNonDLinesToConnectWithFrames[0] = random(0f, 0.1f);

    settings.chancesForDLinesToConnectAtCorner[0] = random(0f, 0.1f);
    settings.chancesForNonDLinesToConnectAtCorner[0] = random(0f, 0.1f);
    settings.chancesForDLinesAndFloorsToConnectAtCorner[0] = random(0f, 0.1f);
    settings.chancesForNonDLinesAndFloorsToConnectAtCorner[0] = random(0f, 0.1f);
    settings.chancesForDLinesAndNonDLinesToConnectAtCorner[0] = random(0f, 0.1f);
    settings.chancesForFloorsToConnectAtCorner[0] = random(0f, 0.1f);

    // Random values for s (between 0 and 360)
    settings.nonDLineAngle.set(0, random(0f, 360f)); // Random angle between 0 and 360
    settings.dLineAngle.set(0, random(0f, 360f)); // Random angle between 0 and 360
    settings.lineAngleStart[0] = random(0, 360); // Random angle between 0 and 360
    settings.lineAngleEnd[0] = random(0, 360); // Random angle between 0 and 360
    settings.lineConnectAngleStart[0] = random(0, 360); // Random angle between 0 and 360
    settings.lineConnectAngleEnd[0] = random(0, 360); // Random angle between 0 and 360

    settings.floorAngle.set(0, random(0f, 360f)); // Random angle between 0 and 360
    settings.floorAngleStart[0] = random(0, 360); // Random angle between 0 and 360
    settings.floorAngleEnd[0] = random(0, 360); // Random angle between 0 and 360

    float chance = random(1);

    settings.frameAngleStart[0] = chance < 0.5 ? 0 : random(0, 360);
    settings.frameAngleEnd[0] = chance < 0.5 ? 0 : random(0, 360);

    chance = random(1);

    settings.floorConnectAngleStart[0] =  chance < 0.5 ? 90 : random(0, 360);
    settings.floorConnectAngleEnd[0] =  chance < 0.5 ? 90 : random(0, 360);

    settings.minFloorWidth[0] = random(1, 50);
    settings.maxFloorWidth[0] = random(settings.minFloorWidth[0], 200);
    settings.floorHeight[0] = random(1, 100);

    settings.limitFloorAngleAfterConnect[0] = random(1) < 0.5;
    chance = random(1);
    settings.floorConnectAngleStart[0] = chance < 0.5 ? 90 : random(0, 360);
    settings.floorConnectAngleEnd[0] = chance < 0.5 ? 90 : random(0, 360);

    settings.lineToMoveConnectPointStart[0] = random(0, 1);
    settings.lineToMoveConnectPointEnd[0] = random(0, 1);

    uiManager.customMapPage.initialize();
  }
}
