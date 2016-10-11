//
//  HMScreenshotCollectionViewItem.m
//  CollectionViewTest
//
//  Created by Hori,Masaki on 2016/10/09.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotCollectionViewItem.h"

#import "HMScreenshotInformation.h"

@interface HMScreenshotCollectionViewItem ()

@property (weak, nonatomic) IBOutlet NSBox *imageBox;
@property (weak, nonatomic) IBOutlet NSTextField *nameField;
@property (weak, nonatomic) IBOutlet NSBox *nameBox;

@property (readonly) HMScreenshotInformation *info;
@end

@implementation HMScreenshotCollectionViewItem
- (void)setSelected:(BOOL)selected
{
    super.selected = selected;
    
    NSColor *imageBoxColor = [NSColor whiteColor];
    NSColor *textColor = [NSColor blackColor];
    NSColor *nameBoxColor = [NSColor whiteColor];
    if(selected) {
        imageBoxColor = [NSColor controlHighlightColor];
        textColor = [NSColor whiteColor];
        nameBoxColor = [NSColor alternateSelectedControlColor];
    }
    self.imageBox.fillColor = imageBoxColor;
    self.nameField.textColor = textColor;
    self.nameBox.fillColor = nameBoxColor;
}

- (HMScreenshotInformation *)info
{
    return self.representedObject;
}

- (NSURL *)previewItemURL
{
    return [NSURL fileURLWithPath:self.info.path];
}


NSRect centerFitRect(NSImage *image, NSRect targetRect)
{
    NSSize imageSize = [image size];
    
    CGFloat ratio = 1;
    CGFloat ratioX, ratioY;
    
    ratioX = targetRect.size.height / imageSize.height;
    ratioY = targetRect.size.width / imageSize.width;
    if(ratioX > ratioY) {
        ratio = ratioY;
    } else {
        ratio = ratioX;
    }
    
    NSSize fitSize = NSMakeSize(imageSize.width * ratio, imageSize.height * ratio);
    CGFloat left = (targetRect.size.width - fitSize.width) * 0.5;
    CGFloat bottom = (targetRect.size.height - fitSize.height) * 0.5;
    return NSMakeRect(left, bottom, fitSize.width, fitSize.height);
}
- (NSRect)imageFrame
{
    NSRect frame = centerFitRect(self.imageView.image, self.imageView.frame);
    return [self.view convertRect:frame fromView:self.imageBox];
}
@end
