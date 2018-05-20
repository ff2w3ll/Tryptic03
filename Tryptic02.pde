import java.awt.Robot;
import java.awt.Rectangle;
import themidibus.*;
import processing.video.*;

Rect previewRect; // preview display
Rect frontVisualRect; // front panels display (OPC collection area)
Rect backVisualRect; // back panels display (OPC collection area)
Rect thumbnailRect; // video thumbnail preview/selection space 

Source frontVisualSource; // OPC source for front panels
Source backVisualSource; // OPC source for back panels

ArrayList<Video> videos; // loaded videos
ArrayList<Thumbnail> thumbnails; // created thumbnails from videos

MidiBus midiBus;
MidiController midiController;

TrypticOPC opc;

int mode;
boolean autoUpdate = false;

int timerDelay;
boolean timerTriggered, isEnabled = true;

void settings() {
  size(MAIN_WIDTH, MAIN_HEIGHT);
  mode = MODE_VIDEO;
  timerDelay = TIME_VIDEO;
  thread("stateFlipper");
}

void setup() {
  frameRate(30);
  initMidi();
  initDisplay();
  initSource();
  initVideos();
  initThumbnails();
  initOPC();
}

void draw() {
  if (timerTriggered) {
    if (autoUpdate) {
      // auto update has been fired
      if (mode == MODE_VIDEO) {
        // randomly select videos
        randomSelectVideos();
      } else if (mode == MODE_GRAPHICS) {
        // randomly select colours
        randomSelectColours();
      }
    }
    timerTriggered = false;
  }
  drawSources();
  //drawPreview();
  drawThumbnails();
  // push OPC data
  pushOPC();
}

void keyPressed() {
  if (key == 'G' || key == 'g') {
    // graphics mode switch
      mode = MODE_GRAPHICS;
      timerDelay = TIME_GRAPHICS; 
      randomSelectColours();
      println("mode switched to: MODE_GRAPHICS");
  } 
  if (key == 'V' || key == 'v') {
    // video mode switch
      mode = MODE_VIDEO;
      timerDelay = TIME_VIDEO; 
      println("mode switched to: MODE_VIDEO");
  } 
  if (key == 'A' || key == 'a') {
    // toggle auto update
      autoUpdate = !autoUpdate;
      println("autoUpdate switched to: " + autoUpdate);
  } 
}

void mousePressed() {
  updateVideoSelection(mouseX, mouseY, 0);
}

void stateFlipper() {
  while (isEnabled) {
      timerTriggered = true;
      delay(timerDelay);
    }
}