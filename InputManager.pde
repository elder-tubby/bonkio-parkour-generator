void keyPressed() {
  if (isExportTextfieldOpen) return;

  if (key == 'p') editLinesManager.handlePlatsColorBtnClick();
  if (key == 's') editLinesManager.handleSpawnBtnClick();

  handleMovementKeys();
  handleControlKeyActions();
  handleEditKeyActions();
  handleGenerateKeyActions();
  handleProcessingLinesKeyActions();
}

void handleMovementKeys() {
  if (keyCode == CONTROL) isControlPressed = true;
  if (keyCode == SHIFT) isShiftPressed = true;

  if (keyCode == RIGHT) {
    isRightPressed = true;
  } else if (keyCode == LEFT) {
    isLeftPressed = true;
  } else if (keyCode == UP) {
    isUpPressed = true;
  } else if (keyCode == DOWN) {
    isDownPressed = true;
  }
}

void handleControlKeyActions() {
  if (!isControlPressed) return;

  if (uiManager.activeTabIndex == 0) {
    if (key == '1') uiManager.customMapPage.setActiveSubPage(1);
    //else if (key == '2') uiManager.customMapPage.setActiveSubPage(2);
    else if (key == '3') uiManager.customMapPage.setActiveSubPage(3);
  }

  if (keyCode == TAB) {
    cycleTabs();
  }
}

void cycleTabs() {
  if (uiManager.activeTabIndex == 0) uiManager.selectTab(1);
  else if (uiManager.activeTabIndex == 1) uiManager.selectTab(2);
  else if (uiManager.activeTabIndex == 2) uiManager.selectTab(0);
}

void handleEditKeyActions() {
  if (selectedLine == null) {
    if (key == 'b') bgButtonManager.handleBgButtonClick();

    if (keyCode == RIGHT) noOfLines += 3;
    else if (keyCode == LEFT) noOfLines -= 3;
    uiManager.updateNoOfLinesSlider();
  } else {
    if (!isControlPressed && !isShiftPressed) {
      handleLineMovement();
    } else if (isControlPressed) {
      handleLineResize();
    } else if (isShiftPressed) {
      handleLineRotation();
    }
  }
}

void handleLineMovement() {
  if (isRightPressed) selectedLine.centerX += 1;
  if (isLeftPressed) selectedLine.centerX -= 1;
  if (isUpPressed) selectedLine.centerY -= 1;
  if (isDownPressed) selectedLine.centerY += 1;
}

void handleLineResize() {
  if (keyCode == RIGHT) selectedLine.width += 2;
  else if (keyCode == LEFT) selectedLine.width -= 2;
  else if (keyCode == UP) selectedLine.height += 2;
  else if (keyCode == DOWN) selectedLine.height -= 2;
}

void handleLineRotation() {
  if (keyCode == RIGHT) selectedLine.angle += 1;
  else if (keyCode == LEFT) selectedLine.angle -= 1;
}

void handleGenerateKeyActions() {
  if (!isProcessingLines) {
    if (key == 'f') generateBtnManager.handleGenerateFloorsClick();
    else if (key == 'l') generateBtnManager.handleGenerateLinesClick();
    else if (key == 'c') editLinesManager.handleCopyLineDataBtnClick();

    if (selectedLine == null) {
      if (key == 'g') generate();
      if (key == 'a') editLinesManager.handleAddNewLineBtnClick();
    } else {
      handleLineToggleActions();
    }
  }
}

void handleLineToggleActions() {
  if (key == 'b') {
    boolean isBouncy = !selectedLine.isBouncy;
    editLinesManager.handleBounceToggle(isBouncy);
  }
  if (key == 'd') {
    boolean isDeath = !selectedLine.isDeath;
    editLinesManager.handleDeathToggle(isDeath);
  }

  if (key == 'g') {
    boolean hasGrapple = !selectedLine.hasGrapple;
    editLinesManager.handleGrappleToggle(hasGrapple);
  }

  if (keyCode == DELETE) editLinesManager.handleDeleteLineBtnClick();
}

void handleProcessingLinesKeyActions() {
  if (key == 'c') isProcessingLines = false;
}


void mouseDragged() {
  if (dragging && selectedLine != null) {
    updateLinePosition(selectedLine);
  }

  if (settings.addNoPhysicsLineDuplicates[0] && selectedLine != null) {
    Line duplicate = noPyhsicsDuplicateLineMap.get(selectedLine);
    if (duplicate != null) updateLinePosition(duplicate);
  }

  if (isDraggingSpawn) {
    cp5.getController("lineDataCopiedLabel").hide();
    // Move the circle with the mouse
    spawnPosition.set(mouseX, mouseY);
  }
}

void updateLinePosition(Line line) {
  cp5.getController("lineDataCopiedLabel").hide();
  line.centerX = mouseX;
  line.centerY = mouseY;
}

void mousePressed() {
  if (shouldSkipMouseSelection()) return;

  if (isSpawnPlaced && dist(mouseX, mouseY, spawnPosition.x, spawnPosition.y) <= spawnRadius) {
    isDraggingSpawn = true;
    return;
  }

  for (Line line : lines) {
    if (line.isMouseOver(mouseX, mouseY)) {
      if (selectLine(line)) break;
    }
  }
}

boolean shouldSkipMouseSelection() {
  return editLinesManager.isMouseOverSlider() || cp5.isMouseOver(); // Check if mouse is over a slider or any cp5 element
}

boolean selectLine(Line line) {
  if (line.noPhysics) {
    selectedLine = null;
  } else {
    selectedLine = line;
    dragging = true;
    editLinesManager.updateSlidersAndToggles();
    return true;
  }
  return false;
}


void mouseReleased() {
  isDraggingSpawn = false; // Stop dragging the circle
  dragging = false;
}

void keyReleased() {
  if (keyCode == CONTROL) {
    isControlPressed = false; // Reset flag when CONTROL is released
  }

  if (keyCode == SHIFT) {
    isShiftPressed = false;
  }

  if (keyCode == RIGHT) {
    isRightPressed = false;
  } else if (keyCode == LEFT) {
    isLeftPressed = false;
  } else if (keyCode == UP) {
    isUpPressed = false;
  } else if (keyCode == DOWN) {
    isDownPressed = false;
  }
}
