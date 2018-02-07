# QQRedPackHelper
Mac 系统下的QQ抢红包插件

> 最近Mac版本的QQ增加了领取红包的功能，感觉比较好玩，所以搞了个自动抢红包的插件。主要hook了三个方法，如下：

 1. ```-[TChatWalletTransferViewController _updateUI]``` 消息界面刷新
 2. ```-[MQAIOChatViewController handleAppendNewMsg:]```收到红包消息
 3. ```-[MQAIOTopBarViewController awakeFromNib]```添加聊天界面顶部*开启助手*选项
 
功能:
> 支持群和个人红包，自动执行抢操作。

#### 注意：
想要自己编译项目，需要安装 [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)

#### 最后：为了方便安装，打包了动态库和所需工具，[下载地址](https://pan.baidu.com/s/1dN7xjo)，密码:ic78。
> 用法：下载完成后解压，将所有文件放到最新版QQ(测试用的是V6.3.0-32293)的MacOS文件目录下。如果QQ默认安装在应用程序目录中，那么该目录为 /Applications/QQ.app/Contents/MacOS/，然后打开控制台，
执行 ```cd /Applications/QQ.app/Contents/MacOS/``` ```sh redPack.sh``` 命令，重启QQ就可以了！
