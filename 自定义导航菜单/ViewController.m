//
//  ViewController.m
//  自定义导航菜单
//
//  Created by cpr on 15/11/3.
//  Copyright (c) 2015年 scsys. All rights reserved.
//

#import "ViewController.h"
#import "LongPressMovableMenu.h"
@interface ViewController ()<LongPressMovableMenuDelegate>
@property(nonatomic, strong)LongPressMovableMenu *menuBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //图片数组
    NSArray *imageList = @[[UIImage imageNamed:@"menuBtn_RN"],[UIImage imageNamed:@"menuBtn_CL"], [UIImage imageNamed:@"menuBtn_MCB"], [UIImage imageNamed:@"menuBtn_MC"], [UIImage imageNamed:@"menuBtn_option"]];
    //创建并将图片添加到sideBar上
    self.menuBar = [[LongPressMovableMenu alloc] init];
    //代理
    self.menuBar.delegate = self;
    
    //	设置自定义菜单展开放行
    self.menuBar.menuDirect = LongPressMovableMenuDirectRight;
    //	菜单列表按钮图片
    [self.menuBar setButtonImages:imageList];
    //	菜单展开按钮不同状态图片
    [self.menuBar setMenuButtonImage:[UIImage imageNamed:@"menuIcon_close"] forStatus:LongPressMovableMenuStatusClose];
    [self.menuBar setMenuButtonImage:[UIImage imageNamed:@"menuIcon_open"] forStatus:LongPressMovableMenuStatusOpen];
    [self.menuBar setMenuButtonImage:[UIImage imageNamed:@"menuIcon_moving"] forStatus:LongPressMovableMenuStatusMoving];
    //	添加到navigationBar
    [self.view addSubview:self.menuBar];
}

-(void)clickMuneBtnAtIndex:(NSInteger)index{
    NSLog(@"%ld", index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
