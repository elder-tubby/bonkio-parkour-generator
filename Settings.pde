class Settings {
  // Line properties:

  ArrayList<Float> heightOfLine;
  boolean[] sameHeightForAllLines = new boolean[1];
  float[] minLineHeight = new float[1];
  float[] maxLineHeight = new float[1];

  ArrayList<Float> widthOfLine;
  boolean[] sameWidthForAllLines = new boolean[1];
  float[] minLineWidth = new float[1];
  float[] maxLineWidth = new float[1];

  float[] chancesOfDeath = new float[1];
  float[] chancesOfBounciness = new float[1];
  String globalBounciness;
  float[] chancesOfGrapple = new float[1];
  float[] chancesOfNoJump = new float[1];

  boolean[] sameColorForAllNonDLines = new boolean[1];
  boolean[] sameColorForAllDLines = new boolean[1];
  boolean[] sameColorForAllBLines = new boolean[1];
  boolean[] sameColorForAllGLines = new boolean[1];

  color deathColor;
  color nonDeathColor;

  color bouncyColor;
  color grappleColor;

  boolean[] setSpecificLineAngles = new boolean[1];
  ArrayList<Float> nonDLineAngle;
  ArrayList<Float> dLineAngle;

  float[] lineAngleStart = new float[1];
  float[] lineAngleEnd = new float[1];

  // Map properties:

  float[] minDistanceBtwDLines = new float[1];
  float[] minDistanceBtwNonDLines = new float[1];

  float[] chancesForDLinesAndNonDLinesToConnect = new float[1];
  float[] chancesForNonDLinesToConnectWithFloors = new float[1];

  boolean[] limitLineAngleAfterConnectingItsCorner = new boolean[1];
  float[] lineConnectAngleStart = new float[1];
  float[] lineConnectAngleEnd = new float[1];

  boolean[] areDLinesAtBack = new boolean[1];
  boolean[] areBLinesAtBack = new boolean[1];

  boolean[] addNoPhysicsLineDuplicates = new boolean[1];
  boolean[] addBackground = new boolean[1];

  /* Randomly chooses one color scheme from the list of schemes in the array.
   Leave empty for randomly choosing a scheme from all avalable schemes.*/
  boolean[] rndlyChooseOneSchemeForBg;

  boolean[] addFrames = new boolean[1];
  float[] frameWidth = new float[1];
  float[] frameAngleStart = new float[1];
  float[] frameAngleEnd = new float[1];
  float[] minDistanceBtwNonDLinesAndFrames = new float[1];

  boolean[] addFloors = new boolean[1];
  float[] numOfFloors = new float[1];

  float[] minFloorWidth = new float[1];
  float[] maxFloorWidth = new float[1];
  float[] floorHeight = new float[1];

  float[] minDistanceBtwFloors = new float[1];
  float[] minDistanceBtwNonDLinesAndFloors = new float[1];
  float[] minDistanceBtwDLinesAndFloors = new float[1];

  boolean[] setSpecificFloorAngles = new boolean[1];
  ArrayList<Float> floorAngle;
  float[] floorAngleStart = new float[1];
  float[] floorAngleEnd = new float[1];

  boolean[] areFloorsBouncy = new boolean[1];

  float[] chancesForDLinesToConnectWithFloors = new float[1];
  float[] chancesForFloorsAndFloorsToConnect = new float[1];

  float[] chancesForFloorsToConnectWithFrames = new float[1];
  boolean[] connectFloorUp = new boolean[1];
  boolean[] connectFloorDown = new boolean[1];
  boolean[] connectFloorLeft = new boolean[1];
  boolean[] connectFloorRight = new boolean[1];

  boolean[] limitFloorAngleAfterConnect = new boolean[1];
  float[] floorConnectAngleStart = new float[1];
  float[] floorConnectAngleEnd = new float[1];

  float[] chancesForDLinesToConnect = new float[1];
  float[] chancesForNonDLinesToConnect = new float[1];
  float[] minDistanceBtwNonDLinesAndDLines = new float[1];

  float[] chancesForDLinesToConnectAtCorner = new float[1];
  float[] chancesForNonDLinesToConnectAtCorner = new float[1];
  float[] chancesForDLinesAndFloorsToConnectAtCorner = new float[1];
  float[] chancesForNonDLinesAndFloorsToConnectAtCorner = new float[1];
  float[] chancesForDLinesAndNonDLinesToConnectAtCorner = new float[1];
  float[] chancesForFloorsToConnectAtCorner = new float[1];

  boolean[] canLinesOverlap = new boolean[1]; // for all lines and floors
  boolean[] areFramesDeath = new boolean[1];
  boolean[] areFramesBouncy = new boolean[1];

  float[] chancesForDLinesToConnectWithFrames = new float[1];
  float[] chancesForNonDLinesToConnectWithFrames = new float[1];

  float[] minDistanceBtwDLinesAndFrames = new float[1];
  float[] minDistanceBtwFloorsAndFrames = new float[1];

  float[] lineToMoveConnectPointStart = new float[1];
  float[] lineToMoveConnectPointEnd = new float[1];

  float[] mapSize = new float[1];

  float[] pathTightness = new float[1];

  // The following aren't preset properties:
  JSONObject presetExportData;
  List<Object> settingsElements;

  Settings() {
    applyDefaultPreset();

    settingsElements = getAllFields();
  }

  void exportPreset(String presetName) {
    // Create a new JSON object
    savePresetsToJSON();
    saveJSONAtFilePath(presetName);
    //println("settings length after saving: " + settingsElements.size());
  }

  void savePresetsToJSON() {
    presetExportData = new JSONObject();
    settingsElements = getAllFields(); // Now excludes internal fields
    Field[] fields = this.getClass().getDeclaredFields();

    int settingsIndex = 0; // Separate index for settingsElements
    for (Field field : fields) {
      String fieldName = field.getName();
      // Skip internal fields
      if (fieldName.equals("settingsElements") || fieldName.equals("presetExportData")) {
        continue;
      }
      // Ensure settingsIndex does not exceed settingsElements size
      if (settingsIndex < settingsElements.size()) {
        Object array = settingsElements.get(settingsIndex++);
        addArrayToPresetData(fieldName, array);
      }
    }
  }


  void saveJSONAtFilePath(String presetName) {

    File folder = new File(sketchPath(savedPresetsFolder));
    if (!folder.exists()) {
      folder.mkdirs(); // Create the folder if it does not exist
    }
    String filePath = sketchPath(savedPresetsFolder + File.separator + presetName + ".json");
    // Save JSON to file
    saveJSONObject(presetExportData, filePath);
    println("Preset exported successfully.");
  }

  void addArrayToPresetData(String key, Object array) {
    JSONArray jsonArray = new JSONArray();
    // Handle different array types
    if (array instanceof float[]) {

      for (float value : (float[]) array) {
        jsonArray.append(value);
      }
    } else if (array instanceof boolean[]) {

      for (boolean value : (boolean[]) array) {
        jsonArray.append(value);
      }
    } else if (array instanceof ArrayList) {
      for (Object value : (ArrayList<?>) array) {
        if (value instanceof Float) {
          jsonArray.append((Float) value);
        }
      }
    }
    presetExportData.setJSONArray(key, jsonArray);
  }

  List<Object> getAllFields() {
    List<Object> fieldValues = new ArrayList<>();
    Field[] fields = this.getClass().getDeclaredFields();
    for (Field field : fields) {
      // Exclude internal fields
      if (field.getName().equals("settingsElements") || field.getName().equals("presetExportData")) {
        continue;
      }
      field.setAccessible(true);
      try {
        fieldValues.add(field.get(this));
      }
      catch (IllegalAccessException e) {
        e.printStackTrace();
      }
    }
    return fieldValues;
  }
  void importPreset(String presetName, boolean importDefaultPreset) {
    String folderName;
    if (importDefaultPreset) folderName = "default-presets";
    else folderName = savedPresetsFolder;
    String filePath = folderName + File.separator + presetName + ".json";
    JSONObject presetImportData;

    try {
      presetImportData = loadJSONObject(filePath);
    }
    catch (Exception e) {
      println("Error loading JSON file: " + e.getMessage());
      return;
    }

    if (presetImportData == null || presetImportData.size() == 0) {
      println("Error: JSON file is empty or malformed.");
      return;
    }

    for (Object keyObj : presetImportData.keys()) {
      String key = (String) keyObj;
      Object jsonValue = presetImportData.get(key);

      try {
        Field field = this.getClass().getDeclaredField(key);
        field.setAccessible(true);

        if (jsonValue instanceof JSONArray) {
          JSONArray jsonArray = (JSONArray) jsonValue;

          // Handle float arrays
          if (field.getType() == float[].class) {
            float[] floatArray = new float[jsonArray.size()];
            for (int i = 0; i < jsonArray.size(); i++) {
              floatArray[i] = jsonArray.getFloat(i);
            }
            field.set(this, floatArray);

            // Handle boolean arrays
          } else if (field.getType() == boolean[].class) {
            boolean[] boolArray = new boolean[jsonArray.size()];
            for (int i = 0; i < jsonArray.size(); i++) {
              boolArray[i] = jsonArray.getBoolean(i);
            }
            field.set(this, boolArray);

            // Handle ArrayList<Float>
          } else if (field.getType() == ArrayList.class) {
            ArrayList<Float> floatList = new ArrayList<>();
            for (int i = 0; i < jsonArray.size(); i++) {
              floatList.add(jsonArray.getFloat(i));
            }
            field.set(this, floatList);
          }
        }

        // Handle single float and boolean values directly
        else if (jsonValue instanceof Float && field.getType() == float.class) {
          field.setFloat(this, (Float) jsonValue);
        } else if (jsonValue instanceof Boolean && field.getType() == boolean.class) {
          field.setBoolean(this, (Boolean) jsonValue);
        }

        println("Updated " + key + " to " + jsonValue);
      }
      catch (NoSuchFieldException e) {
        println("Field " + key + " not found, skipping.");
      }
      catch (Exception e) {
        println("Error setting field " + key + ": " + e.getMessage());
      }
    }
  }




  void setFieldFromJSON(Field field, String fieldName, Object fieldValue, JSONObject presetExportData) {
    try {
      JSONArray jsonArray = presetExportData.getJSONArray(fieldName); // Get the JSON array using the field name

      if (fieldValue instanceof float[]) {
        float[] floatArray = new float[jsonArray.size()];
        for (int i = 0; i < jsonArray.size(); i++) {
          floatArray[i] = jsonArray.getFloat(i);
        }
        field.set(this, floatArray); // Set the field with the imported float array
      } else if (fieldValue instanceof boolean[]) {
        boolean[] booleanArray = new boolean[jsonArray.size()];
        for (int i = 0; i < jsonArray.size(); i++) {
          booleanArray[i] = jsonArray.getBoolean(i);
        }
        field.set(this, booleanArray); // Set the field with the imported boolean array
      } else if (fieldValue instanceof ArrayList) {
        ArrayList<Float> floatList = new ArrayList<>();
        for (int i = 0; i < jsonArray.size(); i++) {
          floatList.add(jsonArray.getFloat(i));
        }
        field.set(this, floatList); // Set the field with the imported ArrayList<Float>
      }
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  String[] getPresetsForImport() {
    String directoryPath = sketchPath(savedPresetsFolder);
    File dir = new File(directoryPath);

    // Filter to only list .json files
    FilenameFilter jsonFilter = new FilenameFilter() {
      public boolean accept(File dir, String name) {
        return name.endsWith(".json");
      }
    };

    // List all .json files in the directory
    String[] jsonFiles = dir.list(jsonFilter);

    // Print out file names
    if (jsonFiles != null && jsonFiles.length != 0) {

      for (int i = 0; i < jsonFiles.length; i++) {
        //println("i " +jsonFiles[i]);
        jsonFiles[i] = jsonFiles[i].replace(".json", "");
      }
      return jsonFiles;
    } else {
      println("No .json files found.");
    }

    return null;
  }

  void applyDefaultPreset() {

    heightOfLine = new ArrayList<Float>(Arrays.asList(5f));
    sameHeightForAllLines[0] = true;
    minLineHeight[0] = 20; // If sameHeightForAllLines[0] == false, then a random value btw min and max is chosen,
    maxLineHeight[0] = 100; // which is different for each line.

    widthOfLine = new ArrayList<Float>(Arrays.asList(100f));
    sameWidthForAllLines[0] = false;
    minLineWidth[0] = 10;
    maxLineWidth[0] = 300;

    chancesOfDeath[0] = 0.5;
    chancesOfBounciness[0] = 0.5;
    globalBounciness = null;
    chancesOfGrapple[0] = 0;
    chancesOfNoJump[0] = 0;

    setSpecificLineAngles[0] = false;
    nonDLineAngle = new ArrayList<Float>(Arrays.asList(0f));
    dLineAngle = new ArrayList<Float>(Arrays.asList(0f));
    lineAngleStart[0] = 0;
    lineAngleEnd[0] = 360;
    limitLineAngleAfterConnectingItsCorner[0] = true;
    lineConnectAngleStart[0] = 90;
    lineConnectAngleEnd[0] = 90;

    chancesForDLinesAndNonDLinesToConnect[0] = 0.1;
    chancesForNonDLinesToConnect[0] = 0;
    chancesForDLinesToConnect[0] = 0;
    chancesForFloorsAndFloorsToConnect[0] = 0.9;
    chancesForNonDLinesToConnectWithFloors[0] = 0.1;
    chancesForDLinesToConnectWithFloors[0] = 0.1;
    chancesForFloorsToConnectWithFrames[0] = 0.9;

    chancesForDLinesToConnectAtCorner[0] = 0;
    chancesForNonDLinesToConnectAtCorner[0] = 0;
    chancesForDLinesAndFloorsToConnectAtCorner[0] = 0;
    chancesForNonDLinesAndFloorsToConnectAtCorner[0] = 0;
    chancesForDLinesAndNonDLinesToConnectAtCorner[0] = 0;
    chancesForFloorsToConnectAtCorner[0] = 0;

    sameColorForAllNonDLines[0] = true;
    sameColorForAllDLines[0] = true;
    sameColorForAllBLines[0] = true;
    sameColorForAllGLines[0] = true;
    areDLinesAtBack[0] = true;
    areBLinesAtBack[0] = true;
    addNoPhysicsLineDuplicates[0] = false;
    addBackground[0] = true;

    minDistanceBtwNonDLinesAndDLines[0] = 19;
    minDistanceBtwNonDLines[0] = 19;
    minDistanceBtwDLines[0] = 19;
    minDistanceBtwFloors[0] = 30;
    minDistanceBtwNonDLinesAndFloors[0] = 19;
    minDistanceBtwDLinesAndFloors[0] = 19;
    minDistanceBtwNonDLinesAndFrames[0] = 10;
    minDistanceBtwDLinesAndFrames[0] = 10;
    minDistanceBtwFloorsAndFrames[0] = 30;
    canLinesOverlap[0] = false;

    /* Randomly chooses one color scheme from the list of schemes in the array.
     Leave empty for randomly choosing a scheme from all avalable schemes.*/
    rndlyChooseOneSchemeForBg = new boolean[]{true};

    addFrames[0] = true;
    frameWidth[0] = 10;
    areFramesDeath[0] = false;
    areFramesBouncy[0] = false;
    frameAngleStart[0] = 0;
    frameAngleEnd[0] = 0;

    addFloors[0] = true;
    numOfFloors[0] = 12;
    minFloorWidth[0] = 100;
    maxFloorWidth[0] = 700;
    floorHeight[0] = 10;
    areFloorsBouncy[0] = false;

    setSpecificFloorAngles[0] = false;
    floorAngle = new ArrayList<Float>(Arrays.asList(0f));
    floorAngleStart[0] = 0;
    floorAngleEnd[0] = 360;
    limitFloorAngleAfterConnect[0] = true;
    floorConnectAngleStart[0] = 45;
    floorConnectAngleEnd[0] = 135;

    connectFloorUp[0] = false;
    connectFloorDown[0] = true;
    connectFloorLeft[0] = true;
    connectFloorRight[0] = true;

    lineToMoveConnectPointStart[0] = 1;
    lineToMoveConnectPointEnd[0] = 1;

    mapSize[0] = 9;
    pathTightness[0] = 20;
  }
}
