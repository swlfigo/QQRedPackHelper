//
//  MessageHandlerManager.h
//  QQRedPackHelper
//
//  Created by Sylar on 2020/1/1.
//  Copyright © 2020 tangxianhai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHandlerManager : NSObject

+ (instancetype)sharedInstance;

-(void)postMessageToServer:(NSDictionary*)infoDic;

@end

NS_ASSUME_NONNULL_END
