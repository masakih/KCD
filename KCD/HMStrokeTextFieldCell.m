//
//  HMStrokeTextFieldCell.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/19.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMStrokeTextFieldCell.h"

const CGFloat boarderWidth = 2.0;

@interface HMStrokeTextFieldCell ()
@property (strong, nonatomic) NSLayoutManager *layoutManager;
@property (strong, nonatomic) NSTextContainer *textContainer;
@end

@implementation HMStrokeTextFieldCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self) {
		_layoutManager = [NSLayoutManager new];
		_textContainer = [NSTextContainer new];
		[self.layoutManager addTextContainer:self.textContainer];
	}
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSAttributedString *attributedString = self.attributedStringValue;
	NSDictionary *attribute = [attributedString attributesAtIndex:0 effectiveRange:NULL];
	NSColor *forgroundColor = [attribute objectForKey:NSForegroundColorAttributeName];
	if(!forgroundColor) return;
	if([forgroundColor isEqual:[NSColor controlTextColor]]) {
		[super drawInteriorWithFrame:cellFrame inView:controlView];
		return;
	}

	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:attributedString.string attributes:attribute];
	[textStorage addLayoutManager:self.layoutManager];
	
	NSRange range = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
	CGGlyph glyph[range.length];
	NSUInteger glyphLength = [self.layoutManager getGlyphsInRange:range
														   glyphs:glyph
													   properties:NULL
												 characterIndexes:NULL
													   bidiLevels:NULL];
	
	NSFont *font = [attribute objectForKey:NSFontAttributeName];
	NSPoint point = {boarderWidth,0};
	point.y -= [font descender];
	if([controlView isFlipped]) {
		point.y -= [controlView frame].size.height;
	}
	
	NSGlyph nsGlyph[range.length];
	for(int i = 0; i < range.length; i++) {
		nsGlyph[i] = glyph[i];
	}
	
	NSBezierPath *path = [NSBezierPath new];
	[path moveToPoint:point];
	[path appendBezierPathWithGlyphs:nsGlyph count:glyphLength inFont:font];
	[path setLineWidth:boarderWidth];
	[path setLineJoinStyle:NSRoundLineJoinStyle];
	if([controlView isFlipped]) {
		NSAffineTransform *affineTransform = [NSAffineTransform transform];
		[affineTransform scaleXBy:1 yBy:-1];
		[path transformUsingAffineTransform:affineTransform];
	}
	
	[[NSColor blackColor] set];
	[path stroke];
	
	[forgroundColor set];
	[path fill];
	
}
@end
