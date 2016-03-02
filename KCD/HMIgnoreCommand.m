//
//  HMIgnoreCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/09.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMIgnoreCommand.h"

static NSArray *ignoreCommands = nil;

@implementation HMIgnoreCommand

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		ignoreCommands = @[
						   @"/kcsapi/api_dmm_payment/paycheck",
						   @"/kcsapi/api_get_member/furniture",
						   @"/kcsapi/api_get_member/mapcell",
						   @"/kcsapi/api_get_member/mapinfo",
						   @"/kcsapi/api_get_member/mission",
						   @"/kcsapi/api_get_member/payitem",
						   @"/kcsapi/api_get_member/picture_book",
						   @"/kcsapi/api_get_member/practice",
						   @"/kcsapi/api_get_member/preset_deck",
						   @"/kcsapi/api_get_member/record",
						   @"/kcsapi/api_get_member/sortie_conditions",
						   @"/kcsapi/api_get_member/unsetslot",
						   @"/kcsapi/api_get_member/useitem",
						   @"/kcsapi/api_req_furniture/buy",
						   @"/kcsapi/api_req_furniture/change",
						   @"/kcsapi/api_req_furniture/music_list",
						   @"/kcsapi/api_req_furniture/music_play",
						   @"/kcsapi/api_req_furniture/set_portbgm",
						   @"/kcsapi/api_req_hensei/lock",
						   @"/kcsapi/api_req_hensei/preset_delete",
						   @"/kcsapi/api_req_hensei/preset_register",
						   @"/kcsapi/api_req_kaisou/marriage",
						   @"/kcsapi/api_req_kaisou/remodeling",
						   @"/kcsapi/api_req_kaisou/slotset",
						   @"/kcsapi/api_req_kaisou/slotset_ex",
						   @"/kcsapi/api_req_kaisou/unsetslot_all",
						   @"/kcsapi/api_req_kousyou/createship_speedchange",
						   @"/kcsapi/api_req_kousyou/remodel_slotlist",
						   @"/kcsapi/api_req_kousyou/remodel_slotlist_detail",
						   @"/kcsapi/api_req_map/select_eventmap_rank",
						   @"/kcsapi/api_req_member/get_incentive",
						   @"/kcsapi/api_req_member/get_practice_enemyinfo",
						   @"/kcsapi/api_req_member/itemuse",
						   @"/kcsapi/api_req_member/itemuse_cond",
						   @"/kcsapi/api_req_member/payitemuse",
						   @"/kcsapi/api_req_member/registration_sp",
						   @"/kcsapi/api_req_member/updatecomment",
						   @"/kcsapi/api_req_member/updatedeckname",
						   @"/kcsapi/api_req_mission/result",
						   @"/kcsapi/api_req_mission/return_instruction",
						   @"/kcsapi/api_req_mission/start",
						   @"/kcsapi/api_req_practice/battle",
						   @"/kcsapi/api_req_practice/battle_result",
						   @"/kcsapi/api_req_practice/midnight_battle",
						   @"/kcsapi/api_req_quest/start",
						   @"/kcsapi/api_req_quest/stop",
						   @"/kcsapi/api_req_ranking/getlist",
						   ];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [ignoreCommands containsObject:api];
}

- (void)execute
{
	// do nothing
}
@end
