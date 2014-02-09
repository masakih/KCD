//
//  HMJSONReciever.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CustomHTTPProtocol.h"
#import "HMQueue.h"

@interface HMJSONReciever : NSObject <CustomHTTPProtocolDelegate>

@property (retain) HMQueue *queueu;

@end
