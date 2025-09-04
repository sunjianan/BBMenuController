//
//  BBMenuEffectsWindow.h
//  BBMenuController
//
//  Created by Sun on 2017/9/27.
//  Copyright © 2017年 Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBMenuViewContainer;
@interface BBMenuEffectsWindow : UIWindow

@property(nonatomic,getter=isMenuVisible) BOOL menuVisible;        // default is NO

+ (instancetype)sharedWindow;

- (void)showMenu:(BBMenuViewContainer *)menu animation:(BOOL)animation;

- (void)hideMenu:(BBMenuViewContainer *)menu;

- (void)hide;

@end
    
