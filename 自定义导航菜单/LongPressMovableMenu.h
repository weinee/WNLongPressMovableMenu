//
//  LongPressMovableView.h
//  长按拖动控件
//
//  Created by 盛嘉炜 on 15/10/16.
//  Copyright (c) 2015年 盛嘉炜. All rights reserved.
//

#import <UIKit/UIKit.h>
//菜单展开的方向
typedef enum{
    LongPressMovableMenuDirectUp,
    LongPressMovableMenuDirectDown,
    LongPressMovableMenuDirectLeft,
    LongPressMovableMenuDirectRight
} LongPressMovableMenuDirect;
//菜单状态
typedef enum{
    LongPressMovableMenuStatusOpen,
    LongPressMovableMenuStatusClose,
    LongPressMovableMenuStatusMoving
} LongPressMovableMenuStatus;
@class LongPressMovableMenu;
@protocol LongPressMovableMenuDelegate <NSObject>

-(void)clickMuneBtnAtIndex:(NSInteger)index;

@end

@interface LongPressMovableMenu : UIView<UIGestureRecognizerDelegate>
//菜单打开方向
@property(assign, nonatomic)LongPressMovableMenuDirect menuDirect;
//是否允许菜单移动
@property(assign, nonatomic)BOOL isAllowMoveMenu;
//点击菜单按钮是否收回菜单
@property(assign, nonatomic)BOOL isAutoCloseMenu;
//代理
@property(weak, nonatomic)id<LongPressMovableMenuDelegate> delegate;


/**
 *  设置菜单上的按钮图片，按钮数量由传入的图片数而定
 *
 *  @param btns 按钮北京图片数组
 */
-(void)setButtonImages:(NSArray *)btnImages;
/**
 *  设置菜单打开和隐藏按钮背景图片
 *
 *  @param menuImage 背景图片
 *  @param status    设置此背景图片的状态
 */
-(void)setMenuButtonImage:(UIImage *)menuImage forStatus:(LongPressMovableMenuStatus)status;
@end

