void initOPC() {
  // connect to fcServer
  opc = new TrypticOPC("127.0.0.1", 7890, SOURCE_WIDTH, SOURCE_HEIGHT);
  opc.showLocations(false);
  // create OPC mapping
  PVector center = new PVector(SOURCE_WIDTH / 2, SOURCE_HEIGHT / 2 + TRIANGLE_CENTER_OFFSET);
  PVector v1 = new PVector(0, -TRIANGLE_FAN_OFFSET);
  PVector v2 = new PVector(-TRIANGLE_SIZE / 2, -TRIANGLE_SIZE * cos(PI * 30 / 180) + v1.y);
  PVector v3 = new PVector(TRIANGLE_SIZE / 2, v2.y);
  
  v1.rotate(PI * -90 / 180);
  v2.rotate(PI * -90 / 180);
  v3.rotate(PI * -90 / 180);
  
  //int index = 0;
  for (int i = 0; i < 4; ++i) {
    // outputs of 1st fadecandy
    opc.ledTriangle(i*64, 9, PVector.add(v1, center), PVector.add(v2, center), PVector.add(v3, center), FRONT_GROUP);
    // outputs of 2nd fadecandy
    opc.ledTriangle((i+8)*64, 9, PVector.add(v1, center), PVector.add(v2, center), PVector.add(v3, center), BACK_GROUP);
    // rotate to next position
    v1.rotate(PI * 60 / 180);
    v2.rotate(PI * 60 / 180);
    v3.rotate(PI * 60 / 180);
  }  
}

void initMidi() {
  midiBus = createMidiBus("BCF2000");
  midiController = new MidiController(midiBus);
}

void initDisplay() {
  // create display rectangles
  previewRect = new Rect(0, 0, PREVIEW_WIDTH, PREVIEW_HEIGHT);
  println("previewRect: " + previewRect);
  frontVisualRect = new Rect(PREVIEW_WIDTH, 0, SOURCE_WIDTH, SOURCE_HEIGHT);
  println("frontVisualRect: " + frontVisualRect);
  backVisualRect = new Rect(PREVIEW_WIDTH, SOURCE_HEIGHT, SOURCE_WIDTH, SOURCE_HEIGHT);
  println("backVisualRect: " + backVisualRect);
  thumbnailRect = new Rect(0, PREVIEW_HEIGHT, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT);
  println("thumbnailRect: " + thumbnailRect);
}

void initSource() {
  // create front and back source areas for OPC
  frontVisualSource = new Source(frontVisualRect);
  println("frontVisualSource: " + frontVisualSource);
  backVisualSource = new Source(backVisualRect);
  println("backVisualSource: " + backVisualSource);
}

void initVideos() {
  videos = new ArrayList<Video>();
  // load videos from data directory
  File folder = new File(dataPath(""));
  if (folder.exists()) {
    File[] files = folder.listFiles();
    for (int i = 0; i < files.length; i++) {
      if (!files[i].isHidden()) {
        Video video = null;
        try {
          if (i<=30) // limit to 30 videos
            video = createVideo(files[i].getPath());
        } catch (Exception e) {
          println("Error creating video: " + files[i].getPath());
        }
        if (video != null) {
          videos.add(video);
        }
      }
    }
  }
  // set front and back default videos
  Video video = videos.get(0);
  video.getMovie().loop();
  frontVisualSource.setVideo(video);

  video = videos.get(1);
  video.getMovie().loop();
  backVisualSource.setVideo(video);
}

void initThumbnails() {
  thumbnails = new ArrayList<Thumbnail>();
  // create list of thumbnails with positioning data - uses videos
  int i = 1;
  int hSize = THUMBNAIL_WIDTH / THUMBNAIL_HORIZONTAL_COUNT;
  int vSize = THUMBNAIL_HEIGHT / THUMBNAIL_VERTICAL_COUNT;
  for (Video video : videos) {
    // calculate the bounding rectangle
    // -- where in counter translate into matrix?? i -> (x, y)
    int yOffset = (i-1)/THUMBNAIL_HORIZONTAL_COUNT + 1;
    int xOffset = i-(yOffset-1)*THUMBNAIL_HORIZONTAL_COUNT;
    // actual position
    int left = thumbnailRect.getLeft() + (xOffset-1)*hSize;
    int top = thumbnailRect.getTop() + (yOffset-1)*vSize;
    Rect rect = new Rect(left, top, hSize, vSize);
    println(rect);
    // add to list
    thumbnails.add(new Thumbnail(video, rect));
    i++;
  }
}