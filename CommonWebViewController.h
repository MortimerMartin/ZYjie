//
//  CommonWebViewController.h
//  iStockNew
//
//  Created by zhouqiang on 15-9-2.
//  Copyright (c) 2015年 Delpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "UISpec.h"
#import "UICategories.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import <MediaPlayer/MediaPlayer.h>
@protocol JSObjcDelegate <JSExport>

- (void)openChat:(NSString *)strID WithName:(NSString *)strName;

- (void)shareView:(NSString *)shareurl;

-(void)showBigImage:(NSString *)imageUrl;
@end
@interface CommonWebViewController : UIViewController<NJKWebViewProgressDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,JSObjcDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    UIWebView *webView;
//    WKWebView * _WKWebView;
    //网页进度条
    NJKWebViewProgressView *progressView;
    NJKWebViewProgress *progressProxy;
    UIView * bgView;
    UIImageView * imgView;
    NSString * IMGurlStr;
}

@property (nonatomic,copy)NSString *url;



@end
