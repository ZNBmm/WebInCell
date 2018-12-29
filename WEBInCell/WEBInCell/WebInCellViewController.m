
//
//  WebInCellViewController.m
//  NatvieWebView
//
//  Created by CodeZNB on 2018/12/28.
//  Copyright © 2018年 ZNB. All rights reserved.
//

#import "WebInCellViewController.h"
#import "WebTableViewCell.h"
#import "UIView+ZFrame.h"
@interface WebInCellViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,
WKNavigationDelegate>
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIScrollView  *containerScrollView;
@property (nonatomic, strong) WKWebView     *webView;
@end

@implementation WebInCellViewController
{
    CGFloat _lastWebViewContentHeight;
    CGFloat _lastTableViewContentHeight;
    CGFloat _webViewHeight;
    WebTableViewCell *_currentWebCell;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
    [self loadRequest];
    [self.tableView registerClass:[WebTableViewCell class] forCellReuseIdentifier:@"WebTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.containerScrollView];
    [self.containerScrollView  addSubview:self.tableView];

    
}
- (void)loadRequest {
    NSURL *url;
    if (NO) {
        NSString *path = @"https://www.jianshu.com/p/a20b1b46de89";
        url = [NSURL URLWithString:path];
    }else {
        NSString *localPath = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:nil];
        url = [NSURL fileURLWithPath:localPath];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}
- (void)dealloc{
    [self removeObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Observers
- (void)addObservers{
    [self.webView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers{
    [self.webView removeObserver:self forKeyPath:@"scrollView.contentSize"];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == _webView) {
        if ([keyPath isEqualToString:@"scrollView.contentSize"]) {
            if (self.webView.scrollView.contentSize.height == _lastWebViewContentHeight) {
                return;
            }
            [self updateContainerScrollViewContentSize];
            
            _lastWebViewContentHeight = self.webView.scrollView.contentSize.height;
            _webViewHeight = _lastWebViewContentHeight > self.containerScrollView.height?self.containerScrollView.height:_lastWebViewContentHeight;
            [self.tableView reloadData];
        }
    }else if(object == _tableView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self updateContainerScrollViewContentSize];
        }
    }
}

- (void)updateContainerScrollViewContentSize{
    CGFloat webViewContentHeight = self.webView.scrollView.contentSize.height;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;
    
    if (webViewContentHeight == _lastWebViewContentHeight && tableViewContentHeight == _lastTableViewContentHeight) {
        return;
    }
    
    _lastWebViewContentHeight = webViewContentHeight;
    _lastTableViewContentHeight = tableViewContentHeight;
    
    self.containerScrollView.contentSize = CGSizeMake(self.containerScrollView.width, webViewContentHeight + tableViewContentHeight-_webViewHeight);

    [self scrollViewDidScroll:self.containerScrollView];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_containerScrollView != scrollView) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <0) {
        self.tableView.top = 0;
        self.tableView.contentOffset = CGPointMake(0, 0);
        self.webView.scrollView.contentOffset = CGPointZero;
    }else if (offsetY <_currentWebCell.top) {
        self.tableView.top = offsetY;
        self.tableView.contentOffset = CGPointMake(0, offsetY);
        self.webView.scrollView.contentOffset = CGPointZero;
    }else if (offsetY < _currentWebCell.top + _lastWebViewContentHeight - _webViewHeight) {
        self.tableView.top = offsetY;
        self.tableView.contentOffset = CGPointMake(0, _currentWebCell.top);
        self.webView.scrollView.contentOffset = CGPointMake(0, offsetY - _currentWebCell.top);
    }else if (offsetY < _lastTableViewContentHeight + _lastWebViewContentHeight - _webViewHeight) {
        self.tableView.top = offsetY;
        self.tableView.contentOffset = CGPointMake(0, offsetY-( _lastWebViewContentHeight - _webViewHeight));
        self.webView.scrollView.contentOffset = CGPointMake(0, _lastWebViewContentHeight - _webViewHeight);
    }
}

#pragma mark - UITableViewDataSouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 300;
    }else if (indexPath.row == 4) {
        return _webViewHeight;
    }else {
        return 200;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",indexPath];
        
        return cell;
    }else if (indexPath.row == 4) {
        WebTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebTableViewCell"];
        _currentWebCell = cell;
        
        [cell.contentView addSubview:self.webView];
        cell.webView = self.webView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor redColor];
        
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",indexPath];
        return cell;
    }
    return nil;
}

#pragma mark - private
- (WKWebView *)webView{
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.scrollView.scrollEnabled = NO;
        _webView.navigationDelegate = self;
    }
    
    return _webView;
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.containerScrollView.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        
        
    }
    return _tableView;
}

- (UIScrollView *)containerScrollView{
    if (_containerScrollView == nil) {
        _containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _containerScrollView.delegate = self;
        _containerScrollView.alwaysBounceVertical = YES;
    }
    
    return _containerScrollView;
}


@end
