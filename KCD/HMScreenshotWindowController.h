//
//  HMScreenshotWindowController.h
//  KCD
//
//  Created by Hori,Masaki on 2014/04/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMScreenshotWindowController : NSWindowController

@property (strong, nonatomic) NSBitmapImageRep *snapImageRep;
@property (strong, nonatomic) NSData *snapData;
@property (readonly) NSImage *snap;
@property (strong, nonatomic) NSString *tweetString;
/// 残り文字数
@property (readonly) NSInteger leaveLength;
@property (readonly) NSColor *leaveLengthColor;
@property (readonly) BOOL canTweet;
@property (readonly) BOOL canSave;
@property BOOL appendKanColleTag;
@property (copy, nonatomic) NSString *tagString;

- (IBAction)tweet:(id)sender;
- (IBAction)saveSnap:(id)sender;
- (IBAction)cancel:(id)sender;

@end
