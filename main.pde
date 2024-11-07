import java.util.List;
import controlP5.*;
import java.util.Map;
import processing.data.JSONObject;
import processing.data.JSONArray;
import java.util.Arrays;
import java.io.File;
import java.io.FilenameFilter;
import java.lang.reflect.Field;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.util.concurrent.CopyOnWriteArrayList;

// For map size 9
//float maxJumpHeight = 51.9; //The bottom-most point of player's circle when they are at max height
//float maxSpecialJumpHeight = 124;
//float minJumpHeight = 14.8; // Without using heavy. The bottom-most point of player's circle when they are at min height
//float playerDiameter = 9;

String savedPresetsFolder = "saved-presets";

CopyOnWriteArrayList<Line> lines = new CopyOnWriteArrayList<>();
LineManager lineManager;
UIManager uiManager;
Settings settings = new Settings();
BgButton bgButton;
EditLinesManager editLinesManager;
GenerateBtnManager generateBtnManager;

int numOfColorSchemesAvailable = 65;
String currentPreset;
int noOfLines = 0;

boolean isProcessingLines = false;
boolean isControlPressed = false;

// Canvas properties:

int startOfWidth = 570;
int startOfHeight = 100;
int endOfWidth = 1300;
int endOfHeight = 600;

PFont defaultFont, tabFont;

final int ACTIVE_COLOR = color(0, 116, 217);
final int INACTIVE_COLOR = color(0, 45, 90);
final int GREYED_OUT_COLOR = color(150, 150, 150);

Line selectedLine = null;
boolean dragging = false;
boolean isDraggingCircle = false; // Check if the circle is being dragged
boolean isCirclePlaced = false; // Check if the circle has been placed
PVector circlePosition; // Position of the circle
float circleRadius; // Radius of the circle
boolean isExportTextfieldOpen;

ControlP5 cp5;

void setup() {
  defaultFont = createFont("Tw Cen MT Bold", 12);
  tabFont = createFont("Tw Cen MT Bold", 11);
  size(1310, 710);
  cp5 = new ControlP5(this);

  currentPreset = "temp"; // in case save presets is clicked before importing any preset
  generateBtnManager = new GenerateBtnManager();
  uiManager = new UIManager();
  editLinesManager = new EditLinesManager();
  lineManager = new LineManager();
}

void generate() {
  lines.clear();
  background(0);
  lineManager = new LineManager();
  selectedLine = null;
  cp5.getController("lineDataCopiedLabel").hide();
}

void draw() {
  background(200);

  drawLinesFromList();
  drawSpawn();
  drawColorIndicator();
  editLinesManager.updateEditLineUI();
  generateBtnManager.updateGenerateButtonsUI();

  //setLockAndColor("defaultPresetsBtn", true); // also disabled its hotkey
  setLockAndColor("addPhysicsLineDuplicates", true);
}

void drawSpawn() {
  //Draw the circle if it has been placed
  if (isCirclePlaced) {
    circleRadius = getSpawnSize();
    fill(255, 0, 0); // Circle color
    strokeWeight(1);
    stroke(0);
    ellipse(circlePosition.x, circlePosition.y, circleRadius * 2, circleRadius * 2);
  }
}

void drawLinesFromList() {
  //synchronized (lines) {

  for (Line line : lines) {
    if (line == selectedLine) {
      line.drawLine(true);  // Draw with an outline
    } else {
      line.drawLine(false);  // Draw normally
    }
  }
  //}
}

void mousePressed() {

  if (editLinesManager.isMouseOverSlider()) {
    return; // Skip line selection if over a slider
  }

  if (cp5.isMouseOver()) {
    return; // Skip line selection if over a cp5 controller
  }


  if (isCirclePlaced && dist(mouseX, mouseY, circlePosition.x, circlePosition.y) <= circleRadius) {
    isDraggingCircle = true; // Start dragging the circle
    return;
  }


  for (Line line : lines) {
    if (line.noPhysics == false && line.isMouseOver(mouseX, mouseY)) {
      selectedLine = line;

      dragging = true;
      editLinesManager.updateSlidersAndToggles();
      break;
    }
    if (line.noPhysics == true && line.isMouseOver(mouseX, mouseY)) {
      selectedLine = null;
    }
  }
}

void mouseDragged() {
  if (dragging && selectedLine != null) {
    cp5.getController("lineDataCopiedLabel").hide();
    selectedLine.centerX = mouseX;
    selectedLine.centerY = mouseY;
  }
  if (isDraggingCircle) {
    cp5.getController("lineDataCopiedLabel").hide();
    // Move the circle with the mouse
    circlePosition.set(mouseX, mouseY);
  }
}

void mouseReleased() {
  isDraggingCircle = false; // Stop dragging the circle
  dragging = false;
}

void keyPressed() {

  if (isExportTextfieldOpen) return;

  if (keyCode == CONTROL) isControlPressed = true;

  if (!isControlPressed) {
  } else if (isControlPressed) {

    if (uiManager.activeTabIndex == 0) {
      if (key == '1') uiManager.customMapPage.setActiveSubPage(1);
      else if (key == '2') uiManager.customMapPage.setActiveSubPage(2);
      else if (key == '3') uiManager.customMapPage.setActiveSubPage(3);
    }
    if (keyCode == TAB) {
      if (uiManager.activeTabIndex == 0) uiManager.selectTab(1);
      else if (uiManager.activeTabIndex == 1) uiManager.selectTab(2);
      else if (uiManager.activeTabIndex == 2) uiManager.selectTab(0);
    }
  }
  if (key == 'b') bgButton.handleBgButtonClick();
  if (key == 'p') editLinesManager.handlePlatsColorBtnClick();
  if (key == 's') editLinesManager.handleSpawnBtnClick();

  if (selectedLine == null) {

    if (keyCode == RIGHT) noOfLines += 3; // Increment by 1
    else if (keyCode == LEFT) noOfLines -= 3; // Decrement by 1
    uiManager.updateNoOfLinesSlider();
  } else if (selectedLine != null) {

    if (!isControlPressed) {

      if (keyCode == RIGHT) selectedLine.width += 2;
      else if (keyCode == LEFT) selectedLine.width -= 2;
      else if (  keyCode == UP) selectedLine.height += 2;
      else if (keyCode == DOWN) selectedLine.height -= 2;
    } else if (isControlPressed) {

      if (keyCode == RIGHT) selectedLine.angle += 1;
      else if (keyCode == LEFT) selectedLine.angle -= 1;
    }
  }

  if (!isProcessingLines) {
    if (key == 'g') generate();
    else if (key == 'f') generateBtnManager.handleGenerateFloorsClick();
    else if (key == 'l') generateBtnManager.handleGenerateLinesClick();
    else if (key == 'c') editLinesManager.handleCopyLineDataBtnClick();

    if (selectedLine == null) {
      if (key == 'a') editLinesManager.handleAddNewLineBtnClick();
    } else if (selectedLine != null) {
      if (key == 'd') editLinesManager.handleDeleteLineBtnClick();
    }
  } else {
    if (key == 'c') isProcessingLines = false;
  }
}

void keyReleased() {
  if (keyCode == CONTROL) {
    isControlPressed = false; // Reset flag when CONTROL is released
  }
}
