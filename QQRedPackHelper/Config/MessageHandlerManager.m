//
//  MessageHandlerManager.m
//  QQRedPackHelper
//
//  Created by Sylar on 2020/1/1.
//  Copyright © 2020 tangxianhai. All rights reserved.
//

#import "MessageHandlerManager.h"
#import <AFNetworking/AFNetworking.h>
@interface MessageHandlerManager()
@property(nonatomic,strong)AFHTTPSessionManager *manager;
@end


@implementation MessageHandlerManager
+ (instancetype)sharedInstance{
    static MessageHandlerManager *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[MessageHandlerManager alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式 JSON
        _manager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    }
    return self;
}

- (void)postMessageToServer:(NSDictionary *)infoDic{
    if (!infoDic) {
        return;
    }
    //本地5400端口
    [_manager POST:@"http://127.0.0.1:5400/qqmessage" parameters:infoDic progress:nil success:nil failure:nil];
    
    
}
@end
