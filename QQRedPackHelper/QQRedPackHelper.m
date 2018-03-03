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

static void (*origin_TChatWalletTransferViewController_updateUI)(TChatWalletTransferViewController *,SEL);
static void new_TChatWalletTransferViewController_updateUI(TChatWalletTransferViewController* self,SEL _cmd) {
    origin_TChatWalletTransferViewController_updateUI(self,_cmd);

    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
        id chatWalletVc = self;
        id chatWalletTransferViewModel = [chatWalletVc valueForKey:@"_viewModel"];
        if (chatWalletTransferViewModel) {
            id helperRedPackViewMode = [chatWalletTransferViewModel valueForKey:@"_redPackViewModel"];
            // 判读显示的单条消息是否红包
            if (helperRedPackViewMode) {
                NSDictionary *helperRedPackDic = [helperRedPackViewMode valueForKey:@"_redPackDic"];
                id chatWalletContentView = [chatWalletVc valueForKey:@"_walletContentView"];
                if (chatWalletContentView) {
                    // 判断红包本机是否抢过
                    id helperRedPackOpenStateText = [chatWalletVc valueForKey:@"_redPackOpenStateLabel"];
                    if (helperRedPackOpenStateText) {
                        NSString *redPackOpenState = [helperRedPackOpenStateText performSelector:@selector(stringValue)];
                        if (![redPackOpenState isEqualToString:@"已拆开"]) {
                            NSLog(@"QQRedPackHelper：抢到红包 - 红包信息: %@",helperRedPackDic);
                            [chatWalletContentView performSelector:@selector(performClick)];
                            [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
                        } else {
                            NSLog(@"QQRedPackHelper：检测到历史红包 - 红包信息: %@",helperRedPackDic);
                        }
                    }
                }
            }
        }
    }
}

static void (*origin_MQAIOChatViewController_handleAppendNewMsg)(MQAIOChatViewController *,SEL,id);
static void new_MQAIOChatViewController_handleAppendNewMsg(MQAIOChatViewController* self,SEL _cmd,id msg) {
    origin_MQAIOChatViewController_handleAppendNewMsg(self,_cmd,msg);
    id chatWalletVc = self;
    [chatWalletVc performSelector:@selector(didClickNewMsgRemindPerformButton)];
}

//static void (*origin_BHMsgListManager_onRefreshUnreadCountWhenGetMessage)(BHMsgListManager *,SEL,NSNotification *);
//static void new_BHMsgListManager_onRefreshUnreadCountWhenGetMessage(BHMsgListManager* self,SEL _cmd, NSNotification * msgNotification) {
//    origin_BHMsgListManager_onRefreshUnreadCountWhenGetMessage(self,_cmd,msgNotification);
//    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
//        // 获取最新消息
//        NSDictionary *redPacketDic = [msgNotification userInfo];
//        NSArray *messages = [redPacketDic objectForKey:@"msgArray"];
//        if ([messages count] != 0) {
//            for (id message in messages) {
//                id redPackHelper = NSClassFromString(@"RedPackHelper");
//                if ([message isKindOfClass:NSClassFromString(@"BHMessageModel")]) {
//                    int mType = [[message valueForKey:@"_msgType"] intValue];
//                    if (mType == 311) {
//                        // 红包消息
//
//                        id content = [message performSelector:@selector(content)];
//
//                        id traceManager = [NSClassFromString(@"TXTraceManager") performSelector:@selector(shareInstance)];
//                        [traceManager performSelector:@selector(setBreadcrumb:argument:) withObject:@"BC_OPEN_REDPACK_MOUSE_DOWN" withObject:@""];
//
//                        [redPackHelper performSelector:@selector(openRedPackWithMsgModel:operation:) withObject:message withObject:@(0)];
//
//                        NSLog(@"QQRedPackHelper：抢到红包 %@ ---- 详细信息: %@",message,content);
//                    }
//                }
//            }
//        }
//    }
//}

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
    
    // 模拟抢红包 - 通用
    MSHookMessageEx(objc_getClass("TChatWalletTransferViewController"), @selector(_updateUI), (IMP)&new_TChatWalletTransferViewController_updateUI, (IMP *)&origin_TChatWalletTransferViewController_updateUI);
    
    // 消息滚到底部 - 才会自动刷新UI
    MSHookMessageEx(objc_getClass("MQAIOChatViewController"), @selector(handleAppendNewMsg:), (IMP)&new_MQAIOChatViewController_handleAppendNewMsg, (IMP *)&origin_MQAIOChatViewController_handleAppendNewMsg);
    
    /* 方法弃用，有问题。
    MSHookMessageEx(objc_getClass("BHMsgListManager"), @selector(onGetMessage:), (IMP)&new_BHMsgListManager_onRefreshUnreadCountWhenGetMessage, (IMP *)&origin_BHMsgListManager_onRefreshUnreadCountWhenGetMessage);
     */
    
     MSHookMessageEx(objc_getClass("RedPackViewController"), @selector(viewDidLoad), (IMP)&new_RedPackViewController_viewDidLoad, (IMP *)&origin_RedPackViewController_viewDidLoad);
}
