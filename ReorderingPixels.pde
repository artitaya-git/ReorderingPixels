
/*

Original code inspired by Jeff Thompson and Kim Asendorf's techniques;

https://github.com/jeffThompson/PixelSorting
https://github.com/kimasendorf/ASDFPixelSort

Modified to include Perlin Noise and interactive elements for reordering pixels

*/


int mode = 1; 
PImage img, sortedImg;
boolean[][] mask; // Sorting mask based on Perlin Noise
int loops = 1;
int brightVal = 50;

int row = 0;
int col = 0;

void setup() {
  size(1000, 607);
  //surface.setResizable(true);
  //surface.setSize(img.width, img.height); 
  
  img = loadImage("mountain.jpg");
  image(img, 0, 0, width, height);
}

void draw() {
  // Update brightness value based on mouseY for interactive control
  brightVal = (int)map(mouseY, 0, height, 0, 255);
  
  // Create mask using Perlin Noise
  mask = new boolean[img.width][img.height];
  for (float i = 0; i < img.width; i++) {
    for (float j = 0; j < img.height; j++) {
      mask[(int)i][(int)j] = noise(i / 100., j / 100.) * 20 > brightVal;
    }
  }
  
  sortedImg = img.copy();
  col = 0;
  
  // Sort columns based on mask
  sortedImg.updatePixels();
  while (col < sortedImg.width - 1) {
    sortCol();
    col++;
  }
  sortedImg.updatePixels();
  
  // Update brightness value based on mouseX for interactive control
  brightVal = (int)map(mouseX, 0, width, 0, 255);
  
  // Update mask with new brightness value
  mask = new boolean[img.width][img.height];
  for (float i = 0; i < img.width; i++) {
    for (float j = 0; j < img.height; j++) {
      mask[(int)i][(int)j] = brightness(img.pixels[(int)i + (int)j * img.width]) > brightVal;
    }
  }
  
  row = 0;
  
  // Sort rows based on mask
  sortedImg.loadPixels();
  while (row < sortedImg.height - 1) {
    sortRow();
    row++;
  }
  sortedImg.updatePixels();
  
  // Display the sorted image
  image(sortedImg, 0, 0, width, height);
}

void sortRow() {
  int y = row;
  int x = 0;
  int endX = 0;
  
  while (endX < sortedImg.width - 1) {
    x = getFirstX(x, y); // Get the starting x position for sorting
    endX = getNextX(x, y); // Get the ending x position for sorting
    
    if (x < 0) break;
    
    int sortLength = endX - x;
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    // Collect pixels to be sorted
    for (int i = 0; i < sortLength; i++) {
      unsorted[i] = sortedImg.pixels[x + i + y * sortedImg.width];
    }
    
    sorted = sort(unsorted); // Sort the pixels
    
    // Place sorted pixels back into the image
    for (int i = 0; i < sortLength; i++) {
      sortedImg.pixels[x + i + y * sortedImg.width] = sorted[i];      
    }
    
    x = endX + 1;
  }
}

void sortCol() {
  int x = col;
  int y = 0;
  int endY = 0;
  
  while (endY < sortedImg.height - 1) {
    y = getFirstBrightY(x, y); // Get the starting y position for sorting
    endY = getNextDarkY(x, y); // Get the ending y position for sorting
    
    if (y < 0) break;
    
    int sortLength = endY - y;
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    // Collect pixels to be sorted
    for (int i = 0; i < sortLength; i++) {
      unsorted[i] = sortedImg.pixels[x + (y + i) * sortedImg.width];
    }
    
    sorted = sort(unsorted);
    
    // Place sorted pixels back into the image
    for (int i = 0; i < sortLength; i++) {
      sortedImg.pixels[x + (y + i) * sortedImg.width] = sorted[i];
    }
    
    y = endY + 1;
  }
}

int getFirstX(int x, int y) {
  while (mask[x][y] == false) {
    x++;
    if (x >= img.width) return -1; // Exit if end of row is reached
  }
  return x;
}

int getNextX(int nextX, int nextY) {
  int x = constrain(nextX + 1, 0, img.width - 1);
  int y = nextY;
  while (mask[x][y]) {
    x++;
    if (x >= img.width) return img.width - 1; // Exit if end of column is reached
  }
  return x - 1;
}

int getFirstBrightY(int x, int y) {
  if (y < img.height) {
    while (mask[x][y] == false) {
      y++;
      if (y >= img.height) return -1;
    }
  }
  return y;
}

int getNextDarkY(int x, int y) {
  y++;
  if (y < img.height) {
    while (mask[x][y]) {
      y++;
      if (y >= img.height) return img.height - 1; // Exit if end of column is reached
    }
  }
  return y - 1;
}
