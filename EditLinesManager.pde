class EditLinesManager {
  List<Controller> lineProperties;
  Slider widthSlider;
  Slider heightSlider;
  Slider angleSlider;
  Toggle toggleDeath;
  Toggle toggleBounce;
  Toggle toggleGrapple;
  Toggle toggleNoJump;
  Toggle toggleCapzone;
  Button deleteLineBtn;
  Button cancelProcessingLinesButton;

  List<Controller> otherOptions;
  Button changeColorsBtn;
  Button addNewLineBtn;
  Button spawnBtn;

  float startXPos = startOfWidth + 10;
  float startYPos = 615;
  float distBtwBtns = 10;


  EditLinesManager() {
    drawEditLineUI();
    bgButtonManager = new BgButtonManager(startYPos);
  }

  void updateEditLineUI() {
    if (isProcessingLines) {
      showProcessingLinesUI();
    } else {
      showNonProcessingLinesUI();
    }
    drawBgRectangles();
  }

  void showProcessingLinesUI() {
    editLinesManager.cancelProcessingLinesButton.setVisible(true);
    generateBtnManager.setStatusLabelsVisibility(true);
    generateBtnManager.setGenerateBtnsVisibility(false);
    hideControllers(lineProperties);
    hideControllers(otherOptions);
    bgButtonManager.hide();
  }

  void showNonProcessingLinesUI() {
    boolean hasSelectedLine = selectedLine != null;
    generateBtnManager.setGenerateBtnsVisibility(true);
    generateBtnManager.setStatusLabelsVisibility(false);
    cancelProcessingLinesButton.hide();

    if (hasSelectedLine) {
      hideControllers(otherOptions);
      bgButtonManager.hide();
      showControllers(lineProperties);
      updateSlidersAndToggles();
    } else {
      hideControllers(lineProperties);
      showControllers(otherOptions);
      bgButtonManager.show();
    }
  }

  void updateSlidersAndToggles() {
    widthSlider.setValue(selectedLine.width);
    heightSlider.setValue(selectedLine.height);
    angleSlider.setValue(updateAngle());
    toggleDeath.setValue(selectedLine.isDeath);
    toggleBounce.setValue(selectedLine.isBouncy);
    toggleGrapple.setValue(selectedLine.hasGrapple);
    toggleNoJump.setValue(selectedLine.isNoJump);
    toggleCapzone.setValue(selectedLine.isCapzone);
  }

  void hideControllers(List<Controller> controllers) {
    for (Controller controller : controllers) {
      controller.hide();
    }
  }

  void showControllers(List<Controller> controllers) {
    for (Controller controller : controllers) {
      controller.show();
    }
  }


  void drawBgRectangles() {
    Line settingsMenuBg = new Line(270, 300, 500, 800, 0, false);
    settingsMenuBg.noPhysics = true;
    settingsMenuBg.lineColor = color(0, 2, 19);
    settingsMenuBg.drawLine(false);

    stroke(8, 37, 63, 255); // Light gray border
    fill(1, 0, 16, 255);
    strokeWeight(1);
    rect((startOfWidth + endOfWidth) / 2, startYPos + 32, endOfWidth - startOfWidth + 0, 80);
  }

  void drawEditLineUI() {
    lineProperties = new ArrayList<>();
    otherOptions = new ArrayList<>();

    cancelProcessingLinesButton = cp5.addButton("cancel")
      .setPosition(endOfWidth - 5 - 100, startYPos + 32 - 15)
      .setLabel("Cancel (c)")
      .setFont(defaultFont)
      .setVisible(false)
      .setSize(90, 30)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        isProcessingLines = false;
      }
    }
    );
    cp5.addButton("copyLineData")
      .setPosition(endOfWidth - 10 - 100, startYPos + 32 - 15)
      .setSize(100, 30)
      .setFont(defaultFont)
      .setLabel("copy data (c)")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleCopyLineDataBtnClick();

      }
    }
    );

    cp5.addButton("pasteLineData")
      .setPosition(endOfWidth - 10 - 150, startOfHeight - 50)
      .setSize(160, 30)
      .setFont(tabFont)
      .setLabel("Paste and create new map")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handlePasteLineDataBtnClick();

      }
    }
    );

    Textlabel lineDataCopiedLabel = cp5.addTextlabel("lineDataCopiedLabel")
      .setPosition(endOfWidth - 10 - 100, startYPos + 50) // Position below the button
      .setFont(createFont("Tw Cen MT Bold", 9))
      .setVisible(false)
      .setText("LINE DATA COPIED TO \nCLIPBOARD"); // Text color

    changeColorsBtn = cp5.addButton("changeColors")
      .setPosition(startXPos, startYPos)
      .setSize(100, 30)
      .setFont(tabFont)
      .setLabel("plat colors (p)")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handlePlatsColorBtnClick();
      }
    }
    );
    otherOptions.add(changeColorsBtn);

    addNewLineBtn = cp5.addButton("addNewLineBtn")
      .setPosition(startXPos + 110, startYPos)
      .setSize(100, 30)
      .setFont(tabFont)
      .setLabel("add line (a)")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleAddNewLineBtnClick();
      }
    }
    );

    otherOptions.add(addNewLineBtn);

    spawnBtn = cp5.addButton("spawnBtn")
      .setPosition(startXPos + 220, startYPos)
      .setSize(100, 30)
      .setFont(tabFont)
      .setLabel("spawn (s)")
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleSpawnBtnClick();
      }
    }
    );

    otherOptions.add(spawnBtn);

    int yDistBtwSliders = 23;

    widthSlider = addSlider("                                            width                          (CTRL + L/R)", startOfWidth, (int) startYPos, 1, 1000, (e) -> {
      if (selectedLine != null) selectedLine.width = e.getController().getValue();
    }
    );

    heightSlider = addSlider("                                            height                        (CTRL + U/D)", startOfWidth, (int) startYPos + yDistBtwSliders * 1, 1, 1000, (e) -> {
      if (selectedLine != null) selectedLine.height = e.getController().getValue();
    }
    );

    angleSlider = addSlider("                                            angle                        (SHIFT + L/R)", startOfWidth, (int) startYPos + yDistBtwSliders * 2, 0, 360, (e) -> {
      if (selectedLine != null) selectedLine.angle = e.getController().getValue();
    }
    );

    int xPos = (int) startXPos + 330;


    toggleDeath = addToggle("toggleDeath", xPos, (int) startYPos, "death (d)", (e) -> {
      boolean isDeath = e.getController().getValue() == 1;
      handleDeathToggle(isDeath);
    }
    );

    toggleBounce = addToggle("toggleBounce", xPos, (int) startYPos + yDistBtwSliders * 1, "bounce (b)", (e) -> {
      boolean isBouncy = e.getController().getValue() == 1;
      handleBounceToggle(isBouncy);
    }
    );

    toggleGrapple = addToggle("toggleGrapple", xPos, (int) startYPos + yDistBtwSliders * 2, "grapple (g)", (e) -> {
      boolean hasGrapple = e.getController().getValue() == 1;
      handleGrappleToggle(hasGrapple);
    }
    );
    xPos = (int) startXPos + 60 + 50 + 330;

    toggleNoJump = addToggle("toggleNoJump", xPos, (int) startYPos + yDistBtwSliders * 0, "no-jump", (e) -> {
      selectedLine.isNoJump = e.getController().getValue() == 1;
      if (selectedLine.isNoJump) selectedLine.setAsNoJump();
      else selectedLine.isNoJump = false;
    }
    );

    toggleCapzone = addToggle("toggleCapzone", xPos, (int) startYPos + yDistBtwSliders * 1, "capzone", (e) -> {
      selectedLine.isCapzone = e.getController().getValue() == 1;
      if (selectedLine.isCapzone) selectedLine.setAsCapzone();
      else selectedLine.isCapzone = false;
    }
    );

    deleteLineBtn = cp5.addButton("deleteLineBtn")
      .setPosition(xPos, startYPos + yDistBtwSliders * 2)
      .setSize(80, 20)
      .setFont(tabFont)
      .setLabel("delete (del)")
      //.setColorBackground(color(150))
      .setColorForeground(color(150, 0, 0))
      .setColorActive(color(255, 0, 0))
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleDeleteLineBtnClick();
      }
    }
    );

    lineProperties.add(deleteLineBtn);
  }

  Slider addSlider(String name, int x, int y, float min, float max, CallbackListener listener) {
    Slider slider = cp5.addSlider(name)
      .setPosition(startXPos, y)
      .setRange(min, max)
      .setSize(300, 20)
      .setDecimalPrecision(0)  // Set decimal precision to 0 to show integer values
      .setFont(tabFont)
      .setValue(0)
      //.snapToTickMarks(true)  // This will snap the slider to integer values.
      //.setSliderMode(Slider.FLEXIBLE)
      .onChange(listener);
    lineProperties.add(slider);
    slider
      .getCaptionLabel()
      .align(ControlP5.CENTER, ControlP5.CENTER);

    slider
      .onChange((e) -> {
      cp5.getController("lineDataCopiedLabel").hide();
    }
    );
    return slider;
  }

  Toggle addToggle(String name, int x, int y, String label, CallbackListener listener) {
    Toggle toggle = cp5.addToggle(name)
      .setPosition(x, y)
      .setLabel(label)
      .setFont(tabFont)
      .setSize(80, 20)
      .onChange(listener);
    toggle.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

    toggle
      .onChange((e) -> {
      cp5.getController("lineDataCopiedLabel").hide();
    }
    );

    lineProperties.add(toggle);
    return toggle;
  }

  void handleAddNewLineBtnClick() {
    float xPos = (startOfWidth + endOfWidth) / 2;
    float yPos = (startOfHeight + endOfHeight) / 2;
    // Check if the pointer is within the canvas
    if (mouseX >= startOfWidth && mouseX <= endOfWidth &&
      mouseY >= startOfHeight && mouseY <= endOfHeight) {
      xPos = mouseX;
      yPos = mouseY;
    }
    Line newLine = new Line(xPos, yPos, 10, 10, 0, false);
    lines.add(newLine);
    selectedLine = newLine;
    cp5.getController("lineDataCopiedLabel").hide();
  }

  void handleDeleteLineBtnClick() {
    cp5.getController("lineDataCopiedLabel").hide();
    lines.remove(selectedLine);
    selectedLine = null;
  }

  void handleBounceToggle(boolean isBouncy) {
    if (selectedLine != null) {
      selectedLine.isBouncy = isBouncy;
      if (selectedLine.isBouncy) {
        selectedLine.makeBouncy();
      } else {
        selectedLine.makeNonBouncy();
      }
    }
  }

  void handleDeathToggle(boolean isDeath) {
    if (selectedLine != null) {
      selectedLine.isDeath = isDeath;
      if (selectedLine.isDeath) {
        selectedLine.makeDeath();
      } else {
        selectedLine.makeNonDeath();
      }
    }
  }

  void handleGrappleToggle(boolean hasGrapple) {
    if (selectedLine != null) {
      selectedLine.hasGrapple = hasGrapple;
      if (selectedLine.hasGrapple) {
        selectedLine.makeGrapplable();
      } else {
        selectedLine.makeNonGrapplable();
      }
    }
  }

  void handlePlatsColorBtnClick() {
    cp5.getController("lineDataCopiedLabel").hide();
    lineManager.setRandomValues();
    for (Line line : lines) {
      if (!line.noPhysics)
        line.setColors();
    }
    if (settings.addNoPhysicsLineDuplicates[0]) lineManager.duplicateAndScaleDownLines(lines);
  }

  void handleSpawnBtnClick() {

    cp5.getController("lineDataCopiedLabel").hide();

    if (!isSpawnPlaced) {
      // Place the circle at the mouse position
      spawnPosition = new PVector(mouseX, mouseY);
      // Check if the pointer is not within the canvas
      if (!(mouseX >= startOfWidth && mouseX <= endOfWidth &&
        mouseY >= startOfHeight && mouseY <= endOfHeight)) {

        spawnPosition.set((startOfWidth + endOfWidth) / 2, (startOfHeight + endOfHeight) / 2 );
      }
      isSpawnPlaced = true;
    } else {
      // Relocate the circle to the new mouse position
      if (!(mouseX >= startOfWidth && mouseX <= endOfWidth &&
        mouseY >= startOfHeight && mouseY <= endOfHeight)) {

        spawnPosition.set((startOfWidth + endOfWidth) / 2, (startOfHeight + endOfHeight) / 2 );
      } else
        spawnPosition.set(mouseX, mouseY);
    }
  }

  void handleCopyLineDataBtnClick() {
    lineManager.moveLinesForwardOrBackward();
    saveLineAttributes();
  }

  boolean isMouseOverSlider() {
    boolean returnValue = false;
    for (Controller controller : lineProperties) {
      returnValue = controller.isMouseOver();
      if (returnValue) break;
    }
    return returnValue;
  }

  float updateAngle() {
    float angle = selectedLine.angle % 360;
    if (angle < 0) {
      angle += 360;
    }
    return angle;
  }
}