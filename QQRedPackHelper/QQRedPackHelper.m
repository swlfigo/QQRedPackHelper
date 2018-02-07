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

@class MQAIOChatViewController;
@class TChatWalletTransferViewController;

static void (*origin_TChatWalletTransferViewController_updateUI)(TChatWalletTransferViewController *,SEL);
static void new_TChatWalletTransferViewController_updateUI(TChatWalletTransferViewController* self,SEL _cmd) {
    origin_TChatWalletTransferViewController_updateUI(self,_cmd);
    
    __block NSViewController * topBarVc = nil;
    __block NSButton *settingButton = nil;
    
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
            settingButton = (NSButton *)obj;
            NSLog(@"QQRedPackHelper：发现settingButton -> %@",settingButton);
        }
    }];
    
    if (settingButton) {
        if (settingButton.state == NSControlStateValueOn) {
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
        } else {
            NSLog(@"QQRedPackHelper：检测到红包助手关闭");
        }
    }
}

static void (*origin_MQAIOChatViewController_handleAppendNewMsg)(TChatWalletTransferViewController *,SEL,id);
static void new_MQAIOChatViewController_handleAppendNewMsg(TChatWalletTransferViewController* self,SEL _cmd,id msg) {
    origin_MQAIOChatViewController_handleAppendNewMsg(self,_cmd,msg);
    id chatWalletVc = self;
    [chatWalletVc performSelector:@selector(didClickNewMsgRemindPerformButton)];
}

static void (*origin_MQAIOTopBarViewController_awakeFromNib)(MQAIOTopBarViewController *,SEL);
static void new_MQAIOTopBarViewController_awakeFromNib(MQAIOTopBarViewController* self,SEL _cmd) {
    origin_MQAIOTopBarViewController_awakeFromNib(self,_cmd);
    NSViewController * topBarVc = (NSViewController *)self;
    NSButton *setttingButton = [NSButton buttonWithTitle:@"开启助手" target:nil action:nil];
    setttingButton.tag = 1010;
    setttingButton.state = NSControlStateValueOn;
    [setttingButton setButtonType:NSButtonTypeSwitch];
    [topBarVc.view addSubview:setttingButton];
    [setttingButton setFrame:NSMakeRect(topBarVc.view.bounds.size.width, 10, 0, 0)];
    [setttingButton sizeToFit];
}

static void __attribute__((constructor)) initialize(void) {
    
    NSLog(@"QQRedPackHelper：抢红包插件开启 ----------------------------------");
    
    MSHookMessageEx(objc_getClass("TChatWalletTransferViewController"), @selector(_updateUI), (IMP)&new_TChatWalletTransferViewController_updateUI, (IMP *)&origin_TChatWalletTransferViewController_updateUI);

    MSHookMessageEx(objc_getClass("MQAIOChatViewController"), @selector(handleAppendNewMsg:), (IMP)&new_MQAIOChatViewController_handleAppendNewMsg, (IMP *)&origin_MQAIOChatViewController_handleAppendNewMsg);
    
    MSHookMessageEx(objc_getClass("MQAIOTopBarViewController"), @selector(awakeFromNib), (IMP)&new_MQAIOTopBarViewController_awakeFromNib, (IMP *)&origin_MQAIOTopBarViewController_awakeFromNib);
}
