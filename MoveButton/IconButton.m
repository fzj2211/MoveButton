//
//  IconButton.m
//  MoveButton
//
//  Created by meng on 2019/7/16.
//  Copyright © 2019 meng. All rights reserved.
//

#import "IconButton.h"

@interface IconButton()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIColor *originColor;

@property (nonatomic, assign) BOOL panEnable;

@property (nonatomic, assign) CGRect lastRect;

@end

@implementation IconButton


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
    press.delegate = self;
    [self addGestureRecognizer:press];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

- (void)press:(UILongPressGestureRecognizer *)press {
    if (press.state == UIGestureRecognizerStateBegan) {
        self.lastRect = self.frame;
        [self.delegate longPressedButton:self isPressed:YES];
        self.originColor = self.backgroundColor;
        self.backgroundColor = [UIColor blackColor];
        self.panEnable = YES;
    } else if (press.state == UIGestureRecognizerStateEnded) {
        self.lastRect = CGRectZero;
        [self.delegate longPressedButton:self isPressed:NO];
        self.backgroundColor = self.originColor;
        self.panEnable = NO;
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (self.panEnable && self.superview) {
        CGPoint point = [pan locationInView:self.superview];
        self.center = point;
        CGRect frame = self.frame;
        
        if (frame.origin.x < _limitRect.origin.x) {
            frame.origin.x = _limitRect.origin.x;
        }
        if (frame.origin.y < _limitRect.origin.y) {
            frame.origin.y = _limitRect.origin.y;
        }
        if (frame.origin.x > _limitRect.origin.x + _limitRect.size.width) {
            frame.origin.x = _limitRect.origin.x + _limitRect.size.width;
        }
        if (frame.origin.y > _limitRect.origin.y + _limitRect.size.height) {
            frame.origin.y = _limitRect.origin.y + _limitRect.size.height;
        }
        
        self.frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(button:moved:)]) {
            [self.delegate button:self moved:[pan locationInView:self.superview]];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (CGRect)lastRect {
    return _lastRect;
}

@end
