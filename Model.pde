// ==========================================================================
// ==========================================================================

class Thumbnail {

  public Thumbnail(Video video, Rect rect) {
    this.video = video;
    this.rect = rect;
  }

  Video getVideo() {
    return video;
  }

  Rect getRect() {
    return rect ;
  }

  Video video;
  Rect rect;
}

// ==========================================================================
// ==========================================================================

class Video {

  public Video(Movie movie, PImage thumbnail, String filename) {
    this.movie = movie;
    this.thumbnail = thumbnail;
    this.filename = filename;
  }

  String toString() {
    String str = "Video -> "
      + "movie: " + movie 
      + ", thumbnail: " + thumbnail 
      + ", filename: " + filename; 
    return str;
  }

  Movie getMovie() {
    return movie;
  }

  PImage getThumbnail() {
    return thumbnail;
  }

  String getFilename() {
    return filename;
  }
  
  Movie movie;
  PImage thumbnail;
  String filename;
}

// ==========================================================================
// ==========================================================================

class Rect {

  public Rect(int left, int top, int horizontalSize, int verticalSize) {
    this.left = left;
    this.top = top;
    this.horizontalSize = horizontalSize;
    this.verticalSize = verticalSize;
  }

  int getLeft() { 
    return left;
  }
  int getRight() { 
    return left + horizontalSize;
  }
  int getTop() { 
    return top;
  }
  int getBottom() { 
    return top + verticalSize;
  }
  int getHorizontalSize() { 
    return horizontalSize;
  }
  int getVerticalSize() { 
    return verticalSize;
  }

  PVector topleft() { 
    return new PVector(getLeft(), getTop());
  }
  PVector topRight() { 
    return new PVector(getRight(), getTop());
  }
  PVector bottomLeft() { 
    return new PVector(getLeft(), getBottom());
  }
  PVector bottomRight() { 
    return new PVector(getRight(), getBottom());
  }
  PVector center() { 
    return new PVector(getLeft() + getHorizontalSize() / 2, getTop() + getVerticalSize() / 2);
  }

  Rect adjusted(int x1, int y1, int x2, int y2) {
    return new Rect(getLeft() + x1, getTop() + y1, getHorizontalSize() + x2 - x1, getVerticalSize() + y2 - y1);
  }

  boolean contains(int xP, int yP) {
    if ((getLeft()<xP && getRight()>xP) && (getTop()<yP && getBottom()>yP)) {
      return true;
    }
    return false;
  }

  String toString() {
    String str = "Rect -> "
      + "left: " + left
      + ", top: " + top
      + ", horizontalSize: " + horizontalSize
      + ", verticalSize: " + verticalSize;
    return str;
  }

  int left;
  int top;
  int horizontalSize;
  int verticalSize;
}

// ==========================================================================
// ==========================================================================

class DisplayOptions {

  public DisplayOptions() {
  }

  void setRedTint(int redTint) {
    this.redTint = redTint;
  }

  int getRedTint() {
    return redTint;
  }

  void setGreenTint(int greenTint) {
    this.greenTint = greenTint;
  }

  int getGreenTint() {
    return greenTint;
  }

  void setBlueTint(int blueTint) {
    this.blueTint = blueTint;
  }

  int getBlueTint() {
    return blueTint;
  }

  void setAlpha(int alpha) {
    this.alpha = alpha;
  }

  int getAlpha() {
    return alpha;
  }

  void setSpeed(int speed) {
    this.speed = speed;
  }

  int getSpeed() {
    return speed;
  }

  void setGraphicsColor(int red, int green, int blue) {
    setRedTint(red);
    setGreenTint(green);
    setBlueTint(blue);
  }

  color getGraphicsColor() {
    return color(getRedTint(), getGreenTint(), getBlueTint());
  }

  int redTint = 255;
  int greenTint = 255;
  int blueTint = 255;
  int alpha = 255;
  int speed = 1;
}


// ==========================================================================
// ==========================================================================

/*
  Source is a display area used for an OPC pull.
 */
class Source {

  public Source(Rect rect) {
    this.displayOptions = new DisplayOptions();
    this.rect = rect;
  }

  Rect getRect() {
    return rect;
  }

  void setVideo(Video video) {
    this.video = video;
  }

  Video getVideo() {
    return video;
  }

  void setDisplayOptions(DisplayOptions displayOptions) {
    this.displayOptions = displayOptions;
  }

  DisplayOptions getDisplayOptions() {
    return displayOptions;
  }

  Video video; // video to run in rect
  Rect rect; // space to draw the video in
  DisplayOptions displayOptions; // display options for the video
};

// ==========================================================================
// ==========================================================================

class BaseMidiController implements RawMidiListener {

  BaseMidiController(MidiBus midiBus, boolean echo) {
    mMidiBus = midiBus;
    mMidiBus.addMidiListener(this);
    mEntry = false;
    mEcho = echo;
  }

  void noteOn(int channel, int pitch, int velocity) {
  }
  void noteOff(int channel, int pitch, int velocity) {
  }
  void pitchBend(int channel, int value) {
  }
  void controllerChange(int channel, int number, int value) {
  }
  void stop() {
  }

  void sendPitchBend(int channel, int value) {
    byte data[] = { (byte)0xE0, (byte)0x00, (byte)0x00 };
    data[0] += channel;
    data[1] = (byte)(value & 0xFF);
    data[2] = (byte)(value >> 7);
    mMidiBus.sendMessage(data);
  }

  void sendControllerChange(int channel, int number, int value) {
    mMidiBus.sendControllerChange(channel, number, value);
  }

  void sendNoteOn(int channel, int pitch, int velocity) {
    mMidiBus.sendNoteOn(channel, pitch, velocity);
  }

  void sendNoteOff(int channel, int pitch, int velocity) {
    mMidiBus.sendNoteOff(channel, pitch, velocity);
  }

  void rawMidiMessage(byte[] data) {
    if (mEntry) {
      return;
    }
    mEntry = true;
    if (mEcho) {
      mMidiBus.sendMessage(data);
    }
    switch (data[0] & 0xF0) {
    case 0x80:
      mMidiBus.sendNoteOn(data[0] & 0x0F, data[1], 0);
      noteOff(data[0] & 0x0F, data[1], data[2]);
      break;
    case 0x90:
      noteOn(data[0] & 0x0F, data[1], data[2]);
      break;
    case 0xB0:
      controllerChange(data[0] & 0x0F, data[1], data[2]);
      break;
    case 0xE0:
      pitchBend(data[0] & 0x0F, data[1] + (data[2] << 7));
      break;
    case 0xF0:
      systemMessage(data);
      break;
    default:
      print("unhandled message: ");
      for (int i = 0; i < data.length; ++i) {
        print(hex(data[i], 2));
        print(" ");
      }
      println();
    }
    mEntry = false;
  }

  void systemMessage(byte[] data) {
    switch(data[0] & 0x0F)
    {
    case 0xC:
      stop();
      break;
    }
  }

  MidiBus mMidiBus;
  boolean mEcho;
  boolean mEntry;
};

// ==========================================================================
// ==========================================================================

class MidiController extends BaseMidiController {

  final int FRONT_MASTER = 8;
  final int FRONT_RED = 9;
  final int FRONT_GREEN = 10;
  final int FRONT_BLUE = 12;
  final int FRONT_VIDEO = 23;
  final int FRONT_SPEED = 24;
  final int BACK_MASTER = 13;
  final int BACK_RED = 14;
  final int BACK_GREEN = 15;
  final int BACK_BLUE = 16;
  final int BACK_VIDEO = 27;
  final int BACK_SPEED = 28;

  MidiController(MidiBus midiBus) {
    super(midiBus, false);
  }

  void controllerChange(int channel, int number, int value) {
    float normalised = (float) value / 0x7F;
    int newValue = (int) (255 * normalised);
    String area = "NONE";
    
    switch(number) {
    case FRONT_MASTER:
      area = "FRONT_MASTER";
      frontVisualSource.getDisplayOptions().setAlpha(newValue);
      break;
    case FRONT_RED:
      area = "FRONT_RED";
      frontVisualSource.getDisplayOptions().setRedTint(newValue);
      break;
    case FRONT_GREEN:
      area = "FRONT_GREEN";
      frontVisualSource.getDisplayOptions().setGreenTint(newValue);
      break;
    case FRONT_BLUE:
      area = "FRONT_BLUE";
      frontVisualSource.getDisplayOptions().setBlueTint(newValue);
      break;
    case FRONT_VIDEO:
      area = "FRONT_VIDEO";
      // jump to next video
            
      //frontVisualSource.getDisplayOptions().setBlueTint(newValue);
      break;
    case FRONT_SPEED:
      area = "FRONT_SPEED";
      int fSpeed = (int) normalised * 2;
      frontVisualSource.getDisplayOptions().setSpeed(fSpeed);
      break;
    case BACK_MASTER:
      area = "BACK_MASTER";
      backVisualSource.getDisplayOptions().setAlpha(newValue);
      break;
    case BACK_RED:
      area = "BACK_RED";
      backVisualSource.getDisplayOptions().setRedTint(newValue);
      break;
    case BACK_GREEN:
      area = "BACK_GREEN";
      backVisualSource.getDisplayOptions().setGreenTint(newValue);
      break;
    case BACK_BLUE:
      area = "BACK_BLUE";
      backVisualSource.getDisplayOptions().setBlueTint(newValue);
      break;
    case BACK_VIDEO:
      area = "BACK_VIDEO";
      // jump to next video
            
      //frontVisualSource.getDisplayOptions().setBlueTint(newValue);
      break;
    case BACK_SPEED:
      area = "BACK_SPEED";
      int bSpeed = (int) normalised * 2;
      frontVisualSource.getDisplayOptions().setSpeed(bSpeed);
      break;
    }
    
    println("Adjusted from MIDI. Area:" + area + ", value:" + newValue);
  }
};

// ==========================================================================
// ==========================================================================

class TrypticOPC extends OPC {

  TrypticOPC(String host, int port, int wid, int hgt) {
    super(host, port, wid, hgt);
  }

  void ledTriangle(int index, int sideLength, PVector v1, PVector v2, PVector v3, int group) {
    PVector delta12 = PVector.div(PVector.sub(v2, v1), sideLength - 1);
    PVector delta23 = PVector.div(PVector.sub(v3, v2), sideLength - 1);
    for (int i12 = 0; i12 < sideLength; ++i12) {
      PVector v12 = PVector.add(v1, PVector.mult(delta12, i12));
      for (int i23 = 0; i23 <= i12; ++i23) {
        int i = (i12 % 2 == 1) ? i23 : i12 - i23;
        PVector v = PVector.add(v12, PVector.mult(delta23, i));
        led(index++, (int)(v.x + 0.5), (int)(v.y + 0.5), group);
      }
    }
  }
};