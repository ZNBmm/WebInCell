//
//  WebTableViewCell.h
//  NatvieWebView
//
//  Created by CodeZNB on 2018/12/28.
//  Copyright © 2018年 ZNB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface WebTableViewCell : UITableViewCell
@property (weak,nonatomic) WKWebView *webView;
@end
