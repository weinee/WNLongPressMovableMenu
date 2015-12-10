//
//  LongPressMovableView.m
//  长按拖动控件
//
//  Created by 盛嘉炜 on 15/10/16.
//  Copyright (c) 2015年 盛嘉炜. All rights reserved.
//
#import "LongPressMovableMenu.h"
//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


//菜单展开和关闭的动画时间
#define ANIMATEDURATION 0.4
//长按时间触发长按手势
#define PRESSDURATION 0.3
//#define SELFWIDTH self.frame.size.width
@interface LongPressMovableMenu (){
//    按钮宽度
    CGFloat _width;
    CGPoint _originPoint;
//    菜单上的按钮数组
    NSArray *_buttons;
//    菜单不同状态下的背景图片
    NSMutableArray *_menuBtnStatusImages;
//    当前菜单按钮状态
    LongPressMovableMenuStatus _menuCurrentStatus;
//    菜单按钮
    UIButton *_menuBtn;
}
@end

static const NSInteger offsetBtnTag = 157511;

@implementation LongPressMovableMenu
- (instancetype)init{
	self = [super init];
	if (self) {
		self.frame = CGRectMake(SCREEN_WIDTH*0.2, SCREEN_HEIGHT*0.85, 40, 40);
		_width = 40;
		//        初始化状态
		[self initView];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width);
        _width = frame.size.width;
//        初始化状态
        [self initView];
    }
    return self;
}
/**
 *  初始化子视图
 */
-(void)initView{
//    初始化设置
    _isAllowMoveMenu = YES;
	_isAutoCloseMenu = YES;
    self.backgroundColor = [UIColor clearColor];
    _menuDirect = LongPressMovableMenuDirectUp;
    _menuCurrentStatus = LongPressMovableMenuStatusClose;
    //        添加长按手势
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressMove:)];
    longPressGesture.delegate = self;
//	设置相应时间
	longPressGesture.minimumPressDuration = PRESSDURATION;
    [self addGestureRecognizer:longPressGesture];
    
//    初始化菜单按钮不同状态的背景图片数组
    _menuBtnStatusImages = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], nil];
//    初始化菜单按钮
    _menuBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_menuBtn addTarget:self action:@selector(clickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    _menuBtn.layer.cornerRadius = _width/2;
    [self addSubview:_menuBtn];
    
    //初始化后半透明
    [self reduceOpacity];
}

#pragma mark 长按手势 可以拖动控件
-(void)LongPressMove:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //获取开始位置
        _originPoint = [gesture locationInView:self];
//        NSLog(@"%lf, %lf", _originPoint.x, _originPoint.y);
        //改变菜单按钮状态,并改变透明度  使用动画
        [self addOpacity];
        [_menuBtn setBackgroundImage:_menuBtnStatusImages[LongPressMovableMenuStatusMoving] forState:UIControlStateNormal];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged){
    
        //    当前位置
        CGPoint point = [gesture locationInView:self];
        //    计算位移
        CGFloat offX = point.x - _originPoint.x;
        CGFloat offY = point.y - _originPoint.y;
        //新的坐标点
        CGPoint newCenter = CGPointMake(self.center.x+offX, self.center.y+offY);
        //限制用户不可将视图托出屏幕
        float halfx=CGRectGetMidX(self.bounds);
        //x坐标左边界
        newCenter.x=MAX(halfx,newCenter.x);
        //x坐标右边界
        newCenter.x=MIN(self.superview.bounds.size.width-halfx,newCenter.x);
        
        //y坐标同理
        float halfy=CGRectGetMidY(self.bounds);
        newCenter.y=MAX(halfy,newCenter.y);
        newCenter.y=MIN(self.superview.bounds.size.height-halfy,newCenter.y);
        
        //    改变位置
        self.center = newCenter;
    
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
        //将当前位置保存到NSUserDefault
        [[NSUserDefaults standardUserDefaults] setDouble:self.center.x-self.superview.center.x forKey:@"menuCenterX"];
        [[NSUserDefaults standardUserDefaults] setDouble:self.center.y-self.superview.center.y forKey:@"menuCenterY"];
        //恢复状态
//        [_menuBtn setImage:_menuBtnStatusImages[LongPressMovableMenuStatusClose] forState:UIControlStateNormal];
        [_menuBtn setBackgroundImage:_menuBtnStatusImages[LongPressMovableMenuStatusClose] forState:UIControlStateNormal];
        [self reduceOpacity];//半透明
    }
}
#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (_isAllowMoveMenu && (_menuCurrentStatus == LongPressMovableMenuStatusClose || _menuCurrentStatus == LongPressMovableMenuStatusMoving)) {
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark 实现接口方法
-(void)setButtonImages:(NSArray *)btnImages{
//    创建并初始化所有的按钮
    NSMutableArray *marr = [NSMutableArray array];
    NSInteger i = 0;
    for (UIImage *img in btnImages) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.tag = offsetBtnTag + i++;
//        [btn setImage:img forState:UIControlStateNormal];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        //圆角
        btn.layer.cornerRadius = _width/2;
        
        [btn addTarget:self action:@selector(clickMenuAtBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [marr addObject:btn];
    }
    _buttons = [marr copy];
    //将菜单按钮放在最前面
    [self bringSubviewToFront:_menuBtn];
}
-(void)setMenuButtonImage:(UIImage *)menuImage forStatus:(LongPressMovableMenuStatus)status{
    [_menuBtnStatusImages setObject:menuImage atIndexedSubscript:status];
    if (status == LongPressMovableMenuStatusClose) {
//        [_menuBtn setImage:menuImage forState:UIControlStateNormal];
        [_menuBtn setBackgroundImage:menuImage forState:UIControlStateNormal];
    }
}
#pragma mark 按钮点击事件
-(void)clickMenuBtn:(UIButton *)sender{
    if (_menuCurrentStatus == LongPressMovableMenuStatusClose) {
        //动画展开,并展开按钮
        [self openMenu];
		[self changeMenuStatus:LongPressMovableMenuStatusOpen];
//        NSLog(@"open menu");
    }
    else if (_menuCurrentStatus == LongPressMovableMenuStatusOpen){
        //动画合并,并隐藏按钮
//		在方法内部改变菜单状态, 当菜单关闭完毕时才改变状态,应该使用代码块实现
        [self closeMenu];
//        NSLog(@"close menu");
    }
}
-(void)clickMenuAtBtn:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(clickMuneBtnAtIndex:)]) {
        [_delegate clickMuneBtnAtIndex:sender.tag-offsetBtnTag];
    }
	if (_isAutoCloseMenu) {
		// 关闭菜单
		[_menuBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}
#pragma mark 根据状态更换菜单按钮图片
-(void)changeMenuStatus:(LongPressMovableMenuStatus)status{
	//改变状态
	_menuCurrentStatus = status;
	//替换图片
	//先判断图片数组中是否已经初始化了图片
	if (![_menuBtnStatusImages[status] isKindOfClass:[NSNull class]]) {
        [_menuBtn setBackgroundImage:_menuBtnStatusImages[status] forState:UIControlStateNormal];
	}
}

#pragma mark 打开和关闭菜单, 动画过程中禁止按钮交互
-(void)openMenu{
    //增加透明度
    [self addOpacity];
	//关闭菜单按钮交互
	_menuBtn.userInteractionEnabled = NO;
	//设置按钮显示
    for (NSInteger i=_buttons.count; i>0; i--) {
        [_buttons[i-1] setHidden:NO];
    }
    CGFloat offX = _width*_buttons.count/2;
    CGFloat offY = _width*_buttons.count/2;
    if (_menuDirect == LongPressMovableMenuDirectUp) {
        //只设置了大小没有设置位置，所以中心没有改变
        self.bounds = CGRectMake(0, 0, _width, _width*(_buttons.count+1));
        //设置菜单中心点的位置，因为菜单中心没有发生变化
        self.center = CGPointMake(self.center.x, self.center.y-offY);
        _menuBtn.frame = CGRectMake(0, _width*_buttons.count, _width, _width);
        //动画效果
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
			for (NSInteger i=_buttons.count; i>0; i--) {
				//左上角为坐标原点
				[_buttons[i-1] setCenter:CGPointMake(_width/2, _width/2+(_buttons.count - i)*_width)];
			}
		} completion:^(BOOL finished) {
			//打开菜单按钮交互
			_menuBtn.userInteractionEnabled = YES;
		}];
    }
    else if (_menuDirect == LongPressMovableMenuDirectDown){
        self.bounds = CGRectMake(0, 0, _width, _width*(_buttons.count+1));
        self.center = CGPointMake(self.center.x, self.center.y+offY);
        _menuBtn.frame = CGRectMake(0, 0, _width, _width);
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
            for (NSInteger i=1; i<=_buttons.count; i++) {
                [_buttons[i-1] setFrame:CGRectMake(0, i*_width, _width, _width)];
            }
		}completion:^(BOOL finished) {
			//打开菜单按钮交互
			_menuBtn.userInteractionEnabled = YES;
		}];
    }
    else if (_menuDirect == LongPressMovableMenuDirectLeft){
        self.bounds = CGRectMake(0, 0, _width*(_buttons.count+1), _width);
        self.center = CGPointMake(self.center.x-offX, self.center.y);
        _menuBtn.frame = CGRectMake(_width*_buttons.count, 0, _width, _width);
//        [UIView animateWithDuration:0.5 animations:^{
//            for (NSInteger i=_buttons.count; i>0; i--) {
//                [_buttons[i-1] setFrame:CGRectMake(_width*(_buttons.count-i), 0, _width, _width)];
//            }
//        }];
		[UIView animateWithDuration:ANIMATEDURATION animations:^{
			for (NSInteger i=_buttons.count; i>0; i--) {
				[_buttons[i-1] setFrame:CGRectMake(_width*(_buttons.count-i), 0, _width, _width)];
			}
		} completion:^(BOOL finished) {
			_menuBtn.userInteractionEnabled = YES;
		}];
    }
    else if (_menuDirect == LongPressMovableMenuDirectRight){
        self.bounds = CGRectMake(0, 0, _width*(_buttons.count+1), _width);
        self.center = CGPointMake(self.center.x+offX, self.center.y);
        _menuBtn.frame = CGRectMake(0, 0, _width, _width);
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
			for (NSInteger i=1; i<=_buttons.count; i++) {
				[_buttons[i-1] setFrame:CGRectMake(i*_width, 0, _width, _width)];
			}
		} completion:^(BOOL finished) {
			//打开菜单按钮交互
			_menuBtn.userInteractionEnabled = YES;
		}];
    }
}
-(void)closeMenu{
	_menuBtn.userInteractionEnabled = NO;
    CGFloat offX = _width*_buttons.count/2;
    CGFloat offY = _width*_buttons.count/2;
    if (_menuDirect == LongPressMovableMenuDirectUp) {
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
            //反向动画
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setCenter:CGPointMake(_width/2, _width/2+_buttons.count*_width)];
            }
        } completion:^(BOOL finished) {
            //恢复到原始状态
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setHidden:YES];
                [_buttons[i-1] setCenter:CGPointMake(_width/2, _buttons.count*_width+_width/2)];
            }
            self.bounds = CGRectMake(0, 0, _width, _width);
            _menuBtn.center = CGPointMake(_width/2, _width/2);
            self.center = CGPointMake(self.center.x, self.center.y+offY);
			//改变按钮菜单按钮状态
			[self changeMenuStatus:LongPressMovableMenuStatusClose];
			//打开菜单按钮交互
			_menuBtn.userInteractionEnabled = YES;
        }];
    }
    else if (_menuDirect == LongPressMovableMenuDirectDown){
        
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setFrame:CGRectMake(0, 0, _width, _width)];
            }
        } completion:^(BOOL finished) {
            //隐藏
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setHidden:YES];
            }
            self.bounds = CGRectMake(0, 0, _width, _width);
            _menuBtn.center = CGPointMake(_width/2, _width/2);
            self.center = CGPointMake(self.center.x, self.center.y-offY);
			[self changeMenuStatus:LongPressMovableMenuStatusClose];
			//打开菜单按钮交互
			_menuBtn.userInteractionEnabled = YES;
        }];
    }
    else if (_menuDirect == LongPressMovableMenuDirectLeft){
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
            //反向动画
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setCenter:CGPointMake( _width/2+_buttons.count*_width, _width/2)];
            }
			_menuBtn.userInteractionEnabled = YES;
        } completion:^(BOOL finished) {
            //恢复到原始状态
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setHidden:YES];
                [_buttons[i-1] setCenter:CGPointMake(_buttons.count*_width+_width/2, _width/2)];
            }
            self.bounds = CGRectMake(0, 0, _width, _width);
            _menuBtn.center = CGPointMake(_width/2, _width/2);
            self.center = CGPointMake(self.center.x+offX, self.center.y);
			[self changeMenuStatus:LongPressMovableMenuStatusClose];
			//打开菜单按钮交互
			_menuBtn.userInteractionEnabled = YES;
        }];

    }
    else if (_menuDirect == LongPressMovableMenuDirectRight){
        
        [UIView animateWithDuration:ANIMATEDURATION animations:^{
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setFrame:CGRectMake(0, 0, _width, _width)];
            }
        } completion:^(BOOL finished) {
            //隐藏
            for (NSInteger i=_buttons.count; i>0; i--) {
                [_buttons[i-1] setHidden:YES];
            }
            self.bounds = CGRectMake(0, 0, _width, _width);
            _menuBtn.center = CGPointMake(_width/2, _width/2);
            self.center = CGPointMake(self.center.x-offX, self.center.y);
			[self changeMenuStatus:LongPressMovableMenuStatusClose];
			_menuBtn.userInteractionEnabled = YES;
        }];

    }
    //半透明
    [self reduceOpacity];
    
//    for (NSInteger i=_buttons.count; i>0; i--) {
//        [_buttons[i-1] setFrame:CGRectMake(0, 0, _width, _width)];
//        [_buttons[i-1] setHidden:YES];
//    }
//    _menuBtn.frame = CGRectMake(0, 0, _width, _width);
}
#pragma mark 绘图
- (void)drawRect:(CGRect)rect {
    //隐藏, 初始位置大小
    for (NSInteger i=_buttons.count; i>0; i--) {
        [_buttons[i-1] setFrame:CGRectMake(0, 0, _width, _width)];
        [_buttons[i-1] setHidden:YES];
    }

    if (_menuDirect == LongPressMovableMenuDirectUp) {
        for (NSInteger i=_buttons.count; i>0; i--) {
            [_buttons[i-1] setCenter:CGPointMake(_width/2, _buttons.count*_width+_width/2)];
        }
    }
    else if (_menuDirect == LongPressMovableMenuDirectLeft){
        for (NSInteger i=_buttons.count; i>0; i--) {
//            [_buttons[i-1] setFrame:CGRectMake(0, 0, _width, _width)];
            [_buttons[i-1] setCenter:CGPointMake(_buttons.count*_width+_width/2, _width/2)];
        }
    }
    else{
        for (NSInteger i=_buttons.count; i>0; i--) {
//            [_buttons[i-1] setFrame:CGRectMake(0, 0, _width, _width)];
            [_buttons[i-1] setCenter:CGPointMake(_width/2, _width/2)];
        }
    }

    
    _menuBtn.frame = CGRectMake(0, 0, _width, _width);
}

#pragma mark 菜单透明度改变的方法
-(void)reduceOpacity{
    //四秒后半透明, 并且保持用户交互
    [UIView animateWithDuration:0.5 delay:4 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _menuBtn.alpha = 0.4;
    } completion:^(BOOL finished) {
        ;
    }];
}
-(void)addOpacity{
    //透明度改为1
    _menuBtn.alpha = 1;
}
@end
