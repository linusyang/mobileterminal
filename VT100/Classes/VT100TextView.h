// VT100TextView.h
// MobileTeterminal
//
// A UI component for rendering a VT100 display in a view.  The VT100TextView
// can be fed VT100 character stream data in chunks which is then rendered.

#import <UIKit/UIKit.h>

@class VT100;
@protocol ScreenBuffer;
@protocol RefreshDelegate;

@interface VT100TextView : UIView {
@private
  id <ScreenBuffer> buffer;
  UIFont* font;
  CGSize fontSize;
  CGFontRef cgFont;
}

@property (nonatomic, retain) IBOutlet id <ScreenBuffer> buffer;

- (void)setFont:(UIFont*)font;

// Process an input stream of data
- (void)readInputStream:(const char*)data withLength:(unsigned int)length;

@end
