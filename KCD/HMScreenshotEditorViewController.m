//
//  HMScreenshotEditorViewController.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/04/06.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotEditorViewController.h"

#import "HMScreenshotInformation.h"

#import "HMTiledImageView.h"


#import "HMUserDefaults.h"


#pragma mark - HMEditedImage class
@interface HMEditedImage : NSObject
@property (strong) NSImage *editedImage;
@property (copy) NSString *path;
@end

@implementation HMEditedImage
@end

#pragma mark - HMTrimRectInformation
@interface HMTrimRectInformation : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSRect rect;
@end

@implementation HMTrimRectInformation
@end

#pragma mark - HMScreenshotEditorViewController
@interface HMScreenshotEditorViewController ()

@property (strong) NSImage *editedImage;

@property (nonatomic, weak) IBOutlet HMTiledImageView *tiledImageView;

@property (strong) NSArray<HMScreenshotInformation *> *currentSelection;
@property (strong) NSMutableArray<HMEditedImage *> *editedImages;


@property (nonatomic) NSInteger columnCount;

@property (nonatomic, copy) NSArray<HMTrimRectInformation *> *trimInfo;
@property (nonatomic, weak) HMTrimRectInformation *currentTrimInfo;

@property (nonatomic) NSUInteger currentTrimInfoIndex;

@end

@implementation HMScreenshotEditorViewController


- (void)viewDidLoad
{
	NSMutableArray<HMTrimRectInformation *> *trimInfos = [NSMutableArray array];
	
	HMTrimRectInformation *trimInfo = [HMTrimRectInformation new];
	trimInfo.name = @"Status";
	trimInfo.rect = NSMakeRect(328, 13, 470, 365);
	[trimInfos addObject:trimInfo];
	
	trimInfo = [HMTrimRectInformation new];
	trimInfo.name = @"List";
	trimInfo.rect = NSMakeRect(362, 15, 438, 368);
	[trimInfos addObject:trimInfo];
	
	trimInfo = [HMTrimRectInformation new];
	trimInfo.name = @"AirplaneBase";
	trimInfo.rect = NSMakeRect(575, 13, 225, 358 );
	[trimInfos addObject:trimInfo];
	
	self.trimInfo = trimInfos;
	
	self.currentTrimInfoIndex = HMStandardDefaults.scrennshotEditorType;
	
	self.columnCount = HMStandardDefaults.screenshotEditorColumnCount;
	
	[super viewDidLoad];
	
	self.editedImages = [NSMutableArray array];
	
	[self.arrayController addObserver:self
						   forKeyPath:NSSelectionIndexesBinding
							  options:0
							  context:NULL];
	
	[self updateSelections];
}
-(void)dealloc
{
	[self.arrayController removeObserver:self forKeyPath:NSSelectionIndexesBinding];
}

- (void)setColumnCount:(NSInteger)columnCount
{
	self.tiledImageView.columnCount = columnCount;
	HMStandardDefaults.screenshotEditorColumnCount = columnCount;
}
- (NSInteger)columnCount
{
	return self.tiledImageView.columnCount;
}

- (void)setCurrentTrimInfo:(HMTrimRectInformation *)currentTrimInfo
{
	_currentTrimInfo = currentTrimInfo;
	self.trimRect = currentTrimInfo.rect;
	
	HMStandardDefaults.scrennshotEditorType = [self.trimInfo indexOfObject:currentTrimInfo];
}

- (void)setTrimRect:(NSRect)trimRect
{
	_trimRect = trimRect;
	[self makeEditedImage];
}

- (void)setCurrentTrimInfoIndex:(NSUInteger)currentTrimInfoIndex
{
	if(self.trimInfo.count < currentTrimInfoIndex) return;
	
	_currentTrimInfoIndex = currentTrimInfoIndex;
	self.currentTrimInfo = self.trimInfo[currentTrimInfoIndex];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:NSSelectionIndexesBinding]) {
		[self updateSelections];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)updateSelections
{
	NSArray *selection = [self.arrayController selectedObjects];
	if([self.currentSelection isEqual:selection]) {
		return;
	}
	
	NSMutableArray<HMScreenshotInformation *> *removed = [NSMutableArray array];
	NSMutableArray<HMScreenshotInformation *> *appended = [NSMutableArray array];
	
	for(HMScreenshotInformation *object in self.currentSelection) {
		if(![selection containsObject:object]) {
			[removed addObject:object];
		}
	}
	for(HMScreenshotInformation *object in selection) {
		if(![self.currentSelection containsObject:object]) {
			[appended addObject:object];
		}
	}
	
	for(HMScreenshotInformation *object in removed) {
		[self removeEditedImageWithPath:object.path];
	}
	for(HMScreenshotInformation *object in appended) {
		[self appendEditedImageOfPath:object.path];
	}
	
	self.currentSelection = selection;
	
	[self makeEditedImage];
}

- (NSUInteger)indexOfEditedImageWithPath:(NSString *)path
{
	NSUInteger index = [self.editedImages indexOfObjectPassingTest:^BOOL(HMEditedImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if([obj.path isEqualToString:path]) {
			*stop = YES;
			return YES;
		}
		return NO;
	}];
	return index;
}
- (void)removeEditedImageWithPath:(NSString *)path
{
	NSUInteger index = [self indexOfEditedImageWithPath:path];
	if(index != NSNotFound) {
		[self.editedImages removeObjectAtIndex:index];
	}
}
- (void)appendEditedImageOfPath:(NSString *)path
{
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
//	HMEditedImage *editedImage = [self editedImageWithImage:image];
	HMEditedImage *editedImage = [HMEditedImage new];
	editedImage.editedImage = image;
	editedImage.path = path;
	if(editedImage) {
		[self appendEditedImage:editedImage];
	}
}
- (void)appendEditedImage:(HMEditedImage *)editedImage
{
	[self.editedImages addObject:editedImage];
}

- (HMEditedImage *)editedImageWithImage:(NSImage *)image
{
	return nil;
}

- (void)makeEditedImage
{
	if(self.editedImages.count == 0) {
		self.tiledImageView.images = nil;
	}
	
	// 切り抜き位置とサイズ
	NSPoint origin = self.trimRect.origin;
	NSSize size = self.trimRect.size;
	
	dispatch_queue_t queue = dispatch_queue_create("makeTrimedImage queue", DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		NSMutableArray<NSImage *> *images = [NSMutableArray array];
		
		// 画像の切り取り
		[self.editedImages enumerateObjectsUsingBlock:^(HMEditedImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSImage *trimedImage = [[NSImage alloc] initWithSize:NSMakeSize(size.width, size.height)];
			NSImage *originalImage = [[NSImage alloc] initWithContentsOfFile:obj.path];
			if(!originalImage) return;
			[trimedImage lockFocus];
			{
				[originalImage drawAtPoint:NSMakePoint(0.0, 0.0)
								  fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height)
								 operation:NSCompositeCopy
								  fraction:1.0];
			}
			[trimedImage unlockFocus];
			
			[images addObject:trimedImage];
		}];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.tiledImageView.images = images;
		});
	});
	
}

- (NSImage *)image
{
	return self.tiledImageView.image;
}

- (IBAction)done:(id)sender
{
	if([sender respondsToSelector:@selector(setAction:)]) {
		[sender setAction:nil];
	}
	
	[NSApp sendAction:@selector(registerImage:) to:nil from:self];
	
	[self performSegueWithIdentifier:@"right" sender:self];
}
@end
