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
  case 0:  // Deep Blues and Greens
    lineColor = color(random(0, 50), random(50, 150), random(100, 200));
    break;
  case 1:  // Rich Purples and Magentas
    lineColor = color(random(80, 160), random(0, 80), random(100, 200));
    break;
  case 2:  // Cool Aqua & Teals
    lineColor = color(random(0, 100), random(150, 255), random(150, 255));
    break;
  case 3:  // Earthy Reds and Browns
    lineColor = color(random(100, 180), random(40, 100), random(20, 80));
    break;
  case 4:  // Vivid Yellows and Golds
    lineColor = color(random(200, 255), random(150, 220), random(0, 60));
    break;
  case 5:  // Fiery Reds and Oranges
    lineColor = color(random(200, 255), random(50, 150), random(0, 50));
    break;
  case 6:  // Neon Greens
    lineColor = color(random(150, 255), random(200, 255), random(0, 100));
    break;
  case 7:  // Soft Pastels
    lineColor = color(random(150, 255), random(150, 255), random(150, 255));
    break;
  case 8:  // Muted Earth Tones
    lineColor = color(random(100, 180), random(80, 140), random(60, 120));
    break;
  case 9:  // Bright Cyan & Sky Blue
    lineColor = color(random(50, 150), random(200, 255), random(200, 255));
    break;
  case 10: // Deep Midnight Blues
    lineColor = color(random(0, 50), random(50, 100), random(150, 255));
    break;
  case 11: // Dark Purples & Plums
    lineColor = color(random(50, 120), random(0, 50), random(80, 150));
    break;
  case 12: // Pale Ice Blues
    lineColor = color(random(150, 220), random(200, 255), random(220, 255));
    break;
  case 13: // Dark & Dusty Greens
    lineColor = color(random(20, 100), random(50, 120), random(20, 80));
    break;
  case 14: // Warm Golden Browns
    lineColor = color(random(150, 220), random(100, 180), random(50, 100));
    break;
  case 15: // Dark Grayscale
    float gray = random(10, 80);
    lineColor = color(gray, gray, gray);
    break;
  case 16: // Light Grayscale
    float lightGray = random(170, 240);
    lineColor = color(lightGray, lightGray, lightGray);
    break;
  case 17: // Vibrant Pinks & Magentas
    lineColor = color(random(200, 255), random(50, 150), random(150, 255));
    break;
  case 18: // Warm Peach & Coral
    lineColor = color(random(255), random(100, 180), random(80, 140));
    break;
  case 19: // Forest Green & Moss
    lineColor = color(random(30, 80), random(90, 160), random(50, 120));
    break;
  case 20: // Sunset Colors
    lineColor = color(random(150, 255), random(50, 120), random(100, 200));
    break;
  case 21: // Very Dark Gray & Black Tones
    lineColor = color(random(0, 40), random(0, 40), random(0, 40));
    break;
  case 22: // Electric Blue & Vivid Cyan
    lineColor = color(random(50, 150), random(100, 255), random(200, 255));
    break;
  case 23: // Royal Blue & Deep Indigo
    lineColor = color(random(0, 80), random(50, 120), random(150, 255));
    break;
  case 24: // Soft Cream & Off-Whites
    lineColor = color(random(220, 255), random(200, 255), random(180, 230));
    break;
  case 25: // Burnt Orange & Copper
    lineColor = color(random(180, 240), random(90, 150), random(40, 100));
    break;
  case 26: // Bright Lime & Yellow Greens
    lineColor = color(random(150, 255), random(200, 255), random(50, 150));
    break;
  case 27: // Dark Burgundy & Plum
    lineColor = color(random(80, 150), random(0, 50), random(50, 100));
    break;
  case 28: // Deep Turquoise & Teal
    lineColor = color(random(0, 80), random(100, 180), random(120, 255));
    break;
  case 29: // Candy Pink & Bubblegum
    lineColor = color(random(230, 255), random(120, 200), random(150, 255));
    break;
  case 30: // Fiery Scarlet & Deep Red
    lineColor = color(random(180, 255), random(0, 80), random(0, 60));
    break;
  case 31: // Mixed Fluorescent Colors
    lineColor = color(random(180, 255), random(180, 255), random(50, 150));
    break;
  case 32: // Metallic Silver & Chrome
    float silver = random(180, 255);
    lineColor = color(silver, silver, silver);
    break;
  case 33: // Jet Black
    lineColor = color(0, 0, 0);
    break;
  case 34: // Ultra White
    lineColor = color(255, 255, 255);
    break;
  case 35: // Arctic Ice Blue
    lineColor = color(random(200, 255), random(230, 255), random(250, 255));
    break;
  case 36: // Toxic Slime Green
    lineColor = color(random(50, 150), random(230, 255), random(50, 100));
    break;
  case 37: // Radioactive Yellow-Green
    lineColor = color(random(200, 255), random(255), random(0, 80));
    break;
  case 38: // Velvet Crimson
    lineColor = color(random(160, 220), random(0, 50), random(50, 100));
    break;
  case 39: // Cosmic Purple
    lineColor = color(random(120, 180), random(20, 80), random(160, 255));
    break;
  case 40: // Ocean Depths Blue-Green
    lineColor = color(random(0, 50), random(100, 180), random(150, 255));
    break;
  case 41: // Steampunk Brass
    lineColor = color(random(180, 220), random(120, 180), random(60, 100));
    break;
  case 42: // Glowing Ember Orange
    lineColor = color(random(200, 255), random(80, 150), random(0, 50));
    break;
  case 43: // Shadowy Amethyst
    lineColor = color(random(80, 150), random(50, 100), random(120, 200));
    break;
  case 44: // Midnight Green
    lineColor = color(random(0, 60), random(70, 120), random(50, 100));
    break;
  case 45: // Alien Plasma
    lineColor = color(random(100, 180), random(200, 255), random(50, 150));
    break;
  case 46: // Antique Rose
    lineColor = color(random(180, 220), random(100, 160), random(120, 180));
    break;
  case 47: // Holographic Blue-Violet
    lineColor = color(random(100, 160), random(120, 200), random(200, 255));
    break;
  case 48: // Desert Sand
    lineColor = color(random(230, 255), random(180, 220), random(150, 200));
    break;
  case 49: // Aurora Borealis Green
    lineColor = color(random(50, 150), random(200, 255), random(100, 200));
    break;
  case 50: // Deep Space Nebula Purple
    lineColor = color(random(40, 100), random(20, 60), random(100, 255));
    break;
  case 51: // Stormy Sky Gray-Blue
    lineColor = color(random(100, 160), random(100, 160), random(140, 200));
    break;
  case 52: // Molten Lava Red
    lineColor = color(random(180, 255), random(30, 80), random(0, 50));
    break;
  case 53: // Bioluminescent Glow Cyan
    lineColor = color(random(0, 100), random(200, 255), random(220, 255));
    break;
  case 54: // Rusted Copper
    lineColor = color(random(120, 180), random(80, 140), random(50, 100));
    break;
  case 55: // Soft Orchid Pink
    lineColor = color(random(200, 255), random(120, 180), random(150, 220));
    break;
  case 56: // Cyberpunk Neon Magenta
    lineColor = color(random(200, 255), random(20, 100), random(180, 255));
    break;
  case 57: // Glistening Pearl White
    lineColor = color(random(230, 255), random(230, 255), random(230, 255));
    break;
  case 58: // Dragonfruit Fuchsia
    lineColor = color(random(200, 255), random(30, 100), random(120, 200));
    break;
  case 59: // Distant Galaxy Blue
    lineColor = color(random(0, 80), random(50, 120), random(200, 255));
    break;
  case 60: // Arctic Blizzard White-Blue
    lineColor = color(random(200, 255), random(220, 255), random(240, 255));
    break;
  case 61: // Radioactive Cyan
    lineColor = color(random(0, 100), random(250, 255), random(200, 255));
    break;
  case 62: // Pumpkin Spice
    lineColor = color(random(200, 255), random(100, 150), random(50, 100));
    break;
  case 63: // Electric Grape Purple
    lineColor = color(random(150, 200), random(50, 100), random(200, 255));
    break;
  case 64: // Glacial Teal
    lineColor = color(random(50, 150), random(200, 255), random(180, 255));
    break;
  case 65: // Starry Night Dark Blue
    lineColor = color(random(0, 40), random(0, 40), random(150, 255));
    break;
  case 66: // Deep Cherry Red
    lineColor = color(random(150, 220), random(0, 50), random(50, 100));
    break;
  case 67: // Sapphire Ice
    lineColor = color(random(0, 50), random(100, 200), random(200, 255));
    break;
  case 68: // Sunset Mauve
    lineColor = color(random(180, 240), random(100, 160), random(150, 210));
    break;
  case 69: // Aged Parchment
    lineColor = color(random(200, 255), random(180, 230), random(150, 200));
    break;
  case 70: // Lava Lamp Pink-Orange
    lineColor = color(random(200, 255), random(50, 150), random(80, 180));
    break;
  case 71: // Twilight Lavender
    lineColor = color(random(140, 200), random(80, 140), random(160, 220));
    break;
  case 72: // Shimmering Gold
    lineColor = color(random(220, 255), random(180, 220), random(50, 100));
    break;
  case 73: // Solar Eclipse Black
    lineColor = color(random(10, 30), random(10, 30), random(10, 30));
    break;
  case 74: // Jellyfish Glow Blue
    lineColor = color(random(50, 150), random(180, 255), random(200, 255));
    break;
  case 75: // Martian Dust Orange
    lineColor = color(random(180, 255), random(80, 140), random(60, 100));
    break;
  case 76: // Deep Indigo Night
    lineColor = color(random(40, 80), random(0, 50), random(100, 200));
    break;
  case 77: // Frosted Mint
    lineColor = color(random(180, 220), random(240, 255), random(200, 255));
    break;

  default: // Random Full-Spectrum Colors
    lineColor = color(random(255), random(255), random(255));
    break;
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
      if (!l.isDeath && !l.noPhysics && !l.isBouncy && !l.hasGrapple && !l.isNoJump) {
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
      rectMode(CENTER);
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

float getSpawnRadius() {
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
