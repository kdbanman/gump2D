// Cells have 6 friendly neighbor cells
// These vectors define the birth and survival conditions in terms of
// the number of live neighbors.
int[] survivalFromNeighbors = {1, 2, 3, 4};
int[] birthFromNeighbors = {3, 4};

int framerate = 60;
int iterationsPerFrame = 1;
boolean paused = true;

int seedDensity = 100;
int defaultSeedSize = 51;
int habSize = 100;

int deadCellColor = 0xFF222222;
int liveCellColor = 0xFFAEAEAE;

int cellWidth = 10;
int spaceWidth = 20;
int totalWidth = cellWidth + spaceWidth;

boolean[][] habitat;
boolean[][] nextHabitat;


void settings() {
  size(totalWidth * (habSize / 2), totalWidth * (habSize / 2));
}

void setup() {
  frameRate(framerate);
  noStroke();
  habitat = new boolean[habSize][habSize];
  nextHabitat = new boolean[habSize][habSize];

  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      habitat[i][j] = false;
      nextHabitat[i][j] = false;
    }
  }

  populateHabitat(defaultSeedSize);
}

void draw() {
  if (!paused) {
    for (int i = 0; i < iterationsPerFrame; i++) {
      iterateHabitat();
    }
  }

  background(0);
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      if (isHorizontalCell(i, j)) {
        fill(deadCellColor);
        if (isLive(i, j)) fill(liveCellColor);
        rect(
          totalWidth * (i + 1) / 2 - spaceWidth,
          totalWidth * j / 2,
          spaceWidth,
          cellWidth
        );
      } else if (isVerticalCell(i, j)) {
        fill(deadCellColor);
        if (isLive(i,j)) fill(liveCellColor);
        rect(
          totalWidth * i / 2,
          totalWidth * (j + 1) / 2 - spaceWidth,
          cellWidth,
          spaceWidth
        );
      }
    }
  }
}

void speedup() {
  iterationsPerFrame = min(2048, iterationsPerFrame * 2);
  println("speed up: " + iterationsPerFrame + " ipf");
}
void speeddown() {
  iterationsPerFrame = max(1, iterationsPerFrame / 2);
  println("speed down: " + iterationsPerFrame + " ipf");
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  } else if (key == RETURN || key == ENTER) {
    populateHabitat(defaultSeedSize);
  } else if (key == '[') {
    speeddown();
  } else if (key == ']') {
    speedup();
  } else if (key == CODED) {
    if (keyCode == UP) {
      speedup();
    } else if (keyCode == DOWN) {
      speeddown();
    }
  }
}

boolean valueWithin(int[] array, int value) {
  for (int arrayValue : array) {
    if (value == arrayValue) {
      return true;
    }
  }
  return false;
}

void iterateHabitat() {
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      nextHabitat[i][j] = false;
      if (isHorizontalCell(i, j)) {
        int liveFriends = 0;
        if (isLive(i - 1, j - 1)) liveFriends++;
        if (isLive(i - 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j - 1)) liveFriends++;
        if (isLive(i - 2, j)) liveFriends++;
        if (isLive(i + 2, j)) liveFriends++;

        if (isLive(i, j) && valueWithin(survivalFromNeighbors, liveFriends)
          || !isLive(i, j) && valueWithin(birthFromNeighbors, liveFriends)) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;

      } else if (isVerticalCell(i, j)) {
        int liveFriends = 0;
        if (isLive(i - 1, j - 1)) liveFriends++;
        if (isLive(i - 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j - 1)) liveFriends++;
        if (isLive(i, j - 2)) liveFriends++;
        if (isLive(i, j + 2)) liveFriends++;

        if (isLive(i, j) && valueWithin(survivalFromNeighbors, liveFriends)
          || !isLive(i, j) && valueWithin(birthFromNeighbors, liveFriends)) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;
      }
    }
  }

  boolean[][] triangleSwap = habitat;
  habitat = nextHabitat;
  nextHabitat = triangleSwap;
}

boolean isLive(int x, int y) {
  if (x < 0) x = habSize + x;
  else if (x >= habSize) x = x - habSize;

  if (y < 0) y = habSize + y;
  else if (y >= habSize) y = y - habSize;

  return habitat[x][y];
}

void setLive(int x, int y) {
  if (x < 0) x = habSize + x;
  else if (x >= habSize) x = x - habSize;

  if (y < 0) y = habSize + y;
  else if (y >= habSize) y = y - habSize;

  habitat[x][y] = true;
}

boolean isCell(int x, int y) {
  return isHorizontalCell(x, y) || isVerticalCell(x, y);
}

boolean isHorizontalCell(int x, int y) {
  return x % 2 == 1 && y % 2 == 0;
}

boolean isVerticalCell(int x, int y) {
  return x % 2 == 0 && y % 2 == 1;
}

void populateHabitat(int seedSize) {
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      habitat[i][j] = false;
    }
  }

  int seedStart = habSize / 2 - seedSize / 2;
  int seedEnd = habSize / 2 + seedSize / 2;

  if (seedEnd - seedStart < seedSize) {
    // Above math always results in even valued start and end due to division flooring, so
    // get back to the right size if necessary.  Use mod 4 math to decide which direction
    // to shift the seed.
    if (seedSize % 4 == 0) {
      seedStart -= 1;
    } else {
      seedStart += 1;
    }
  }
  println("populating size " + (seedEnd - seedStart) + " from " + seedStart + " to " + seedEnd);

  for (int i = seedStart; i < seedEnd; i++) {
    for (int j = seedStart; j < seedEnd; j++) {
      if (isCell(i, j)) {
        if (random(100) <= seedDensity) habitat[i][j] = true;
      }
    }
  }
}
