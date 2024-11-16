class CustomMapPage {

  String groupTag = "";

  int xPosOfGroupChild = 22;
  int yPosOfGroupChild = 50;
  int uiGap = 30;
  int uiGapWithLine = 50;
  List<Toggle> groupToggles = new ArrayList<>();
  int uiElementHeight = 25;

  List<Controller> customMapFixedElements = new ArrayList<>();
  List<List<Controller>> subPages;
  List<Controller> savePopupElements;
  int activeSubPageIndex = 1;

  Textfield presetNameField;

  Map<String, List<String>> groupChildrenMap = new HashMap<>();

  List<Controller> initialize() {
    initializeCommonElements();
    initializeSubPages();
    return customMapFixedElements;
  }

  void setActiveSubPage(int index) {
    hideAllSubPages();

    // Show the selected subpage
    activeSubPageIndex = index;
    List<Controller> activeSubPage = subPages.get(activeSubPageIndex - 1);
    for (Controller controller : activeSubPage) {
      if (controller.getId() == ("groupTag".hashCode())) {
        controller.show();
        controller.setValue(0);
      }
    }
    updateLocks();
    updateSubPageBtnColor();
  }

  void initializeCommonElements() {


    int bg1Height = 410;
    int bg1Width = 500;
    int bg1XPos = 20;
    int bg1YPos = 180;
    int outLineWidth = 2;

    // Adding elements that act as background visuals
    customMapFixedElements.add(cp5.addButton("groupChildrenBg1")
      .setLabel("")
      .setPosition(bg1XPos, bg1YPos)
      .setVisible(false)
      .setSize(bg1Width, bg1Height)
      .setLock(true)
      .setColorBackground(color(8, 37, 63, 255)));

    customMapFixedElements.add(cp5.addButton("groupChildrenBg2")
      .setLabel("") // No label
      .setPosition(bg1XPos + outLineWidth, bg1YPos + outLineWidth)
      .setSize(bg1Width - outLineWidth * 2, bg1Height - outLineWidth * 2)
      .setLock(true)
      .setVisible(false)
      .setColorBackground(color(1, 0, 16, 255)));


    //customMapFixedElements.add(noOfLinesSlider);

    // Adding more buttons
    customMapFixedElements.add(cp5.addButton("exportBtn")
      .setPosition(420, 600)
      .setSize(100, 30)
      .setLabel("save preset")
      .setFont(defaultFont)
      .setVisible(false)

      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        showExportPopup();
      }
    }
    )
    );

    customMapFixedElements.add(cp5.addButton("customMapPage1Btn")
      .setPosition(420, 650)
      .setSize(30, 30)
      .setLabel("1")

      .setFont(defaultFont)
      .setVisible(false)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        setActiveSubPage(1);
      }
    }
    )
    );

    customMapFixedElements.add(cp5.addButton("customMapPage2Btn")
      .setPosition(455, 650)
      .setSize(30, 30)
      .setLabel("2")
      .setFont(defaultFont)
      .setVisible(false)

      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        setActiveSubPage(2);
      }
    }
    )
    );

    customMapFixedElements.add(cp5.addButton("customMapPage3Btn")
      .setPosition(490, 650)
      .setSize(30, 30)
      .setLabel("3")
      .setFont(defaultFont)
      .setVisible(false)

      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        setActiveSubPage(3);
      }
    }
    )
    );
  }

  void initializeSubPages() {
    subPages = new ArrayList<>();
    subPages.add(initializeSubPage1());
    subPages.add(initializeSubPage2());
    subPages.add(initializeSubPage3());

    updateAllLocks();

    hideAllSubPages();
  }

  List<Controller> initializeSubPage1() {

    List<Controller> subPage1Buttons = new ArrayList<>();

    int leftXPosGroup = 22;
    int rightXPosGroup = 320;
    int yPosGroup = 100;
    int distanceBtwGroups = 40;
    int yPosOfFirstChild = 200;
    int uiGap = 40;
    String groupName;

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "lineHeightGroup";

    subPage1Buttons.add(createCustomGroup(leftXPosGroup, yPosGroup, groupName));

    subPage1Buttons.add(createToggle("sameHeightForAllLines", settings.sameHeightForAllLines, "same Height For All Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createTextfield("heightOfLine", "line height (chosen randomly)", settings.heightOfLine, groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("minLineHeight", 1, 500, settings.minLineHeight, "min line height", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("maxLineHeight", 1, 500, settings.maxLineHeight, "max line height", groupName));

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "lineWidthGroup";

    subPage1Buttons.add(createCustomGroup(rightXPosGroup, yPosGroup, groupName));

    subPage1Buttons.add(createToggle("sameWidthForAllLines", settings.sameWidthForAllLines, "same width for all lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createTextfield("widthOfLine", "line width (chosen randomly)", settings.widthOfLine, groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("minLineWidth", 1, 500, settings.minLineWidth, "min line width", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("maxLineWidth", 1, 500, settings.maxLineWidth, "max line width", groupName));

    yPosGroup += distanceBtwGroups;
    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "lineAngleGroup";

    subPage1Buttons.add(createCustomGroup(leftXPosGroup, yPosGroup, groupName));

    subPage1Buttons.add(createToggle("setSpecificLineAngles", settings.setSpecificLineAngles, "set specific angles", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createTextfield("nonDLineAngle", "Non-Death line angle", settings.nonDLineAngle, groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createTextfield("dLineAngle", "death line angle", settings.dLineAngle, groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("lineAngleStart", 0, 360, settings.lineAngleStart, "line angle start", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("lineAngleEnd", 0, 360, settings.lineAngleEnd, "line angle end", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createToggle("limitLineAngleAfterConnectingItsCorner", settings.limitLineAngleAfterConnectingItsCorner, "limit Line angle After Connecting Corner", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("lineConnectAngleStart", 0, 360, settings.lineConnectAngleStart, "angle Limit Start", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("lineConnectAngleEnd", 0, 360, settings.lineConnectAngleEnd, "angle Limit End", groupName));

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "lineTypeGroup";

    subPage1Buttons.add(createCustomGroup(rightXPosGroup, yPosGroup, groupName));

    subPage1Buttons.add(createSlider("chancesOfDeath", 0, 1, settings.chancesOfDeath, "chances of death", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("chancesOfBounciness", 0, 1, settings.chancesOfBounciness, "chances of bounciness", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("chancesOfGrapple", 0, 1, settings.chancesOfGrapple, "chances of grapple", groupName));
    yPosOfGroupChild += uiGap;

    subPage1Buttons.add(createSlider("chancesOfNoJump", 0, 1, settings.chancesOfNoJump, "chances of No-Jump", groupName));

    return subPage1Buttons;
  }

  List<Controller> initializeSubPage2() {
    List<Controller> subPage2Buttons = new ArrayList<>();

    int leftXPosGroup = 22;
    int rightXPosGroup = 320;
    int yPosGroup = 100;
    int distanceBtwGroups = 40;
    int yPosOfFirstChild = 200;
    int uiGap = 40;
    String groupName;

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "frameSettingsGroup";

    subPage2Buttons.add(createCustomGroup(leftXPosGroup, yPosGroup, groupName));

    subPage2Buttons.add(createToggle("addFrames", settings.addFrames, "Add Frames", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("frameWidth", 1, 100, settings.frameWidth, "Frame Width", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createToggle("areFramesDeath", settings.areFramesDeath, "Are Frames Death?", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createToggle("areFramesBouncy", settings.areFramesBouncy, "Are Frames Bouncy?", groupName));

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "floorSettingsGroup";

    subPage2Buttons.add(createCustomGroup(rightXPosGroup, yPosGroup, groupName));

    subPage2Buttons.add(createToggle("addFloors", settings.addFloors, "Add Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("numOfFloors", 1, 100, settings.numOfFloors, "Number of Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("minFloorWidth", 1, endOfWidth - startOfWidth, settings.minFloorWidth, "Min Floor Width", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("maxFloorWidth", 1, endOfWidth - startOfWidth, settings.maxFloorWidth, "Max Floor Width", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("floorHeight", 1, 500, settings.floorHeight, "Floor Height", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createToggle("areFloorsBouncy", settings.areFloorsBouncy, "Make Floors Bouncy", groupName));

    yPosGroup += distanceBtwGroups;
    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "floorAngleGroup";

    subPage2Buttons.add(createCustomGroup(leftXPosGroup, yPosGroup, groupName));

    subPage2Buttons.add(createToggle("setSpecificFloorAngles", settings.setSpecificFloorAngles, "set specific angles", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createTextfield("floorAngle", "floor angle (chosen randomly)", settings.floorAngle, groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("floorAngleStart", 0, 360, settings.floorAngleStart, "floor angle start", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("floorAngleEnd", 0, 360, settings.floorAngleEnd, "floor angle end", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createToggle("limitFloorAngleAfterConnect", settings.limitFloorAngleAfterConnect, "Limit Floor Angle After Connect", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("floorConnectAngleStart", 0, 180, settings.floorConnectAngleStart, "Floor Angle Start", groupName));
    yPosOfGroupChild += uiGap;

    subPage2Buttons.add(createSlider("floorConnectAngleEnd", 0, 180, settings.floorConnectAngleEnd, "Floor Angle End", groupName));

    return subPage2Buttons;
  }

  List<Controller> initializeSubPage3() {
    List<Controller> subPage3Buttons = new ArrayList<>();

    int leftXPosGroup = 22;
    int rightXPosGroup = 320;
    int yPosGroup = 100;
    int distanceBtwGroups = 40;
    int yPosOfFirstChild = 200;
    int uiGap = 40;
    String groupName;

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "chancesOfLinesConnectingGroup";

    subPage3Buttons.add(createCustomGroup(leftXPosGroup, yPosGroup, groupName));

    subPage3Buttons.add(createSlider("chancesForDLinesAndNonDLinesToConnect", 0, 1, settings.chancesForDLinesAndNonDLinesToConnect,
      "Death Lines With Non-Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForNonDLinesAndNonDLinesToConnect", 0, 1, settings.chancesForNonDLinesAndNonDLinesToConnect,
      "Non-Death Lines With Non-Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForDLinesAndDLinesToConnect", 0, 1, settings.chancesForDLinesAndDLinesToConnect,
      "Death Lines With Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForFloorsAndFloorsToConnect", 0, 1, settings.chancesForFloorsAndFloorsToConnect,
      "Floors With Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForNonDLinesToConnectWithFloors", 0, 1, settings.chancesForNonDLinesToConnectWithFloors,
      "Non-Death Lines With Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForDLinesToConnectWithFloors", 0, 1, settings.chancesForDLinesToConnectWithFloors,
      "Death Lines With Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForFloorsToConnectWithFrames", 0, 1, settings.chancesForFloorsToConnectWithFrames,
      "Floors With Frames", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForDLinesToConnectWithFrames", 0, 1, settings.chancesForDLinesToConnectWithFrames,
      "Death Lines With Frames", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForNonDLinesToConnectWithFrames", 0, 1, settings.chancesForNonDLinesToConnectWithFrames,
      "Non-Death Lines With Frames", groupName));

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "chancesToConnectAtCorner";

    subPage3Buttons.add(createCustomGroup(rightXPosGroup, yPosGroup, groupName));

    subPage3Buttons.add(createSlider("chancesForDLinesAndNonDLinesToConnectAtCorner", 0, 1, settings.chancesForDLinesAndNonDLinesToConnectAtCorner, "Death Lines and Non-Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForNonDLinesToConnectAtCorner", 0, 1, settings.chancesForNonDLinesToConnectAtCorner, "Non-Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForDLinesToConnectAtCorner", 0, 1, settings.chancesForDLinesToConnectAtCorner, "Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForFloorsToConnectAtCorner", 0, 1, settings.chancesForFloorsToConnectAtCorner, "Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForNonDLinesAndFloorsToConnectAtCorner", 0, 1, settings.chancesForNonDLinesAndFloorsToConnectAtCorner, "Non-Death Lines and Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("chancesForDLinesAndFloorsToConnectAtCorner", 0, 1, settings.chancesForDLinesAndFloorsToConnectAtCorner, "Death Lines and Floors", groupName));
    yPosOfGroupChild += uiGap;

    List<String> children = groupChildrenMap.get(groupName + "Children");

    Toggle connectFloorUpToggle = cp5.addToggle("connectFloorUp")
      .setPosition(xPosOfGroupChild, yPosOfGroupChild)
      .setValue(settings.connectFloorUp[0])
      .setLabel("Connect Floor Up")
      .setFont(defaultFont).setSize(25, uiElementHeight)
      .setVisible(false)
      .onChange((e) -> {
      settings.connectFloorUp[0] = e.getController().getValue() == 1;
      updateLocks();
    }
    );
    connectFloorUpToggle.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);

    subPage3Buttons.add(connectFloorUpToggle);

    Toggle connectFloorDownToggle = cp5.addToggle("connectFloorDown")
      .setPosition(197, yPosOfGroupChild)
      .setValue(settings.connectFloorDown[0])
      .setLabel("Connect Floor Down")
      // Use a unique hashCode or ID
      .setFont(defaultFont)
      .setSize(25, uiElementHeight)
      .setVisible(false)
      .onChange((e) -> {
      settings.connectFloorDown[0] = e.getController().getValue() == 1;
      updateLocks();
    }
    );
    connectFloorDownToggle.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);

    subPage3Buttons.add(connectFloorDownToggle);

    yPosOfGroupChild += uiGap;

    Toggle connectFloorLeftToggle = cp5.addToggle("connectFloorLeft")
      .setPosition(xPosOfGroupChild, yPosOfGroupChild) // Adjust yPos if needed
      .setValue(settings.connectFloorLeft[0])
      .setLabel("Connect Floor Left")
      // Use a unique hashCode or ID
      .setFont(defaultFont)
      .setSize(25, uiElementHeight)
      .setVisible(false)
      .onChange((e) -> {
      settings.connectFloorLeft[0] = e.getController().getValue() == 1;
      updateLocks();
    }
    );
    connectFloorLeftToggle.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);

    subPage3Buttons.add(connectFloorLeftToggle);

    Toggle connectFloorRightToggle = cp5.addToggle("connectFloorRight")
      .setPosition(197, yPosOfGroupChild) // Adjust yPos if needed
      .setValue(settings.connectFloorRight[0])
      .setLabel("Connect Floor Right")
      // Use a unique hashCode or ID
      .setFont(defaultFont)
      .setSize(25, uiElementHeight)
      .setVisible(false)
      .onChange((e) -> {
      settings.connectFloorRight[0] = e.getController().getValue() == 1;
      updateLocks();
    }
    );
    connectFloorRightToggle.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);

    subPage3Buttons.add(connectFloorRightToggle);

    if (children != null) {
      children.add("connectFloorUp");
      children.add("connectFloorDown");
      children.add("connectFloorLeft");
      children.add("connectFloorRight");
    }

    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("lineToMoveConnectPointStart", 0, 1, settings.lineToMoveConnectPointStart, "Line to move connect point start", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("lineToMoveConnectPointEnd", 0, 1, settings.lineToMoveConnectPointEnd, "Line to move connect point end", groupName));

    yPosGroup += distanceBtwGroups;
    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "minimumDistanceBtwLinesGroup";

    subPage3Buttons.add(createCustomGroup(leftXPosGroup, yPosGroup, groupName));

    subPage3Buttons.add(createSlider("minDistanceBtwNonDLinesAndDLines", 0, 100, settings.minDistanceBtwNonDLinesAndDLines, "Death Lines and Non-Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwNonDLines", 0, 100, settings.minDistanceBtwNonDLines, "Non-Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwDLines", 0, 100, settings.minDistanceBtwDLines, "Death Lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwFloors", 0, 100, settings.minDistanceBtwFloors, "Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwNonDLinesAndFloors", 0, 100, settings.minDistanceBtwNonDLinesAndFloors, "Non-Death Lines and Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwDLinesAndFloors", 0, 100, settings.minDistanceBtwDLinesAndFloors, "Death Lines and Floors", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwNonDLinesAndFrames", 0, 100, settings.minDistanceBtwNonDLinesAndFrames, "Non-Death Lines and Frames", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwDLinesAndFrames", 0, 100, settings.minDistanceBtwDLinesAndFrames, "Death Lines and Frames", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("minDistanceBtwFloorsAndFrames", 0, 100, settings.minDistanceBtwFloorsAndFrames, "Floors and Frames", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("canLinesOverlap", settings.canLinesOverlap, "Can Lines Overlap?", groupName));

    yPosOfGroupChild = yPosOfFirstChild;
    groupName = "visualSettingsGroup";

    subPage3Buttons.add(createCustomGroup(rightXPosGroup, yPosGroup, groupName));

    subPage3Buttons.add(createToggle("sameColorForAllNonDLines", settings.sameColorForAllNonDLines, "same color for all Non-Death lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("sameColorForAllDLines", settings.sameColorForAllDLines, "same color for all death lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("sameColorForAllBLines", settings.sameColorForAllBLines, "same color for all bouncy lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("sameColorForAllGLines", settings.sameColorForAllGLines, "same color for all grapple lines", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("moveDLinesToBack", settings.moveDLinesToBack, "move Death Lines To Back", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("moveDLinesToFront", settings.moveDLinesToFront, "move Death Lines To Front", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("addPhysicsLineDuplicates", settings.addNoPhysicsLineDuplicates, "add Physics Line Duplicates", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createToggle("addBackground", settings.addBackground, "add Background", groupName));
    yPosOfGroupChild += uiGap;

    subPage3Buttons.add(createSlider("mapSize", 1, 13, settings.mapSize, "map size", groupName));

    return subPage3Buttons;
  }

  void hideAllSubPages() {
    for (List<Controller> subPage : subPages) {
      for (Controller controller : subPage) {
        controller.hide();
      }
    }
  }
  void updateSubPageBtnColor() {
    cp5.getController("customMapPage1Btn").setColorBackground(INACTIVE_COLOR); // Change color
    cp5.getController("customMapPage2Btn").setColorBackground(INACTIVE_COLOR); // Change color
    cp5.getController("customMapPage3Btn").setColorBackground(INACTIVE_COLOR); // Change color

    if (activeSubPageIndex == 1) {
      cp5.getController("customMapPage1Btn").setColorBackground(color(0, 116, 217)); // Change to original color
    } else if (activeSubPageIndex == 2) {
      cp5.getController("customMapPage2Btn").setColorBackground(color(0, 116, 217)); // Change to original color
    } else if (activeSubPageIndex == 3) {
      cp5.getController("customMapPage3Btn").setColorBackground(color(0, 116, 217)); // Change to original color
    }
  }

  // Helper function to create a toggle with automatic state update
  Toggle createToggle(String name, boolean[] state, String label, String groupName) {
    Toggle toggle = cp5.addToggle(name)
      .setPosition(xPosOfGroupChild, yPosOfGroupChild)
      .setValue(state[0])
      .setLabel(label)

      .setFont(defaultFont)
      .setSize(200, uiElementHeight)
      .setVisible(false)
      .onChange((e) -> {
      state[0] = e.getController().getValue() == 1;
      updateLocks();
    }
    );
    toggle.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
    //toggle.getCaptionLabel().setPadding(210, -20);



    //Add toggle to the group's children list
    List<String> children = groupChildrenMap.get(groupName + "Children");
    if (children != null) {
      children.add(name);
    }

    return toggle;
  }

  // Helper function to create a slider
  Slider createSlider(String name, int minValue, int maxValue, float[] value, String label, String groupName) {

    Slider slider = cp5.addSlider(name)
      .setPosition(xPosOfGroupChild, yPosOfGroupChild)
      .setRange(minValue, maxValue)
      .setValue(value[0])
      .setFont(defaultFont)
      .setSize(200, uiElementHeight)
      .setLabel(label)
      .setVisible(false)
      .onChange((e) -> {
      value[0] = e.getController().getValue();
      updateLocks();
    }
    );
    slider.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);

    if (name.equals("mapSize") || name.equals("numOfFloors"))
      slider
        .setDecimalPrecision(0)
        .setFont(defaultFont);  // Set decimal precision to 0 to show integer values

    if (name.equals("mapSize"))
      slider
        .onChange((e) -> {
        cp5.getController("lineDataCopiedLabel").hide();
      }
    );


    List<String> children = groupChildrenMap.get(groupName + "Children");
    if (children != null) {
      children.add(name);
    }

    return slider;
  }

  // Helper function to create a text field
  Textfield createTextfield(String name, String label, ArrayList<Float> valueList, String groupName) {
    Textfield textfield = cp5.addTextfield(name)
      .setPosition(xPosOfGroupChild, yPosOfGroupChild)
      .setSize(200, uiElementHeight)
      .setFont(defaultFont)
      .setLabel(label)
      .setVisible(false)
      .setAutoClear(false)

      .setText(join(floatListToStringArray(valueList), ", "))
      .onChange((e) -> {
      String input = e.getController().getStringValue();

      // Check if input is valid
      if (input.matches("^\\s*\\d+(\\.\\d+)?(\\s*,\\s*\\d+(\\.\\d+)?)*\\s*$")) {
        ArrayList<Float> newList = parseInputToFloatList(input);
        valueList.clear(); // Clear the original list
        valueList.addAll(newList); // Add all values from newList

        // Update the text field with the new valid input
        String updatedText = join(floatListToStringArray(valueList), ", ");
        e.getController().setStringValue(updatedText);
      } else {
        // Invalid input: revert to the last valid input
        String revertedText = join(floatListToStringArray(valueList), ", ");
        e.getController().setStringValue(revertedText);

        // Optionally, provide feedback to the user
        System.out.println("Invalid input, reverting to: " + revertedText);
      }
      updateLocks(); // Update dependent states
    }
    );
    textfield.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
    //textfield.getCaptionLabel().setPadding(210, -20);

    List<String> children = groupChildrenMap.get(groupName + "Children");
    if (children != null) {
      children.add(name);
    }
    //textfield.setInputFilter(ControlP5.FLOAT); // Restrict to valid float inputs

    return textfield;
  }

  Toggle createCustomGroup(int xPos, int yPos, String label) {
    // Create a toggle for the group
    Toggle toggle = cp5.addToggle(label)
      .setPosition(xPos, yPos)
      .setSize(200, 30)
      .setLabel(getGroupLabel(label))
      .setFont(defaultFont)
      .setId("groupTag".hashCode())
      .onChange((e) -> {
      boolean visible = e.getController().getValue() == 1;

      // If toggle is on, hide other group toggles
      if (visible) {
        for (Toggle groupToggle : groupToggles) {
          if (!groupToggle.getName().equals(label)) {
            groupToggle.setValue(false);
          }
        }
      }
      // else {
      // // If toggle is off, show all group toggles
      // for (Toggle groupToggle : groupToggles) {
      // groupToggle.setVisible(true);
      // }
      //}

      // Toggle visibility of the group's children elements
      toggleGroupElements(label + "Children", visible);
    }
    );

    toggle.getCaptionLabel()
      .align(ControlP5.CENTER, ControlP5.CENTER);

    groupToggles.add(toggle);

    // Initialize the group's children list
    groupChildrenMap.put(label + "Children", new ArrayList<>());

    return toggle;
  }


  void toggleGroupElements(String groupChildrenKey, boolean visible) {
    List<String> children = groupChildrenMap.get(groupChildrenKey);
    if (children != null) {
      for (String childName : children) {
        cp5.getController(childName).setVisible(visible);
      }
    }
  }

  String getGroupLabel(String input) {
    // Remove the substring "group" from the input string
    String result = input.replace("Group", "");

    // Insert spaces after each capital letter (assuming words are separated by capital letters)
    StringBuilder spacedResult = new StringBuilder();
    for (int i = 0; i < result.length(); i++) {
      char currentChar = result.charAt(i);
      // Check if the current character is an uppercase letter and not the first character
      if (Character.isUpperCase(currentChar) && i != 0) {
        spacedResult.append(' '); // Add a space before the uppercase letter
      }
      spacedResult.append(currentChar);
    }

    return spacedResult.toString();
  }

  void setLockAndColor(String controllerName, boolean lockState) {
    Controller ctrl = cp5.getController(controllerName);

    int bgColor = !lockState ? INACTIVE_COLOR : GREYED_OUT_COLOR;
    ctrl.setLock(lockState);
    ctrl.setColorBackground(bgColor);
  }

  void updateLocks() {
    if (activeSubPageIndex == 1) {

      updateLocksCustomMapPg1();
    } else if (activeSubPageIndex == 2) {

      updateLocksCustomMapPg2();
    } else if (activeSubPageIndex == 3) {

      updateLocksCustomMapPg3();
    }
  }
  void updateAllLocks() {
    updateLocksCustomMapPg1();
    updateLocksCustomMapPg2();
    //updateLocksCustomMapPg3();
  }

  void updateLocksCustomMapPg1() {

    Controller ctrl;
    boolean isLocked = false;

    setLockAndColor("heightOfLine", !settings.sameHeightForAllLines[0]);
    setLockAndColor("minLineHeight", settings.sameHeightForAllLines[0]);
    setLockAndColor("maxLineHeight", settings.sameHeightForAllLines[0]);

    setLockAndColor("widthOfLine", !settings.sameWidthForAllLines[0]);
    setLockAndColor("minLineWidth", settings.sameWidthForAllLines[0]);
    setLockAndColor("maxLineWidth", settings.sameWidthForAllLines[0]);

    setLockAndColor("nonDLineAngle", !settings.setSpecificLineAngles[0]);
    setLockAndColor("dLineAngle", !settings.setSpecificLineAngles[0]);
    setLockAndColor("lineAngleStart", settings.setSpecificLineAngles[0]);
    setLockAndColor("lineAngleEnd", settings.setSpecificLineAngles[0]);
    setLockAndColor("limitLineAngleAfterConnectingItsCorner",
      settings.chancesForDLinesAndNonDLinesToConnect[0] <= 0 &&
      settings.chancesForNonDLinesAndNonDLinesToConnect[0] <= 0 &&
      settings.chancesForDLinesAndDLinesToConnect[0] <= 0 &&
      settings.chancesForFloorsAndFloorsToConnect[0] <= 0 &&
      settings.chancesForNonDLinesToConnectWithFloors[0] <= 0 &&
      settings.chancesForDLinesToConnectWithFloors[0] <= 0 &&
      settings.chancesForFloorsToConnectWithFrames[0] <= 0
      );
    ctrl = cp5.getController("limitLineAngleAfterConnectingItsCorner");
    isLocked = cp5.getController("limitLineAngleAfterConnectingItsCorner").isLock() || !settings.limitLineAngleAfterConnectingItsCorner[0];
    setLockAndColor("lineConnectAngleStart", isLocked);
    setLockAndColor("lineConnectAngleEnd", isLocked);
  }

  void updateLocksCustomMapPg2() {

    Controller ctrl;
    boolean isLocked = false;

    setLockAndColor("frameWidth", !settings.addFrames[0]);
    setLockAndColor("areFramesDeath", !settings.addFrames[0]);

    setLockAndColor("areFramesBouncy", !settings.addFrames[0]);

    setLockAndColor("numOfFloors", !settings.addFloors[0]);
    setLockAndColor("minFloorWidth", !settings.addFloors[0]);
    setLockAndColor("maxFloorWidth", !settings.addFloors[0]);
    setLockAndColor("floorHeight", !settings.addFloors[0]);

    setLockAndColor("setSpecificFloorAngles", !settings.addFloors[0]);
    setLockAndColor("floorAngle", !settings.addFloors[0] || !settings.setSpecificFloorAngles[0]);
    setLockAndColor("floorAngleStart", !settings.addFloors[0] || settings.setSpecificFloorAngles[0]);
    setLockAndColor("floorAngleEnd", !settings.addFloors[0] || settings.setSpecificFloorAngles[0]);
    setLockAndColor("limitFloorAngleAfterConnect", !settings.addFloors[0]);
    ctrl = cp5.getController("limitFloorAngleAfterConnect");
    isLocked = cp5.getController("limitFloorAngleAfterConnect").isLock() || !settings.limitFloorAngleAfterConnect[0];
    setLockAndColor("floorConnectAngleStart", isLocked);
    setLockAndColor("floorConnectAngleEnd", isLocked);
    setLockAndColor("areFloorsBouncy", !settings.addFloors[0]);
  }

  void updateLocksCustomMapPg3() {

    Controller ctrl;
    boolean isLocked = false;

    setLockAndColor("chancesForDLinesAndNonDLinesToConnect", settings.chancesOfDeath[0] <= 0 || settings.chancesOfDeath[0] >= 1);
    setLockAndColor("chancesForDLinesToConnectWithFloors", !settings.addFloors[0] || settings.chancesOfDeath[0] <= 0);
    setLockAndColor("chancesForFloorsAndFloorsToConnect", !settings.addFloors[0]);
    setLockAndColor("chancesForNonDLinesToConnectWithFloors", !settings.addFloors[0] || settings.chancesOfDeath[0] >= 1);
    setLockAndColor("chancesForDLinesAndDLinesToConnect", settings.chancesOfDeath[0] <= 0);
    setLockAndColor("chancesForNonDLinesAndNonDLinesToConnect", settings.chancesOfDeath[0] >= 1);
    setLockAndColor("chancesForFloorsToConnectWithFrames", !settings.addFloors[0] || !settings.addFrames[0]);
    setLockAndColor("chancesForDLinesToConnectWithFrames", settings.chancesOfDeath[0] <= 0 || !settings.addFrames[0]);
    setLockAndColor("chancesForNonDLinesToConnectWithFrames", settings.chancesOfDeath[0] >= 1 || !settings.addFrames[0]);

    setLockAndColor("chancesForDLinesAndNonDLinesToConnectAtCorner", settings.chancesOfDeath[0] >= 1 || settings.chancesOfDeath[0] <= 0 || settings.chancesForDLinesAndNonDLinesToConnect[0] <= 0);
    setLockAndColor("chancesForDLinesAndFloorsToConnectAtCorner", !settings.addFloors[0] || settings.chancesOfDeath[0] <= 0 || settings.chancesForDLinesToConnectWithFloors[0] <= 0);
    setLockAndColor("chancesForFloorsToConnectAtCorner", !settings.addFloors[0] || settings.chancesForFloorsAndFloorsToConnect[0] <= 0);
    setLockAndColor("chancesForNonDLinesAndFloorsToConnectAtCorner", !settings.addFloors[0] || settings.chancesOfDeath[0] >= 1 || settings.chancesForNonDLinesToConnectWithFloors[0] <= 0);
    setLockAndColor("chancesForDLinesToConnectAtCorner", settings.chancesOfDeath[0] <= 0 || settings.chancesForDLinesAndDLinesToConnect[0] <= 0);
    setLockAndColor("chancesForNonDLinesToConnectAtCorner", settings.chancesOfDeath[0] >= 1 || settings.chancesForNonDLinesAndNonDLinesToConnect[0] <= 0);
    isLocked = cp5.getController("chancesForFloorsToConnectWithFrames").isLock() || settings.chancesForFloorsToConnectWithFrames[0] <= 0;
    setLockAndColor("connectFloorUp", isLocked);
    setLockAndColor("connectFloorDown", isLocked);
    setLockAndColor("connectFloorLeft", isLocked);
    setLockAndColor("connectFloorRight", isLocked);

    setLockAndColor("minDistanceBtwNonDLinesAndDLines", settings.chancesOfDeath[0] <= 0 || settings.chancesOfDeath[0] >= 1);
    setLockAndColor("minDistanceBtwNonDLines", settings.chancesOfDeath[0] >= 1);
    setLockAndColor("minDistanceBtwDLines", settings.chancesOfDeath[0] <= 0);
    setLockAndColor("minDistanceBtwFloors", !settings.addFloors[0]);
    setLockAndColor("minDistanceBtwNonDLinesAndFloors", !settings.addFloors[0] || settings.chancesOfDeath[0] >= 1);
    setLockAndColor("minDistanceBtwDLinesAndFloors", !settings.addFloors[0] || settings.chancesOfDeath[0] <= 0);
    setLockAndColor("minDistanceBtwNonDLinesAndFrames", !settings.addFrames[0] || settings.chancesOfDeath[0] >= 1);
    setLockAndColor("minDistanceBtwDLinesAndFrames", !settings.addFrames[0] || settings.chancesOfDeath[0] <= 0);
    setLockAndColor("minDistanceBtwFloorsAndFrames", !settings.addFrames[0] || !settings.addFloors[0] || settings.numOfFloors[0] == 0);

    setLockAndColor("sameColorForAllDLines", settings.chancesOfDeath[0] <= 0);
    setLockAndColor("sameColorForAllBLines", settings.chancesOfBounciness[0] <= 0);
    setLockAndColor("sameColorForAllGLines", settings.chancesOfGrapple[0] <= 0);
    setLockAndColor("moveDLinesToBack", settings.moveDLinesToFront[0]);
    setLockAndColor("moveDLinesToFront", settings.moveDLinesToBack[0]);
  }
  void showExportPopup() {

    isExportTextfieldOpen = true;

    int xPos = 120;
    int yPos = 200;

    lockBgElements(true);

    cp5.addButton("popupBackground")
      .setLabel("") // No label
      .setPosition(20, 20) // Cover the entire screen
      .setSize(500, 800)
      .setLock(true)
      .setColorBackground(color(0, 0, 0, 215)); // Semi-transparent black

    cp5.addTextlabel("popupTitle")
      .setText("ENTER PRESET NAME")
      .setPosition(xPos - 5, yPos + 20)
      .setFont(defaultFont)
      .setSize(200, 30);

    presetNameField = cp5.addTextfield("presetNameField")
      .setPosition(xPos, yPos + 50)
      .setSize(300, 30)
      .setFocus(true)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setLabel("")
      .setColor(color(0, 0, 0))
      .setColorBackground(color(250))
      .setColorActive(color(255, 255, 255))
      .setColorForeground(color(0, 0, 0));

    if (currentPreset != "default")
      presetNameField.setText(currentPreset);

    presetNameField.onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        if (keyCode == ENTER) {
          handleSavePresetAction();
        }
      }
    }
    );

    cp5.addButton("popupExportBtn")
      .setLabel("save")
      .setPosition(xPos, yPos + 100)
      .setFont(defaultFont)
      .setSize(130, 50)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleSavePresetAction();
      }
    }
    );

    cp5.addButton("popupCancelBtn")
      .setLabel("Cancel")
      .setPosition(xPos + 170, yPos + 100)
      .setFont(defaultFont)
      .setSize(130, 50)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        hideExportPopup();
      }
    }
    );
  }

  void handleSavePresetAction() {
    isExportTextfieldOpen = false;
    String presetName = presetNameField.getText();
    currentPreset = presetName;
    if (presetName.equals("")) presetName = "Unnamed Preset";
    settings.exportPreset(presetName);
    uiManager.updateLoadPresetsUI();
    hideExportPopup();
  }

  // Hide popup menu
  void hideExportPopup() {
    isExportTextfieldOpen = false;
    // Hide popup elements
    cp5.getController("popupBackground").hide();
    cp5.getController("popupTitle").hide();
    cp5.getController("presetNameField").hide();
    cp5.getController("popupExportBtn").hide();
    cp5.getController("popupCancelBtn").hide();

    lockBgElements(false);
  }

  void lockBgElements(boolean isLocked) {
    for (ControllerInterface<?> ci : cp5.getAll()) {
      if (ci instanceof Controller<?>) {
        Controller<?> controller = (Controller<?>) ci;
        if (!(controller.getName() == "exportBtn") && !(controller.getName() == "groupChildrenBg1") && !(controller.getName() == "groupChildrenBg2")) {
          controller.setLock(isLocked);
        }
      }
    }
  }
}
