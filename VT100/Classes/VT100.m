// VT100.m
// MobileTerminal

#import "VT100.h"

#import "VT100Terminal.h"
#import "VT100Screen.h"

// The default width and height are basically thrown away as soon as the text
// view is initialized and determins the right height and width for the
// current font.
static const int kDefaultWidth = 80;
static const int kDefaultHeight = 25;

@implementation VT100

- (id) init
{
  self = [super init];
  if (self != nil) {
    terminal = [[VT100Terminal alloc] init];
    screen = [[VT100Screen alloc] initWithWidth:kDefaultWidth 
                                         height:kDefaultHeight];
  }
  return self;
}

- (void) dealloc
{
  [terminal release];
  [screen release];
  [super dealloc];
}

- (void)handleInputStream:(const char*)data withLength:(unsigned int)length
{
  // Push the input stream into the terminal, then parse the stream back out as
  // a series of tokens and feed them back to the screen
  [terminal putStreamData:data length:length];
  VT100TCC token;
  while((token = [terminal getNextToken]),
        token.type != VT100_WAIT && token.type != VT100CC_NULL) {
    NSLog(@"process token");
    // process token
    if (token.type != VT100_SKIP) {
      if (token.type == VT100_NOTSUPPORT) {
        NSLog(@"%s(%d):not support token", __FILE__ , __LINE__);
      } else {
        [screen putToken:token];
      }
    } else {
      NSLog(@"%s(%d):skip token", __FILE__ , __LINE__);
    }
  }
}

- (void)setScreenSize:(ScreenSize)size {
  [screen resizeWidth:size.width height:size.height];
}

- (ScreenSize)screenSize {
  ScreenSize size;
  size.width = [screen width];
  size.height = [screen height];
  return size;
}

- (screen_char_t*)bufferForRow:(int)row {
  return [screen getLineAtIndex:row];
}

@end
