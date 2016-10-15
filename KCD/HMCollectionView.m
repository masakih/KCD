//
//  HMCollectionView.m
//  CollectionViewTest
//
//  Created by Hori,Masaki on 2016/10/10.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMCollectionView.h"

#import "HMScreenshotCollectionViewItem.h"
#import <Quartz/Quartz.h>

@interface HMCollectionView () <QLPreviewPanelDataSource, QLPreviewPanelDelegate>

@end

@implementation HMCollectionView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self) {
        [self addObserver:self
               forKeyPath:@"selectionIndexPaths"
                  options:0
                  context:nil];
    }
    return self;
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectionIndexPaths"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if( object == self ) {
        if([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
            id panel = [QLPreviewPanel sharedPreviewPanel];
            [panel performSelector:@selector(reloadData)
                        withObject:nil
                        afterDelay:0.0];
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

//
- (void)rightMouseDown:(NSEvent *)event
{
    if(!self.menu) return;
    
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if(!indexPath) return;
    
    NSCollectionViewItem *item = [self itemAtIndexPath:indexPath];
    if(!item) return;
    
    if(![self.selectionIndexPaths containsObject:indexPath]) {
        [self deselectAll:nil];
        self.selectionIndexPaths = [NSSet setWithObject:indexPath];
    }
    
    [NSMenu popUpContextMenu:self.menu withEvent:event forView:self];
}
- (void)keyDown:(NSEvent *)event
{
    NSString *key = event.charactersIgnoringModifiers;
    if([key isEqualToString:@" "]) {
        [self quickLookWithEvent:event];
        
        return;
    }
    // 左右矢印キーの時の動作
    const NSUInteger leftArrow = 123;
    const NSUInteger rightArrow = 124;
    if(event.keyCode == leftArrow || event.keyCode == rightArrow) {
        NSSet *se = self.selectionIndexPaths;
        if(se.count == 0) return;
        NSIndexPath *indexPath = se.allObjects[0];
        NSInteger index = indexPath.item;
        
        if(event.keyCode == leftArrow) {
            if(index == 0) return;
            index -= 1;
        } else {
            NSUInteger count = self.content.count;
            if(index == count - 1) return;
            index += 1;
        }
        
        NSRect frame = [self frameForItemAtIndex:index];
        [self scrollRectToVisible:frame];
        
        NSUInteger i[] = { 0, index };
        NSIndexPath *newIndexPath = [NSIndexPath indexPathWithIndexes:i length:2];
        self.selectionIndexPaths = [NSSet setWithObject:newIndexPath];
        
        return;
    }
    
    [super keyDown:event];
}

- (void)quickLookWithEvent:(NSEvent *)event
{
    [self quickLookPreviewItems:nil];
}

- (void)quickLookPreviewItems:(nullable id)sender
{
    if([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}

//
- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
    return YES;
}
- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    panel.dataSource = self;
    panel.delegate = self;
}
- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    panel.dataSource = nil;
    panel.delegate = nil;
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return self.selectionIndexPaths.count;
}
- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    HMScreenshotCollectionViewItem *item = (HMScreenshotCollectionViewItem *)[self itemAtIndexPath:self.selectionIndexPaths.allObjects[index]];
    return item;
}

//
- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    if(event.type == NSKeyDown) {
        [self keyDown:event];
        return YES;
    }
    return NO;
}
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)aItem
{
    HMScreenshotCollectionViewItem *item = (HMScreenshotCollectionViewItem *)aItem;
    NSRect frame = [self convertRect:item.imageFrame fromView:item.view];
    frame = [self convertRect:frame toView:nil];
    return [self.window convertRectToScreen:frame];
    
}
@end
