class BgButtonManager {
  Button activeBgButton;
  Button leftArrowButton, rightArrowButton;
  String activeBgPattern = "Pattern1";
  List<String> bgPatternLabels = new ArrayList<String>();
  int currentIndex = 0;  // Keeps track of the current pattern index
  List<Controller> bgRelatedBtns = new ArrayList<Controller>();

  float bgBtnWidth = 130;
  float arrowBtnWidth = 30;
  float distBtwBgAndArrowBtns = 10;
  float bgBtnXPos = startOfWidth + arrowBtnWidth + distBtwBgAndArrowBtns + 10;
  float bgBtnYPos;

  BgButtonManager(float yPos) {

    bgBtnYPos = yPos + 35;

    // Initialize the list of patterns
    bgPatternLabels.add("BG Pattern 01");
    bgPatternLabels.add("BG Pattern 02");
    bgPatternLabels.add("BG Pattern 03");

    // Create the main active background button
    activeBgButton = createActiveBgButton(currentIndex, bgPatternLabels.get(currentIndex) + " (B)");

    // Create the left and right arrow buttons
    leftArrowButton = createArrowButton("<", bgBtnXPos - distBtwBgAndArrowBtns - arrowBtnWidth, bgBtnYPos, new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        cycleLeft();
      }
    }
    );

    rightArrowButton = createArrowButton(">", bgBtnXPos + bgBtnWidth + distBtwBgAndArrowBtns, bgBtnYPos, new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        cycleRight();
      }
    }
    );

    bgRelatedBtns.add(activeBgButton);
    bgRelatedBtns.add(leftArrowButton);
    bgRelatedBtns.add(rightArrowButton);
  }

  void hide() {
    for (Controller c : bgRelatedBtns) {
      c.hide();
    }
  }

  void show() {
    for (Controller c : bgRelatedBtns) {
      c.show();
    }
  }

  // Create the active background button
  Button createActiveBgButton(int index, String label) {
    return cp5.addButton("activeBgButton")
      .setLabel(label)  // Display index and pattern name
      .setPosition(bgBtnXPos, bgBtnYPos)
      .setSize((int) bgBtnWidth, 30)
      .setFont(tabFont)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handleBgButtonClick();
      }
    }
    );
  }

  void handleBgButtonClick() {
    cp5.getController("lineDataCopiedLabel").hide();
    String activePattern = bgPatternLabels.get(currentIndex);
    lineManager.removeBgLines();
    lineManager.addBackground(activePattern);
  }

  // Create arrow buttons for cycling patterns
  Button createArrowButton(String symbol, float x, float y, CallbackListener callback) {
    return cp5.addButton(symbol)
      .setLabel(symbol)
      .setPosition(x, y)
      .setSize((int) arrowBtnWidth, 30)
      .setFont(defaultFont)
      .onClick(callback);
  }

  // Cycle to the previous pattern
  void cycleLeft() {
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = bgPatternLabels.size() - 1;  // Wrap around to the last pattern
    }
    updateActiveButton();
  }

  // Cycle to the next pattern
  void cycleRight() {
    if (currentIndex < bgPatternLabels.size() - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;  // Wrap around to the first pattern
    }
    updateActiveButton();
  }

  // Update the active button with the new pattern
  void updateActiveButton() {
    String newPattern = bgPatternLabels.get(currentIndex);
    activeBgButton.setLabel(newPattern + " (B)");
  }
}
