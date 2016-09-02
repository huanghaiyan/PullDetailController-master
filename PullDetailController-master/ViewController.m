//
//  ViewController.m
//  PullDetailController-master
//
//  Created by 黄海燕 on 16/9/1.
//  Copyright © 2016年 huanghy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UILabel *headLab;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadContentView];
    // 开始监听_webView.scrollView的偏移量
    [_webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)loadContentView
{
    // first view
    [self.view addSubview:self.tableView];
    
    // second view
    [self.view addSubview:self.webView];
    
    UILabel *hv = self.headLab;
    // headLab
    [self.webView addSubview:hv];
    [self.headLab bringSubviewToFront:self.view];
}


- (UILabel *)headLab
{
    if(!_headLab){
        _headLab = [[UILabel alloc] init];
        _headLab.text = @"上拉，返回详情";
        _headLab.textAlignment = NSTextAlignmentCenter;
        _headLab.font = [UIFont systemFontOfSize:13];
        
    }
    
    _headLab.frame = CGRectMake(0, 0, self.view.frame.size.width, 40.f);
    _headLab.alpha = 0.f;
    _headLab.textColor = [UIColor blackColor];
    
    
    return _headLab;
}


- (UITableView *)tableView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        //    _tableView.contentSize = CGSizeMake(PDWidth_mainScreen, 800);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 40.f;
        UILabel *tabFootLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        tabFootLab.text = @"继续拖动，查看图文详情";
        tabFootLab.font = [UIFont systemFontOfSize:13];
        tabFootLab.textAlignment = NSTextAlignmentCenter;
        _tableView.tableFooterView = tabFootLab;
    }
    
    return _tableView;
}


- (UIWebView *)webView
{
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _tableView.contentSize.height, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    }
    
    return _webView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

#pragma mark - datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.text = @"dfgh";
    }
    return cell;
}

#pragma mark ---- scrollView delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if([scrollView isKindOfClass:[UITableView class]]) // tableView界面上的滚动
    {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
        CGFloat valueNum = _tableView.contentSize.height -self.view.frame.size.height;
        if ((offsetY - valueNum) > 100)
        {
            [self goToDetailAnimation]; // 进入图文详情的动画
        }
    }
    
    else // webView页面上的滚动
    {
        NSLog(@"-----webView-------");
        if(offsetY<0 && -offsetY>100)
        {
            [self backToFirstPageAnimation]; // 返回基本详情界面的动画
        }
    }
}

// 进入详情的动画
- (void)goToDetailAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _tableView.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

// 返回第一个界面的动画
- (void)backToFirstPageAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
        NSLog(@"----old:%@----new:%@",change[@"old"],change[@"new"]);
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    _headLab.alpha = -offsetY/60;
    _headLab.center = CGPointMake(self.view.frame.size.width/2, -offsetY/2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY>100){
        _headLab.textColor = [UIColor redColor];
        _headLab.text = @"释放，返回详情";
    }else{
        _headLab.textColor = [UIColor blackColor];
        _headLab.text = @"上拉，返回详情";
    }
}


@end
