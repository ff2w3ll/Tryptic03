void drawRect(Rect rect) {
  rect(rect.getLeft(), rect.getTop(), rect.getHorizontalSize(), rect.getVerticalSize());
}

void drawColorRect(Rect rect, color rectColor) {
  noStroke();
  fill(rectColor);
  rect(rect.getLeft(), rect.getTop(), rect.getHorizontalSize(), rect.getVerticalSize());
}

void drawImage(PImage image, Rect rect) {
  image(image, rect.getLeft(), rect.getTop(), rect.getHorizontalSize(), rect.getVerticalSize()); 
}

void drawSource(Source source) {
  // draw video for source (running video)
  Movie movie = source.getVideo().getMovie();
  movie.read();
  DisplayOptions displayOptions = source.getDisplayOptions();  
  movie.speed(displayOptions.getSpeed());
  tint(displayOptions.getRedTint(), displayOptions.getGreenTint(), displayOptions.getBlueTint(), displayOptions.getAlpha());
  drawImage(movie, source.getRect()); 
  noTint();
}

void drawSourceTwice(Source frontSource, Source backSource) {
  // draw video for source (running video)
  Movie movie = frontSource.getVideo().getMovie();
  movie.read();
  // draw front from movie
  DisplayOptions displayOptions = frontSource.getDisplayOptions();  
  movie.speed(displayOptions.getSpeed());
  tint(displayOptions.getRedTint(), displayOptions.getGreenTint(), displayOptions.getBlueTint(), displayOptions.getAlpha());
  drawImage(movie, frontSource.getRect()); 
  noTint();
  // draw back from same movie, so from fron movie to avoid 2 movie.read() per cycle 
  displayOptions = backSource.getDisplayOptions();  
  tint(displayOptions.getRedTint(), displayOptions.getGreenTint(), displayOptions.getBlueTint(), displayOptions.getAlpha());
  drawImage(movie, backSource.getRect()); 
  noTint();
}

void drawSources() {
  if (mode == MODE_GRAPHICS) {
     drawColorRect(frontVisualSource.getRect(), frontVisualSource.getDisplayOptions().getGraphicsColor());    
     drawColorRect(backVisualSource.getRect(), backVisualSource.getDisplayOptions().getGraphicsColor());    
  } else if (mode == MODE_VIDEO) {
    Video frontVideo = frontVisualSource.getVideo();
    Video backVideo = backVisualSource.getVideo();
    
    // check if movie is the same for top and bottom
    if (frontVideo.getFilename().equals(backVideo.getFilename())) {
      drawSourceTwice(frontVisualSource, backVisualSource);
    } else {
      drawSource(frontVisualSource);
      drawSource(backVisualSource);
    }
  }
}

void drawThumbnails() {
  // draw thumbnail section of screen
  for (Thumbnail thumbnail : thumbnails) {
    // draw thumbail in allocated rect
    drawImage(thumbnail.getVideo().getThumbnail(), thumbnail.getRect());
  }
}