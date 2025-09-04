//
//  BBMenuControllerHeader.h
//  BBMenuController
//
//  Created by Sun on 2017/10/19.
//  Copyright © 2017年 Sun. All rights reserved.
//

#ifndef BBMenuControllerHeader_h
#define BBMenuControllerHeader_h

typedef NS_ENUM(NSUInteger, BBMenuControllerArrowDirection) {
    BBMenuControllerArrowDefault, // up or down based on screen location
    BBMenuControllerArrowUp ,       // Forced upward. If the screen is not displayed,  Will do anchor displacement
    BBMenuControllerArrowDown ,     // Forced down
};

UIKIT_EXTERN NSNotificationName const BBMenuControllerWillShowMenuNotification;
UIKIT_EXTERN NSNotificationName const BBMenuControllerDidShowMenuNotification;
UIKIT_EXTERN NSNotificationName const BBMenuControllerWillHideMenuNotification;
UIKIT_EXTERN NSNotificationName const BBMenuControllerDidHideMenuNotification;
UIKIT_EXTERN NSNotificationName const BBMenuControllerMenuFrameDidChangeNotification;

#endif /* BBMenuControllerHeader_h */
