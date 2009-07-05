// VT100Types.h
// MobileTerminal
//
// This header file contains types that are used by both the low level VT100
// components and the higher level text view components so they both do not
// have to depend on each other.

typedef struct screen_char_t {
    unichar ch;  // the actual character
    unsigned int bg_color;  // background color
    unsigned int fg_color;  // foreground color
} screen_char_t;

typedef struct {
  int width;
  int height;
} ScreenSize;

// The protocol for 
@protocol ScreenBuffer
@required
- (void)setScreenSize:(ScreenSize)size;
- (ScreenSize)screenSize;
- (screen_char_t*)bufferForRow:(int)row;
@end

// A thin protocol for implementing a delegate interface with a single method
// that is invoked when the screen needs to be refreshed because at least some
// portion has become invalidated.
@protocol ScreenBufferRefreshDelegate
@required
- (void)updateIfNecessary;
@end