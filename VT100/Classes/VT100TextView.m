// VT100TextView.m
// VT100

#import "VT100TextView.h"
#import "VT100.h"

extern void CGFontGetGlyphsForUnichars(CGFontRef, unichar[], CGGlyph[], size_t);

@implementation VT100TextView

@synthesize buffer;
@synthesize font;

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super initWithCoder:decoder];
  if (self != nil) {
    buffer = [[VT100 alloc] init];
    font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
  }
  return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)awakeFromNib
{
  CGFloat fontHeight = [font pointSize];
  CGSize frameSize = [self frame].size;
  ScreenSize size;
  size.width = frameSize.height / fontHeight;
  size.height = 80;
  [buffer setScreenSize:size];
  
  NSLog(@"ScreenView: (%d, %d)", size.width, size.height);
}

// TODO(allen): This is by no means complete! The old PTYTextView does a lot
// more stuff that needs to be ported -- and it also does it quite efficiently.
- (void)drawRect:(CGRect)rect
{
  NSLog(@"ScreenView draw rect: %f, %f -> %f, %f",
        rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  
  CGContextRef context = UIGraphicsGetCurrentContext();  
  const char* fontName =
  [font.fontName cStringUsingEncoding:NSMacOSRomanStringEncoding];
  CGContextSelectFont(context, fontName,font.pointSize, kCGEncodingMacRoman);
  CGContextSetCharacterSpacing(context, 0.0f);
  CGContextSetTextDrawingMode(context, kCGTextFill);
  
  // By default, text is drawn upside down.  Apply a transformation to turn
  // orient the text correctly.
  CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
  CGContextSetTextMatrix(context, xform);
  
  // TODO(allen): This writes all characters using the same color instead of
  // the color attached to the screen_char_t.
  CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.8f);
  
  // Walk through the screen and output all characeters to the display
  ScreenSize screenSize = [buffer screenSize];  
  char* characters = (char*)malloc(sizeof(char) * screenSize.width);
  
  // TODO(allen): This currently draws the entire screen.  Instead, just draw
  // the parts that are dirty.
  for (int i = 0; i < screenSize.height; ++i) {
    screen_char_t* row = [buffer bufferForRow:i];
    // Pull out the unicode characters, drop the colors for now
    int j;
    for (j = 0; j < screenSize.width && row[j].ch != '\0'; ++j) {
      characters[j] = row[j].ch;
    }
    CGContextShowTextAtPoint(context, 0, font.pointSize * (i + 1), characters,
                             j); 
  }
}

- (void)handleInputStream:(const char*)data withLength:(unsigned int)length {
  // Simply forward the input stream down the VT100 processor.
  // TODO(allen): Setup the refresh delegate
  [buffer handleInputStream:data withLength:length]; 
}

@end
