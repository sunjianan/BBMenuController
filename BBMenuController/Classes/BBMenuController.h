//
//  BBMenuController.h
//  BBMenuController
//
//  Created by Sun on 2017/9/27.
//  Copyright © 2017年 Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBMenuControllerHeader.h"
#import "BBMenuViewContainer.h"

NS_ASSUME_NONNULL_BEGIN

@class BBMenuItem, BBMenuViewContainer;

@interface BBMenuController : NSObject

+ (BBMenuController *)sharedMenuController;

@property(nonatomic,getter=isMenuVisible) BOOL menuVisible;        // default is NO

@property(nonatomic) BBMenuControllerArrowDirection arrowDirection ; // default is BBMenuControllerArrowDefault

@property(nullable, nonatomic,copy) NSArray<BBMenuItem *> *menuItems; // default is nil. these are in addition to the standard items

@property (nonatomic, readonly) BBMenuViewContainer * menuViewContainer;

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface BBMenuItem : NSObject

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image target:(id)target action:(SEL)action;

@end
NS_ASSUME_NONNULL_END
