//
//  BBAdjustButton.h
//  BBMenuController
//
//  Created by Sun on 2017/10/19.
//  Copyright © 2017年 Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BBAdjustButtonIMGPosition) {
    BBAdjustButtonIMGPositionLeft = 0, //Default
    BBAdjustButtonIMGPositionRight,
    BBAdjustButtonIMGPositionTop,
    BBAdjustButtonIMGPositionBottom,
};

@interface BBAdjustButton : UIButton

@property (nonatomic, assign) BBAdjustButtonIMGPosition  imagePosition;

@end
