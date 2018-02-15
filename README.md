# QQRedPackHelper
Mac 系统下的QQ抢红包插件，两种方式实现抢红包操作，一种是模拟用户点击执行抢红包操作，另一种是调用执行抢红包的函数，直接进行抢红包，第二种方式更底层一些，也无需消息界面执行UI刷新操作就能抢。

![](https://ws2.sinaimg.cn/large/006tNc79gy1fohan457dzj30tf0mtta7.jpg)
![](https://ws2.sinaimg.cn/large/006tNc79gy1fohao5m6hmj30tf0mtq4g.jpg)
![](https://ws1.sinaimg.cn/large/006tNc79gy1fohamphngaj30tf0mtwfy.jpg)

> 自动抢红包的插件，hook了四个方法，如下：

 1. ```-[TChatWalletTransferViewController _updateUI]``` 消息界面刷新，当前最新消息，在消息聊天界面最底部时候才调用
 2. ```-[MQAIOChatViewController handleAppendNewMsg:]``` 收到新的消息，并且消息界面的最新一条消息，不在最底部时候调用
 3. ```-[MQAIOTopBarViewController awakeFromNib]``` 添加聊天界面顶部*助手功能*选项
 4. ```-[BHMsgListManager getMessageKey:]``` 收到新消息，收到就会调用该方法，新增抢红包方式也在此方法中处理。
 
功能:
> 支持群和个人红包，自动执行抢操作。

#### 注意：
1. 助手设置选项控件位置可能不太对，只需要拖动调整QQ窗口大小即可更新助手设置控件位置
2. 想要自己编译项目，需要安装 [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)

#### 最后：为了方便安装，打包了动态库和所需工具，[下载地址](https://pan.baidu.com/s/1ggYSUEB)，密码:hyl0。
> 用法：下载完成后解压，将所有文件放到最新版QQ(测试用的是V6.3.0-32293)的MacOS文件目录下。如果QQ默认安装在应用程序目录中，那么该目录为 /Applications/QQ.app/Contents/MacOS/，然后打开控制台，
执行 ```cd /Applications/QQ.app/Contents/MacOS/``` ```sh redPack.sh``` 命令，重启QQ就可以了！
