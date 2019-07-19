//
//  IconButton.h
//  MoveButton
//
//  Created by meng on 2019/7/16.
//  Copyright © 2019 meng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IconButton;

@protocol IconButtonDelegate <NSObject>

- (void)longPressedButton:(IconButton *)button isPressed:(BOOL)isPressed;

- (void)button:(IconButton *)button moved:(CGPoint)point;

@end

@interface IconButton : UIButton

@property (nonatomic, weak) id <IconButtonDelegate> delegate;

@property (nonatomic, assign) CGRect limitRect;

- (CGRect)lastRect;

@end

NS_ASSUME_NONNULL_END
