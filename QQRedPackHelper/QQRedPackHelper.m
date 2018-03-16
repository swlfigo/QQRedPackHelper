//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//
//  QQRedPackHelper.m
//  QQRedPackHelper
//
//  Created by tangxianhai on 2018/2/4.
//  Copyright © 2018年 tangxianhai. All rights reserved.
//

#import "QQRedPackHelper.h"
#import "substrate.h"
#import "QQHelperSetting.h"

@class MQAIOChatViewController;
@class MQAIORecentSessionViewController;

@class BHMsgListManager;
@class AppController;
@class MQAIOChatViewController;
@class TChatWalletTransferViewController;
@class RedPackWindowController;
@class RedPackViewController;

//static void (*origin_TChatWalletTransferViewController_updateUI)(TChatWalletTransferViewController *,SEL);
//static void new_TChatWalletTransferViewController_updateUI(TChatWalletTransferViewController* self,SEL _cmd) {
//    origin_TChatWalletTransferViewController_updateUI(self,_cmd);
//
//    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
//        id chatWalletVc = self;
//        id chatWalletTransferViewModel = [chatWalletVc valueForKey:@"_viewModel"];
//        if (chatWalletTransferViewModel) {
//            id helperRedPackViewMode = [chatWalletTransferViewModel valueForKey:@"_redPackViewModel"];
//            // 判读显示的单条消息是否红包
//            if (helperRedPackViewMode) {
//                NSDictionary *helperRedPackDic = [helperRedPackViewMode valueForKey:@"_redPackDic"];
//                id chatWalletContentView = [chatWalletVc valueForKey:@"_walletContentView"];
//                if (chatWalletContentView) {
//                    // 判断红包本机是否抢过
//                    id helperRedPackOpenStateText = [chatWalletVc valueForKey:@"_redPackOpenStateLabel"];
//                    if (helperRedPackOpenStateText) {
//                        NSString *redPackOpenState = [helperRedPackOpenStateText performSelector:@selector(stringValue)];
//                        if (![redPackOpenState isEqualToString:@"已拆开"]) {
//                            NSLog(@"QQRedPackHelper：抢到红包 - 红包信息: %@",helperRedPackDic);
//                            [chatWalletContentView performSelector:@selector(performClick)];
//                            [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
//                        } else {
//                            NSLog(@"QQRedPackHelper：检测到历史红包 - 红包信息: %@",helperRedPackDic);
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

static void (*origin_MQAIORecentSessionViewController_setupMenuForSessionId)(MQAIORecentSessionViewController *,SEL,id,id);
static void new_MQAIORecentSessionViewController_setupMenuForSessionId(MQAIORecentSessionViewController* self,SEL _cmd,id a3,id a4) {
    origin_MQAIORecentSessionViewController_setupMenuForSessionId(self,_cmd,a3,a4);
    {
        NSInteger uin = [[a4 valueForKey:@"_uin"] integerValue];
        NSInteger sessionChatType = [[a4 valueForKey:@"_sessionChatType"] integerValue];
        if (sessionChatType == 2 && uin != 0) {
            {
                NSMenuItem *separatorItem1 = [NSMenuItem separatorItem];
                [a3 addItem:separatorItem1];
            }
            {
                RedPackSettingMenuItem *item = [RedPackSettingMenuItem sharedInstance];
                item.groupSessionId = uin;
                NSMenuItem *settingWindowItem = [item redPacSettingItem];
                BOOL ok = [[QQHelperSetting sharedInstance] groupSessionIdContainer:uin];
                if (ok) {
                    [settingWindowItem setState:NSControlStateValueOn];
                } else {
                    [settingWindowItem setState:NSControlStateValueOff];
                }
                [a3 addItem:settingWindowItem];
            }
        }
    }
}

static id (*origin_BHMsgListManager_getMessageKey)(BHMsgListManager *,SEL,id);
static id new_BHMsgListManager_getMessageKey(BHMsgListManager* self,SEL _cmd, id msgKey) {
    id key = origin_BHMsgListManager_getMessageKey(self,_cmd,msgKey);
    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
        id redPackHelper = NSClassFromString(@"RedPackHelper");
        if ([msgKey isKindOfClass:NSClassFromString(@"BHMessageModel")]) {
            int mType = [[msgKey valueForKey:@"_msgType"] intValue];
            int read = [[msgKey valueForKey:@"_read"] intValue];
            NSInteger groupCode = [[msgKey valueForKey:@"_groupCode"] integerValue];
            if (mType == 311 && read == 0) {
                NSString * content = [msgKey performSelector:@selector(content)];
                NSDictionary * contentDic = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                NSString *title = [contentDic objectForKey:@"title"];
                // 1. 关键字过滤
                BOOL ok = [[QQHelperSetting sharedInstance] keywordContainer:title];
                if (ok) {
                    return key;
                }
                // 2. 指定群过滤
                BOOL groupOk = [[QQHelperSetting sharedInstance] groupSessionIdContainer:groupCode];
                if (!groupOk) {
                    return key;
                }
                // 3. 红包延迟
                QQHelperSetting *helper = [QQHelperSetting sharedInstance];
                NSInteger delayInSeconds = [helper getRandomNumber:[helper startTime] to:[helper endTime]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [redPackHelper performSelector:@selector(openRedPackWithMsgModel:operation:) withObject:msgKey withObject:@(0)];
                    if ([msgKey isKindOfClass:NSClassFromString(@"QQRecentMessageModel")]) {
                        [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
                        NSLog(@"QQRedPackHelper：抢到红包 %@ ---- 详细信息: %@",msgKey,content);
                    }
                });
            }
        }
    }
    return key;
}

static void (*origin_AppController_applicationDidFinishLaunching)(AppController *,SEL,NSNotification *);
static void new_AppController_applicationDidFinishLaunching(AppController* self,SEL _cmd,NSNotification * aNotification) {
    origin_AppController_applicationDidFinishLaunching(self,_cmd,aNotification);
    [[QQHelperMenu sharedInstance] addMenu];
}

static void (*origin_MQAIOChatViewController_revokeMessages)(MQAIOChatViewController*,SEL,id);
static void new_MQAIOChatViewController_revokeMessages(MQAIOChatViewController* self,SEL _cmd,id arrays){
    if (![[QQHelperSetting sharedInstance] isMessageRevoke]) {
        origin_MQAIOChatViewController_revokeMessages(self,_cmd,arrays);
    }
}

static void (*origin_QQMessageRevokeEngine_handleRecallNotify_isOnline)(QQMessageRevokeEngine*,SEL,void * ,BOOL);
static void new_QQMessageRevokeEngine_handleRecallNotify_isOnline(QQMessageRevokeEngine* self,SEL _cmd,void * notify,BOOL isOnline){
    if (![[QQHelperSetting sharedInstance] isMessageRevoke]) {
        origin_QQMessageRevokeEngine_handleRecallNotify_isOnline(self,_cmd,notify,isOnline);
    }
}

static void (*origin_RedPackViewController_viewDidLoad)(RedPackViewController*,SEL);
static void new_RedPackViewController_viewDidLoad(RedPackViewController* self,SEL _cmd) {
    origin_RedPackViewController_viewDidLoad(self,_cmd);
    NSViewController *redPackVc = (NSViewController *)self;
    [[QQHelperSetting sharedInstance] saveOneRedPacController:redPackVc];
    if ([[QQHelperSetting sharedInstance] isHideRedDetailWindow]) {
        [[QQHelperSetting sharedInstance] closeRedPacWindowns];
    }
}

//NSArray *(*oldNSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);
//NSArray *newNSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory,
//                                             NSSearchPathDomainMask domainMask,
//                                             BOOL expandTilde) {
//    NSString *supportDir = [[QQHelperSetting sharedInstance] supportDir];
//    NSString *documentDir = [[QQHelperSetting sharedInstance] documentDir];
//    NSString *libraryDir = [[QQHelperSetting sharedInstance] libraryDir];
//    if (directory == NSApplicationSupportDirectory) {
//        if (![supportDir containsString:@"Containers"]) {
//            NSString *temp1 = [[supportDir componentsSeparatedByString:@"/Application"] firstObject];
//            // /Users/tangxianhai/Library
//            // /Users/tangxianhai/Library/Containers/com.tencent.qq/Data/Library/Application Support
//            NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
//            NSString *path = [NSString stringWithFormat:@"%@/Containers/%@/Data/Library/Application Support",temp1,bundleId];
//            NSLog(@"QQRedPackHelper333 NSApplicationSupportDirectory ：---------------------------------- %@",path);
//            return @[path];
//        }
//    }
//    if (directory == NSDocumentDirectory) {
//        NSString *temp1 = [[documentDir componentsSeparatedByString:@"/Documents"] firstObject];
//        // /Users/tangxianhai/Documents
//        // /Users/tangxianhai/Library/Containers/com.tencent.qq/Data/Documents
//        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
//        NSString *path = [NSString stringWithFormat:@"%@/Library/Containers/%@/Data/Documents",temp1,bundleId];
//        NSLog(@"QQRedPackHelper333 NSDocumentDirectory ：---------------------------------- %@",path);
//        return @[path];
//    }
////    if (directory == NSLibraryDirectory) {
////        // /Users/tangxianhai/Library
////        // /Users/tangxianhai/Library/Containers/com.tangxianhai.com.QQDemo/Data/Library
////        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
////        NSString *path = [NSString stringWithFormat:@"%@/Containers/%@/Data/Library",libraryDir,bundleId];
////        NSLog(@"QQRedPackHelper333 NSLibraryDirectory ：---------------------------------- %@",path);
////        return @[path];
////    }
//
//    NSArray *array = oldNSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde);
//    return array;
//}

static void __attribute__((constructor)) initialize(void) {
    
    NSLog(@"QQRedPackHelper111：抢红包插件2.0 开启 ----------------------------------");
    
//    // 获取原始支持路径
//    NSArray *path1 = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
//    [path1 enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
//        [[QQHelperSetting sharedInstance] setSupportDir:obj];
//        NSLog(@"QQRedPackHelper333 setSupportDir：---------------------------------- %@",obj);
//    }];
//
//    NSArray *path2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    [path2 enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
//        [[QQHelperSetting sharedInstance] setDocumentDir:obj];
//        NSLog(@"QQRedPackHelper333 setDocumentDir：---------------------------------- %@",obj);
//    }];
//
//
//    NSArray *path3 = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//    [path3 enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
//        [[QQHelperSetting sharedInstance] setLibraryDir:obj];
//        NSLog(@"QQRedPackHelper333 NSLibraryDirectory：---------------------------------- %@",obj);
//    }];
    
    // 消息防撤回 1
    MSHookMessageEx(objc_getClass("MQAIOChatViewController"),  @selector(revokeMessages:), (IMP)&new_MQAIOChatViewController_revokeMessages, (IMP*)&origin_MQAIOChatViewController_revokeMessages);
    
    // 消息防撤回 2
    MSHookMessageEx(objc_getClass("QQMessageRevokeEngine"),  @selector(handleRecallNotify:isOnline:), (IMP)&new_QQMessageRevokeEngine_handleRecallNotify_isOnline, (IMP*)&origin_QQMessageRevokeEngine_handleRecallNotify_isOnline);
    
    // 助手设置菜单项
    MSHookMessageEx(objc_getClass("AppController"), @selector(applicationDidFinishLaunching:), (IMP)&new_AppController_applicationDidFinishLaunching, (IMP *)&origin_AppController_applicationDidFinishLaunching);
    
    // 群右键设置选项
    MSHookMessageEx(objc_getClass("MQAIORecentSessionViewController"), @selector(setupMenu:forSessionId:), (IMP)&new_MQAIORecentSessionViewController_setupMenuForSessionId, (IMP *)&origin_MQAIORecentSessionViewController_setupMenuForSessionId);
    
    // 自动关闭红包弹框
     MSHookMessageEx(objc_getClass("RedPackViewController"), @selector(viewDidLoad), (IMP)&new_RedPackViewController_viewDidLoad, (IMP *)&origin_RedPackViewController_viewDidLoad);
    
    // 模拟抢红包，底层调用
    MSHookMessageEx(objc_getClass("BHMsgListManager"), @selector(getMessageKey:), (IMP)&new_BHMsgListManager_getMessageKey, (IMP *)&origin_BHMsgListManager_getMessageKey);
    
    // 解决历史记录
//    MSHookFunction(&NSSearchPathForDirectoriesInDomains, &newNSSearchPathForDirectoriesInDomains, &oldNSSearchPathForDirectoriesInDomains);
}
