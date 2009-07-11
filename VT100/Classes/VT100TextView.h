// VT100TextView.h
// MobileTeterminal
//
// A UI component for rendering a VT100 display in a view.  The VT100TextView
// can be fed VT100 character stream data in chunks which is then rendered.

#import <UIKit/UIKit.h>

@class ColorMap;
@class VT100;
@protocol ScreenBuffer;
@protocol RefreshDelegate;

// Callers can implement this protocol to get notified about possible changes
// to the screen width and height.  This can be invoked, for example, when the
// font changes.
// TODO(aporter): It might be simpler for the caller to set the font, then read
// the new height and width of the text view.
@protocol VT100ResizeDelegate
@required
- (void)screenResizedToWidth:(int)width height:(int)height;
@end

@interface VT100TextView : UIView {
@private
  id <ScreenBuffer> buffer;
  id <VT100ResizeDelegate> resizeDelegate;
  UIFont* font;
  CGSize fontSize;
  CGFontRef cgFont;
  
  ColorMap* colorMap;
  
  // Buffer for rows
  unichar* characterBuffer;
  CGGlyph* glyphBuffer;
}

@property (nonatomic, retain) IBOutlet id <ScreenBuffer> buffer;
@property (nonatomic, retain) IBOutlet id <VT100ResizeDelegate> resizeDelegate;
@property (nonatomic, retain) IBOutlet ColorMap* colorMap;


- (void)setFont:(UIFont*)font;

// Process an input stream of data
- (void)readInputStream:(NSData*)data;

@end
