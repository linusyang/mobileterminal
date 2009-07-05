// VT100Test.m
// VT100

#import "VT100Test.h"

#import "VT100.h"

@implementation VT100Test

- (void) setUp {
  ScreenSize size;
  size.width = 80;
  size.height = 25;
  vt100 = [[VT100 alloc] init];
  [vt100 setScreenSize:size];
}

- (void) tearDown {
  [vt100 release];
}

// Tests a basic case where a few leters are inserted into the terminals 
// input stream and read back
- (void) testBasicInput {
  const char* text = "abc";
  [vt100 handleInputStream:text withLength:strlen(text)];

  screen_char_t* buffer = [vt100 bufferForRow:0];
  STAssertTrue(buffer[0].ch == 'a', @"expected 'a', got '%c'", buffer[0].ch);
  STAssertTrue(buffer[1].ch == 'b', @"expected 'b', got '%c'", buffer[0].ch);
  STAssertTrue(buffer[2].ch == 'c', @"expected 'c', got '%c'", buffer[0].ch);
  STAssertTrue(buffer[3].ch == '\0', @"expected '\0', got '%c'", buffer[0].ch);
}

// Tests basic window resizing
- (void) testResize {
  ScreenSize size = [vt100 screenSize];
  STAssertEquals(80, size.width, @"expected 80, got %d", size.width);
  STAssertEquals(25, size.height, @"expected 25, got %d", size.height);
  
  // Change the size of the screen
  size.width = 40;
  size.height = 20;
  [vt100 setScreenSize:size];
  
  // Verify that the size has been changed
  size = [vt100 screenSize];
  STAssertEquals(40, size.width, @"expected 40, got %d", size.width);
  STAssertEquals(20, size.height, @"expected 20, got %d", size.height);
}

static const int kLargeBufferSize = 8 * 1024;

// Tests the case where we input data into the terminal, then resize the
// window.  This causes some of the strings to change position.
- (void) testMultipleLinesWithResizing {
  char data[kLargeBufferSize];
  
  // First row is entirely a's
  int i = 0;
  for (int j = 0; j < 79; ++j) {
    data[i++] = 'a';
  }
  data[i++] = '\r';
  data[i++] = '\n';
  // Second row is entirely b's
  for (int j = 0; j < 79; ++j) {
    data[i++] = 'b';
  }
  data[i++] = '\r';
  data[i++] = '\n';
  // Single c on the third row
  data[i++] = 'c';
  data[i++] = '\0';
  [vt100 handleInputStream:data withLength:strlen(data)];
    
  // Verify the each row looks correct
  screen_char_t* buffer = [vt100 bufferForRow:0];
  for (int j = 0; j < 79; j++) {
    STAssertTrue('a' == buffer[j].ch, @"got '%c'", buffer[j].ch);
  }
  STAssertTrue('\0' == buffer[79].ch, @"got '%c'", buffer[79].ch);
  buffer = [vt100 bufferForRow:1];
  for (int j = 0; j < 79; j++) {
    STAssertTrue('b' == buffer[j].ch, @"got '%c'", buffer[j].ch);
  }
  STAssertTrue('\0' == buffer[79].ch, @"got '%c'", buffer[79].ch);
  buffer = [vt100 bufferForRow:2];
  STAssertTrue('c' == buffer[0].ch, @"got '%c'", buffer[0].ch);
  STAssertTrue('\0' == buffer[1].ch, @"got '%c'", buffer[1].ch);
  

  // Change the size of the screen, which causes the terminal to move
  // everything.
  ScreenSize size = [vt100 screenSize];
  size.width = 40;
  size.height = 25;
  [vt100 setScreenSize:size];
  
  // Now the first two (shorter) rows are a's
  buffer = [vt100 bufferForRow:0];
  for (int j = 0; j < 40; j++) {
    STAssertTrue('a' == buffer[j].ch, @"buffer[%d] was '%c'", j, buffer[j].ch);
  }
  buffer = [vt100 bufferForRow:1];
  for (int j = 0; j < 39; j++) {
    STAssertTrue('a' == buffer[j].ch, @"buffer[%d] was'%c'", j, buffer[j].ch);
  }
  STAssertTrue('\0' == buffer[39].ch, @"was '%c'", buffer[39].ch);
  
  // Next two rows are b's
  buffer = [vt100 bufferForRow:2];
  for (int j = 0; j < 40; j++) {
    STAssertTrue('b' == buffer[j].ch, @"buffer[%d] was '%c'", j, buffer[j].ch);
  }
  buffer = [vt100 bufferForRow:3];
  for (int j = 0; j < 39; j++) {
    STAssertTrue('b' == buffer[j].ch, @"buffer[%d] was'%c'", j, buffer[j].ch);
  }
  STAssertTrue('\0' == buffer[39].ch, @"was '%c'", buffer[39].ch);
  
  // Last row has a single c
  buffer = [vt100 bufferForRow:4];
  STAssertTrue('c' == buffer[0].ch, @"got '%c'", buffer[0].ch);
  STAssertTrue('\0' == buffer[1].ch, @"got '%c'", buffer[1].ch);
}

@end
