//
//  BBMenuController.m
//  BBMenuController
//
//  Created by Sun on 2017/9/27.
//  Copyright © 2017年 Sun. All rights reserved.
//

#import "BBMenuController.h"
#import "BBMenuEffectsWindow.h"
#import "BBMenuViewContainer.h"
#import "BBMenuController_internal.h"

NSNotificationName  const BBMenuControllerWillShowMenuNotification = @"BBMenuControllerWillShowMenuNotification_private";
NSNotificationName  const BBMenuControllerDidShowMenuNotification= @"BBMenuControllerDidShowMenuNotification_private";
NSNotificationName  const BBMenuControllerWillHideMenuNotification= @"BBMenuControllerWillHideMenuNotification_private";
NSNotificationName  const BBMenuControllerDidHideMenuNotification= @"BBMenuControllerDidHideMenuNotification_private";
NSNotificationName  const BBMenuControllerMenuFrameDidChangeNotification= @"BBMenuControllerMenuFrameDidChangeNotification_private";

@implementation BBMenuController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menuViewContainer = [BBMenuViewContainer new];
    }
    return self;
}

#pragma mark - public Method

+ (BBMenuController *)sharedMenuController
{
    static BBMenuController *inst = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [BBMenuController new];
    });
    return inst;
}

- (BOOL)isMenuVisible
{
    return [BBMenuEffectsWindow sharedWindow].isMenuVisible;
}

- (void)setMenuVisible:(BOOL)menuVisible
{
    [self setMenuVisible:menuVisible animated:YES];
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
    if (menuVisible) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BBMenuControllerWillShowMenuNotification object:nil];
        [self showMenuWithAnimated:animated];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:BBMenuControllerWillHideMenuNotification object:nil];
        [[BBMenuEffectsWindow sharedWindow] hideMenu:self.menuViewContainer];
    }
}

- (void)showMenuWithAnimated:(BOOL)animated
{
   [[BBMenuEffectsWindow sharedWindow] showMenu:self.menuViewContainer animation:YES];
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView
{
    if (!self.menuViewContainer) return;
    self.targetView = targetView;
    [self.menuViewContainer setTargetRect:targetRect inView:targetView];
}

- (void)setMenuItems:(NSArray<BBMenuItem *> *)menuItems
{
    _menuItems = menuItems;
    self.menuViewContainer.menuItems = menuItems;
}

- (void)update
{
    [self.menuViewContainer processMenuFrame];
}

- (void)reset
{
    [self.menuViewContainer initConfigs];
}

- (CGRect)menuFrame
{
    return self.menuViewContainer ? self.menuViewContainer.frame :CGRectZero;
}

- (void)setArrowDirection:(BBMenuControllerArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    self.menuViewContainer.arrowDirection = arrowDirection;
}

@end

@implementation BBMenuItem

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
        self.image = image;
    }
    return self;
}

@end
