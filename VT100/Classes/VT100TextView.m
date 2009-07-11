// VT100TextView.m
// VT100

#import "VT100TextView.h"
#import "VT100.h"

extern void CGFontGetGlyphsForUnichars(CGFontRef, unichar[], CGGlyph[], size_t);

@interface VT100TextView (RefreshDelegate) <ScreenBufferRefreshDelegate>
- (void)refresh;
@end

@implementation VT100TextView

@synthesize buffer;
@synthesize resizeDelegate;

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super initWithCoder:decoder];
  if (self != nil) {
    VT100* vt100 = [[VT100 alloc] init];
    [vt100 setRefreshDelegate:self];
    self.buffer = vt100;
    [self setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
  }
  return self;
}

- (void)dealloc
{
  CFRelease(cgFont);
  [buffer release];
  [font release];
  [super dealloc];
}

- (void)setFont:(UIFont*)newFont;
{
  // Release the old font, if it exists (this is a no-op otherwise)
  CGFontRelease(cgFont);
  [font release];
  
  // Retain the new font, and cache some of its properties that are expensive
  // to look up every time we draw.
  font = newFont;
  [font retain];  
  cgFont = CGFontCreateWithFontName((CFStringRef)font.fontName);
  NSAssert(font != NULL, @"Error CGFontCreateWithFontName");
  
  // This assumes a monospaced font, which is probably not a safe assumption.
  // Determine size of the screen based on the font size
  fontSize = [@"A" sizeWithFont:font];
  CGSize frameSize = [self frame].size;
  ScreenSize size;
  size.width = (int)(frameSize.width / fontSize.width);
  size.height = (int)(frameSize.height / fontSize.height);
  [buffer setScreenSize:size];
  
  // Notify the delegate that the size of the screen has changed
  [resizeDelegate screenResizedToWidth:size.width height:size.height];
}

// TODO(allen): This is by no means complete! The old PTYTextView does a lot
// more stuff that needs to be ported -- and it also does it quite efficiently.
- (void)drawRect:(CGRect)rect
{
  NSLog(@"(%f, %f) -> (%f, %f)", rect.origin.x, rect.origin.y,
        rect.size.width, rect.size.height);
  NSAssert(font != NULL, @"No font specified");
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFont(context, cgFont);
  CGContextSetFontSize(context, font.pointSize);
  
  // By default, text is drawn upside down.  Apply a transformation to turn
  // orient the text correctly.
  CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
  CGContextSetTextMatrix(context, xform);
  
  // TODO(allen): This writes all characters using the same color instead of
  // the color attached to the screen_char_t.
  CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.8f);
  
  // Walk through the screen and output all characeters to the display
  ScreenSize screenSize = [buffer screenSize];  
  unichar* characters = (unichar*)malloc(sizeof(unichar) * screenSize.width);
  CGGlyph* glyphs = (CGGlyph*)malloc(sizeof(CGGlyph) * screenSize.width);
  for (int i = 0; i < screenSize.height; ++i) {
    screen_char_t* row = [buffer bufferForRow:i];
    // Pull out the unicode characters, drop the colors for now
    int j;
    for (j = 0; j < screenSize.width && row[j].ch != '\0'; ++j) {
      characters[j] = row[j].ch;
    }
    if (j == 0) {
      continue;
    }
    CGFontGetGlyphsForUnichars(cgFont, characters, glyphs, j);
    CGFloat y = font.pointSize * (i + 1);
    CGContextShowGlyphsAtPoint(context, 0, y, glyphs, j);
  }
}

- (void)readInputStream:(NSData*)data;
{
  // Simply forward the input stream down the VT100 processor.  When it notices
  // changes to the screen, it should invoke our refresh delegate below.
  // TODO(aporter): The ScreenBuffer interface should just deal with NSData
  // directly.
  [buffer readInputStream:(const char*)[data bytes] withLength:[data length]];
}

@end

@implementation VT100TextView (RefreshDelegate)

- (void)refresh
{
  // TODO(aporter): Call setNeedsDisplayInRect for only the dirty bits
  [self setNeedsDisplay];
}

@end
