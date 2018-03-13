# QQRedPackHelper

#### Mac系统下的QQ抢红包神器，支持群和个人红包，包括文字口令红包。

#### V2.21
> 参考Mac微信助手的安装脚本，更改安装方式，新增插件卸载脚本，已支持APP Store应用商店下载版本注入。

#### V2.2
> 修复bug：
1. 最近一条消息不能显示的问题。
2. 然后优化了助手设置界面，改为菜单栏方式设置。
3. 新增消息防撤回功能，可以在菜单栏进行设置。

#### 安装
打开控制台窗口，执行Other目录中的`Install.sh`文件，如：`sh Install.sh`

#### 卸载
打开控制台窗口，执行Other目录中的`Uninstall.sh`文件，如：`sh Uninstall.sh`

#### 效果图
![](https://ws2.sinaimg.cn/large/006tNc79ly1fozons6ttzj30o30iagmu.jpg)

> 自动抢红包的插件，hook了四个方法，如下：

 1. ```-[TChatWalletTransferViewController _updateUI]``` 消息界面刷新，当前最新消息，在消息聊天界面最底部时候才调用
 2. ```-[MQAIOChatViewController handleAppendNewMsg:]``` 收到新的消息，并且消息界面的最新一条消息，不在最底部时候调用
 3. ```-[MQAIOTopBarViewController awakeFromNib]``` 添加聊天界面顶部*助手功能*选项
 4. ```-[BHMsgListManager getMessageKey:]``` 收到新消息，收到就会调用该方法，新增抢红包方式也在此方法中处理。
 
#### 功能:
> 红包自动抢？ 支持群和个人红包，包括口令-文字红包，自动执行抢操作。
> 有朋友撤回消息，你想看吗？新增消息防撤回功能。
> 每次都要去点击左上角的关闭按钮，是不是很烦？现在新增红包弹框自动关闭功能。

#### 注意：
1. 助手设置选项现在直接放在顶部的菜单栏中啦，设置更加方便  
2. 想要自己编译项目，需要安装 [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)
3. 测试QQ版本截图：

![](https://ws1.sinaimg.cn/large/006tNc79gy1fozoyuhihej30dw09bgly.jpg)  
