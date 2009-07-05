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

@end
