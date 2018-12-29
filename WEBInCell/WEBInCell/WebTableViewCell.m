//
//  WebTableViewCell.m
//  NatvieWebView
//
//  Created by CodeZNB on 2018/12/28.
//  Copyright © 2018年 ZNB. All rights reserved.
//

#import "WebTableViewCell.h"

@implementation WebTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.webView.frame = self.contentView.bounds;
    
}

@end
