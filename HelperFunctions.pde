color adjustBrightness(color original, float adjustment) {

  float r = red(original) + adjustment;
  float g = green(original) + adjustment;
  float b = blue(original) + adjustment;

  // Ensure RGB values are within the valid range [0, 255]
  r = constrain(r, 0, 255);
  g = constrain(g, 0, 255);
  b = constrain(b, 0, 255);

  return color(r, g, b);
}

color getRandomColor(int scheme) {
  color lineColor;

  switch (scheme) {
  case 0:
    lineColor = color(random(0, 50), random(50, 150), random(100, 200)); // Dark greens and blues
    break;
  case 1:
    lineColor = color(random(50, 150), random(0, 50), random(100, 200)); // Dark purples and magentas
    break;
  case 2:
    lineColor = color(random(0, 100), random(100, 255), random(100, 255)); // Cool tones
    break;
  case 3:
    lineColor = color(random(100, 180), random(20, 80), random(20, 60)); // Dark reds and browns
    break;
  case 4:
    lineColor = color(random(0, 60), random(100, 200), random(100, 255)); // Deep teal and aqua
    break;
  case 5:
    lineColor = color(random(0, 50), random(50, 100), random(150, 255)); // Midnight blues
    break;
  case 6:
    lineColor = color(random(0, 30), random(30, 100), random(50, 150)); // Charcoal tones
    break;
  case 7:
    lineColor = color(random(50, 100), random(20, 60), random(20, 60)); // Muted olive greens
    break;
  case 8:
    lineColor = color(random(30, 80), random(20, 50), random(70, 150)); // Dusky purples
    break;
  case 9:
    lineColor = color(random(10, 50), random(40, 100), random(70, 120)); // Cool gray-blues
    break;
  case 10:
    lineColor = color(random(0, 50), random(50, 100), random(100, 150)); // Steel blues
    break;
  case 11:
    lineColor = color(random(20, 60), random(0, 40), random(60, 120)); // Slate
    break;
  case 12:
    lineColor = color(random(40, 100), random(60, 120), random(100, 180)); // Forest green
    break;
  case 13:
    lineColor = color(random(10, 60), random(60, 140), random(90, 160)); // Mossy greens
    break;
  case 14:
    lineColor = color(random(30, 80), random(70, 130), random(130, 200)); // Ocean blues
    break;
  case 15:
    lineColor = color(0, random(100, 180), 0); // Fallback dark green
    break;
  case 16:
    lineColor = color(random(150, 255), random(50, 150), random(0, 50)); // Bright reds and oranges
    break;
  case 17:
    lineColor = color(random(200, 255), random(150, 200), random(0, 50)); // Vibrant yellows and golds
    break;
  case 18:
    lineColor = color(random(150, 200), random(100, 150), random(50, 100)); // Warm earth tones
    break;
  case 19:
    lineColor = color(random(200, 255), random(0, 100), random(150, 255)); // Pink to purple
    break;
  case 20:
    lineColor = color(random(150, 255), random(150, 255), random(150, 255)); // Soft pastel colors
    break;
  case 21:
    float gray = random(100, 200);
    lineColor = color(gray, gray, gray); // Grayscale
    break;
  case 22:
    lineColor = color(random(50, 100), random(150, 255), random(150, 255)); // Mint greens and blues
    break;
  case 23:
    lineColor = color(random(200, 255), random(100, 150), random(50, 100)); // Coral and peach tones
    break;
  case 24:
    lineColor = color(random(150, 255), random(50, 100), random(100, 200)); // Sunset colors
    break;
  case 25:
    lineColor = color(random(100, 200), random(150, 255), random(0, 100)); // Bright lime and neon
    break;
  case 26:
    lineColor = color(random(200, 255), random(100, 200), random(150, 255)); // Bright lavender
    break;
  case 27:
    lineColor = color(random(150, 255), random(50, 150), random(50, 100)); // Tangerine and soft orange
    break;
  case 28:
    lineColor = color(random(150, 255), random(150, 200), random(50, 150)); // Lemon and lime
    break;
  case 29:
    lineColor = color(random(50, 100), random(200, 255), random(200, 255)); // Aqua and cyan
    break;
  case 30:
    lineColor = color(random(200, 255), random(150, 255), random(0, 50)); // Goldenrod
    break;
  case 31:
    lineColor = color(random(150, 255), random(50, 150), random(100, 200)); // Berry colors
    break;
  case 32:
    lineColor = color(random(50, 150), random(100, 200), random(150, 255)); // Cool blues
    break;
  case 33:
    lineColor = color(random(200, 255), random(100, 150), random(50, 100)); // Warm oranges
    break;
  case 34:
    lineColor = color(random(150, 255), random(50, 150), random(50, 150)); // Soft pinks
    break;
  case 35:
    lineColor = color(random(50, 100), random(100, 150), random(200, 255)); // Bright blues
    break;
  case 36:
    lineColor = color(random(200, 255), random(200, 255), random(150, 200)); // Pastel yellows
    break;
  case 37:
    lineColor = color(random(100, 200), random(200, 255), random(50, 150)); // Spring greens
    break;
  case 38:
    lineColor = color(random(150, 255), random(100, 200), random(50, 100)); // Coral tones
    break;
  case 39:
    lineColor = color(random(50, 150), random(50, 150), random(200, 255)); // Deep purples
    break;
  case 40:
    lineColor = color(random(100, 150), random(200, 255), random(200, 255)); // Soft aquas
    break;
  case 41:
    lineColor = color(random(200, 255), random(150, 255), random(50, 150)); // Peachy tones
    break;
  case 42:
    lineColor = color(random(150, 255), random(100, 200), random(100, 200)); // Lavender tones
    break;
  case 43:
    lineColor = color(random(100, 150), random(150, 255), random(100, 200)); // Mint greens
    break;
  case 44:
    lineColor = color(random(50, 100), random(200, 255), random(150, 255)); // Bright teals
    break;
  case 45:
    lineColor = color(random(150, 200), random(100, 150), random(200, 255)); // Cool grays
    break;
  case 46:
    lineColor = color(random(200, 255), random(200, 255), random(50, 100)); // Soft creams
    break;
  case 47:
    lineColor = color(random(50, 100), random(150, 200), random(100, 150)); // Muted olives
    break;
  case 49:
    lineColor = color(random(100, 150), random(50, 100), random(150, 200)); // Dusty roses
    break;
  case 50:
    lineColor = color(random(200, 255), random(50, 100), random(100, 200)); // Vibrant reds
    break;
  case 51:
    lineColor = color(random(150, 255), random(150, 200), random(100, 150)); // Light mauves
    break;
  case 52:
    lineColor = color(random(50, 150), random(100, 200), random(50, 150)); // Forest greens
    break;
  case 53:
    lineColor = color(random(100));
    break;
  case 54:
    lineColor = color(random(10, 30), random(10, 30), random(10, 30)); // Very dark gray
    break;
  case 55:
    lineColor = color(random(0, 20), random(0, 20), random(50, 70)); // Dark blue
    break;
  case 56:
    lineColor = color(random(20, 40), random(0, 10), random(0, 10)); // Dark red
    break;
  case 57:
    lineColor = color(random(0, 10), random(20, 40), random(0, 10)); // Dark green
    break;
  case 58:
    lineColor = color(random(20, 40), random(20, 40), random(0, 10)); // Dark yellow-brown
    break;
  case 59:
    lineColor = color(random(10, 30), random(10, 30), random(50, 70)); // Dark cyan
    break;
  case 60:
    lineColor = color(random(0, 20), random(20, 40), random(50, 70)); // Dark teal
    break;
  case 61:
    lineColor = color(random(40, 60), random(10, 30), random(10, 30)); // Dark burgundy
    break;
  case 62:
    lineColor = color(random(0, 20), random(0, 20), random(20, 40)); // Dark purple
    break;
  case 63:
    lineColor = color(random(10, 30), random(10, 30), random(0, 10)); // Dark olive
    break;
  default:
    lineColor = color(random(255), random(255), random(255));
  }

  return lineColor;
}

// Helper function to convert float array to String array
String[] floatArrayToStringArray(float[] array) {
  String[] strArray = new String[array.length];
  for (int i = 0; i < array.length; i++) {
    strArray[i] = str(array[i]);
  }
  return strArray;
}

String[] floatListToStringArray(ArrayList<Float> list) {
  String[] strArray = new String[list.size()];
  for (int i = 0; i < list.size(); i++) {
    strArray[i] = Float.toString(list.get(i));
  }
  return strArray;
}

float[] parseInputToFloatArray(String input) {
  String[] values = input.split(", ");
  float[] result = new float[values.length];

  for (int i = 0; i < values.length; i++) {
    try {
      result[i] = Float.parseFloat(values[i].trim());
    }
    catch (NumberFormatException e) {
      result[i] = 0; // You can handle the error as needed
    }
  }
  return result;
}

ArrayList<Float> parseInputToFloatList(String input) {
  String[] values = input.split("\\s*,\\s*");
  ArrayList<Float> result = new ArrayList<Float>();

  for (String value : values) {
    try {
      result.add(Float.parseFloat(value.trim()));
    }
    catch (NumberFormatException e) {
      result.add(0.0f); // You can handle the error as needed
    }
  }
  return result;
}

int getPhysicsShapesSize(CopyOnWriteArrayList<Line> lines) {

  int size = 0;
  for (Line line : lines) {
    if (!line.noPhysics)
      size++;
  }
  return size;
}



String getGroupLabel(String input) {
  // Remove the substring "group" from the input string
  String result = input.replace("Group", "");

  // Insert spaces after each capital letter (assuming words are separated by capital letters)
  StringBuilder spacedResult = new StringBuilder();
  for (int i = 0; i < result.length(); i++) {
    char currentChar = result.charAt(i);
    // Check if the current character is an uppercase letter and not the first character
    if (Character.isUpperCase(currentChar) && i != 0) {
      spacedResult.append(' '); // Add a space before the uppercase letter
    }
    spacedResult.append(currentChar);
  }

  return spacedResult.toString();
}

void drawColorIndicator() {

  // Find the color of the indicators
  color deathColorIndicator = -1;
  if (settings.sameColorForAllDLines[0]) {
    for (Line l : lines) {
      if (l.isDeath && !l.noPhysics && !l.hasGrapple) {
        deathColorIndicator = l.lineColor;
        break;
      }
    }
  }

  color grappleColorIndicator = -1;
  if (settings.sameColorForAllGLines[0]) {
    for (Line l : lines) {
      if (l.hasGrapple && !l.noPhysics) {
        grappleColorIndicator = l.lineColor;
        break;
      }
    }
  }

  color bounceColorIndicator = -1;
  if (settings.sameColorForAllBLines[0]) {

    for (Line l : lines) {
      if (l.isBouncy && !l.noPhysics && !l.hasGrapple) {
        bounceColorIndicator = l.lineColor;
        break;
      }
    }
  }

  color nonDeathColorIndicator = -1;
  if (settings.sameColorForAllNonDLines[0]) {

    for (Line l : lines) {
      if (!l.isDeath && !l.noPhysics && !l.isBouncy && !l.hasGrapple) {
        nonDeathColorIndicator = l.lineColor;
        break;
      }
    }
  }

  // Collect all colors and labels to draw
  color[] colors = {deathColorIndicator, nonDeathColorIndicator, bounceColorIndicator, grappleColorIndicator};
  String[] labels = {"Death", "Not bouncy", "Bouncy", "Grapplable"};
  //println("death: " + colors[0]);
  //println("not bouncy: " + colors[1]);
  //println("bouncy: " + colors[2]);
  //println("grapplable: " + colors[3]);
  // Count the number of valid colors
  int count = 0;
  for (color c : colors) {
    if (c != -1) {
      count++;
    }
  }

  if (count == 0) return;

  float distanceBtwSquare = 100; // Adjust as needed
  float xPos = (startOfWidth + endOfWidth) / 2;
  float yPos = startOfHeight - 50;
  float size = 20; // Size of the squares
  float labelOffset = 15; // Distance between square and label

  // Calculate the positions dynamically
  float[] xPositions = new float[count];
  if (count == 1) {
    xPositions[0] = xPos;
  } else if (count == 2) {
    xPositions[0] = xPos - distanceBtwSquare / 2;
    xPositions[1] = xPos + distanceBtwSquare / 2;
  } else if (count == 3) {
    xPositions[0] = xPos;
    xPositions[1] = xPos - distanceBtwSquare;
    xPositions[2] = xPos + distanceBtwSquare;
  } else {
    // More than 3 squares
    xPositions[0] = xPos - distanceBtwSquare * 1.5;
    xPositions[1] = xPos - distanceBtwSquare / 2;
    xPositions[2] = xPos + distanceBtwSquare / 2;
    xPositions[3] = xPos + distanceBtwSquare * 1.5;
  }

  // Draw the squares and labels
  int index = 0;
  for (int i = 0; i < 4; i++) {
    if (colors[i] != -1) {
      float currentX = xPositions[index];
      color c = colors[i];

      fill(c);
      noStroke();
      rect(currentX - size / 2, yPos - size / 2, size, size); // Draw the square
      fill(255);
      textAlign(CENTER, CENTER);
      text(labels[i], currentX - 8, yPos + labelOffset); // Draw the label

      index++;
    }
  }
}

void setLockAndColor(String controllerName, boolean lockState) {
  Controller ctrl = cp5.getController(controllerName);

  int bgColor = !lockState ? INACTIVE_COLOR : GREYED_OUT_COLOR;
  ctrl.setLock(lockState);
  ctrl.setColorBackground(bgColor);
}

float getSpawnSize() {
  float size = 0;
  int mapSize = (int) Math.floor(settings.mapSize[0]);

  if (mapSize == 13) size = 5;
  else if (mapSize == 12) size = 6;
  else if (mapSize == 11) size = 7;
  else if (mapSize == 10) size = 8;
  else if (mapSize == 9) size = 9;
  else if (mapSize == 8) size = 10;
  else if (mapSize == 7) size = 12;
  else if (mapSize == 6) size = 13;
  else if (mapSize == 5) size = 15;
  else if (mapSize == 4) size = 17;
  else if (mapSize == 3) size = 20;
  else if (mapSize == 2) size = 24;
  else if (mapSize == 1) size = 30;

  return size;
}
