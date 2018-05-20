void copyFit(PImage source, PImage dest) {
  if(source == null || dest == null || source.width == 0 || source.height == 0  || dest.width == 0 || dest.height == 0 )
    return;
  
  float sourceAspect = source.width / source.height;
  float destAspect = dest.width / dest.height;
  
  if(sourceAspect >= destAspect) {
    float destToSourceScale = source.height / dest.height;
    int sw = int(destToSourceScale * dest.width);
    int sh = int(source.height);
    int sx = int(source.width - sw) / 2;
    int sy = 0;
    
    dest.copy(source, sx, sy, sw, sh, 0, 0, dest.width, dest.height);
  }
  else {
    float destToSourceScale = source.width / dest.width;
    int sh = int(destToSourceScale * dest.height);
    int sw = int(source.width);
    int sy = int(source.height - sh) / 2;
    int sx = 0;
    
    dest.copy(source, sx, sy, sw, sh, 0, 0, dest.width, dest.height);
  }
}

Thumbnail getThumbnailFromPosition(int xP, int yP) {
  // over thumbnails
  if (yP>PREVIEW_HEIGHT) {
    // check each thumbnail
    for (Thumbnail thumbnail : thumbnails) {
        if (thumbnail.getRect().contains(xP, yP)) {
          return thumbnail;
        }
    }
  }
  return null;
}

void pushOPC() {
  // NOTE: cannot copy from video because the tint is not applied, so copy from screen 
  
  //PImage frontCapture = new PImage(SOURCE_WIDTH, SOURCE_HEIGHT, RGB);
  //copyFit(frontVisualSource.getVideo().getMovie(), frontCapture);
  PImage frontCapture = get(PREVIEW_WIDTH, 0, SOURCE_WIDTH, SOURCE_HEIGHT);
  opc.capture(frontCapture, FRONT_GROUP);
  
  //PImage backCapture = new PImage(SOURCE_WIDTH, SOURCE_HEIGHT, RGB);
  //copyFit(backVisualSource.getVideo().getMovie(), backCapture);
  PImage backCapture = get(PREVIEW_WIDTH, SOURCE_HEIGHT, SOURCE_WIDTH, SOURCE_HEIGHT);
  opc.capture(backCapture, BACK_GROUP);
  
  opc.writePixels();
}

void updateVideoSelection(int mX, int mY, int click) {
  Thumbnail thumbnail = getThumbnailFromPosition(mX, mY);
  if (thumbnail != null) {
    println("Clicked on thumbnail: " + thumbnail);
    if (mouseButton == LEFT || click == LEFT) {
      // select front panel video if thumbnail selected
      Video oldVideo = frontVisualSource.getVideo();
      if (!frontVisualSource.getVideo().getFilename().equals(backVisualSource.getVideo().getFilename())) {
        // only pause if not same as back video
        oldVideo.getMovie().pause();
      }
      frontVisualSource.setVideo(thumbnail.getVideo());
      thumbnail.getVideo().getMovie().loop();
    } else if (mouseButton == RIGHT || click == RIGHT) {
      // select back panel video if thumbnail selected
      // select front panel video if thumbnail selected
      Video oldVideo = backVisualSource.getVideo();
      if (!backVisualSource.getVideo().getFilename().equals(frontVisualSource.getVideo().getFilename())) {
        // only pause if not same as front video
        oldVideo.getMovie().pause();
      }
      backVisualSource.setVideo(thumbnail.getVideo());
      thumbnail.getVideo().getMovie().loop();
    } 
  }
}

void randomSelectVideos() {
  // random position
  int mX = (int) random(0, THUMBNAIL_WIDTH);  
  int mY = (int) (PREVIEW_HEIGHT + random(0, THUMBNAIL_HEIGHT));
  println("Auto update FRONT to video position x:" + mX + ", y:" +mY);
  updateVideoSelection(mX, mY, LEFT);
  // random position
  mX = (int) random(0, THUMBNAIL_WIDTH);  
  mY = (int) (PREVIEW_HEIGHT + random(0, THUMBNAIL_HEIGHT));
  println("Auto update BACK to video position x:" + mX + ", y:" +mY);
  updateVideoSelection(mX, mY, RIGHT);
}

void randomSelectColours() {
 frontVisualSource.getDisplayOptions().setGraphicsColor((int)random(255), (int)random(255), (int)random(255));
 backVisualSource.getDisplayOptions().setGraphicsColor((int)random(255), (int)random(255), (int)random(255));
}