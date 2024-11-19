class DefaultPresetsPage {

  int groupBtnIndex = 1;
  int presetBtnIndex = 130;
  float yPos = 130;
  List<Controller> presetGroupsButtons = new ArrayList<>();
  List<Controller> commonSubPageElements;
  Button selectedBtn;
  Textlabel lineSuggestionText = cp5.addTextlabel("");

  List<List<Controller>> subPages = new ArrayList<>();
  int activeSubPageIndex = 0;

  List<Controller> initialize() {
    initializePresetGroupsPage();
    initializePresetPages();
    return presetGroupsButtons;
  }

  void initializePresetGroupsPage() {

    presetGroupsButtons.add(cp5.addTextlabel("textLabel1")
      .setPosition(215, yPos - 35)
      .setFont(cp5.papplet.createFont("Tw Cen MT Bold", 15))
      .setText("PRESET GROUPS"));

    // Add Btns with highlight logic
    presetGroupsButtons.add(addGroupBtn("1. Bouncy + Death"));
    presetGroupsButtons.add(addGroupBtn("2. Bouncy + non bouncy"));
    presetGroupsButtons.add(addGroupBtn("3. Death + non bouncy"));
    presetGroupsButtons.add(addGroupBtn("4. non bouncy"));
    presetGroupsButtons.add(addGroupBtn("5. Death + Bouncy + non bouncy"));
    presetGroupsButtons.add(addGroupBtn("6. Death + Grapple"));
    presetGroupsButtons.add(addGroupBtn("7. non bouncy + Grapple"));
    presetGroupsButtons.add(addGroupBtn("8. Frame + Floors"));
    presetGroupsButtons.add(addGroupBtn("9. Djumps"));
  }

  void initializePresetPages() {

    initializeCommonElements();

    // Initialize multiple sub-pages with a loop or manually
    addSubPage(new String[]{
      "0 90 bounce non boune death connect corner% 1.1% 20 - 60",
      "1.2 thin plats + small squares% 1.2% 30 - 100",
      "1.3 0° and 90°% 1.3% 30 - 80",
      "1.4 large squares% 1.4% 30 - 80",
      "1.5 0°, 45° and 90°% 1.5% 30 - 50"
      });

    addSubPage(new String[]{
      "2.1 0 and 90°% 2.1% 20 - 35",
      "2.2 large squares (random)% 2.2% 50 - 70",
      "2.3 large squares (45°)% 2.3% 30"
      });

    addSubPage(new String[]{
      ""
      });

    addSubPage(new String[]{
      "4.1 random% 4.1% 20 - 25"
      });

    addSubPage(new String[]{
      "5.1 random thin plats% 5.1% 20 - 60",
      "5.2 0° plats + small squares% 5.2% 40 - 70",
      "5.3 90° plats + small squares% 5.3% 40 - 80",
      "5.4 large squares% 5.4% 40 - 60",
      "5.5 0° and 90°% 5.5% 30 - 50"
      });

    addSubPage(new String[]{
      ""
      });

    addSubPage(new String[]{
      ""
      });

    addSubPage(new String[]{
      "8.1 floors + death% 8.1% 50 - 75",
      "8.2 floors + death squares \n   and 0° plats% 8.2% 60 - 90",
      "8.3 floors + non bouncy \n   + death% 8.3% 40 - 70",
      "8.4 floors + death + bouncy% 8.4% 40 - 70",
      "8.5 slope + death + bouncy°% 8.5% 30 - 50",
      "8.6 walls + death% 8.6% 30 - 50",
      "8.7 walls + non bouncy% 8.7% 40 - 60"
      });

    addSubPage(new String[]{
      ""
      });
  }

  void initializeCommonElements() {

    int yPos = 130;

    commonSubPageElements = new ArrayList<>();
    commonSubPageElements.add(cp5.addTextlabel("textLabel2")
      .setPosition(205, yPos - 35)
      .setFont(createFont("Tw Cen MT Bold", 15))
      .setText("PRESET SELECTION")
      .setVisible(false));
  }

  void addSubPage(String[] buttonData) {
    List<Controller> subPage = new ArrayList<>();
    float yPos = 130; // Starting y-position for buttons
    presetBtnIndex = 1;

    if (buttonData.length > 1) {
      for (String data : buttonData) {
        String[] parts = data.split("%");

        String label = parts[0];
        float value = Float.parseFloat(parts[1]);
        String range = parts[2];

        subPage.add(addPresetBtn(label, yPos, value, range));
        presetBtnIndex++;
        //if (presetBtnIndex % 2 != 0)
        yPos += 40;
      }
    }
    subPages.add(subPage); // Add the fully populated sub-page to the main list
  }

  Button addPresetBtn(String label, float yPos, final float presetValue, String lineSuggestion) {

    float xPos = getXPos(1);

    Button button = cp5.addButton("preset" + presetValue)
      .setPosition(xPos, yPos)
      .setSize(500, 25)
      .setFont(defaultFont)
      .setLabel(label)
      .setVisible(false)
      .setId("uiElements".hashCode())
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        handlePresetBtnClick(e.getController(), lineSuggestion);
        println("Selected item: " + label);
        settings.importPreset(label, true);
        currentPreset = label;
      }
    }
    );

    return button;
  }

  void handlePresetBtnClick(Controller<?> controller, String lineSuggestion) {
    // Deselect the previously selected btn

    lineSuggestionText = cp5.addTextlabel("lineSuggestionText")
      .setPosition(20, 575)
      .setFont(createFont("Tw Cen MT Bold", 12))
      .setText("SUGGESTED: " + lineSuggestion)
      .setId("uiElements".hashCode());

    updatePresetBtnColor(controller);
  }

  Button addGroupBtn(String label) {

    int index = groupBtnIndex;
    float xPos = getXPos(groupBtnIndex);
    Button button = cp5.addButton("presetGroup" + index)
      .setPosition(xPos, yPos)
      .setSize(220, 25)
      .setFont(defaultFont)
      .setLabel(label)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        openPresetGroup(index);
      }
    }
    );

    groupBtnIndex++;

    updateYPos();

    return button;
  }

  void updateYPos() {
    if (groupBtnIndex % 2 != 0)
      yPos += 40;
  }

  float getXPos(int groupBtnIndex) {
    return groupBtnIndex % 2 == 0 ? 300 : 20;
  }

  void openPresetGroup(int groupBtnIndex) {
    activeSubPageIndex = groupBtnIndex;
    selectedBtn = null;
    hideGroupsPage();

    for (Controller controller : commonSubPageElements) {
      controller.show();
      //controller.setValue(0);
    }

    List<Controller> activeSubPage = subPages.get(activeSubPageIndex - 1);
    for (Controller controller : activeSubPage) {
      controller.show();
      controller.setValue(0);
    }
  }

  void hideGroupsPage() {
    for (Controller controller : presetGroupsButtons) {
      controller.hide();
    }
  }

  void hideAllPresetPages() {
    removeAllPresetBtnHighlights();
    for (List<Controller> subPage : subPages) {
      for (Controller controller : subPage) {
        controller.hide();
      }
      for (Controller controller : commonSubPageElements) {
        controller.hide();
      }
    }
    lineSuggestionText.hide();
  }

  void showPresetGroupsPage() {
    for (Controller controller : presetGroupsButtons) {
      controller.show();
    }
    hideAllPresetPages();
    removeAllPresetBtnHighlights();
  }

  void updatePresetBtnColor(Controller<?> controller) {
    if (selectedBtn != null) {
      selectedBtn.setColorBackground(INACTIVE_COLOR); // Default color
    }

    // Select the new btn
    selectedBtn = (Button) controller;
    selectedBtn.setColorBackground(color(0, 116, 217)); // Highlight color
  }

  void removeAllPresetBtnHighlights() {
    for (List<Controller> subPage : subPages) {
      for (Controller c : subPage) {
        c.setColorBackground(INACTIVE_COLOR);
      }
    }
  }
}
