//import com.google.gson.Gson; // Make sure to import Gson library

void saveLineAttributes() {

  float spawnX;
  float spawnY;

  if  (circlePosition != null) {
    float halfMapWidth = (endOfWidth - startOfWidth) / 2;
    float halfMapHeight = (endOfHeight - startOfHeight) / 2;
    float convertedXPos = circlePosition.x - startOfWidth - halfMapWidth;
    float convertedYPos = circlePosition.y - startOfHeight - halfMapHeight;
    spawnX = convertedXPos;
    spawnY = convertedYPos;
  } else {
    spawnX = 99999;
    spawnY = 99999;
  }

  int mapSize = getMapSize();

  // Create a JSON structure
  StringBuilder jsonBuilder = new StringBuilder();
  jsonBuilder.append("{\n");
  jsonBuilder.append("  \"spawn\": {\n");
  jsonBuilder.append("    \"spawnX\": ").append(spawnX).append(",\n");
  jsonBuilder.append("    \"spawnY\": ").append(spawnY).append("\n");
  jsonBuilder.append("  },\n");
  jsonBuilder.append("  \"mapSize\": ").append(mapSize).append(",\n"); // Added mapSize variable
  jsonBuilder.append("  \"lines\": [\n");

  int id = 0;

  for (Line line : lines) {
    if (line.isOnlyForProgram) continue;

    int colorString = rgbToDecimal(line.lineColor);
    boolean isDeath = line.isDeath;
    boolean noGrapple = !line.hasGrapple; // Inverted logic
    boolean noPhysics = line.noPhysics;

    // Append line data to JSON string
    jsonBuilder.append("    {\n");
    jsonBuilder.append("      \"id\": ").append(id).append(",\n");
    jsonBuilder.append("      \"x\": ").append(line.centerX).append(",\n");
    jsonBuilder.append("      \"y\": ").append(line.centerY).append(",\n");
    jsonBuilder.append("      \"width\": ").append(line.width).append(",\n");
    jsonBuilder.append("      \"height\": ").append(line.height).append(",\n");
    jsonBuilder.append("      \"angle\": ").append(line.angle).append(",\n");
    jsonBuilder.append("      \"isDeath\": ").append(isDeath).append(",\n");
    jsonBuilder.append("      \"color\": ").append(colorString).append(",\n");
    jsonBuilder.append("      \"noPhysics\": ").append(noPhysics).append(",\n");
    jsonBuilder.append("      \"noGrapple\": ").append(noGrapple).append(",\n");
    jsonBuilder.append("      \"isCapzone\": ").append(line.isCapzone).append(",\n");
    jsonBuilder.append("      \"isNoJump\": ").append(line.isNoJump).append(",\n");
    jsonBuilder.append("      \"bounciness\": ").append(line.bounciness).append(",\n");
    jsonBuilder.append("      \"friction\": ").append(line.friction).append("\n");
    jsonBuilder.append("    },\n");

    id++;
  }

  // Remove the last comma for the last line object
  if (lines.size() > 0) {
    jsonBuilder.setLength(jsonBuilder.length() - 2); // Remove last comma and newline
  }

  jsonBuilder.append("  ]\n");
  jsonBuilder.append("}");

  // Convert to JSON string
  String jsonOutput = jsonBuilder.toString();
  //System.out.println(jsonOutput); // or save it to a file as needed
  copyToClipboard(jsonOutput);
  cp5.getController("lineDataCopiedLabel").show();
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
