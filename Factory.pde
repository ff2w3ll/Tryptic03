Movie createMovie(String filename) {
  println("Creating movie.");
  return new Movie(this, filename);
}

PImage createThumbnail(Movie movie) {
  println("Creating thumbnail.");
  movie.play();
  movie.pause();
  movie.jump(min(movie.duration() * 0.5, 2.0));
  movie.read();
  PImage thumbnail = new PImage(movie.width, movie.height, RGB);
  copyFit(movie, thumbnail);
  movie.jump(0);
  return thumbnail;
}

Video createVideo(String filename) {
  println("Creating video from filename:" + filename);
  // create movie
  Movie movie = createMovie(filename);
  movie.speed(1); // start speed
  // create thumbnail
  PImage thumbnail = createThumbnail(movie);
  // pause movie
  movie.pause();
  return new Video(movie, thumbnail, filename);
}

MidiBus createMidiBus(String device) {
  String inputs[] = MidiBus.availableInputs();
  boolean found = false;
  for (int i = 0; i < inputs.length; ++i) {
    println(i + " : " + inputs[i]);
    if (inputs[i].equals(device)) {
      found = true;
    }
  }
  try {
    MidiBus midiBus = new MidiBus(this, device, device);
    if (!found) {
      println("\"" + device + "\" MIDI device not found. Using \"" + inputs[0] + "\" instead.");
    }
    return midiBus;
  }
  catch (Exception e) { 
    println("\"" + device + "\" MIDI device not found.");
  }
  return null;
}