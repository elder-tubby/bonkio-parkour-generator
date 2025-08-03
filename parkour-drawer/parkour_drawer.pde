import processing.data.JSONArray;
import processing.data.JSONObject;
import java.awt.datatransfer.*;
import java.awt.Toolkit;

// Global JSON array that will hold our finalized point/line instances.
JSONArray instances;

// Recording state & timing for point sampling
boolean isRecording = false;
int lastRecordTime = 0;

// UI buttons
Button copyButton, clearButton;
Slider angleSlider;
boolean copied = false;
int copyTime = 0;

boolean eraserMode = false;
Button eraserButton;

// Temporary stroke storage (each drag stroke)
ArrayList<PVector> currentStroke;

// Constants for segmentation criteria
final float MAX_DIST = 40;           // Maximum distance between successive points
float ANGLE_THRESHOLD = 0.6;   // 10° in radians (~0.175 radians)
final float MIN_POINT_DIST = 2;  // Minimum distance between points

void setup() {
  size(730, 500);

  // Initialize the JSON array for finalized strokes
  instances = new JSONArray();

  // Initialize the current stroke list
  currentStroke = new ArrayList<PVector>();

  // Initialize the buttons
  copyButton = new Button("Copy to Clipboard (C)", width - 160, 10, 150, 30);
  clearButton = new Button("Clear (X)", width - 160, 50, 150, 30);
  eraserButton = new Button("Eraser: OFF (D)", width - 160, 90, 150, 30);
  angleSlider = new Slider("Angle Sensitivity", width - 160, 140, 150, 0.1, 1, ANGLE_THRESHOLD);

  // Dark theme setup
  background(30);
  cursor(CROSS); // Set a crosshair for precision
}

void draw() {
  background(30); // Dark background

  // Use a coordinate system centered in the window for finalized instances.
  pushMatrix();
  translate(width/2, height/2);
  noStroke();

  // Draw finalized instances.
  // If "length" is 1, we treat it as a point, otherwise as a line marker.
  for (int i = 0; i < instances.size(); i++) {
    JSONObject inst = instances.getJSONObject(i);
    float x = inst.getFloat("x");
    float y = inst.getFloat("y");
    float len = inst.getFloat("width");

    if (len == 1) {  // Single point instance
      fill(255, 100, 100);
      ellipse(x, y, 5, 5);
    } else {
      // Retrieve the stored angle in degrees and convert it to radians for rotate()
      float angle = inst.getFloat("angle");
      pushMatrix();
      translate(x, y);
      rotate(radians(angle));  // Conversion added here
      stroke(255, 100, 100);
      strokeWeight(2);
      line(-len/2, 0, len/2, 0);
      popMatrix();
      noStroke();
    }
  }



  popMatrix();

  // Draw the points of the current stroke (while dragging)
  stroke(100, 255, 100);
  strokeWeight(4);
  for (PVector pt : currentStroke) {
    point(pt.x, pt.y);
  }

  if (eraserMode) {
    float eraserRadius = 20;  // Make sure this value matches the eraser radius used in your eraseAt() function.
    noFill();
    stroke(255, 0, 0); // Red outline to indicate the eraser area
    strokeWeight(2);
    noCursor();
    ellipse(mouseX, mouseY, eraserRadius * 2, eraserRadius * 2);
  } else {
    // Optionally, you can call cursor() to revert to a standard cursor when not erasing.
    cursor(CROSS);
  }

  // Draw the UI buttons (drawn in screen coordinates)
  copyButton.display();
  clearButton.display();
  eraserButton.display();
  angleSlider.display();
  ANGLE_THRESHOLD = angleSlider.getValue();  // Update global threshold

  // Reset button text after 2 seconds if copied
  if (copied && millis() - copyTime > 2000) {
    copied = false;
    copyButton.label = "Copy to Clipboard (C)";
  }
}

void mousePressed() {
  if (copyButton.isHovered()) {
    copyInstancesToClipboard();
    copyButton.label = "Copied";
    copied = true;
    copyTime = millis();
  } else if (clearButton.isHovered()) {
    instances = new JSONArray();
  } else if (eraserButton.isHovered()) {
    // Toggle eraser mode by clicking the eraser button
    eraserMode = !eraserMode;
    eraserButton.label = eraserMode ? "Eraser: ON (D)" : "Eraser: OFF (D)";
  } else if (eraserMode) {
    // If eraser mode is active and no buttons are pressed, erase at the mouse location.
    eraseAt(mouseX, mouseY);
  } else if (angleSlider.isOverHandle()) {
    angleSlider.dragging = true;
  } else {


    // Start drawing a new stroke.
    isRecording = true;
    currentStroke.clear();
    currentStroke.add(new PVector(mouseX, mouseY));
    lastRecordTime = millis();
  }
}


void mouseDragged() {
  if (isRecording && millis() - lastRecordTime > 10) {
    // Only add the new point if it's farther than MIN_POINT_DIST from the last recorded point
    if (currentStroke.size() == 0 || PVector.dist(currentStroke.get(currentStroke.size()-1), new PVector(mouseX, mouseY)) > MIN_POINT_DIST) {
      currentStroke.add(new PVector(mouseX, mouseY));
      lastRecordTime = millis();
    }
  }
    angleSlider.update();

}

void mouseReleased() {
  if (isRecording) {
    processCurrentStroke();
    currentStroke.clear();
    isRecording = false;
  }
    angleSlider.dragging = false;

}

void keyPressed() {
  if (key == 'C' || key == 'c') {
    copyInstancesToClipboard();
    copyButton.label = "Copied";
    copied = true;
    copyTime = millis();
  } else if (key == 'X' || key == 'x') {
    instances = new JSONArray();
  } else if (key == 'D' || key == 'd') {
    eraserMode = !eraserMode;
    eraserButton.label = eraserMode ? "Eraser: ON (D)" : "Eraser: OFF (D)";
  }
}
// New helper function: compute the distance from a point (px,py)
// to a line segment defined by (x1,y1) and (x2,y2)
float distToSegment(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  if (dx == 0 && dy == 0) return dist(px, py, x1, y1);
  float t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy);
  t = constrain(t, 0, 1);
  float projX = x1 + t * dx;
  float projY = y1 + t * dy;
  return dist(px, py, projX, projY);
}

// Updated eraseAt() function: convert the eraser point from screen space to drawing coordinates.
void eraseAt(float ex, float ey) {
  float eraserRadius = 20; // Adjust eraser radius as needed
  // Convert screen coordinates (mouseX, mouseY) to drawing coordinates (center origin)
  float rx = ex - width / 2;
  float ry = ey - height / 2;

  for (int i = instances.size() - 1; i >= 0; i--) {
    JSONObject inst = instances.getJSONObject(i);
    float x = inst.getFloat("x");
    float y = inst.getFloat("y");
    float w = inst.getFloat("width");  // For a point, w is 1; otherwise, it's the line length.
    float angleDeg = inst.getFloat("angle");

    if (w == 1) {  // Single point instance
      if (dist(rx, ry, x, y) <= eraserRadius) {
        instances.remove(i);
      }
    } else {  // Line instance
      float angleRad = radians(angleDeg);
      float halfLength = w / 2.0;
      // Calculate the endpoints of the line based on its center (x,y) and angle.
      float x1 = x - halfLength * cos(angleRad);
      float y1 = y - halfLength * sin(angleRad);
      float x2 = x + halfLength * cos(angleRad);
      float y2 = y + halfLength * sin(angleRad);
      if (distToSegment(rx, ry, x1, y1, x2, y2) <= eraserRadius) {
        instances.remove(i);
      }
    }
  }
}




// Process the current stroke into one or more segments based on distance and angle criteria.
void processCurrentStroke() {
  if (currentStroke.size() == 0) return;

  // A segment is represented by its first and last points.
  ArrayList<Segment> segments = new ArrayList<Segment>();

  // Start with the first point of the stroke.
  PVector segStart = currentStroke.get(0);
  PVector segEnd = segStart.copy();

  for (int i = 1; i < currentStroke.size(); i++) {
    PVector current = currentStroke.get(i);
    float distFromLast = PVector.dist(segEnd, current);

    // Check distance criterion – if too far, finalize current segment and start a new one.
    if (distFromLast > MAX_DIST) {
      segments.add(new Segment(segStart.copy(), segEnd.copy()));
      segStart = current.copy();
      segEnd = current.copy();
      continue;
    }

    // For segments longer than a single point, check the angle.
    if (!segStart.equals(segEnd)) {
      //The current segment's direction.
      PVector segDir = PVector.sub(segEnd, segStart);
      // The direction from the last point to the current point.
      PVector newDir = PVector.sub(current, segEnd);
      float angleDiff = PVector.angleBetween(segDir, newDir);

      if (angleDiff > ANGLE_THRESHOLD) {
        // Angle deviation is too high; finalize current segment and start a new one.
        segments.add(new Segment(segStart.copy(), segEnd.copy()));
        segStart = current.copy();
        segEnd = current.copy();
        continue;
      }
    }

    // Otherwise, extend the current segment.
    segEnd = current.copy();
  }

  // Add the final segment.
  segments.add(new Segment(segStart.copy(), segEnd.copy()));

  // For each segment, compute the center and length then store it.
  // For each segment, compute the center, length, and angle then store it.
  // For each segment, compute the center, length, and angle then store it.
  for (Segment seg : segments) {
    PVector center;
    float segLength = PVector.dist(seg.start, seg.end);
    float ang = 0;
    if (segLength < 0.1) {
      center = seg.start.copy();
      segLength = 1;  // Represents a single point
    } else {
      center = new PVector((seg.start.x + seg.end.x) / 2, (seg.start.y + seg.end.y) / 2);
      ang = atan2(seg.end.y - seg.start.y, seg.end.x - seg.start.x);
    }
    // Convert angle from radians to degrees and ensure it's between 0 and 360.
    float angleDeg = degrees(ang);
    if (angleDeg < 0) {
      angleDeg += 360;
    }

    // Convert center from screen coordinates to drawing coordinates (origin top left)
    // Change this if you prefer a different coordinate space.
    float cx = center.x - width/2;
    float cy = center.y - height/2;


    JSONObject inst = new JSONObject();
    inst.setFloat("x", cx);
    inst.setFloat("y", cy);
    inst.setFloat("width", segLength);
    inst.setFloat("height", 2);
    inst.setFloat("angle", angleDeg);
    inst.setInt("bounciness", -1);
    inst.setBoolean("isOnlyForProgram", false);
    inst.setInt("friction", 0);
    inst.setBoolean("isDeath", false);
    inst.setBoolean("isBgLine", false);
    inst.setBoolean("noPhysics", false);
    inst.setBoolean("noGrapple", true);
    inst.setBoolean("isCapzone", false);
    inst.setBoolean("isNoJump", false);
    inst.setBoolean("isFrame", false);
    inst.setBoolean("isFloor", true);
    inst.setInt("id", instances.size());
    inst.setBoolean("isBouncy", false);

    instances.append(inst);
  }
}

// Helper class to represent a segment (from a drag stroke)
class Segment {
  PVector start, end;
  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
  }
}

void offsetAllInstances(float offsetX, float offsetY) {
  for (int i = 0; i < instances.size(); i++) {
    JSONObject inst = instances.getJSONObject(i);
    float x = inst.getFloat("x");
    float y = inst.getFloat("y");

    inst.setFloat("x", x + offsetX);
    inst.setFloat("y", y + offsetY);
  }
}


// Helper function to copy the JSON string of the final instances (segments/points) to the clipboard.
void copyInstancesToClipboard() {
  offsetAllInstances(935, 350);  // Temporarily shift all instance coordinates

  // Create the final JSON structure
  JSONObject root = new JSONObject();

  root.setInt("version", 1);

  // Add the "lines" array and copy each instance into it
  JSONArray lines = new JSONArray();
  for (int i = 0; i < instances.size(); i++) {
    JSONObject inst = instances.getJSONObject(i);
    lines.append(inst);
  }
  root.setJSONArray("lines", lines);

  // Copy to clipboard as formatted string
  copyToClipboard(root.toString());

  offsetAllInstances(-935, -350);  // Revert the coordinate shift
}


void copyToClipboard(String text) {
  StringSelection selection = new StringSelection(text);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(selection, selection);
}

// Button class for the UI
class Button {
  String label;
  int x, y, w, h;

  Button(String label, int x, int y, int w, int h) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    fill(isHovered() ? color(80) : color(50));
    stroke(200);
    rect(x, y, w, h, 10);
    fill(255);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);

    fill(isHovered() ? color(80) : color(50));
  }

  boolean isHovered() {
    return mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h;
  }
}

class Slider {
  String label;
  int x, y, w;
  float minVal, maxVal, val;
  boolean dragging = false;

  Slider(String label, int x, int y, int w, float minVal, float maxVal, float defaultVal) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.minVal = minVal;
    this.maxVal = maxVal;
    this.val = constrain(defaultVal, minVal, maxVal);
  }

  void display() {
    fill(50);
    stroke(200);
    rect(x, y + 15, w, 4);  // Slider track

    float handleX = map(val, minVal, maxVal, x, x + w);
    fill(100, 200, 255);
    noStroke();
    ellipse(handleX, y + 17, 12, 12);  // Handle

    fill(255);
    textAlign(LEFT, CENTER);
    text(label + ": " + nf(val, 1, 2), x, y);
  }

  boolean isOverHandle() {
    float handleX = map(val, minVal, maxVal, x, x + w);
    return dist(mouseX, mouseY, handleX, y + 17) < 10;
  }

  void update() {
    if (dragging) {
      val = map(constrain(mouseX, x, x + w), x, x + w, minVal, maxVal);
    }
  }

  float getValue() {
    return val;
  }
}
