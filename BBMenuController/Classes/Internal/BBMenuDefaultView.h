//
//  BBMenuDefaultView.h
//  BBMenuController
//
//  Created by Sun on 2017/9/29.
//  Copyright © 2017年 Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBMenuControllerHeader.h"
@class BBMenuItem,BBMenuViewContainer;
@interface BBMenuDefaultView : UIView
@property (nonatomic, strong) NSArray<BBMenuItem*>* menuItems;
@property (nonatomic, assign) CGSize  maxSize;
@property (nonatomic, assign) CGSize  arrowSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, strong) UIColor  *menuTintColor;
@property (nonatomic, assign) BBMenuControllerArrowDirection  CorrectDirection;
+(instancetype)defaultView:(BBMenuViewContainer*)container WithMenuItems:(NSArray<BBMenuItem*>*)menuItems MaxSize:(CGSize)maxSize arrowSize:(CGSize)arrowSize AnchorPoint:(CGPoint)anchorPoint;
- (void)processLineWithMidX:(CGFloat)midX direction:(BBMenuControllerArrowDirection)direction;
@end
