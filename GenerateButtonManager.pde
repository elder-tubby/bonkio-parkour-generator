class GenerateBtnManager {

  Button generateBtn;
  Button generateFloorsBtn;
  Button generateLinesBtn;
  boolean mousePressedOnButton = false;  // Track if mouse is pressed on a popup button

  boolean showExtraButtons = true;

  Textlabel generatingLineLabel;
  Textlabel generatingLineValueLabel;
  Textlabel attemptToGenerateLabel;
  Textlabel attemptToGenerateValueLabel;
  Textlabel attemptLimitReachedLabel;
  Textlabel attemptLimitReachedValueLabel;

  // Constants for positioning and sizing

  final int BTN_WIDTH = 90;
  final int BTN_HEIGHT = 30;
  final int BTN_Y_POS = 650;
  final int DISTANCE_BETWEEN_BTNS = 10;
  final int GENERATE_BTN_X_POS = 30;  // X-position for the middle "generate all" button

  // Declare final variables for position values
  final int LABEL_X_POSITION = 700;     // X position for static labels
  final int VALUE_X_POSITION = 1050;      // X position for dynamic value labels
  final int INITIAL_Y_POSITION = 620;    // Initial Y position for the first label
  final int LABEL_HEIGHT = 20;            // Height increment for each label

  // A bounding box element that contains all three buttons
  float containerX, containerY, containerWidth, containerHeight;

  Textlabel statusLabel;

  GenerateBtnManager() {
   
    createClearLinesToggle();
    setupGenerateButtons();
    createBoundingBox();
    setupStatusLabel();
  }
  void createClearLinesToggle() {

    Toggle toggle = cp5.addToggle("clearExistingLinesToggle")
      .setPosition(GENERATE_BTN_X_POS + 320, BTN_Y_POS)
      .setValue(clearExistingLines)
      .setLabel("")
      .setFont(defaultFont)
      .setSize(30, 30)
      .onChange((e) -> {
      clearExistingLines = !clearExistingLines;
    }
    );
    toggle.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
  }
  void setupStatusLabel() {
    generatingLineLabel = cp5.addTextlabel("generatingLineLabel")
      .setPosition(LABEL_X_POSITION, INITIAL_Y_POSITION)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("GENERATING LINE:")
      .setVisible(false);

    generatingLineValueLabel = cp5.addTextlabel("generatingLineValueLabel")
      .setPosition(VALUE_X_POSITION, INITIAL_Y_POSITION)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("")
      .setVisible(false);  // Initially empty

    attemptToGenerateLabel = cp5.addTextlabel("attemptToGenerateLabel")
      .setPosition(LABEL_X_POSITION, INITIAL_Y_POSITION + LABEL_HEIGHT)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("ATTEMPT TO GENERATE CURRENT LINE:")
      .setVisible(false);

    attemptToGenerateValueLabel = cp5.addTextlabel("attemptToGenerateValueLabel")
      .setPosition(VALUE_X_POSITION, INITIAL_Y_POSITION + LABEL_HEIGHT)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("")
      .setVisible(false);  // Initially empty

    attemptLimitReachedLabel = cp5.addTextlabel("attemptLimitReachedLabel")
      .setPosition(LABEL_X_POSITION, INITIAL_Y_POSITION + 2 * LABEL_HEIGHT)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("NO. OF TIMES ATTEMPT LIMIT REACHED:")
      .setVisible(false);

    attemptLimitReachedValueLabel = cp5.addTextlabel("attemptLimitReachedValueLabel")
      .setPosition(VALUE_X_POSITION, INITIAL_Y_POSITION + 2 * LABEL_HEIGHT)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("")
      .setVisible(false);  // Initially empty
  }



  void updateStatus(int i, int noOfLines, int j, int loopLimitForEachLine, int numOfTimesLoopLimitReached, boolean isTextForFloors) {
    generatingLineValueLabel.setText((i + 1) + "/" + noOfLines);
    attemptToGenerateValueLabel.setText(j + "/" + loopLimitForEachLine);
    attemptLimitReachedValueLabel.setText(String.valueOf(numOfTimesLoopLimitReached));

    if (isTextForFloors) {
      generatingLineLabel.setText("GENERATING FLOOR:");
      attemptToGenerateLabel.setText("ATTEMPT TO GENERATE CURRENT FLOOR:");
    } else {
      generatingLineLabel.setText("GENERATING LINE:");
      attemptToGenerateLabel.setText("ATTEMPT TO GENERATE CURRENT LINE:");
    }
  }

  void setStatusLabelsVisibility(boolean isVisible) {
    generatingLineLabel.setVisible(isVisible);
    generatingLineValueLabel.setVisible(isVisible);
    attemptToGenerateLabel.setVisible(isVisible);
    attemptToGenerateValueLabel.setVisible(isVisible);
    attemptLimitReachedLabel.setVisible(isVisible);
    attemptLimitReachedValueLabel.setVisible(isVisible);
  }


  void setupGenerateButtons() {

    // Create the main "generate all" button
    generateBtn = cp5.addButton("generate")
      .setPosition(GENERATE_BTN_X_POS, BTN_Y_POS)
      .setLabel("generate (g)")
      .setFont(defaultFont)
      .setSize(BTN_WIDTH, BTN_HEIGHT)
      .onEnter(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        //showExtraButtons = true;
        //updateExtraButtonsVisibility();
        //createBoundingBox();
      }
    }
    );

    // Create the "generate floors only" button (initially hidden)
    generateFloorsBtn = cp5.addButton("generateFloors")
      .setPosition(GENERATE_BTN_X_POS + BTN_WIDTH + DISTANCE_BETWEEN_BTNS, BTN_Y_POS)
      .setLabel("floors (f)")
      .setFont(defaultFont)
      .setSize(BTN_WIDTH, BTN_HEIGHT)
      .setVisible(true)  // Hidden by default
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleGenerateFloorsClick();
      }
    }
    );

    // Create the "generate lines only" button (initially hidden)
    generateLinesBtn = cp5.addButton("generateLines")
      .setPosition(GENERATE_BTN_X_POS + (BTN_WIDTH + DISTANCE_BETWEEN_BTNS) * 2, BTN_Y_POS)
      .setLabel("lines (l)")
      .setFont(defaultFont)
      .setSize(BTN_WIDTH, BTN_HEIGHT)
      .setVisible(true)  // Hidden by default
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleGenerateLinesClick();
      }
    }
    );

    //generateFloorsBtn.onPress(new CallbackListener() {
    //  public void controlEvent(CallbackEvent e) {
    //    mousePressedOnButton = true;  // Mouse pressed on this button
    //  }
    //}
    //)
    //.onRelease(new CallbackListener() {
    //  public void controlEvent(CallbackEvent e) {
    //    println("released floorsbtn");
    //    mousePressedOnButton = false;  // Mouse released, reset the flag
    //    handleGenerateFloorsClick();  // Handle the actual click action
    //    handleMouseLeaveBoundingBox();  // Recheck if the bounding box should be hidden
    //  }
    //}
    //);

    //generateLinesBtn.onPress(new CallbackListener() {
    //  public void controlEvent(CallbackEvent e) {
    //    mousePressedOnButton = true;  // Mouse pressed on this button
    //  }
    //}
    //)
    //.onRelease(new CallbackListener() {
    //  public void controlEvent(CallbackEvent e) {
    //    mousePressedOnButton = false;  // Mouse released, reset the flag
    //    handleGenerateLinesClick();  // Handle the actual click action
    //    handleMouseLeaveBoundingBox();  // Recheck if the bounding box should be hidden
    //  }
    //}
    //);
  }

  // Update visibility of the extra buttons based on hover state
  //void updateExtraButtonsVisibility() {
  //  generateFloorsBtn.setVisible(showExtraButtons);
  //  generateLinesBtn.setVisible(showExtraButtons);
  //}

  // Create the bounding box to keep the buttons visible when hovering
  void createBoundingBox() {
    containerX = GENERATE_BTN_X_POS - 10;  // Adjust for padding
    containerY = BTN_Y_POS - 10;
    containerWidth = BTN_WIDTH * 3 + 2 * DISTANCE_BETWEEN_BTNS + 20;  // Include both extra buttons
    containerHeight = BTN_HEIGHT + 20;  // Add some padding
  }

  // Draw the bounding box (visual container)
  void drawContainer() {
    if (showExtraButtons) {
      stroke(8, 37, 63, 255); // Light gray border
      fill(1, 0, 16, 255); // Light background with some transparency
      rect(containerX + containerWidth / 2, containerY + containerHeight / 2, containerWidth, containerHeight);
    } else {

      float tempWidth = containerWidth - BTN_WIDTH * 2 - 20;
      stroke(8, 37, 63, 255); // Light gray border
      fill(1, 0, 16, 255); // Light background with some transparency
      rect(GENERATE_BTN_X_POS + tempWidth / 2 - 10, containerY + containerHeight / 2, tempWidth, containerHeight);
    }
  }

  // Check if the mouse is hovering over the container area
  boolean isMouseHoveringBoundingBox() {
    return (mouseX > containerX && mouseX < containerX + containerWidth &&
      mouseY > containerY && mouseY < containerY + containerHeight);
  }

  // Check if the mouse is leaving the container area
  //void handleMouseLeaveBoundingBox() {
  //  if (!isMouseHoveringBoundingBox() && !isMouseHovering(generateBtn) && !mousePressedOnButton) {
  //    showExtraButtons = false;
  //    updateExtraButtonsVisibility();
  //  }
  //}


  // Helper to check if the mouse is over a specific button
  //boolean isMouseHovering(Button button) {
  //  return (mouseX > button.getPosition()[0] && mouseX < button.getPosition()[0] + button.getWidth() &&
  //    mouseY > button.getPosition()[1] && mouseY < button.getPosition()[1] + button.getHeight());
  //}

  // This should be called every frame in the draw loop
  void updateGenerateButtonsUI() {
    drawContainer();  // Draw the container around the buttons
    //handleMouseLeaveBoundingBox();  // Check if the mouse left the container
    //setLockAndColor("generateFloors", !settings.addFloors[0]);
  }

  // Handle generating floors logic
  void handleGenerateFloorsClick() {
    if (!settings.addFrames[0]) lineManager.clearFrames();
    lineManager.clearFloorsAndLines();
    if (settings.addFloors[0]) {
      cp5.getController("lineDataCopiedLabel").hide();
      lineManager.createFloorsAsync();
    }
  }

  // Handle generating lines logic
  void handleGenerateLinesClick() {

    if (!settings.addFloors[0])
      lineManager.clearFloors();
    if (clearExistingLines)
      lineManager.clearLines();
    if (!settings.addFrames[0])
      lineManager.clearFrames();

    if (noOfLines > 0) {
      cp5.getController("lineDataCopiedLabel").hide();
      lineManager.createLinesAsync();
    }
  }

  void setGenerateBtnsVisibility(boolean isVisible) {
    for (ControllerInterface<?> ci : cp5.getAll()) {
      if (ci instanceof Controller<?>) {
        Controller<?> controller = (Controller<?>) ci;
        String controllerName = controller.getName();
        if (controllerName.equals("generate") || controllerName.equals("copyLineData") ||
          controllerName.equals("generateFloors") || controllerName.equals("generateLines") || controllerName.equals("pasteLineData")) {
          if (isVisible) {
            controller.show();
          } else {
            controller.hide();
          }
        }
      }
    }
  }
}
