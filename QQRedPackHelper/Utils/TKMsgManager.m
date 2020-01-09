//
//  TKMsgManager.m
//  QQPlugin
//
//  Created by TK on 2018/3/31.
//  Copyright © 2018年 TK. All rights reserved.
//

#import "TKMsgManager.h"
#import "QQPlugin.h"
#import "TKWebServerManager.h"

@interface TKMsgManager(){
    NSInteger cleanUnknownTime;
}
@property(nonatomic,strong)NSMutableDictionary *cacheDic;
@end

@implementation TKMsgManager

+ (instancetype)shareManager{
    static TKMsgManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TKMsgManager alloc] init];
        
    });
    return manager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _cacheDic = [[NSMutableDictionary alloc]init];
        _cacheDic[@"buddy"] = [[NSMutableArray alloc]init];
        _cacheDic[@"group"] = [[NSMutableArray alloc]init];
        _cacheDic[@"unknown"] = [[NSMutableArray alloc]init];
        NSDate *datenow = [NSDate date];
        _cleanUnknownTime =  [datenow timeIntervalSince1970];
    }
    return self;
}

+ (void)sendTextMessage:(NSString *)msg uin:(long long)uin sessionType:(int)type {
    BHCompoundMessagePacket *packet =  [[objc_getClass("BHCompoundMessagePacket") alloc] initWithMessageType:1024];
    [packet setValue:@[@{@"msg-type":@(0), @"text":msg}] forKey:@"array"];
    struct _BHMessageSession session = {0,0,0,0};
    session._field1 = type;
    switch (type) {
        case 1:
            session._field2 = uin;
            break;
        case 101:
            session._field3 = uin;
            break;
        case 201:
            session._field4 = uin;
            break;
        default:
            break;
    }
    BHMsgManager *manager = [objc_getClass("BHMsgManager") sharedInstance];
    packet.fontInfo  = [manager defaultFontInfo];
    [manager sendMessagePacket:packet target:session completion:nil ProgressBlock:nil];
}


+ (void)sendMessageWithInfo:(NSDictionary *)messageInfo{
    //发送的ID
    NSString *toUserID = messageInfo[@"toUserID"]?:messageInfo[@"groupCode"];
    if (!toUserID) {
        return;
    }
    NSMutableArray *buddyArray = [[TKMsgManager shareManager]cacheDic][@"buddy"];
    NSMutableArray *groupArray = [[TKMsgManager shareManager]cacheDic][@"group"];
    NSMutableArray *unKnownArray = [[TKMsgManager shareManager]cacheDic][@"unknown"];
    if ([unKnownArray containsObject:toUserID]) {
        //列表中不包括这个人/号码
        NSDate *datenow = [NSDate date];
        NSInteger currentTime =  [datenow timeIntervalSince1970];
        if (currentTime - [TKMsgManager shareManager].cleanUnknownTime > 1800) {
            [unKnownArray removeAllObjects];
            [TKMsgManager shareManager].cleanUnknownTime = currentTime;
        }
        return;
    }
    BOOL canSendMessage = NO;
    BOOL isGroupChat = NO;
    if (messageInfo[@"groupCode"] && ((NSString*)messageInfo[@"groupCode"]).length > 0) {
        //群或讨论组
        if (![groupArray containsObject:toUserID]) {
            //都不包含Code,寻找服务器
            ContactSearcherInter *inter = [[objc_getClass("ContactSearcherInter") alloc] init];
            if ([inter respondsToSelector:@selector(Query:)]) {
                [inter Query:toUserID];
            }else if ([inter respondsToSelector:@selector(Query:completion:)]){
                void(^queryBlock)(void) = ^{
//                    NSLog(@"queryBlock");
                };
                [inter Query:toUserID completion:queryBlock];
            }
            NSMutableArray *sessionList = [NSMutableArray array];
            NSMutableArray *tempDiscusses = [NSMutableArray arrayWithArray:inter.searchedDiscusses];
            NSMutableArray *tempSearchedGroups = [NSMutableArray arrayWithArray:inter.searchedGroups];
            [tempDiscusses enumerateObjectsUsingBlock:^(Discuss * _Nonnull discuss, NSUInteger idx, BOOL * _Nonnull stop) {
                [sessionList addObject:[[TKWebServerManager shareManager] dictFromDiscussSearchResult:discuss searcherInter:inter]];
            }];
            
            [tempSearchedGroups enumerateObjectsUsingBlock:^(Group * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
                [sessionList addObject:[[TKWebServerManager shareManager] dictFromGroupSearchResult:group]];
            }];
            if (sessionList.count) {
                //找到
                canSendMessage = YES;
                [groupArray addObject:toUserID];
                isGroupChat = YES;
            }else{
                [unKnownArray addObject:toUserID];
            }
        }else{
            canSendMessage = YES;
            isGroupChat = YES;
        }
        
    }else{
        //个人
        if (![buddyArray containsObject:toUserID]) {
            ContactSearcherInter *inter = [[objc_getClass("ContactSearcherInter") alloc] init];
                if ([inter respondsToSelector:@selector(Query:)]) {
                    [inter Query:toUserID];
                }else if ([inter respondsToSelector:@selector(Query:completion:)]){
                    void(^queryBlock)(void) = ^{
//                        NSLog(@"queryBlock");
                    };
                    [inter Query:toUserID completion:queryBlock];
                }
                NSMutableArray *sessionList = [NSMutableArray array];
                NSMutableArray *tempSearchedBuddys = [NSMutableArray arrayWithArray:inter.searchedBuddys];
                [tempSearchedBuddys enumerateObjectsUsingBlock:^(Buddy * _Nonnull buddy, NSUInteger idx, BOOL * _Nonnull stop) {
                    [sessionList addObject:[[TKWebServerManager shareManager]  dictFromBuddySearchResult:buddy]];
                }];
            if (sessionList.count) {
                //找到
                canSendMessage = YES;
                [buddyArray addObject:toUserID];
            }else{
                [unKnownArray addObject:toUserID];
            }
        }else{
            canSendMessage = YES;
        }
    }

    
    if (canSendMessage) {
    //发送群消息
    BHCompoundMessagePacket *packet =  [[objc_getClass("BHCompoundMessagePacket") alloc] initWithMessageType:1024];
    struct _BHMessageSession session = {0,0,0,0};
    if (isGroupChat) {
        session._field1 = 101;
        session._field3 = [((NSString*)messageInfo[@"groupCode"]) integerValue];
    }else{
        session._field1 = 1;
        session._field2 = [((NSString*)messageInfo[@"toUserID"]) integerValue];
    }

    NSMutableArray *messageArray = [[NSMutableArray alloc]init];
    for (NSDictionary *message in messageInfo[@"messages"]) {
        if (message[@"file-path"]) {
            //图片信息
            NSMutableDictionary *newMessage = [[NSMutableDictionary alloc]init];
            newMessage[@"msg-type"] = @(1);
            newMessage[@"file-path"] = message[@"file-path"];
            newMessage[@"burn"] = @(NO);
            [messageArray addObject:newMessage];
        }else{
            //如果是多个文字消息会合并成一个发送
            NSInteger msgType = message[@"msg-type"]?[message[@"msg-type"] integerValue]:0;
            NSMutableDictionary *newMessage = [[NSMutableDictionary alloc]init];
            newMessage[@"msg-type"] = @(msgType);
            newMessage[@"text"] = message[@"text"];
            [messageArray addObject:newMessage];
        }
    }
    [packet setValue:messageArray forKey:@"array"];
    BHMsgManager *manager = [objc_getClass("BHMsgManager") sharedInstance];
    packet.fontInfo  = [manager defaultFontInfo];
    [manager sendMessagePacket:packet target:session completion:nil ProgressBlock:nil];

    }
    
    
}

@end
