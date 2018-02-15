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

@class MQAIOTopBarViewController;

@class BHMsgListManager;

@class MQAIOChatViewController;
@class TChatWalletTransferViewController;

static void (*origin_TChatWalletTransferViewController_updateUI)(TChatWalletTransferViewController *,SEL);
static void new_TChatWalletTransferViewController_updateUI(TChatWalletTransferViewController* self,SEL _cmd) {
    origin_TChatWalletTransferViewController_updateUI(self,_cmd);
    
    __block NSViewController * topBarVc = nil;
    __block NSComboBox *settingComboBox = nil;

    NSArray *windows = [[NSApplication sharedApplication] windows];
    [windows enumerateObjectsUsingBlock:^(NSWindow * obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isKindOfClass:NSClassFromString(@"MQAIOWindow2")]) {
            id winVc = [obj performSelector:@selector(windowController)];
            topBarVc = [winVc valueForKey:@"_topBarViewController"];
            NSLog(@"QQRedPackHelper：发现topBarVc -> %@",topBarVc);
        }
    }];

    [topBarVc.view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * obj, NSUInteger idx, BOOL * stop) {
        if (obj.tag == 1010) {
            settingComboBox = (NSComboBox *)obj;
            NSLog(@"QQRedPackHelper：发现settingComboBox -> %@",settingComboBox);
        }
    }];

    if (settingComboBox) {
        
        NSInteger selectIndex = [settingComboBox indexOfSelectedItem];
        
        if (selectIndex == 0) {
            // 助手关闭
            NSLog(@"QQRedPackHelper：检测到红包助手关闭");
        } else if (selectIndex == 1) {
            // 模拟点击1
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
                            } else {
                                NSLog(@"QQRedPackHelper：检测到历史红包 - 红包信息: %@",helperRedPackDic);
                            }
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
    __block NSViewController * topBarVc = nil;
    __block NSComboBox *settingComboBox = nil;

    NSArray *windows = [[NSApplication sharedApplication] windows];
    [windows enumerateObjectsUsingBlock:^(NSWindow * obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isKindOfClass:NSClassFromString(@"MQAIOWindow2")]) {
            id winVc = [obj performSelector:@selector(windowController)];
            topBarVc = [winVc valueForKey:@"_topBarViewController"];
            NSLog(@"QQRedPackHelper：发现topBarVc -> %@",topBarVc);
        }
    }];

    [topBarVc.view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * obj, NSUInteger idx, BOOL * stop) {
        if (obj.tag == 1010) {
            settingComboBox = (NSComboBox *)obj;
            NSLog(@"QQRedPackHelper：发现settingComboBox -> %@",settingComboBox);
        }
    }];

    if (settingComboBox) {
        NSInteger selectIndex = [settingComboBox indexOfSelectedItem];
        if (selectIndex == 0) {
            // 助手关闭
            NSLog(@"QQRedPackHelper：检测到红包助手关闭");
        } else if (selectIndex == 1) {
            // 模拟方式1，才开启消息到达自动滑动到最底部
            id chatWalletVc = self;
            [chatWalletVc performSelector:@selector(didClickNewMsgRemindPerformButton)];
        }
    }
    
}

static void (*origin_MQAIOTopBarViewController_awakeFromNib)(MQAIOTopBarViewController *,SEL);
static void new_MQAIOTopBarViewController_awakeFromNib(MQAIOTopBarViewController* self,SEL _cmd) {
    origin_MQAIOTopBarViewController_awakeFromNib(self,_cmd);
    
    NSViewController * topBarVc = (NSViewController *)self;
    
    NSComboBox * settingComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(topBarVc.view.bounds.size.width, 14, 86, 26)];
   
    [settingComboBox addItemWithObjectValue:@"助手关闭"];
    [settingComboBox addItemWithObjectValue:@"模拟点击"];
    [settingComboBox addItemWithObjectValue:@"模拟打开"];
    [settingComboBox selectItemAtIndex:0];
    settingComboBox.tag = 1010;
    [topBarVc.view addSubview:settingComboBox];
}

static void (*origin_BHMsgListManager_getMessageKey)(BHMsgListManager *,SEL,id);
static void new_BHMsgListManager_getMessageKey(BHMsgListManager* self,SEL _cmd, id msgKey) {
    origin_BHMsgListManager_getMessageKey(self,_cmd,msgKey);
    
    __block NSViewController * topBarVc = nil;
    __block NSComboBox *settingComboBox = nil;

    NSArray *windows = [[NSApplication sharedApplication] windows];
    [windows enumerateObjectsUsingBlock:^(NSWindow * obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isKindOfClass:NSClassFromString(@"MQAIOWindow2")]) {
            id winVc = [obj performSelector:@selector(windowController)];
            topBarVc = [winVc valueForKey:@"_topBarViewController"];
            NSLog(@"QQRedPackHelper：发现topBarVc -> %@",topBarVc);
        }
    }];

    [topBarVc.view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * obj, NSUInteger idx, BOOL * stop) {
        if (obj.tag == 1010) {
            settingComboBox = (NSComboBox *)obj;
            NSLog(@"QQRedPackHelper：发现settingComboBox -> %@",settingComboBox);
        }
    }];

    if (settingComboBox) {
        NSInteger selectIndex = [settingComboBox indexOfSelectedItem];
        if (selectIndex == 0) {
            // 助手关闭
            NSLog(@"QQRedPackHelper：检测到红包助手关闭");
        } else if (selectIndex == 2) {
            // 模拟点击2
            id redPackHelper = NSClassFromString(@"RedPackHelper");
            if ([msgKey isKindOfClass:NSClassFromString(@"BHMessageModel")]) {
                int mType = [[msgKey valueForKey:@"_msgType"] intValue];
                if (mType == 311) {
                    // 红包消息
                    [redPackHelper performSelector:@selector(openRedPackWithMsgModel:operation:) withObject:msgKey withObject:@(0)];
                    id content = [msgKey performSelector:@selector(content)];
                    NSLog(@"QQRedPackHelper：抢到红包 %@ ---- 详细信息: %@",msgKey,content);
                }
            }

        }
    }
    
    
}

static void __attribute__((constructor)) initialize(void) {
    
    NSLog(@"QQRedPackHelper：抢红包插件2.0 开启 ----------------------------------");
    
    MSHookMessageEx(objc_getClass("TChatWalletTransferViewController"), @selector(_updateUI), (IMP)&new_TChatWalletTransferViewController_updateUI, (IMP *)&origin_TChatWalletTransferViewController_updateUI);
    
    MSHookMessageEx(objc_getClass("MQAIOChatViewController"), @selector(handleAppendNewMsg:), (IMP)&new_MQAIOChatViewController_handleAppendNewMsg, (IMP *)&origin_MQAIOChatViewController_handleAppendNewMsg);
    
    MSHookMessageEx(objc_getClass("MQAIOTopBarViewController"), @selector(awakeFromNib), (IMP)&new_MQAIOTopBarViewController_awakeFromNib, (IMP *)&origin_MQAIOTopBarViewController_awakeFromNib);
    
    MSHookMessageEx(objc_getClass("BHMsgListManager"), @selector(getMessageKey:), (IMP)&new_BHMsgListManager_getMessageKey, (IMP *)&origin_BHMsgListManager_getMessageKey);
}
