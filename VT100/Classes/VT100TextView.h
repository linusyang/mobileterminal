// VT100TextView.h
// MobileTeterminal
//
// A UI component for rendering a VT100 display in a view.  The VT100TextView
// can be fed VT100 character stream data in chunks which is then rendered.

#import <UIKit/UIKit.h>

@class VT100;

@interface VT100TextView : UIView {
@private
  VT100* buffer;
  UIFont* font;
}

@property (nonatomic, retain) IBOutlet VT100* buffer;
@property (nonatomic, retain) IBOutlet UIFont *font;

- (void)handleInputStream:(const char*)data withLength:(unsigned int)length;

@end
