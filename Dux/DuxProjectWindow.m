//
//  DuxProjectWindow.m
//  Dux
//
//  Created by Abhi Beckert on 2012-12-28.
//
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxProjectWindow.h"
#import "MyTextDocument.h"
#import "DuxProjectWindowController.h"
#import "DuxPreferences.h"

#import <objc/runtime.h>

@interface DuxProjectWindow()
// disable some method implementation warnings
- (void)drawRectOriginal:(NSRect)rect;
- (float)roundedCornerRadius;
- (NSWindow*)window;
- (NSRect)_titlebarTitleRect;
@end

@implementation DuxProjectWindow

// disable some compile time warnings for methods that will never exist (part of themeFrameDrawRect:)
- (void)drawRectOriginal:(NSRect)rect { }
- (float)roundedCornerRadius { return 0; }
- (NSWindow*)window { return nil; }
- (NSRect)_titlebarTitleRect { return NSMakeRect(0, 0, 0, 0); }

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
  if ([DuxPreferences editorDarkMode]) {
    aStyle |= NSTexturedBackgroundWindowMask;
  }
  
  if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag]) {
    
    // modify NSThemeFrame to do our custom drawing
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      // get the class definition responsible for drawing window frames (NSThemeFrame)
      id themeFrameClass = [[[self contentView] superview] class];
      
      // add the themeFrameDrawRect: method on self as a method on the themeFrame class, but name it "drawRectOriginal:"
      Method duxProjectWindowDrawRect = class_getInstanceMethod([self class], @selector(themeFrameDrawRect:));
      class_addMethod(themeFrameClass, @selector(drawRectOriginal:), method_getImplementation(duxProjectWindowDrawRect), method_getTypeEncoding(duxProjectWindowDrawRect));
      
      // swap the drawRect: and drawRectOriginal: methods on NSThemeFrame
      Method themeFrameDrawRect = class_getInstanceMethod(themeFrameClass, @selector(drawRect:));
      Method themeFrameDrawRectOriginal = class_getInstanceMethod(themeFrameClass, @selector(drawRectOriginal:));
      method_exchangeImplementations(themeFrameDrawRect, themeFrameDrawRectOriginal);
    });
    
  }
  
  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  if ([DuxPreferences editorDarkMode]) {
    [self.toolbar setShowsBaselineSeparator:NO];
  }
}


/**
 * this method will be copied over the top of [NSThemeFrame drawRect:]. It calls the
 * original theme frame implementation, then checks if the window is a DuxProjectWindow,
 * then draws our own custom stuff.
 */
- (void)themeFrameDrawRect:(NSRect)rect
{
	// Call original drawing method
	[(id)self drawRectOriginal:rect];
  
  // check if this is a DuxProjectWindow. if it's not, bail out now
  if (![[self window] isKindOfClass:[DuxProjectWindow class]])
    return;
  
  
  // are we in dark mode?
  if (![DuxPreferences editorDarkMode])
    return;
  
  // grab gfx context
  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  
  
  
	// Build clipping path : intersection of frame clip (bezier path with rounded corners) and rect argument
	NSRect windowRect = [[(id)self window] frame];
	windowRect.origin = NSMakePoint(0, 0);
  
  NSRect clipRect = NSMakeRect(1, windowRect.size.height - 40, windowRect.size.width - 2, 39);
  
	float cornerRadius = [(id)self roundedCornerRadius];
	[[NSBezierPath bezierPathWithRoundedRect:clipRect xRadius:cornerRadius yRadius:cornerRadius] addClip];
	[[NSBezierPath bezierPathWithRect:rect] addClip];
  

  
  
  // define gradient
  CGFloat colors [] = {
    0.596, 0.643, 0.710, 0.000,
    0.596, 0.643, 0.710, 0.400
  };
  
  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
  CGColorSpaceRelease(baseSpace), baseSpace = NULL;
  
  
  
if ([DuxPreferences editorDarkMode]) {
  // white-out the window title
  CGContextMoveToPoint(context, 1, windowRect.size.height - 3);
  CGContextAddLineToPoint(context, windowRect.size.width - 1, windowRect.size.height - 3);
  CGContextAddLineToPoint(context, windowRect.size.width - 1, windowRect.size.height - 20);
  CGContextAddLineToPoint(context, 1, windowRect.size.height - 20);
  CGContextSetFillColorWithColor(context, self.window.backgroundColor.CGColor);
  CGContextFillPath(context);
}
  
  
  
  // draw gradient
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), self.frame.size.height - 40);
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), self.frame.size.height);
  
if ([DuxPreferences editorDarkMode]) {
  CGContextSetBlendMode(context, kCGBlendModeScreen);
} else {
  CGContextSetBlendMode(context, kCGBlendModeMultiply);
}
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  
  // release gradient
  CGGradientRelease(gradient), gradient = NULL;
  
  
  
  
  // draw a light horizontal line near the top of the window (3D bevel)
  CGContextSetBlendMode(context, kCGBlendModeNormal);
if ([DuxPreferences editorDarkMode]) {
  CGContextSetStrokeColorWithColor(context, [NSColor colorWithCalibratedWhite:1 alpha:0.24].CGColor);
} else {
  CGContextSetStrokeColorWithColor(context, [NSColor colorWithCalibratedWhite:1 alpha:0.34].CGColor);
}
  CGContextSetLineWidth(context, 1.0);
  
  CGContextMoveToPoint(context, 0, windowRect.size.height - 1.5);
  CGContextAddLineToPoint(context, windowRect.size.width, windowRect.size.height - 1.5);
  
  CGContextStrokePath(context);
  
  
  
  // draw title (we wiped it out earlier)
if ([DuxPreferences editorDarkMode]) {
  NSRect titleRect = [self _titlebarTitleRect];
  
  NSDictionary *attrs = @{NSFontAttributeName: [NSFont titleBarFontOfSize:0], NSForegroundColorAttributeName: [NSColor blackColor]};
  [self.title drawInRect:NSMakeRect(titleRect.origin.x, titleRect.origin.y + 1, titleRect.size.width, titleRect.size.height) withAttributes:attrs];
  
  attrs = @{NSFontAttributeName: [NSFont titleBarFontOfSize:0], NSForegroundColorAttributeName: [NSColor lightGrayColor]};
  [self.title drawInRect:titleRect withAttributes:attrs];
}
}

@end
