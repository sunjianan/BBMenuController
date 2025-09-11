//
//  BBMenuDefaultView.m
//  BBMenuController
//
//  Created by Sun on 2017/9/29.
//  Copyright © 2017年 Sun. All rights reserved.
//

#import "BBMenuDefaultView.h"
#import "BBMenuController.h"
#import "BBMenuEffectsWindow.h"
#import "BBMenuViewContainer.h"
#import "BBAdjustButton.h"
#import "BBMenuController_internal.h"

@interface BBMenuItemDefaultView:BBAdjustButton
@property (nonatomic, strong) UIColor  *highlightedColor;
@property (nonatomic, strong) UIImageView  *effectView;

@property (nonatomic, strong) id customTarget;
@property (nonatomic) SEL customSelector;

@end
@implementation BBMenuItemDefaultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        [self addTarget:self action:@selector(itemDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    UIButton *button = (UIButton *)object;
    if ([keyPath isEqualToString:@"highlighted"]) {
        if (button.highlighted) {
            [button setBackgroundColor:self.highlightedColor ? :[UIColor lightGrayColor]];
            return;
        }
        [button setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"highlighted"];
}

- (UIImageView *)effectView
{
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectV = [[UIVisualEffectView alloc] initWithEffect:effect];
        
        _effectView = [UIImageView new];
        _effectView.backgroundColor = [UIColor lightGrayColor];
        [_effectView addSubview:effectV];
    }
    return _effectView;
}

+ (UIImage *)createBackgroundImageWithSize:(CGRect)rect tintColor:(UIColor *)tintColor
{

    UIImage *resultImage = nil;
    tintColor = tintColor ? tintColor : [UIColor lightGrayColor];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
    
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    [path fill];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (void)itemDidSelected:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        IMP imp = [self.customTarget methodForSelector:self.customSelector];
        void (* func)(id, SEL) = (void *)imp;
        func(self.customTarget, self.customSelector);
    });
    
    [[BBMenuEffectsWindow sharedWindow] hide];
}

@end

#define kItemWidth 62
#define kTitleMargin 15
#define kMoreWidth 29.3
#define kTriangleHeight 11
#define kTriangleWidth 8.7

@interface BBMenuDefaultView()
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, weak) BBMenuViewContainer * container;
@property (nonatomic, assign) CGSize safeAreaSize;
@property (nonatomic, assign) NSUInteger  totalCount;
@property (nonatomic, strong) NSMutableArray * pageCounts;
@property (nonatomic, strong) NSMutableArray * lines;

@end

static inline BOOL BBMenuHasContainingInRange(CGFloat index,NSRange range) {
    
    if ((index <= range.location + range.length) && (index >= range.location)) {
        return YES;
    }
    return NO;
}

@implementation BBMenuDefaultView

+(instancetype)defaultView:(BBMenuViewContainer*)container WithMenuItems:(NSArray<BBMenuItem*>*)menuItems MaxSize:(CGSize)maxSize arrowSize:(CGSize)arrowSize AnchorPoint:(CGPoint)anchorPoint
{
    BBMenuDefaultView *defaultView = [[BBMenuDefaultView alloc] initView:container WithMenuItems:menuItems MaxSize:maxSize arrowSize:arrowSize AnchorPoint:anchorPoint];
    return defaultView;
}

- (instancetype)initView:(BBMenuViewContainer*)container WithMenuItems:(NSArray<BBMenuItem*>*)menuItems MaxSize:(CGSize)maxSize arrowSize:(CGSize)arrowSize AnchorPoint:(CGPoint)anchorPoint
{
    if (self = [super init]) {
        //        self.backgroundColor = [UIColor grayColor];
        self.menuItems = menuItems;
        self.arrowSize = arrowSize;
        self.maxSize = maxSize;
        self.anchorPoint = anchorPoint;
        self.totalCount = 0;
        self.container = container;
        self.contentView = [UIView new];
        [self addSubview:self.contentView];
          self.menuTintColor = self.container.menuItemTintColor;
        self.contentView.layer.cornerRadius = self.container.cornerRadius;
        self.contentView.layer.masksToBounds = YES;
        
        [self layoutMenuViews:YES];
    }
    return self;
}

- (void)dealloc
{
   // NSLog(@"BBMenuDefaultView dealloc~");
}

- (void)processLineWithMidX:(CGFloat)midX direction:(BBMenuControllerArrowDirection)direction
{
    NSRange arrowRange = NSMakeRange(midX - _arrowSize.width/2, _arrowSize.width);
    
    [self.lines enumerateObjectsUsingBlock:^(UIView* line, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect1 = line.frame;
        if (direction == BBMenuControllerArrowDown) {
            rect1.origin.y = _arrowSize.height;
            line.frame = rect1;
        }
        CGFloat x = line.frame.origin.x;
        BOOL tf = BBMenuHasContainingInRange(x, arrowRange);
        if (tf) {
            double realH = 0.000;
            if (x == midX) {
                realH = _arrowSize.height;
            } else if (x < midX) {
                realH = (double)(_arrowSize.height*((_arrowSize.width*0.5) - (midX - x)))/(_arrowSize.width*0.5);
            } else {
                realH = (double)(_arrowSize.height/(_arrowSize.width*0.5))*(_arrowSize.width*0.5 - (x-midX));
            }
            CGRect rect = line.frame;
            rect.size.height += realH;
            if (direction == BBMenuControllerArrowDown) {
                rect.origin.y -= realH;
            }
            line.frame = rect;
        }
    }];
}

- (void)setCorrectDirection:(BBMenuControllerArrowDirection)CorrectDirection
{
    _CorrectDirection = CorrectDirection;
    if (CorrectDirection == BBMenuControllerArrowDown) {
        CGRect rect = self.contentView.frame;
        rect.origin.y = _arrowSize.height;
        self.contentView.frame = rect;
        [self.lines enumerateObjectsUsingBlock:^(UIView* line, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect1 = line.frame;
            if (CorrectDirection == BBMenuControllerArrowDown) {
                rect1.origin.y = _arrowSize.height;
                line.frame = rect1;
            }
        }];
    }
}

- (void)layoutMenuViews:(BOOL)needResetLayout
{
    [self.lines removeAllObjects];
    
    __block CGFloat totalWidth = 0;
    __block NSUInteger index = 0;
    __weak typeof(self) ws = self;
    
    NSArray *array = self.menuItems;
    
    NSUInteger itemsCount = array.count;
    [array enumerateObjectsUsingBlock:^(BBMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat maxWidth = ((idx+1)==itemsCount)? self.maxSize.width : self.maxSize.width-kMoreWidth;
        CGFloat itemW = [ws calculateTextSize:obj maxWidth:maxWidth].width + kTitleMargin*2;
        if (obj.image && (self.container.imagePosition == BBAdjustButtonIMGPositionLeft || self.container.imagePosition == BBAdjustButtonIMGPositionRight)) {
             BBMenuItemDefaultView *test = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
             [test setImage:obj.image forState:UIControlStateNormal];
             test.frame = CGRectMake(0, 0, itemW, self.maxSize.height-_arrowSize.height);
             CGFloat imageW = test.imageView.frame.size.width;
             itemW +=imageW;
            if (itemW > maxWidth) {
                itemW = maxWidth;
            }
        }
        totalWidth += itemW;
        if ((totalWidth > maxWidth) && (totalWidth - maxWidth) > kTitleMargin) {
            totalWidth -= itemW;
            index = idx;
            if (idx <= (itemsCount-1)) {
                BBMenuItemDefaultView *more = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
                more.highlightedColor = self.container.menuItemHighlightColor;
                [more addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
                more.enabled = YES;
                more.frame = CGRectMake(totalWidth, 0, kMoreWidth, self.maxSize.height-_arrowSize.height);
                UIImage *image = [[self class] createTriangleImageWithSize:CGSizeMake(kTriangleWidth, kTriangleHeight) tintColor:  self.menuTintColor isRight:YES];
                [more setImage:image forState:UIControlStateNormal];
                [self.contentView addSubview:more];
                
                
                if (idx != 0) {
                    UIView *line = [UIView new];
                    line.backgroundColor =   self.menuTintColor ?:[UIColor whiteColor];
                    [self addSubview:line];
                    line.frame = CGRectMake(totalWidth, 0, 1/[UIScreen mainScreen].scale, self.maxSize.height-_arrowSize.height);
                    [self.lines addObject:line];
                }
            }
            totalWidth +=kMoreWidth;
            *stop = YES;
        } else {
            if ((totalWidth > maxWidth) && (totalWidth - maxWidth) <= kTitleMargin) {
                itemW -= (totalWidth - maxWidth);
                totalWidth -= (totalWidth - maxWidth);
            }
          
            BBMenuItemDefaultView *item = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
            item.customTarget = obj.target;
            item.customSelector = obj.action;
//            [item addTarget:obj.target action:obj.action forControlEvents:UIControlEventTouchUpInside];
            item.frame = CGRectMake(totalWidth-itemW, 0, itemW, self.maxSize.height-_arrowSize.height);
            [item setTitle:obj.title forState:UIControlStateNormal];
            item.titleLabel.font =self.container.menuItemFont;
            [item setTitleColor:   self.menuTintColor?:[UIColor whiteColor] forState:UIControlStateNormal];
            item.highlightedColor = self.container.menuItemHighlightColor;
            [self.contentView addSubview:item];
            if (obj.image) {
                item.imagePosition = self.container.imagePosition;
                [item setImage:obj.image forState:UIControlStateNormal];
            }
            
            if (idx != 0) {
                UIView *line = [UIView new];
                line.backgroundColor =   self.menuTintColor?:[UIColor whiteColor];
                [self addSubview:line];
                line.frame = CGRectMake(totalWidth-itemW, 0, 1/[UIScreen mainScreen].scale, self.maxSize.height-_arrowSize.height);
                [self.lines addObject:line];
            }
        }
    }];
    if (needResetLayout) {
        self.frame = (CGRect){{0,0},{totalWidth,self.maxSize.height}};
        self.contentView.frame = (CGRect){{0,0},{totalWidth,self.maxSize.height-_arrowSize.height}};
    }
     [self setCorrectDirection:_CorrectDirection];
    self.totalCount = index;
    [self.pageCounts addObject:@(self.totalCount)];
}

- (void)layoutMoreMenuViews
{
    [self.lines removeAllObjects];
    
    __block NSUInteger index = 0;
    __weak typeof(self) ws = self;
    
    NSArray *array = self.menuItems;
    if (self.totalCount != 0) {
        __block NSMutableArray * arrM = [NSMutableArray array];
        [self.menuItems enumerateObjectsUsingBlock:^(BBMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= self.totalCount) {
                [arrM addObject:obj];
            }
        }];
        array = arrM.copy;
    }
    // moreLeft
    {
        BBMenuItemDefaultView *moreleft = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
        [moreleft addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
        moreleft.frame = CGRectMake(0, 0, kMoreWidth, self.maxSize.height-_arrowSize.height);
        UIImage *image = [[self class] createTriangleImageWithSize:CGSizeMake(kTriangleWidth, kTriangleHeight) tintColor:  self.menuTintColor isRight:NO];
        [moreleft setImage:image forState:UIControlStateNormal];
        [self.contentView addSubview:moreleft];
        moreleft.highlightedColor = self.container.menuItemHighlightColor;
        
        UIView *line = [UIView new];
        line.backgroundColor =   self.menuTintColor?: [UIColor whiteColor];
        [self addSubview:line];
        line.frame = CGRectMake(kMoreWidth, 0, 1/[UIScreen mainScreen].scale, self.maxSize.height-_arrowSize.height);
        [self.lines addObject:line];
    }
    
    CGFloat menuWidth = self.frame.size.width - kMoreWidth*2;
    __block CGFloat totalWidth = 0;
    __block NSMutableArray *newMenuArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(BBMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat maxWidth = (self.maxSize.width-kMoreWidth*2);
        CGFloat itemW = [ws calculateTextSize:obj maxWidth:maxWidth].width + kTitleMargin*2;
        if (obj.image && (self.container.imagePosition == BBAdjustButtonIMGPositionLeft || self.container.imagePosition == BBAdjustButtonIMGPositionRight)) {
            BBMenuItemDefaultView *test = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
            [test setImage:obj.image forState:UIControlStateNormal];
            test.frame = CGRectMake(0, 0, itemW, self.maxSize.height-_arrowSize.height);
            CGFloat imageW = test.imageView.frame.size.width;
            itemW +=imageW;
            if (itemW > maxWidth) {
                itemW = maxWidth;
            }
        }
        totalWidth += itemW;
        
        if (totalWidth > maxWidth) {
            totalWidth -= itemW;
            *stop = YES;
        } else {
            [newMenuArray addObject:obj];
        }
        
    }];
    
    if (newMenuArray.count == 0) return;

    __block CGFloat lastWidth = kMoreWidth;
    CGFloat averageWidth = (menuWidth - totalWidth)/newMenuArray.count;
    [newMenuArray enumerateObjectsUsingBlock:^(BBMenuItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat maxWidth = (self.maxSize.width-kMoreWidth*2);
        CGFloat itemW = [ws calculateTextSize:obj maxWidth:maxWidth].width + kTitleMargin*2 + averageWidth;
        if (obj.image && (self.container.imagePosition == BBAdjustButtonIMGPositionLeft || self.container.imagePosition == BBAdjustButtonIMGPositionRight)) {
            BBMenuItemDefaultView *test = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
            [test setImage:obj.image forState:UIControlStateNormal];
            test.frame = CGRectMake(0, 0, itemW, self.maxSize.height-_arrowSize.height);
            CGFloat imageW = test.imageView.frame.size.width;
            itemW +=imageW;
            if (itemW > maxWidth) {
                itemW = maxWidth;
            }
        }
        index = idx+1;
        BBMenuItemDefaultView *item = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
        item.customTarget = obj.target;
        item.customSelector = obj.action;
//        [item addTarget:obj.target action:obj.action forControlEvents:UIControlEventTouchUpInside];
        item.frame = CGRectMake(lastWidth, 0, itemW, self.maxSize.height-_arrowSize.height);
        [item setTitle:obj.title forState:UIControlStateNormal];
        item.titleLabel.font = self.container.menuItemFont;
         item.highlightedColor = self.container.menuItemHighlightColor;
        [item setTitleColor:  self.menuTintColor?:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:item];
        if (obj.image) {
            item.imagePosition = self.container.imagePosition;
            [item setImage:obj.image forState:UIControlStateNormal];
        }
        
        lastWidth += itemW;
        
        if (idx != 0) {
            UIView *line = [UIView new];
            line.backgroundColor =  self.menuTintColor?: [UIColor whiteColor];
            [self addSubview:line];
            line.frame = CGRectMake(lastWidth-itemW, 0, 1/[UIScreen mainScreen].scale, self.maxSize.height-_arrowSize.height);
            [self.lines addObject:line];
        }
        
    }];
    self.totalCount += index;
    [self.pageCounts addObject:@(index)];
    // moreRight
    {
        BBMenuItemDefaultView *moreRight = [BBMenuItemDefaultView buttonWithType:UIButtonTypeCustom];
        [moreRight addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
        moreRight.frame = CGRectMake(self.frame.size.width-kMoreWidth, 0, kMoreWidth, self.maxSize.height-_arrowSize.height);
         moreRight.highlightedColor = self.container.menuItemHighlightColor;
        
        if (self.totalCount ==  self.menuItems.count) {
            moreRight.enabled = NO;
        } else {
            moreRight.enabled = YES;
        }
        UIImage *image = [[self class] createTriangleImageWithSize:CGSizeMake(8.7, 11) tintColor:nil isRight:YES];
        [moreRight setImage:image forState:UIControlStateNormal];
        [self.contentView addSubview:moreRight];
        
        
        UIView *line = [UIView new];
        line.backgroundColor =   self.menuTintColor?:[UIColor whiteColor];
        [self addSubview:line];
        line.frame = CGRectMake(self.frame.size.width-kMoreWidth, 0, 1/[UIScreen mainScreen].scale,self.maxSize.height-_arrowSize.height);
        [self.lines addObject:line];
    }
    [self setCorrectDirection:_CorrectDirection];
}

- (CGSize)calculateTextSize:(BBMenuItem*)obj maxWidth:(CGFloat)maxWidth
{
    NSString *text = obj.title;
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:self.container.menuItemFont ?: [UIFont systemFontOfSize:14]}];
    if (textSize.width > (maxWidth-kTitleMargin*2)) {
        return CGSizeMake((maxWidth-kTitleMargin*2), self.maxSize.height-_arrowSize.height);
    }
    return CGSizeMake(textSize.width, self.maxSize.height);
}

- (void)more:(UIButton*)btn
{
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.lines enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [obj removeFromSuperview];
    }];
    [self layoutMoreMenuViews];
}

- (void)forward:(UIButton*)btn
{
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.lines enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    if (self.pageCounts.count <= 2) {
        [self.pageCounts removeAllObjects];
        self.totalCount = 0;
        [self layoutMenuViews:NO];
    } else {
        NSInteger precount1 = [[self.pageCounts objectAtIndex:self.pageCounts.count - 1] integerValue];
        NSInteger precount2 = [[self.pageCounts objectAtIndex:self.pageCounts.count - 2] integerValue];
        [self.pageCounts removeObjectAtIndex:(self.pageCounts.count -1)];
        [self.pageCounts removeObjectAtIndex:(self.pageCounts.count -1)];
        self.totalCount =  self.totalCount - precount1-precount2;
        [self layoutMoreMenuViews];
    }
    
}

+ (UIImage *)createTriangleImageWithSize:(CGSize)size tintColor:(UIColor *)tintColor isRight:(BOOL)isRight
{
    
    UIImage *resultImage = nil;
    tintColor = tintColor ? tintColor : [UIColor whiteColor];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPath];
    if (!isRight) {
        [path moveToPoint:CGPointMake(0, size.height/2)];
        [path addLineToPoint:CGPointMake(size.width , 0)];
        [path addLineToPoint:CGPointMake(size.width, size.height)];
        [path closePath];
    } else {
        [path moveToPoint:CGPointMake(0, size.height)];
        [path addLineToPoint:CGPointMake(0 , 0)];
        [path addLineToPoint:CGPointMake(size.width, size.height/2)];
        [path closePath];
    }
    
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    [path fill];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (NSMutableArray *)pageCounts
{
    if (!_pageCounts) {
        _pageCounts = [NSMutableArray array];
    }
    return _pageCounts;
}

- (NSMutableArray *)lines
{
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}



@end
