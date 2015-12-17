//
//  Copyright (c) 2013 modocache
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "MDCScrollBarLabel.h"
#import <QuartzCore/QuartzCore.h>


#undef DEGREES_TO_RADIANS
#define DEGREES_TO_RADIANS(x) M_PI * (x) / 180.0


static CGFloat const kMDCScrollBarLabelWidth = 56.0f;
static CGFloat const kMDCScrollBarLabelHeight = 32.0f;
static CGFloat const kMDCScrollBarLabelDefaultHorizontalPadding = 10.0f;
static CGFloat const kMDCScrollBarLabelDefaultVerticalPadding = 30.0f;


typedef enum {
    MDCClockHandTypeHour = 0,
    MDCClockHandTypeMinute
} MDCClockHandType;


@interface MDCScrollBarLabel ()
@property (nonatomic, strong) NSDate *displayedDate;
@end


@implementation MDCScrollBarLabel


#pragma mark - Object Lifecycle

- (id)initWithScrollView:(UIScrollView *)scrollView {
    CGRect frame = CGRectMake(scrollView.frame.size.width - kMDCScrollBarLabelWidth,
                              kMDCScrollBarLabelDefaultVerticalPadding,
                              kMDCScrollBarLabelWidth,
                              kMDCScrollBarLabelHeight);

    self = [super initWithFrame:frame];
    if (self) {
        _horizontalPadding = kMDCScrollBarLabelDefaultHorizontalPadding;
        _verticalPadding = kMDCScrollBarLabelDefaultVerticalPadding;

        _scrollView = scrollView;

        self.alpha = 0.0f;
        self.backgroundColor = [UIColor clearColor];

        UIImage *backgroundImage = [UIImage imageNamed:@"label-background.png"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:15.0f
                                                               topCapHeight:5.0f];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:backgroundImageView];

        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        _label.shadowColor = [UIColor darkTextColor];
        _label.shadowOffset = CGSizeMake(0, -1);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.adjustsFontSizeToFitWidth = true;
        _label.minimumFontSize = 10;
        [self addSubview:_label];
    }
    return self;
}


#pragma mark - Public Interface

- (void)adjustPositionForScrollView:(UIScrollView *)scrollView {
    CGSize size = self.frame.size;
    CGPoint origin = self.frame.origin;
    UIView *indicator = [[scrollView subviews] lastObject];

    float y = \
        scrollView.contentOffset.y \
        + scrollView.contentOffset.y * (scrollView.frame.size.height/scrollView.contentSize.height)
        + scrollView.frame.size.height/scrollView.contentSize.height \
        + (indicator.frame.size.height - size.height)/2;

    float topLimit = self.verticalPadding + scrollView.contentOffset.y;

    if (y < topLimit || isnan(y)) {
        y = topLimit;
    }

    self.frame = CGRectMake(origin.x, y, size.width, size.height);
}

- (void)setDisplayed:(BOOL)displayed animated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    CGFloat end = displayed ? -self.horizontalPadding : 0.0;

    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:self.fadeAnimationDuration
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, end, 0.0);
                         self.alpha = displayed ? 1.0f : 0.0f;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.center = CGPointMake(floorf(self.scrollView.frame.size.width - self.frame.size.width/2),
                                                       self.center.y);
                             _displayed = YES;
                         }
                     }];
    [UIView setAnimationsEnabled:animationsEnabled];
}


#pragma mark - Internal Methods
@end
