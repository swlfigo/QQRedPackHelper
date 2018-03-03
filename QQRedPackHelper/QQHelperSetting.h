//
//  QQHelperSetting.h
//  QQRedPackHelper
//
//  Created by tangxianhai on 2018/3/2.
//  Copyright © 2018年 tangxianhai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface QQHelperSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL isEnableRedPacket;
@property (nonatomic, assign) BOOL isHideRedDetailWindow;
@property (nonatomic, assign) BOOL isMessageRevoke;

@property (nonatomic, strong) NSMutableArray *redPacControllers;

- (void)saveOneRedPacController:(NSViewController *)redPacVc;
- (void)closeRedPacWindowns;
@end
