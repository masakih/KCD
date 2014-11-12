//
//  HMScreenshotListWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/11/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class HMMaskSelectView;

@interface HMScreenshotListWindowController : NSWindowController


- (IBAction)reloadData:(id)sender;

- (void)reloadData;
- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect;


// Tweet
@property (strong, nonatomic) NSString *tweetString;
/// 残り文字数
@property (readonly) NSInteger leaveLength;
@property (readonly) NSColor *leaveLengthColor;
@property (readonly) BOOL canTweet;
@property BOOL appendKanColleTag;
@property (copy, nonatomic) NSString *tagString;

@property (strong, nonatomic) IBOutlet HMMaskSelectView *maskSelectView;
@property BOOL useMask;

- (IBAction)tweet:(id)sender;

@end
