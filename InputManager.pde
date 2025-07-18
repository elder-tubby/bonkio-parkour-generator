ArrayList<Line> multiSelectedLines = new ArrayList<>();
boolean isSelecting = false;
PVector selectionStart = new PVector();
PVector selectionEnd = new PVector();
float dragOffsetX, dragOffsetY;

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


  if (!isProcessingLines) {
    if (keyCode == 'P' || keyCode == 'p') {
      handlePasteLineDataBtnClick();
    }
  }

  if (keyCode == 'S' || keyCode == 's') {
    scriptManager.toggleVisibility();
  }


  if (uiManager.activeTabIndex == 0) {
    if (key == '1') uiManager.customMapPage.setActiveSubPage(1);
    else if (key == '2') uiManager.customMapPage.setActiveSubPage(2);
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
  if (selectedLine == null && (multiSelectedLines == null || multiSelectedLines.isEmpty())) {
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
  // Move selected line
  if (selectedLine != null) {
    if (isRightPressed) selectedLine.centerX += 1;
    if (isLeftPressed) selectedLine.centerX -= 1;
    if (isUpPressed) selectedLine.centerY -= 1;
    if (isDownPressed) selectedLine.centerY += 1;
  }

  // Move all lines in multiSelectedLines
  if (multiSelectedLines.size() > 0) {
    for (Line line : multiSelectedLines) {
      if (isRightPressed) line.centerX += 1;
      if (isLeftPressed) line.centerX -= 1;
      if (isUpPressed) line.centerY -= 1;
      if (isDownPressed) line.centerY += 1;
    }
  }
}


void handleLineResize() {
  // Resize the selected line
  if (selectedLine != null) {
    if (keyCode == RIGHT) selectedLine.width += 2;
    else if (keyCode == LEFT) selectedLine.width -= 2;
    else if (keyCode == UP) selectedLine.height += 2;
    else if (keyCode == DOWN) selectedLine.height -= 2;
  }

  // Resize all lines in multiSelectedLines
  if (multiSelectedLines.size() > 0) {
    for (Line line : multiSelectedLines) {
      if (keyCode == RIGHT) line.width += 2;
      else if (keyCode == LEFT) line.width -= 2;
      else if (keyCode == UP) line.height += 2;
      else if (keyCode == DOWN) line.height -= 2;
    }
  }
}

void handleLineRotation() {
  // Rotate the selected line
  if (selectedLine != null) {
    if (keyCode == RIGHT) selectedLine.angle += 1;
    else if (keyCode == LEFT) selectedLine.angle -= 1;
  }

  // Rotate all lines in multiSelectedLines
  else if (multiSelectedLines.size() > 0) {
    for (Line line : multiSelectedLines) {
      if (keyCode == RIGHT) line.angle += 1;
      else if (keyCode == LEFT) line.angle -= 1;
      else if (keyCode == UP) // rotate clockwise:
        editLinesManager.rotateSelectedLinesAsGroup(0.1);
      else if (keyCode == DOWN)
        // rotate counter‑clockwise:
        editLinesManager.rotateSelectedLinesAsGroup(-0.1);
    }
  }
}


void handleGenerateKeyActions() {
  if (!isProcessingLines) {
    if (key == 'f') generateBtnManager.handleGenerateFloorsClick();
    else if (key == 'l') generateBtnManager.handleGenerateLinesClick();
    else if (key == 'c') editLinesManager.handleCopyLineDataBtnClick();
    else if (key == 'x') uiManager.moreOptionsPage.handleCreateDeathFromPathClick(false);
    if (selectedLine == null && (multiSelectedLines == null || multiSelectedLines.isEmpty())) {
      if (key == 'g') generate();
      if (key == 'a') editLinesManager.handleAddNewLineBtnClick();
    } else {
    }
  }
  if (selectedLine != null || multiSelectedLines.size() > 0) {
    handleLineToggleActions();
  }
}

void handleLineToggleActions() {
  boolean isBouncy;
  if (key == 'b') {
    // Handle bounce toggle for multi-selected or single selected line
    if (multiSelectedLines.size() > 1) {
      isBouncy = !multiSelectedLines.get(0).isBouncy;
    } else if (selectedLine != null) {
      isBouncy = !selectedLine.isBouncy;
    } else {
      return; // No line selected, do nothing
    }
    editLinesManager.handleBounceToggle(isBouncy);
  }

  if (key == 'd') {
    // Handle death toggle for multi-selected or single selected line
    boolean isDeath;
    if (multiSelectedLines.size() > 1) {
      isDeath = !multiSelectedLines.get(0).isDeath;
    } else if (selectedLine != null) {
      isDeath = !selectedLine.isDeath;
    } else {
      return; // No line selected, do nothing
    }
    editLinesManager.handleDeathToggle(isDeath);
  }

  if (key == 'g') {
    // Handle grapple toggle for multi-selected or single selected line
    boolean hasGrapple;
    if (multiSelectedLines.size() > 1) {
      hasGrapple = !multiSelectedLines.get(0).hasGrapple;
    } else if (selectedLine != null) {
      hasGrapple = !selectedLine.hasGrapple;
    } else {
      return; // No line selected, do nothing/
    }
    editLinesManager.handleGrappleToggle(hasGrapple);
  }

  if (key == 'n') {
    // Handle no jump toggle for multi-selected or single selected line
    boolean isNoJump;
    if (multiSelectedLines.size() > 1) {
      isNoJump = !multiSelectedLines.get(0).isNoJump;
    } else if (selectedLine != null) {
      isNoJump = !selectedLine.isNoJump;
    } else {
      return; // No line selected, do nothing
    }
    editLinesManager.handleNoJumpToggle(isNoJump);
  }

  if (keyCode == DELETE) editLinesManager.handleDeleteLineBtnClick();
}

void handleProcessingLinesKeyActions() {
  if (key == 'c') isProcessingLines = false;
}




void updateLinePosition(Line line) {
  if (line.noPhysics) return;
  cp5.getController("lineDataCopiedLabel").hide();
  line.centerX = mouseX - dragOffsetX;
  line.centerY = mouseY - dragOffsetY;
}

void mousePressed() {
  lineManager.updateNoPhysicsPlatsColor(); // Can't figure out where else to place it. This line is why noPhysicsDplicates change color on every mouse press.

  if (selectedLine != null && mouseX < startOfWidth - 50)
    selectedLine = null;

  if (shouldSkipMouseSelection()) return;

  if (isSpawnPlaced && dist(mouseX, mouseY, spawnPosition.x, spawnPosition.y) <= spawnRadius) {
    isDraggingSpawn = true;
    return;
  }

  for (Line line : lines) {
    // Check if the line is under the mouse and not already in multiSelectedLines
    if (line.isMouseOver(mouseX, mouseY) && !multiSelectedLines.contains(line)) {
      if (selectLine(line)) {
        println("Selected a line");
        break;
      }
    }
  }



  if (selectedLine != null) {
    dragOffsetX = mouseX - selectedLine.centerX;
    dragOffsetY = mouseY - selectedLine.centerY;
  }

  if (selectedLine == null) {

    // Start selection area
    isSelecting = true;
    cursor(CROSS);
    selectionStart.set(mouseX, mouseY);
    selectionEnd.set(mouseX, mouseY);
    multiSelectedLines.clear();
  }
  boolean isMouseOverLine = false;
  for (Line line : lines) {
    // Check if the line is under the mouse and not already in multiSelectedLines
    if (line.isMouseOver(mouseX, mouseY)) {
      isMouseOverLine = true;
      break;
    }
  }
  if (!isMouseOverLine) selectedLine = null;
}

boolean shouldSkipMouseSelection() {
  return editLinesManager.isMouseOverSlider() || cp5.isMouseOver() || mouseX < startOfWidth - 50; // Check if mouse is over a slider or any cp5 element
}

boolean selectLine(Line line) {
  if (line.noPhysics) {
    selectedLine = null;
    multiSelectedLines.clear(); // Deselect everything
  } else {
    selectedLine = line;
    multiSelectedLines.clear();
    dragging = true;
    editLinesManager.updateSlidersAndToggles();
    return true;
  }
  return false;
}



void mouseDragged() {
  if (isSelecting) {
    selectionEnd.set(mouseX, mouseY);
    updateMultiSelection();
  } else if (dragging && (selectedLine != null || multiSelectedLines.size() > 0)) {

    if (selectedLine != null) {
      updateLinePosition(selectedLine);
    }
    for (Line line : multiSelectedLines) {
      updateLinePosition(line);
    }
  }

  if (settings.addNoPhysicsLineDuplicates[0] && selectedLine != null && noPhysicsDuplicateLineMap != null) {
    Line duplicate = noPhysicsDuplicateLineMap.get(selectedLine);
    if (duplicate != null) updateLinePosition(duplicate);
  }

  if (isDraggingSpawn) {
    cp5.getController("lineDataCopiedLabel").hide();
    spawnPosition.set(mouseX, mouseY);
  }
}

void mouseReleased() {
  isDraggingSpawn = false;
  dragging = false;
  isSelecting = false;
  cursor(ARROW);
}

void updateMultiSelection() {
  multiSelectedLines.clear();
  float selLeft   = min(selectionStart.x, selectionEnd.x);
  float selRight  = max(selectionStart.x, selectionEnd.x);
  float selTop    = min(selectionStart.y, selectionEnd.y);
  float selBottom = max(selectionStart.y, selectionEnd.y);

  for (Line line : lines) {
    if (!line.noPhysics && lineIntersectsSelection(line, selLeft, selTop, selRight, selBottom)) {
      multiSelectedLines.add(line);
      cp5.getController("lineDataCopiedLabel").hide();
    }
  }
}

// Helper function – assumes your Line class has endpoints x1,y1 and x2,y2.
boolean lineIntersectsSelection(Line line, float selLeft, float selTop, float selRight, float selBottom) {
  // Get the four corners of the line
  PVector[] corners = line.getCorners();

  // Check if any corner is inside the selection rectangle.
  for (PVector p : corners) {
    if (p.x >= selLeft && p.x <= selRight && p.y >= selTop && p.y <= selBottom) {
      return true;
    }
  }

  // Optionally, check if the line's bounding box intersects the selection rectangle.
  float lineMinX = Float.MAX_VALUE;
  float lineMaxX = Float.MIN_VALUE;
  float lineMinY = Float.MAX_VALUE;
  float lineMaxY = Float.MIN_VALUE;

  for (PVector p : corners) {
    if (p.x < lineMinX) lineMinX = p.x;
    if (p.x > lineMaxX) lineMaxX = p.x;
    if (p.y < lineMinY) lineMinY = p.y;
    if (p.y > lineMaxY) lineMaxY = p.y;
  }

  // Check if the bounding boxes intersect.
  boolean intersects = (lineMinX <= selRight && lineMaxX >= selLeft &&
    lineMinY <= selBottom && lineMaxY >= selTop);
  return intersects;
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
