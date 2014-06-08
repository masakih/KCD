//
//  HMKCShipObject+Extensions.h
//  KCD
//
//  Created by Hori,Masaki on 2014/06/08.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKCShipObject.h"

@interface HMKCShipObject (Extensions)

@property (readonly) NSString *name;
@property (readonly) NSString *shortTypeName;


@property (readonly) NSColor *statusColor;
@property (readonly) NSColor *conditionColor;



@property (nonatomic, retain) NSNumber * primitiveBull;
@property (nonatomic, retain) NSNumber * primitiveCond;
@property (nonatomic, retain) NSNumber * primitiveExp;
@property (nonatomic, retain) NSNumber * primitiveFuel;
@property (nonatomic, retain) NSNumber * primitiveId;
@property (nonatomic, retain) NSNumber * primitiveKaihi_0;
@property (nonatomic, retain) NSNumber * primitiveKaihi_1;
@property (nonatomic, retain) NSNumber * primitiveKaryoku_0;
@property (nonatomic, retain) NSNumber * primitiveKaryoku_1;
@property (nonatomic, retain) NSNumber * primitiveKyouka_0;
@property (nonatomic, retain) NSNumber * primitiveKyouka_1;
@property (nonatomic, retain) NSNumber * primitiveKyouka_2;
@property (nonatomic, retain) NSNumber * primitiveKyouka_3;
@property (nonatomic, retain) NSNumber * primitiveKyouka_4;
@property (nonatomic, retain) NSNumber * primitiveLocked;
@property (nonatomic, retain) NSNumber * primitiveLucky_0;
@property (nonatomic, retain) NSNumber * primitiveLucky_1;
@property (nonatomic, retain) NSNumber * primitiveLv;
@property (nonatomic, retain) NSNumber * primitiveMaxhp;
@property (nonatomic, retain) NSNumber * primitiveNdock_time;
@property (nonatomic, retain) NSNumber * primitiveNowhp;
@property (nonatomic, retain) NSNumber * primitiveOnslot_0;
@property (nonatomic, retain) NSNumber * primitiveOnslot_1;
@property (nonatomic, retain) NSNumber * primitiveOnslot_2;
@property (nonatomic, retain) NSNumber * primitiveOnslot_3;
@property (nonatomic, retain) NSNumber * primitiveOnslot_4;
@property (nonatomic, retain) NSNumber * primitiveRaisou_0;
@property (nonatomic, retain) NSNumber * primitiveRaisou_1;
@property (nonatomic, retain) NSNumber * primitiveSakuteki_0;
@property (nonatomic, retain) NSNumber * primitiveSakuteki_1;
@property (nonatomic, retain) NSNumber * primitiveShip_id;
@property (nonatomic, retain) NSNumber * primitiveSlot_0;
@property (nonatomic, retain) NSNumber * primitiveSlot_1;
@property (nonatomic, retain) NSNumber * primitiveSlot_2;
@property (nonatomic, retain) NSNumber * primitiveSlot_3;
@property (nonatomic, retain) NSNumber * primitiveSlot_4;
@property (nonatomic, retain) NSNumber * primitiveSortno;
@property (nonatomic, retain) NSNumber * primitiveSoukou_0;
@property (nonatomic, retain) NSNumber * primitiveSoukou_1;
@property (nonatomic, retain) NSNumber * primitiveSrate;
@property (nonatomic, retain) NSNumber * primitiveTaiku_0;
@property (nonatomic, retain) NSNumber * primitiveTaiku_1;
@property (nonatomic, retain) NSNumber * primitiveTaisen_0;
@property (nonatomic, retain) NSNumber * primitiveTaisen_1;
@property (nonatomic, retain) NSNumber * primitiveUse_bull;
@property (nonatomic, retain) NSNumber * primitiveUse_fuel;

@property (nonatomic, strong) NSManagedObject *primitiveMaster_ship;


@end
