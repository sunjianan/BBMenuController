//
//  BBMenuController_internal.h
//  BBMenuController
//
//  Created by v on 2019/11/7.
//  Copyright © 2019 Sun. All rights reserved.
//

#ifndef BBMenuController_internal_h
#define BBMenuController_internal_h

@interface BBMenuController ()

@property (nonatomic, weak) UIView * targetView;
@property (nonatomic, readonly) CGRect menuFrame;

- (void)update;

- (void)reset; /// reset menuViewContrainer configs

@end

@interface BBMenuItem ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) id target;
@property (nonatomic) SEL action;

@end

#endif /* BBMenuController_internal_h */
