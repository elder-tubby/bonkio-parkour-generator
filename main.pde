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
import bsh.*;

// For map size 9
//float maxJumpHeight = 51.9; //The bottom-most point of player's circle when they are at max height
//float maxSpecialJumpHeight = 124;
//float minJumpHeight = 14.8; // Without using heavy. The bottom-most point of player's circle when they are at min height
//float playerDiameter = 9;

Interpreter bsh;

String savedPresetsFolder = "saved-presets";

CopyOnWriteArrayList<Line> lines = new CopyOnWriteArrayList<>();
LineManager lineManager;
UIManager uiManager;
Settings settings = new Settings();
BgButtonManager bgButtonManager;
EditLinesManager editLinesManager;
GenerateBtnManager generateBtnManager;
Map<Line, Line> noPhysicsDuplicateLineMap;

int numOfColorSchemesAvailable = 77;
String currentPreset;
int noOfLines = 1;
boolean clearExistingLines = true;

boolean isProcessingLines = false;
boolean isControlPressed = false;
boolean isShiftPressed = false;
boolean isRightPressed = false;
boolean isLeftPressed = false;
boolean isUpPressed = false;
boolean isDownPressed = false;


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
boolean isDraggingSpawn = false; // Check if the circle is being dragged
boolean isSpawnPlaced = false; // Check if the circle has been placed
PVector spawnPosition; // Position of the circle
float spawnRadius; // Radius of the circle
boolean isExportTextfieldOpen;

ControlP5 cp5;
ScriptManager scriptManager;

void setup() {
  defaultFont = createFont("Tw Cen MT Bold", 12);
  tabFont = createFont("Tw Cen MT Bold", 11);
  size(1310, 710);
  cp5 = new ControlP5(this);

  currentPreset = "temp"; // in case save presets is clicked before importing any preset
  settings.importPreset(currentPreset, false);
  generateBtnManager = new GenerateBtnManager();
  uiManager = new UIManager();
  editLinesManager = new EditLinesManager();
  lineManager = new LineManager();

  scriptManager = new ScriptManager();
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
}

void drawSpawn() {
  //Draw the circle if it has been placed
  if (isSpawnPlaced) {
    spawnRadius = getSpawnRadius();
    fill(255, 0, 0); // Circle color
    strokeWeight(1);
    stroke(0);
    ellipse(spawnPosition.x, spawnPosition.y, spawnRadius * 2, spawnRadius * 2);
  }
}

void drawLinesFromList() {

  for (Line line : lines) {
    if (line == selectedLine || multiSelectedLines.contains(line)) {
      line.drawLine(true);  // Draw with an outline
    } else {
      line.drawLine(false);  // Draw normally
    }
  }

  if (isSelecting) {
    // Switch to CORNERS mode so that the rectangle is drawn using two opposite corners.
    rectMode(CORNERS);
    fill(0, 0, 255, 50); // Semi-transparent blue fill
    stroke(0, 0, 255);   // Blue stroke
    rect(selectionStart.x, selectionStart.y, selectionEnd.x, selectionEnd.y);
    // Optionally, restore the rectMode to CORNER if your other drawing uses it:
    rectMode(CORNER);
  }
  if (!isProcessingLines)
    lineManager.moveLinesForwardOrBackward();
}
