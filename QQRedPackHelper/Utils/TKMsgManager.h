//
//  TKMsgManager.h
//  QQPlugin
//
//  Created by TK on 2018/3/31.
//  Copyright © 2018年 TK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKMsgManager : NSObject

//用于缓存好友列表与群聊ID
+ (instancetype)shareManager;
@property(nonatomic,strong,readonly)NSMutableDictionary *cacheDic;
@property(nonatomic,assign)NSInteger cleanUnknownTime;

+ (void)sendTextMessage:(NSString *)msg uin:(long long)uin sessionType:(int)type;

+ (void)sendMessageWithInfo:(NSDictionary*)messageInfo;

@end
