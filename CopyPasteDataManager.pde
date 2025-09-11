void saveLineAttributes() {

  float spawnX;
  float spawnY;
  if  (spawnPosition != null) {
    float halfMapWidth = (endOfWidth - startOfWidth) / 2;
    float halfMapHeight = (endOfHeight - startOfHeight) / 2;
    float convertedXPos = spawnPosition.x - startOfWidth - halfMapWidth;
    float convertedYPos = spawnPosition.y - startOfHeight - halfMapHeight;

    spawnX = convertedXPos;
    spawnY = convertedYPos;
  } else {
    spawnX = 99999;
    spawnY = 99999;
  }

  int mapSize = (int) Math.floor(settings.mapSize[0]);

  // Create the main JSON object
  JSONObject jsonObject = new JSONObject();
  jsonObject.put("version", 1);

  // Create the "spawn" JSON object
  JSONObject spawnObject = new JSONObject();
  spawnObject.put("spawnX", spawnX);
  spawnObject.put("spawnY", spawnY);
  jsonObject.put("spawn", spawnObject);

  // Add map size
  jsonObject.put("mapSize", mapSize);

  // Create the "objects" JSON array (renamed from "lines")
  JSONArray objectsArray = new JSONArray();

  int id = 0;
  HashMap<Line, Integer> lineIdMap = new HashMap<>();

  // First pass: Assign IDs
  for (Line line : lines) {
    if (line.isOnlyForProgram) continue;
    lineIdMap.put(line, id++);
  }

  for (Line line : lines) {
    if (line.isOnlyForProgram) continue;

    int colorString = rgbToDecimal(line.lineColor);
    boolean isDeath = line.isDeath;
    boolean noGrapple = !line.hasGrapple;
    boolean noPhysics = line.noPhysics;

    // Create the object JSON
    JSONObject obj = new JSONObject();
    obj.put("id", lineIdMap.get(line));
    obj.put("x", line.centerX);
    obj.put("y", line.centerY);
    obj.put("width", line.width);
    obj.put("height", line.height);
    obj.put("angle", line.angle);
    obj.put("isDeath", isDeath);
    obj.put("isBouncy", line.isBouncy);
    obj.put("color", colorString);
    obj.put("noPhysics", noPhysics);
    obj.put("isSelectableNoPhysics", line.isSelectableNoPhysics);
    obj.put("noGrapple", noGrapple);
    obj.put("isCapzone", line.isCapzone);
    obj.put("isNoJump", line.isNoJump);
    obj.put("isFrame", line.isFrame);
    obj.put("isFloor", line.isFloor);
    obj.put("isBgLine", line.isBgLine);
    obj.put("isOnlyForProgram", line.isOnlyForProgram);

    // NEW: add type
    obj.put("type", "line");

    if (!line.isBouncy) {
      line.bounciness = "-1";
    }

    if (line.bounciness != null && !line.bounciness.equals("null")) {
      obj.put("bounciness", Float.parseFloat(line.bounciness));
    } else {
      obj.put("bounciness", JSONObject.NULL);
    }

    obj.put("friction", line.friction);

    if (!noPhysics && noPhysicsDuplicateLineMap != null && noPhysicsDuplicateLineMap.containsKey(line)) {
      Line duplicate = noPhysicsDuplicateLineMap.get(line);
      if (lineIdMap.containsKey(duplicate)) {
        obj.put("noPhysicsDuplicateId", lineIdMap.get(duplicate));
      }
    }

    objectsArray.append(obj);
    id++;
  }

  // Attach objects array instead of lines array
  jsonObject.put("objects", objectsArray);

 // --- NEW COLORS SECTION ---
  JSONObject colorsObject = new JSONObject();

  // background: first bg line
  for (Line line : lines) {
    if (line.isBgLine) {
      colorsObject.put("background", "rgb(" + red(line.lineColor) + ", " + green(line.lineColor) + ", " + blue(line.lineColor) + ")");
      break;
    }
  }

  // none: first physics, not death, not bouncy
  for (Line line : lines) {
    if (!line.noPhysics && !line.isDeath && !line.isBouncy) {
      colorsObject.put("none", "rgb(" + red(line.lineColor) + ", " + green(line.lineColor) + ", " + blue(line.lineColor) + ")");
      break;
    }
  }

  // bouncy
  for (Line line : lines) {
    if (line.isBouncy) {
      colorsObject.put("bouncy", "rgb(" + red(line.lineColor) + ", " + green(line.lineColor) + ", " + blue(line.lineColor) + ")");
      break;
    }
  }

  // death
  for (Line line : lines) {
    if (line.isDeath) {
      colorsObject.put("death", "rgb(" + red(line.lineColor) + ", " + green(line.lineColor) + ", " + blue(line.lineColor) + ")");
      break;
    }
  }

  // Attach colors object to the root json
  jsonObject.put("colors", colorsObject);



  // Convert to JSON string
  String jsonOutput = jsonObject.toString();

 
  // Copy to clipboard and show label
  copyToClipboard(jsonOutput);
  cp5.getController("lineDataCopiedLabel").show();
}



void handlePasteLineDataBtnClick() {
  // Step 1: Get clipboard data as a JSON string
  String clipboardData = getClipboardString(); // This retrieves the clipboard data as a String

  if (clipboardData == null || clipboardData.isEmpty()) {
    println("Clipboard is empty or contains non-text data.");
    return;
  }

  // Step 2: Parse the clipboard data into a JSONObject
  JSONObject jsonData = new JSONObject(); // Create an empty JSONObject
  jsonData = parseJSONObject(clipboardData); // Use parseJSONObject to convert string to JSONObject

  if (jsonData == null) {
    println("Failed to parse JSON data.");
    return;
  }

  // Step 3: Get mapSize and spawn data

  lineManager.clearAllLinesExceptProgramLines();
  selectedLine = null;
  cp5.getController("lineDataCopiedLabel").hide();

  // Safely retrieve mapSize, defaulting to a value if it doesn't exist
  int mapSize;

  if (jsonData.hasKey("version")) {

    if (jsonData.hasKey("mapSize")) {
      mapSize = jsonData.getInt("mapSize");
    } else {
      mapSize = (int) Math.floor(settings.mapSize[0]);
    }
  } else {
    if (jsonData.hasKey("mapSize")) {
      mapSize = getTransformedMapSize(jsonData.getInt("mapSize"));
    } else {
      mapSize = getTransformedMapSize(7);
    }
  }

  settings.mapSize[0] = mapSize;
  uiManager.customMapPage.updateControllerByName("mapSize", mapSize);

  // Safely retrieve spawn data, creating a default if "spawn" key is missing
  JSONObject spawnData = jsonData.hasKey("spawn") ? jsonData.getJSONObject("spawn") : new JSONObject(); // Default to an empty JSONObject if "spawn" is missing

  // Safely retrieve spawnX and spawnY, defaulting to some reasonable value if missing
  float spawnX = spawnData.hasKey("spawnX") ? spawnData.getFloat("spawnX") : 99999.0f; // Default to 99999 if "spawnX" is missing
  float spawnY = spawnData.hasKey("spawnY") ? spawnData.getFloat("spawnY") : 99999.0f; // Default to 99999 if "spawnY" is missing

  if (spawnX != 99999 && spawnY != 99999) {

    float halfMapWidth = (endOfWidth - startOfWidth) / 2;
    float halfMapHeight = (endOfHeight - startOfHeight) / 2;
    float convertedXPos = spawnX + startOfWidth + halfMapWidth;
    float convertedYPos = spawnY + startOfHeight + halfMapHeight;
    spawnX = convertedXPos;
    spawnY = convertedYPos;

    if (!isSpawnPlaced) {
      spawnPosition = new PVector(spawnX, spawnY);
      isSpawnPlaced = true;
    } else
      spawnPosition.set(spawnX, spawnY);
  }
  // Step 4: Get the "lines" array from JSON
  //JSONArray linesArray = jsonData.getJSONArray("lines");

  JSONArray linesArray = jsonData.hasKey("objects") ? jsonData.getJSONArray("objects") : null;

  if (linesArray == null) {
    println("The 'objects' key is missing.");
    return;
  }

  // Step 6: Track lines by ID for later mapping
  HashMap<Integer, Line> lineIdMap = new HashMap<>();


  // Step 5: Iterate through the lines array and create new Line objects
  for (int i = 0; i < linesArray.size(); i++) {

    JSONObject lineData = linesArray.getJSONObject(i);

    if (lineData.hasKey("type") && lineData.getString("type").equals("poly")) {
      continue;

  }

    // Extract the basic attributes for the Line object
    float x = lineData.hasKey("x") && lineData.get("x") != null ? lineData.getFloat("x") : (endOfWidth - startOfWidth);
    float y = lineData.hasKey("y") && lineData.get("y") != null ? lineData.getFloat("y") : (endOfHeight - startOfHeight);
    float width = lineData.hasKey("width") && lineData.get("width") != null ? lineData.getFloat("width") : 1.0f;
    float height = lineData.hasKey("height") && lineData.get("height") != null ? lineData.getFloat("height") : 1.0f;
    float angle = lineData.hasKey("angle") && lineData.get("angle") != null ? lineData.getFloat("angle") : 0.0f;
    boolean isDeath = lineData.hasKey("isDeath") && lineData.get("isDeath") != null ? lineData.getBoolean("isDeath") : false;

    // Create the new Line object using constructor
    Line newLine = new Line(x, y, width, height, angle, isDeath);

    // Step 6: Set additional attributes based on the JSON data
    newLine.id = lineData.hasKey("id") && lineData.get("id") != null ? lineData.getInt("id") : -1;  // Default value if "id" is missing or null

    // Handle "bounciness" key, check if it's null or absent
    if (lineData.hasKey("bounciness") && lineData.get("bounciness") != null) {
      if (lineData.get("bounciness") instanceof String) {
        String bouncinessValue = lineData.getString("bounciness");
        // If it's literally "null", treat it as null
        newLine.bounciness = bouncinessValue.equals("null") ? null : bouncinessValue;
      } else if (lineData.get("bounciness") instanceof Integer || lineData.get("bounciness") instanceof Float) {
        // If it's a float, convert it to a string
        newLine.bounciness = "" + lineData.getFloat("bounciness");
      } else {
        newLine.bounciness = null; // Handle other cases or if the field is not a recognized type
      }
    } else {
      newLine.bounciness = null; // Default value if "bounciness" is null or missing
    }

    // Handle "friction", default to 0.0f if null or missing
    newLine.friction = lineData.hasKey("friction") && lineData.get("friction") != null
      ? lineData.getFloat("friction") : 0.0f;

    // Handle boolean flags with default values if null
    newLine.isBgLine = lineData.hasKey("isBgLine") && lineData.get("isBgLine") != null
      ? lineData.getBoolean("isBgLine") : false;

    newLine.noPhysics = lineData.hasKey("noPhysics") && lineData.get("noPhysics") != null
      ? lineData.getBoolean("noPhysics") : false;

    newLine.isSelectableNoPhysics = lineData.hasKey("isSelectableNoPhysics") && lineData.get("isSelectableNoPhysics") != null
      ? lineData.getBoolean("isSelectableNoPhysics") : false;

    newLine.hasGrapple = lineData.hasKey("noGrapple") && lineData.get("noGrapple") != null
      ? !lineData.getBoolean("noGrapple") : true;  // Default to true if "noGrapple" is missing or null

    newLine.isCapzone = lineData.hasKey("isCapzone") && lineData.get("isCapzone") != null
      ? lineData.getBoolean("isCapzone") : false;

    newLine.isNoJump = lineData.hasKey("isNoJump") && lineData.get("isNoJump") != null
      ? lineData.getBoolean("isNoJump") : false;

    newLine.isFrame = lineData.hasKey("isFrame") && lineData.get("isFrame") != null
      ? lineData.getBoolean("isFrame") : false;

    newLine.isFloor = lineData.hasKey("isFloor") && lineData.get("isFloor") != null
      ? lineData.getBoolean("isFloor") : false;

    newLine.isBouncy = lineData.hasKey("isBouncy") && lineData.get("isBouncy") != null
      ? lineData.getBoolean("isBouncy")
      : (newLine.bounciness != null && newLine.bounciness.equals("null") ? true : false);

    newLine.isOnlyForProgram = lineData.hasKey("isOnlyForProgram") && lineData.get("isOnlyForProgram") != null
      ? lineData.getBoolean("isOnlyForProgram") : false;

    // Handle "color", default to white if null or missing
    int colorValue = lineData.hasKey("color") && lineData.get("color") != null
      ? lineData.getInt("color") : -1;
    if (colorValue != -1)
      newLine.lineColor = decimalToRgb(colorValue);
    else
      editLinesManager.handlePlatsColorBtnClick();

    ArrayList<Line> tempLines = new ArrayList<Line>();
    tempLines.add(newLine);
    lineIdMap.put(newLine.id, newLine); // Store by ID
    lines.addAll(tempLines);
  }

  // Second pass: Link physics lines with their noPhysics duplicates
  for (int i = 0; i < linesArray.size(); i++) {
    JSONObject lineData = linesArray.getJSONObject(i);

    if (lineData.hasKey("noPhysicsDuplicateId")) {
      int physicsLineId = lineData.getInt("id");
      int duplicateId = lineData.getInt("noPhysicsDuplicateId");

      if (lineIdMap.containsKey(physicsLineId) && lineIdMap.containsKey(duplicateId)) {
        Line physicsLine = lineIdMap.get(physicsLineId);
        Line duplicateLine = lineIdMap.get(duplicateId);

        noPhysicsDuplicateLineMap.put(physicsLine, duplicateLine);
      }
    }
  }

  matchProgramColorsToPastedDataColors();
  lineManager.moveLinesForwardOrBackward();
  lineManager.updateNoPhysicsDuplicatesColor();

  // Optional: Provide feedback to the user that the lines were pasted and processed
  println("Lines have been successfully pasted and added!");
}

void matchProgramColorsToPastedDataColors() {
  for (Line line : lines) {
    if (!line.isOnlyForProgram && !line.noPhysics) {
      if (line.isDeath && !line.isBouncy && !line.hasGrapple) settings.deathColor = line.lineColor;
      if (!line.isDeath && !line.isBouncy && !line.hasGrapple) settings.nonDeathColor = line.lineColor;
      if (!line.isDeath && line.isBouncy && !line.hasGrapple) settings.bouncyColor = line.lineColor;
      if (line.hasGrapple) settings.grappleColor = line.lineColor;
    }
  }
}

int getMapSize() {
  if (Math.floor(settings.mapSize[0]) == 1) return 30;
  else if (Math.floor(settings.mapSize[0]) == 2) return 24;
  else if (Math.floor(settings.mapSize[0]) == 3) return 20;
  else if (Math.floor(settings.mapSize[0]) == 4) return 17;
  else if (Math.floor(settings.mapSize[0]) == 5) return 15;
  else if (Math.floor(settings.mapSize[0]) == 6) return 13;
  else if (Math.floor(settings.mapSize[0]) == 7) return 12;
  else if (Math.floor(settings.mapSize[0]) == 8) return 10;
  else if (Math.floor(settings.mapSize[0]) == 9) return 9;
  else if (Math.floor(settings.mapSize[0]) == 10) return 8;
  else if (Math.floor(settings.mapSize[0]) == 11) return 7;
  else if (Math.floor(settings.mapSize[0]) == 12) return 6;
  else if (Math.floor(settings.mapSize[0]) == 13) return 5;
  else return 9; // Default return value
}



color decimalToRgb(int decimal) {
  int r = (decimal >> 16) & 0xFF; // Extract red component
  int g = (decimal >> 8) & 0xFF;  // Extract green component
  int b = decimal & 0xFF;         // Extract blue component

  // Return the color object created from the RGB components
  return color(r, g, b);
}


int rgbToDecimal(color col) {
  int r = (col >> 16) & 0xFF; // Extract red component
  int g = (col >> 8) & 0xFF; // Extract green component
  int b = col & 0xFF;   // Extract blue component

  // Combine the RGB values into a single decimal value
  return (r << 16) | (g << 8) | b;
}

void copyToClipboard(String text) {
  StringSelection selection = new StringSelection(text);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(selection, selection);
}

import java.awt.datatransfer.*;
import java.awt.Toolkit;

String getClipboardString() {
  try {
    // Get the system clipboard
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();

    // Get the clipboard contents
    Transferable contents = clipboard.getContents(null);

    // Check if the clipboard contains text data
    if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
      // Return the clipboard content as a String
      return (String) contents.getTransferData(DataFlavor.stringFlavor);
    }
  }
  catch (UnsupportedFlavorException | IOException e) {
    e.printStackTrace(); // Handle any exceptions that may occur (e.g., unsupported data flavor or IO error)
  }

  // Return null if no text data is available
  return null;
}

// Function to transform mapSize based on the mapping. Only used for old JSON files when mapSize was stored differently.
int getTransformedMapSize(int mapSize) {
  println("mapsize in getransformedmap: " + mapSize);
  // Define the map size transformation mapping
  HashMap<Integer, Integer> mapSizeMapping = new HashMap<>();
  mapSizeMapping.put(30, 1);
  mapSizeMapping.put(24, 2);
  mapSizeMapping.put(20, 3);
  mapSizeMapping.put(17, 4);
  mapSizeMapping.put(15, 5);
  mapSizeMapping.put(13, 6);
  mapSizeMapping.put(12, 7);
  mapSizeMapping.put(10, 8);
  mapSizeMapping.put(9, 9);
  mapSizeMapping.put(8, 10);
  mapSizeMapping.put(7, 11);
  mapSizeMapping.put(6, 12);
  mapSizeMapping.put(5, 13);

  // Return the transformed map size, or default to 9 if no match
  return mapSizeMapping.getOrDefault(mapSize, 9);
}
