class LoadPresetsPage {

  String[] itemLabels = null;
  ListBox fileList;
  Button deleteBtn;
  List<Controller> loadPresetsElements = new ArrayList<>();
  Textlabel noPresetsLabel;
  String presetName[] = {null};

  List<Controller> initialize() {
    itemLabels = getPresetsForImport();
    formatItemLabels();
    createPopupText();
    createFileList();
    createDeleteButton();

    createNoPresetsLabel();

    return loadPresetsElements;
  }

  void showUI() {
    refreshFileList();
    itemLabels = getPresetsForImport();
    if (itemLabels != null && itemLabels.length != 0) {
      showFileList();
    } else {
      showNoPresetsLabel();
    }
  }

  void hideUI() {
    for (Controller c : loadPresetsElements) {
      c.hide();
    }
    noPresetsLabel.hide();
  }

  void formatItemLabels() {
    for (int i = 0; i < itemLabels.length; i++) {
      itemLabels[i] = String.format("%02d. %s", (i + 1), itemLabels[i]);
    }
  }

  void createPopupText() {
    Textlabel popupTitle = cp5.addTextlabel("popupTitle")
      .setText("CLICK A PRESET TO SET ITS VALUES IN CUSTOM MAP")
      .setPosition(20, 90)
      .setFont(defaultFont)
      .setSize(200, 30);
    loadPresetsElements.add(popupTitle);
  }

  void createFileList() {
    fileList = cp5.addListBox("fileList")
      .setPosition(20, 110)
      .setSize(390, 450)
      .setBarHeight(10)
      .setLabel("")
      .setFont(defaultFont)
      .setItemHeight(40)
      .addItems(itemLabels)
      .addItems(getPlaceholdersForListBox())
      .onChange(this::onFileListChange);
    loadPresetsElements.add(fileList);
  }

  void onFileListChange(CallbackEvent e) {
    int index = (int) fileList.getValue();
    if (index >= 0 && index < getPresetsForImport().length) {
      presetName[0] = getPresetsForImport()[index];
      println("Selected item: " + presetName[0]);
      settings.importPreset(presetName[0], false);
      currentPreset = presetName[0];
      uiManager.updateCustomMapUIValues();
    } else {
      presetName[0] = null;
      println("This is a placeholder.");
    }
    updateDeleteButtonColor();
  }

  void updateDeleteButtonColor() {
    deleteBtn
      .setColorForeground(presetName[0] == null ? ACTIVE_COLOR : color(150, 0, 0)) // Color on hover/click
      .setColorActive(presetName[0] == null ? ACTIVE_COLOR : color(255, 0, 0))// Color when pressed
      .setColorBackground(presetName[0] == null ? ACTIVE_COLOR : INACTIVE_COLOR);
  }

  void createDeleteButton() {
    deleteBtn = cp5.addButton("deleteBtn")
      .setLabel("Delete")
      .setPosition(415, 110)
      .setSize(105, 30)
      .setColorBackground(color(150))
      .setColorForeground(color(150))
      .setColorActive(color(150))
      .setFont(defaultFont)
      .onClick(this::onDeleteButtonClick);
    loadPresetsElements.add(deleteBtn);
  }

  void onDeleteButtonClick(CallbackEvent e) {

    if (presetName[0] != null) {
      deletePreset(presetName[0]);
    } else if (presetName[0] == null) {
      println("No preset selected for delete.");
    }
  }

  void deletePreset(String presetNameTemp) {
    String fileName = presetNameTemp + ".json";
    String directoryPath = sketchPath(savedPresetsFolder);
    File fileToDelete = new File(directoryPath, fileName);

    if (fileToDelete.exists() && fileToDelete.delete()) {
      println("File deleted: " + fileName);
      refreshFileList();
    } else {
      println(fileToDelete.exists() ? "Failed to delete the file: " + fileName : "File not found: " + fileName);
    }
  }

  void refreshFileList() {
    fileList.clear();
    itemLabels = getPresetsForImport();
    if (itemLabels != null && itemLabels.length != 0) {
      formatItemLabels();
      fileList.addItems(itemLabels);
      fileList.addItems(getPlaceholdersForListBox());
      presetName[0] = null;
    } else {
      hideUI();
      showNoPresetsLabel();
    }
  }

  void createNoPresetsLabel() {

    if (fileList != null) fileList.hide();

    noPresetsLabel = cp5.addTextlabel("noPresetsTitle")
      .setText("NO SAVED PRESETS")
      .setPosition(210, 90)
      .setFont(defaultFont)
      .setSize(200, 30)
      .setVisible(false);
  }

  void showFileList() {
    for (Controller c : loadPresetsElements) {
      c.show();
    }
  }

  void showNoPresetsLabel() {
    noPresetsLabel.show();
  }

  String[] getPlaceholdersForListBox() {
    int numOfPlaceholders = Math.max(0, 11 - (itemLabels != null ? itemLabels.length : 0));
    String[] placeholders = new String[numOfPlaceholders];
    Arrays.fill(placeholders, "");
    return placeholders;
  }

  String[] getPresetsForImport() {
    File dir = new File(sketchPath(savedPresetsFolder));
    String[] jsonFiles = dir.list((d, name) -> name.endsWith(".json"));

    if (jsonFiles != null) {
      for (int i = 0; i < jsonFiles.length; i++) {
        jsonFiles[i] = jsonFiles[i].replace(".json", "");
      }
      return jsonFiles;
    } else {
      println("No .json files found.");
      return new String[0];
    }
  }
}
