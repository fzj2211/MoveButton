//
//  ViewController.m
//  MoveButton
//
//  Created by meng on 2019/7/16.
//  Copyright © 2019 meng. All rights reserved.
//

#import "ViewController.h"
#import "IconButton.h"
#include <sys/time.h>

#define NUM_OF_BUTTONS 43
#define NUM_OF_ROWS 4
#define NUM_OF_COLS 3
#define NUM_OF_PAGES (NUM_OF_BUTTONS / (NUM_OF_ROWS * NUM_OF_COLS) + 1)
#define FULL_WIDTH [UIScreen mainScreen].bounds.size.width
#define FULL_HEIGHT [UIScreen mainScreen].bounds.size.height
#define BUTTON_WIDTH FULL_WIDTH / NUM_OF_COLS
#define BUTTON_HEIGHT FULL_HEIGHT / NUM_OF_ROWS

@interface ViewController () <IconButtonDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray <IconButton *> *buttonList;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
    self.buttonList = [NSMutableArray array];
    [self setupButtons];
    
}

- (void)setupButtons {
    NSArray *array = @[[UIColor redColor], [UIColor cyanColor],[UIColor grayColor], [UIColor greenColor], [UIColor purpleColor], [UIColor brownColor]];
    for (NSInteger i = 0; i < NUM_OF_BUTTONS; i++) {
        IconButton *btn = [[IconButton alloc] initWithFrame:[self rectForButtonAtIndex:i]];
        btn.limitRect = CGRectMake( - BUTTON_WIDTH / 3, - BUTTON_HEIGHT / 3, FULL_WIDTH * NUM_OF_PAGES - BUTTON_WIDTH / 3, FULL_HEIGHT - BUTTON_HEIGHT / 3);
        btn.delegate = self;
        [btn setTitle:[NSString stringWithFormat:@"%ld", i + 1] forState:UIControlStateNormal];
        btn.backgroundColor = [array objectAtIndex:random() % 6];
        [self.scrollView addSubview:btn];
        [_buttonList addObject:btn];
    }
}

#pragma mark - IconButtonDelegate

- (void)longPressedButton:(IconButton *)button isPressed:(BOOL)isPressed {
    [self.scrollView setScrollEnabled:!isPressed];
    if (!isPressed) {
        CGRect rect = [self rectForButtonAtIndex:[self.buttonList indexOfObject:button]];
        [UIView animateWithDuration:0.5 animations:^{
            button.frame = rect;
        }];
    } else {
        [self.scrollView bringSubviewToFront:button];
    }
}

- (void)button:(IconButton *)button moved:(CGPoint)point {
    [self.view bringSubviewToFront:button];
    NSInteger origin = [_buttonList indexOfObject:button];
    BOOL find = NO;
    NSInteger offset = 0;
    NSInteger new = 0;
    IconButton *tempBtn = nil;
    for (NSInteger i = 0; i < _buttonList.count; i++) {
        if (i == origin) {
            continue;
        }
        tempBtn = [_buttonList objectAtIndex:i];
        if (point.x > tempBtn.frame.origin.x && point.x < tempBtn.frame.origin.x + BUTTON_WIDTH && point.y > tempBtn.frame.origin.y && point.y < tempBtn.frame.origin.y + BUTTON_HEIGHT) {
            find = YES;
            new = i;
            offset = point.x < tempBtn.center.x ? 0 : 1;
        }
    }
    NSInteger ins = 0;
    if (find) {
        if (new < origin && offset == 0) {
            ins = new;
        } else if (new < origin && offset == 1) {
            ins = new + 1;
        } else if (new > origin && offset == 0) {
            ins = new - 1;
        } else if (new > origin && offset == 1) {
            ins = new;
        }
        if (ins == origin) {
            return;
        }
        [_buttonList removeObject:button];
        [_buttonList insertObject:button atIndex:ins];
        
        for (NSInteger i = 0; i < _buttonList.count; i++) {
            IconButton *btn = [_buttonList objectAtIndex:i];
            if (btn == button) {
                continue;
            }
            CGRect rect = [self rectForButtonAtIndex:i];
            if (rect.origin.x == btn.frame.origin.x && rect.origin.y == btn.frame.origin.y) {
                continue;
            } else {
                [UIView animateWithDuration:0.5 animations:^{
                    btn.frame = rect;
                }];
            }
        }
    }
    
    [self scrollAt:button];
}

- (void)scrollAt:(IconButton *)button {
    static struct timeval preTime;
    static int flg = 0;
    if (flg != 0) {
        struct timeval now;
        gettimeofday(&now, NULL);
        if (now.tv_sec + now.tv_usec / 1000000 < preTime.tv_sec + preTime.tv_usec / 1000000 + 1) {
            return;
        }
    }
    flg = 0;
    CGRect lastRect = [button lastRect];
    int offset = button.frame.origin.x < lastRect.origin.x ? -1 : 1;
    NSInteger page = self.scrollView.contentOffset.x / FULL_WIDTH + 1;
    if (offset == -1) {
        if (button.frame.origin.x + BUTTON_WIDTH / 3 + 5.f < (page - 1) * FULL_WIDTH) {
            flg = 1;
            gettimeofday(&preTime, NULL);
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollView.contentOffset = CGPointMake((page - 2) * FULL_WIDTH, 0);
            }];
            CGPoint point = button.center;
            point.x += offset * FULL_WIDTH;
            button.center = point;
        }
    } else {
        if (button.frame.origin.x + BUTTON_WIDTH * 2 / 3 - 5.f > page * FULL_WIDTH) {
            flg = 1;
            gettimeofday(&preTime, NULL);
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollView.contentOffset = CGPointMake(page * FULL_WIDTH, 0);
            }];
            CGPoint point = button.center;
            point.x += offset * FULL_WIDTH;
            button.center = point;
        }
    }
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.pageControl setCurrentPage:scrollView.contentOffset.x / FULL_WIDTH];
}

#pragma mark - private

- (CGRect)rectForButtonAtIndex:(NSInteger)index {
    NSUInteger pages = index / (NUM_OF_ROWS * NUM_OF_COLS);
    NSUInteger rows = index / NUM_OF_COLS;
    NSUInteger row = rows % NUM_OF_ROWS;
    NSUInteger col = index % NUM_OF_COLS;
    
    CGFloat x = col * BUTTON_WIDTH;
    CGFloat y = row * BUTTON_HEIGHT;
    
    return CGRectMake(x + pages * FULL_WIDTH, y, BUTTON_WIDTH, BUTTON_HEIGHT);
}


#pragma mark - getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, FULL_WIDTH, FULL_HEIGHT)];
        _scrollView.contentSize = CGSizeMake(FULL_WIDTH * NUM_OF_PAGES, FULL_HEIGHT);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, FULL_HEIGHT - 50.f, FULL_WIDTH, 50.f)];
        _pageControl.tintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor blackColor];
        _pageControl.numberOfPages = NUM_OF_PAGES;
    }
    return _pageControl;
}

@end
