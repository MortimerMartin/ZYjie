//
//  CommonWebViewController.m
//  iStockNew
//
//  Created by zhouqiang on 15-9-2.
//  Copyright (c) 2015年 Delpan. All rights reserved.
//

#import "CommonWebViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SDWebImageManager.h"
#import "EaseChatViewController.h"
#import "ShareView.h"
#import "AppDelegate+UMeng.h"
#import "UIView+MJExtension.h"
#import "LBXScanViewStyle.h"
#import "ZYLBXScanViewController.h"

#define IOS8x ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
#define IOS_VERSION_10 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max)?(YES):(NO)  

@interface CommonWebViewController ()
{
    NSString * VideoPlayerStr;
    BOOL  isShowBigView;
    CGFloat lastScale;
}

@property (nonatomic , strong) UIView      * borderView;
@property (nonatomic , assign) BOOL   isFrame;
@property (nonatomic , copy) NSString * ImgUrlStr;
@property (nonatomic , assign) NSUInteger loadCount;
@property (nonatomic , strong) UIProgressView * WKprogressView;

@property (nonatomic , strong) WKWebView * WKWebView;

@property (nonatomic , strong) UIView * videoView;

@property (nonatomic , strong) UIProgressView * progress;

@property (nonatomic , copy) NSString * QRScanURL;



@end


@implementation CommonWebViewController


static NSString * const picMethodName = @"showBigImage:";

static NSString * const openChatWithName = @"openChat:WithName:";
static NSString * const shareView = @"shareView:";


- (void)viewDidLoad {
    [super viewDidLoad];

    self.isFrame = YES;
    [self setupWeb];

    [self loadRequest];
    
    [self addRightItem];

//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];





}

- (void)dealloc{
    if (IOS8x) {
        [_WKWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
//    [_avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
//    [_avPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];


    [_WKWebView.configuration.userContentController removeScriptMessageHandlerForName:@"showBigImage"];
      [_WKWebView.configuration.userContentController removeScriptMessageHandlerForName:@"openChatWithName"];
      [_WKWebView.configuration.userContentController removeScriptMessageHandlerForName:@"shareView"];
    [_WKWebView.configuration.userContentController removeAllUserScripts];
    [progressView removeFromSuperview];


    webView = nil;
//    [self cleanCacheAndCookie];
//     self.navigationController.navigationBar.translucent = NO;
}
/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{



    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}
- (void)setupWeb
{
    
    if (IOS8x) {

        // 进度条
        UIProgressView *progressView1 = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        progressView1.tintColor = BackBlue;
        progressView1.trackTintColor = [UIColor clearColor];
        [self.view addSubview:progressView1];

        self.WKprogressView = progressView1;

        NSString *jScript = @"window.jgIos= {};$('body').on('click','*[showBig]',function(){window.webkit.messageHandlers.showBigImage.postMessage({methodName:'showBigImage:',imageSrc:this.src});});";

        NSString * jsChat = @"$('[data-chatList]').on('click', function(){var id = $(this).attr('data-chatList').split(',')[0];var name = $(this).attr('data-chatList').split(',')[1];window.webkit.messageHandlers.openChatWithName.postMessage({methodName:'openChat:WithName:',strID:id,strName:name});});";

        NSString * jsShare = @"$('body').on('click','.sharePageButton',function(ev){var src =  $(this).attr('data-shareHref') || window.location.href;ev.stopPropagation();window.webkit.messageHandlers.shareView.postMessage({methodName:'shareView:', shareUrl:src});});" ;

//    NSString * jsTest = @"window.jgIos.scanQRCode = function (params) {window.webkit.messageHandlers.showScanVC.postMessage({methodName:'showScanVC:',params: params});};";
//        NSString * jsTest = @"window.webkit.messageHandlers.showScanVC.postMessage({methodName:'showScanVC:',params: 'success: function (url) {alert(url)}'});";

//        NSString * jsTest =@"var $qrcode = $('.qrcode input');$qrcode.off().on('click', function () {alert('scan');window.webkit.messageHandlers.showScanVC.postMessage({methodName:'showScanVC:',params: 'success: function (url) {alert(url)}'});return false})";


        //调整字号
        NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
//        NSString *headerStr = @"document.getElementsByTagName('video')[0].style.webkit-playsinline = 'true';";
//         NSString *headerStr1 = @"document.getElementsByTagName('video')[0].style.playsinline = 'true';";
        //进行配置控制器
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];

        //        if (IOS_VERSION_10){
        //              configuration.mediaTypesRequiringUserActionForPlayback =WKAudiovisualMediaTypeAll;
        //        }
        //实例化对象
//        configuration.userContentController = [WKUserContentController new];
        //调用js方法
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:str injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];


        WKPreferences * preferences = [[WKPreferences alloc] init];

        preferences.javaScriptEnabled = YES;

        configuration.preferences = preferences;
        WKUserScript *wkUScript1 = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserScript *wkUScript2 = [[WKUserScript alloc] initWithSource:jsChat injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserScript *wkUScript3 = [[WKUserScript alloc] initWithSource:jsShare injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//        WKUserScript *wkUScript4 = [[WKUserScript alloc] initWithSource:jsTest injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//        WKUserScript *wkUScript4 = [[WKUserScript alloc] initWithSource:headerStr injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//        WKUserScript *wkUScript5 = [[WKUserScript alloc] initWithSource:headerStr1 injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];

        WKUserContentController *userContentController = [[WKUserContentController alloc]init];
        [userContentController addScriptMessageHandler:self name:@"showBigImage"];
        [userContentController addScriptMessageHandler:self name:@"openChatWithName"];
        [userContentController addScriptMessageHandler:self name:@"shareView"];
        [userContentController addScriptMessageHandler:self name:@"scanQRCode"];
        [userContentController addUserScript:wkUScript];
        [userContentController addUserScript:wkUScript1];
        [userContentController addUserScript:wkUScript2];
        [userContentController addUserScript:wkUScript3];
//        [userContentController addUserScript:wkUScript4];

        if (IOS_VERSION_10) {
//            [userContentController addUserScript:wkUScript5];
            configuration.requiresUserActionForMediaPlayback = YES;
            //允许视频播放
            configuration.allowsAirPlayForMediaPlayback = YES;
        }
//        else{
//            [userContentController addUserScript:wkUScript4];
//        }

        configuration.userContentController = userContentController;

        // 允许在线播放
        configuration.allowsInlineMediaPlayback = YES;
        configuration.mediaPlaybackRequiresUserAction = YES;
        // 允许可以与网页交互，选择视图

        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-64)configuration:configuration];
//        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        wkWebView.navigationDelegate = self;
        wkWebView.UIDelegate =self;

//        [wkWebView setAllowsBackForwardNavigationGestures:YES];
        [self.view insertSubview:wkWebView belowSubview:progressView1];

        [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];


        _WKWebView = wkWebView;
    }else{
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
        webView.scalesPageToFit = YES;
        [self.view addSubview:webView];

        progressProxy = [[NJKWebViewProgress alloc]init];
        webView.delegate = progressProxy;



        progressProxy.webViewProxyDelegate = self;
        progressProxy.progressDelegate = self;

        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;

        progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, 3)];

        [progressView setProgress:0];

        [self.navigationController.navigationBar addSubview:progressView];
    }





    
    

}

//重点二
//- (UIView* )viewForZoomingInScrollView:(UIScrollView* )scrollView {
//    return nil;
//}

- (void)addRightItem{
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UILabel *label = [UILabel labelWithFrame:CGRectMake(10, 0, 40, 44) font:[UIFont systemFontOfSize:15.0] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentRight text:@"刷新"];
    [button addSubview:label];
    [button addTarget:self action:@selector(loadRequesturl) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
}


- (void)navigationPop:(UIButton *)sender
{

    if (IOS8x) {
        if (isShowBigView == YES) {
            [bgView removeFromSuperview];
        }
            if (_WKWebView.canGoBack) {

//                if (_WKWebView.backForwardList.backList.count>0) {
////                    WKBackForwardListItem * item = _WKWebView.backForwardList.currentItem;
//
//
//                             [_WKWebView goToBackForwardListItem:_WKWebView.backForwardList.backList[_WKWebView.backForwardList.backList.count-1]];
//                    [_WKWebView reload];
//
//                }

                [_WKWebView goBack];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            };


    }else{
        if (webView.canGoBack)
        {
            [webView goBack];
            return;
        }


        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)loadRequest
{

    if (IOS8x) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_url]];
        [_WKWebView loadRequest:request];


        [_WKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    }else{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_url]];
        //    [WebView loadRequest:request];
        [webView loadRequest:request];
    }

}

- (void)loadRequesturl{

    if (IOS8x) {
        NSString * jsTest = @"window.jgIos.scanQRCode = function (params) {window.webkit.messageHandlers.showScanVC.postMessage({methodName:'showScanVC:',params: params});};";
        [_WKWebView evaluateJavaScript:jsTest completionHandler:nil];
        [_WKWebView reload];

    }else{
        [webView reload];
    }

    
}
// 计算wkWebView进度条
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{


//    AVPlayerItem *playerItem = object;
//    if ([keyPath isEqualToString:@"status"]) {
//        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
//        if (status == AVPlayerStatusReadyToPlay) {
//            NSLog(@"正在播放:%.2f", CMTimeGetSeconds(playerItem.duration));
//        }
//    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
//        NSArray *array = playerItem.loadedTimeRanges;
//        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
//        float startSeconds = CMTimeGetSeconds(timeRange.start);
//        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
//        NSLog(@"共缓冲：%.2f", totalBuffer);path	
//    }
    if (object == _WKWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newProgress == 1) {
            self.WKprogressView.hidden = YES;
            [self.WKprogressView setProgress:0 animated:NO];
        }else{
            self.WKprogressView.hidden = NO;
            [self.WKprogressView setProgress:newProgress animated:YES];
        }
    }

}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{

    NSString *path= [_WKWebView.URL absoluteString];
    NSString * newPath = [path lowercaseString];

    if ([newPath hasPrefix:@"sms:"] || [newPath hasPrefix:@"tel:"]) {

        UIApplication * app = [UIApplication sharedApplication];
        if ([app canOpenURL:[NSURL URLWithString:newPath]]) {
            [app openURL:[NSURL URLWithString:newPath]];
        }
        return;
    };
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{

}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{

}
#pragma mark - WKUIDelegate
//当把JS返回给控制器,然后弹窗就是这样设计的
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();

    }]];
    [self presentViewController:alert animated:YES completion:nil];

}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                                                  completionHandler(YES);
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                      {  
                          completionHandler(NO);  
                      }]];  
    [self presentViewController:alert animated:YES completion:NULL];  
    NSLog(@"%@", message);  
}
// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler([[alert.textFields lastObject] text]);
                                              }]];  
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSDictionary *imageDict = message.body;
    NSString *src = [NSString string];

    if (imageDict[@"imageSrc"]) {
        src = imageDict[@"imageSrc"];
    }else{
        src = imageDict[@"videoSrc"];
    }

    NSString *name = imageDict[@"methodName"];

    //如果方法名是我们需要的，那么说明是时候调用原生对应的方法了
    if ([picMethodName isEqualToString:name]) {
        SEL sel = NSSelectorFromString(picMethodName);

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        //写在这个中间的代码,都不会被编译器提示PerformSelector may cause a leak because its selector is unknown类型的警告
        [self performSelector:sel withObject:src];
#pragma clang diagnostic pop
    }else if ([openChatWithName isEqualToString:name]){
        [self openChat:imageDict[@"strID"] WithName:imageDict[@"strName"]];
    }else if ([shareView isEqualToString:name]){
        SEL sel = NSSelectorFromString(name);
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"

        NSString * url = imageDict[@"shareUrl"];
        [self performSelector:sel withObject:url];
#pragma clang diagnostic pop

    }else if ([name isEqualToString:@"scanQRCode:"]){

        [self scanQRCode:imageDict[@"params"]];

    }else{


    }




 NSLog(@"%@,%@",message.name,message.body);
}



// 二维码
- (void)scanQRCode:(NSString *)URL{

    self.QRScanURL = URL;

    dispatch_async(dispatch_get_main_queue(), ^{
        //创建参数对象
        LBXScanViewStyle * style = [[LBXScanViewStyle alloc] init];
        //矩形区域中心上移，默认中心为屏幕中心点
        style.centerUpOffset = 44;
        //扫码框周围4个角的类型，设置为外挂式
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
        //扫码框周围4个角绘制的线条宽度
        style.photoframeLineW = 6;
        //扫码框周围4个角的宽度
        style.photoframeAngleW = 24;
        //扫码框周围4个角的高度
        style.photoframeAngleH = 24;
        //扫码框内，动画类型 －－线条上下移动
        style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
        //线条上下移动图片
        style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];

        ZYLBXScanViewController * vc = [ZYLBXScanViewController new];


        __weak typeof(self) weakSelf = self;
        vc.scanURLblock = ^(NSString * QRURL){



            NSString * qrulr = [NSString stringWithFormat:@"({%@}).success({url:'%@'});",_QRScanURL,QRURL];

            [weakSelf.WKWebView evaluateJavaScript:qrulr completionHandler:nil];


        };

        vc.style = style;
        vc.isVideoZoom = YES;
        [self.navigationController pushViewController:vc animated:YES];
//        NSString * jsTest = @"window.jgIos.scanQRCode = function (params) {window.webkit.messageHandlers.showScanVC.postMessage({methodName:'showScanVC:',params: params});};";
//        [_WKWebView evaluateJavaScript:jsTest completionHandler:nil];
    });


}



// 在发送请求之前，决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    NSString *path= [_WKWebView.URL absoluteString];
//    NSString * newPath = [path lowercaseString];
//    NSLog(@"%@",newPath);
//    if (navigationAction.navigationType == UIWebViewNavigationTypeBackForward) {
//        NSLog(@"back");
//    }
    if ([_WKWebView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"] || [_WKWebView.URL.absoluteString hasPrefix:@"http://itunes.apple.com"] ) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
// 在收到响应后，决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{

   decisionHandler(WKNavigationResponsePolicyAllow);
}




//webview.
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    

    //调整字号
    NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '95%'";
    [webView stringByEvaluatingJavaScriptFromString:str];
    
    //js方法遍历图片添加点击事件 返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){$('body').on('click','img[showBig]',function(ev){var src =  this.src ;document.location='myweb:imageClick:'+src;ev.stopPropagation();})};";

    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
      //调用js方法
    [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
  
    
//    [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    static NSString * const jsChat=@"function chat(){$('[data-chatList]').on('click', function()\
    {\
    var id = $(this).attr('data-chatList').split(',')[0];\
    var name = $(this).attr('data-chatList').split(',')[1];\
    JSObjcDelegate.openChatWithName(id,name);\
    }\
    )\
    }" ;
    [webView stringByEvaluatingJavaScriptFromString:jsChat];
    [webView stringByEvaluatingJavaScriptFromString:@"chat()"];
    
    
    static NSString * const jsShare=@"function shareUrl(){$('body').on('click','.sharePageButton',function(ev){\
    var src =  $(this).attr('data-shareHref') || window.location.href;\
    ev.stopPropagation();\
    JSObjcDelegate.shareView(src);\
    })}" ;
    [webView stringByEvaluatingJavaScriptFromString:jsShare];
    [webView stringByEvaluatingJavaScriptFromString:@"shareUrl()"];
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"JSObjcDelegate"] = self;
    
    
 
//    [webView stringByEvaluatingJavaScriptFromString:@"chat()"];
    

//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
//    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
//    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    
    //    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
  
    
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
      
        [self showBigImage:imageUrl];//创建视图并显示图片

        return NO;
    }
    

    return YES;
}

#pragma mark js向oc传参 分享
- (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)shareView:(NSString *)shareurl{
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
    ShareView *view = [ShareView createWithTitle:@"地尔" content:shareurl imageUrl:nil link:shareurl viewController:self];
        view.shareUrl = shareurl;
     });
//    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline]];
//    
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:@"5279f92156240b8271023b8e"
//                                      shareText:shareurl
//                                     shareImage:[UIImage imageNamed:@"icon 180x180.png"]
//                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil]
//                                       delegate:nil];
//    //link UMShareToSina
//    [[self sharedAppDelegate]setUMengSocial:shareurl];
    
}


#pragma mark js向oc传参 打开聊天界面
- (void)openChat:(NSString *)strID WithName:(NSString *)strName{
//    NSLog(@"this is ios TestTowParameter=%@  Second=%@",strID,strName);
    
    
    if ([kUserID isEqualToString:strID]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", @"提示") message:NSLocalizedString(@"不能和自己聊天", @"不能和自己聊天") delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", @"确定") otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    
    
    EaseChatViewController *chatController = [[EaseChatViewController alloc] initWithConversationChatter:strID conversationType:eConversationTypeChat];
    
    chatController.title = strName;
    chatController.nameId = strID;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatController animated:YES];
    });
    
    
    
    
}
#pragma mark 显示大图片
-(void)showBigImage:(NSString *)imageUrl{

    isShowBigView = YES;
    //创建灰色透明背景，使其背后内容不可操作
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    [bgView setBackgroundColor:[UIColor colorWithRed:0.3
                                               green:0.3
                                                blue:0.3
                                               alpha:0.7]];
    [self.view addSubview:bgView];
    
    //创建边框视图
    UIView * borderView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-64)];
    
    //将图层的边框设置为圆脚
    borderView.layer.cornerRadius = 8;
    borderView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    borderView.layer.borderWidth = 8;
    borderView.layer.borderColor = [[UIColor colorWithRed:0.9
                                                     green:0.9
                                                      blue:0.9
                                                     alpha:0.7] CGColor];
    //    [_borderView setCenter:bgView.center];
    
    [bgView addSubview:borderView];
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
 
    closeBtn.backgroundColor = [UIColor redColor];
    [closeBtn setImage:[UIImage imageNamed:@"设置111_01_13.png"] forState:UIControlStateNormal];

    closeBtn.layer.cornerRadius = 13;
    closeBtn.layer.masksToBounds = YES;
    [closeBtn addTarget:self action:@selector(removeBigImage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(borderView.frame.origin.x+borderView.frame.size.width-25, borderView.frame.origin.y, 26, 26)];
    [bgView addSubview:closeBtn];
    
    //创建显示图像视图

    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(borderView.frame)-20, borderView.frame.size.height-20)];
    imgView.userInteractionEnabled = YES;
//   [imgView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
    [imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
     imgView.frame = CGRectMake(10, 10, image.size.width*([UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height), image.size.height*([UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height));

        if (imgView.frame.size.width>borderView.frame.size.width-20 ) {
            imgView.frame = CGRectMake(10, 10, CGRectGetWidth(borderView.frame)-20, imgView.frame.size.height);
        }

        if (imgView.frame.size.height > borderView.frame.size.height - 20) {
            imgView.frame = CGRectMake(10, 10,imgView.frame.size.width, borderView.frame.size.height-20);

        }
        imgView.center = borderView.center;

    }];

    IMGurlStr = imageUrl;
    [borderView addSubview:imgView];


    //图片缩放
    [imgView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)]];
    //滑动手势
    [imgView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
    //旋转手势
//    [imgView addGestureRecognizer:[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)]];
    //双击手势
    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [imgView addGestureRecognizer:doubleTap];
    //长按手势
    [imgView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)]];
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer{
    
    
    if (recognizer.state==UIGestureRecognizerStateBegan) {
        //显示菜单
        //1.创建MenuItem对象
        UIMenuItem *menuItem=[[UIMenuItem alloc] initWithTitle:@"屏幕大小" action:@selector(resetImgFrame:)];
        UIMenuItem *menuItem1=[[UIMenuItem alloc] initWithTitle:@"原图" action:@selector(setImgFrame)];
        //2.UIMenuController 对象
        UIMenuController *menuController=[UIMenuController sharedMenuController];
        //3设置要显示的菜单项
        menuController.menuItems=@[menuItem,menuItem1];
        //4设置大小显示区域
        
        CGPoint point=[recognizer locationInView:recognizer.view];
        [recognizer.view becomeFirstResponder];
        
        
        [menuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:recognizer.view];
        //5.显示出来
        [menuController setMenuVisible:YES animated:YES];
    }
    
}


- (void)resetImgFrame:(UIGestureRecognizer *)recognizer{
    __weak typeof(imgView) weakImg = imgView;
    [imgView sd_setImageWithURL:[NSURL URLWithString:IMGurlStr] placeholderImage:nil options:EMSDWebImageRetryFailed completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        [weakImg setFrame:CGRectMake(10, 10, CGRectGetWidth(bgView.frame)-20, bgView.frame.size.height-84)];

    }];


}

-(void)setImgFrame{
    __weak typeof(imgView) weakImg = imgView;
    [imgView sd_setImageWithURL:[NSURL URLWithString:IMGurlStr] placeholderImage:nil options:EMSDWebImageRetryFailed completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        [weakImg setFrame:CGRectMake(10, 10, image.size.width, image.size.height)];

    }];
    
    
}
- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    
    
    if (_isFrame) {
        [UIView animateWithDuration:0.3 animations:^{
            recognizer.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        }];
        
        
        _isFrame = NO;
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            recognizer.view.transform=CGAffineTransformIdentity
            ;
        }];
        
        _isFrame = YES;
    }
}
- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer{



    //3.tranform 旋转角度
    recognizer.view.transform=CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    //4.设置rotation 为增量值
    recognizer.rotation=0;
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer{
    
    
    
    //1.获取视图
    UIImageView *ImageView=(UIImageView *)recognizer.view;
    //2.获取移动的点当前坐标
    CGPoint point=[recognizer translationInView:ImageView.superview];

    [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
    
    //3.视图中心点赋值
    
    recognizer.view.center=CGPointMake(recognizer.view.center.x+point.x, recognizer.view.center.y+point.y);

}
- (void) handlePinch:(UIPinchGestureRecognizer*)sender
{
    //当手指离开屏幕时,将lastscale设置为1.0
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        lastScale = 1.0;
        return;
    }

    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [[(UIPinchGestureRecognizer*)sender view]setTransform:newTransform];
    lastScale = [(UIPinchGestureRecognizer*)sender scale];

//    //缩放:设置缩放比例
//    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    recognizer.scale = 1;
}

//协议处理多个手势之间的互斥，返回yes 可以同时使用两个手势
#pragma mark UIgesture delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}




#pragma mark NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [progressView setProgress:progress animated:YES];
}

//关闭按钮
-(void)removeBigImage
{
//    bgView.hidden = YES;
    isShowBigView = NO;
    [bgView removeFromSuperview];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
  
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
