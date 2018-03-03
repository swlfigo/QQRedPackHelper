//
//  QQHelperSetting.m
//  QQRedPackHelper
//
//  Created by tangxianhai on 2018/3/2.
//  Copyright © 2018年 tangxianhai. All rights reserved.
//

#import "QQHelperSetting.h"

@implementation QQHelperSetting {
    
}

static NSString *hideRedDetailWindowKey = @"txh_hideRedDetailWindowKey";
static NSString *redPacketKey = @"txh_redPacketKeyy";
static NSString *messageRevokeKey = @"txh_messageRevokeKey";

static QQHelperSetting *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)setIsEnableRedPacket:(BOOL)isEnableRedPacket {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isEnableRedPacket] forKey:redPacketKey];
}

- (BOOL)isEnableRedPacket {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:redPacketKey] != nil) {
        BOOL enable = [[[NSUserDefaults standardUserDefaults] objectForKey:redPacketKey]boolValue];
        return enable;
    }
    return true;
}

- (void)setIsHideRedDetailWindow:(BOOL)isHideRedDetailWindow {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isHideRedDetailWindow] forKey:hideRedDetailWindowKey];
}

- (BOOL)isHideRedDetailWindow {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:hideRedDetailWindowKey] != nil) {
        BOOL autoLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:hideRedDetailWindowKey]boolValue];
        return autoLogin;
    }
    return false;
}

- (void)setIsMessageRevoke:(BOOL)isMessageRevoke {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isMessageRevoke] forKey:messageRevokeKey];
}

- (BOOL)isMessageRevoke {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:messageRevokeKey] != nil) {
        BOOL autoLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:messageRevokeKey]boolValue];
        return autoLogin;
    }
    return false;
}

- (void)saveOneRedPacController:(NSViewController *)redPacVc {
    if (self.redPacControllers == nil) {
        self.redPacControllers = [NSMutableArray new];
    }
    [self.redPacControllers addObject:redPacVc];
}

- (void)closeRedPacWindowns {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.redPacControllers == nil || [self.redPacControllers count] == 0) {
            return;
        }
        NSArray *controllers = [self.redPacControllers copy];
        for (NSViewController *vc in controllers) {
            [vc performSelector:@selector(onClose:) withObject:nil];
            [self.redPacControllers removeObject:vc];
        }
    });
}

@end
