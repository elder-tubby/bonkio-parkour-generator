class Tab {

  Button tabButton;
  List<Controller> controllers;
  int tabIndex;
  int btnWidth = 163;
  int btnHeight = 40;
  int btnGap = 5;
  int initialXPos = 20;
  int yPos = 22;

  Tab(String name, String label, int i, List<Controller> controllers, UIManager uiManager) {
    this.controllers = controllers;
    tabIndex = i;

    tabButton = cp5.addButton(name)
      .setLabel(label)
      .setPosition(initialXPos + i * (btnWidth + btnGap), yPos)
      .setSize(btnWidth, btnHeight)
      .setFont(defaultFont)
      .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent e) {
        uiManager.selectTab(i);
      }
    }
    );
  }

  void select() {
    tabButton.setColorBackground(color(0, 116, 217)); // Highlight the active tab
    for (Controller c : controllers) {
      c.show();
    }
  }

  void deselect() {
    tabButton.setColorBackground(INACTIVE_COLOR);
    for (Controller c : controllers) {
      c.hide();
    }
  }

  void setTabColor(color c) {
    tabButton.setColorBackground(c);
  }
}
