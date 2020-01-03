//
//  TKWebServerManager.h
//  QQPlugin
//
//  Created by TK on 2018/3/24.
//  Copyright © 2018年 tk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QQPlugin.h"
@interface TKWebServerManager : NSObject

+ (instancetype)shareManager;

- (void)startServer;
- (void)endServer;


- (NSDictionary *)dictFromBuddySearchResult:(Buddy *)buddy;
- (NSDictionary *)dictFromDiscussSearchResult:(Discuss *)discuss searcherInter:(ContactSearcherInter *)inter;
- (NSDictionary *)dictFromGroupSearchResult:(Group *)group ;
- (NSString *)avatarPathWithUIN:(NSString *)uin isUser:(BOOL)isUser ;
@end
