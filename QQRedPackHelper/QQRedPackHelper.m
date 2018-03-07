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
@class QQMessageRevokeEngine;

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

static void (*origin_MQAIOChatViewController_handleAppendNewMsg)(MQAIOChatViewController *,SEL,id);
static void new_MQAIOChatViewController_handleAppendNewMsg(MQAIOChatViewController* self,SEL _cmd,id msg) {
    origin_MQAIOChatViewController_handleAppendNewMsg(self,_cmd,msg);
    id chatWalletVc = self;
    [chatWalletVc performSelector:@selector(didClickNewMsgRemindPerformButton)];
}

static id (*origin_BHMsgListManager_getMessageKey)(BHMsgListManager *,SEL,id);
static id new_BHMsgListManager_getMessageKey(BHMsgListManager* self,SEL _cmd, id msgKey) {
    id key = origin_BHMsgListManager_getMessageKey(self,_cmd,msgKey);
    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
        id redPackHelper = NSClassFromString(@"RedPackHelper");
        if ([msgKey isKindOfClass:NSClassFromString(@"BHMessageModel")]) {
            int mType = [[msgKey valueForKey:@"_msgType"] intValue];
            if (mType == 311) {
                // 红包消息
                dispatch_async(dispatch_get_main_queue(),^{
                    [redPackHelper performSelector:@selector(openRedPackWithMsgModel:operation:) withObject:msgKey withObject:@(0)];
                    id content = [msgKey performSelector:@selector(content)];
                    [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
                    NSLog(@"QQRedPackHelper：抢到红包 %@ ---- 详细信息: %@",msgKey,content);
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

static void (*origin_QQMessageRevokeEngine_handleRecallNotify_isOnline)(QQMessageRevokeEngine*,SEL,void*,BOOL);
static void new_QQMessageRevokeEngine_handleRecallNotify_isOnline(QQMessageRevokeEngine* self,SEL _cmd,void* notify,BOOL isOnline){
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

static void __attribute__((constructor)) initialize(void) {
    
    NSLog(@"QQRedPackHelper：抢红包插件2.0 开启 ----------------------------------");
    
    // 消息防撤回
    MSHookMessageEx(objc_getClass("MQAIOChatViewController"),  @selector(revokeMessages:), (IMP)&new_MQAIOChatViewController_revokeMessages, (IMP*)&origin_MQAIOChatViewController_revokeMessages);
    
    MSHookMessageEx(objc_getClass("QQMessageRevokeEngine"),  @selector(handleRecallNotify:isOnline:), (IMP)&new_QQMessageRevokeEngine_handleRecallNotify_isOnline, (IMP*)&origin_QQMessageRevokeEngine_handleRecallNotify_isOnline);
    
    // 助手设置菜单
    MSHookMessageEx(objc_getClass("AppController"), @selector(applicationDidFinishLaunching:), (IMP)&new_AppController_applicationDidFinishLaunching, (IMP *)&origin_AppController_applicationDidFinishLaunching);
    
    // 模拟抢红包 - 通用 - 比较慢，每次刷新UI都要变化弹框 弃用
//    MSHookMessageEx(objc_getClass("TChatWalletTransferViewController"), @selector(_updateUI), (IMP)&new_TChatWalletTransferViewController_updateUI, (IMP *)&origin_TChatWalletTransferViewController_updateUI);
    
//     消息滚到底部 - 才会自动刷新UI
//    MSHookMessageEx(objc_getClass("MQAIOChatViewController"), @selector(handleAppendNewMsg:), (IMP)&new_MQAIOChatViewController_handleAppendNewMsg, (IMP *)&origin_MQAIOChatViewController_handleAppendNewMsg);
    
    // 自动关闭红包弹框
     MSHookMessageEx(objc_getClass("RedPackViewController"), @selector(viewDidLoad), (IMP)&new_RedPackViewController_viewDidLoad, (IMP *)&origin_RedPackViewController_viewDidLoad);
    
    // 模拟抢红包方式二，底层调用
    MSHookMessageEx(objc_getClass("BHMsgListManager"), @selector(getMessageKey:), (IMP)&new_BHMsgListManager_getMessageKey, (IMP *)&origin_BHMsgListManager_getMessageKey);
}
