class UIManager {

  CustomMapPage customMapPage;
  LoadPresetsPage loadPresetsPage;
  MoreOptionsPage moreOptionsPage;
  List<Tab> tabs = new ArrayList<>();

  Slider noOfLinesSlider;

  int activeTabIndex;

  UIManager() {

    customMapPage = new CustomMapPage();
    loadPresetsPage = new LoadPresetsPage();
    moreOptionsPage = new MoreOptionsPage();

    setupCommonUI();

    selectTab(0);
  }

  void setupCommonUI() {
    setupTabs(); // also creates BG inside customMapPage .initialize()
    generateBtnManager.setupGenerateButtons();
    setupNoOfLinesSlider();
  }

  void setupTabs() {

    String[] tabNames = {"customMapBtn", "importPresetsBtn", "moreOptionsBtn"};
    String[] tabLabels = {"Custom Map", "Load Presets", "More Options"};

    for (int i = 0; i < tabNames.length; i++) {
      tabs.add(new Tab(tabNames[i], tabLabels[i], i, getControllersForTab(i), this));
      tabs.get(i).deselect();
    }
  }

  public void selectTab(int tabIndex) {
    // Deselect the currently active tab
    if (activeTabIndex >= 0) {
      tabs.get(activeTabIndex).deselect();
    }

    if (activeTabIndex == 0) {
      customMapPage.hideAllSubPages();
    } else if (activeTabIndex == 1) {
      loadPresetsPage.hideUI();
    }
    activeTabIndex = tabIndex;

    if (activeTabIndex == 1) {

      loadPresetsPage.showUI();
    } else {
      tabs.get(activeTabIndex).select();
      if (activeTabIndex == 0) {
        // Show the last active subpage when returning to CustomMapPage
        customMapPage.setActiveSubPage(customMapPage.activeSubPageIndex);
      }
    }
  }

  List<Controller> getControllersForTab(int index) {
    // Logic to retrieve the controllers for each tab
    if (index == 0) return customMapPage.initialize();
    if (index == 1) return loadPresetsPage.initialize();
    if (index == 2) return moreOptionsPage.initialize();

    return new ArrayList<>();
  }

  void updateCustomMapUIValues() {
    customMapPage.initialize();
  }

  void updateLoadPresetsUI() {
    loadPresetsPage.initialize();
    tabs.get(1).deselect();
  }

  void setupNoOfLinesSlider() {
    noOfLinesSlider = cp5.addSlider("numberOfLines") // not seting the name to "noOfLines" is on purpose as it causes fault
      .setPosition(20, 600)
      .setRange(0, 200)      // Set the range of the slider
      .setValue(noOfLines)    // Set the initial value
      .setLabel("                                no. of lines                            L / R")
      .setSize(310, 30)
      .setDecimalPrecision(0)  // Set decimal precision to 0 to show integer values
      .setFont(defaultFont)
      .onChange((e) -> {
      // Get the new slider value and round it to the nearest integer
      int newNoOfLines = (int) Math.floor(e.getController().getValue());

      // Only update if the new value is different to reduce redraw frequency
      if (newNoOfLines != noOfLines) {
        noOfLines = newNoOfLines;
        // Ensure this line doesn't cause the error by not forcing an immediate redraw
        // e.getController().setValue(noOfLines);  // Only use if absolutely necessary

        // Throttle drawing logic to prevent matrix overflow
        redraw();  // Explicitly call for a redraw instead of constantly redrawing
      }
    }
    );

    noOfLinesSlider
      .getCaptionLabel()
      .align(ControlP5.CENTER, ControlP5.CENTER);
  }

  void updateNoOfLinesSlider() {
    noOfLinesSlider.setValue(noOfLines);
  }
}
