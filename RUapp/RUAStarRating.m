//
//  RUAStarRating.m
//  RUapp
//
//  Created by Igor Camilo on 2014-05-20.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAStarRating.h"

@implementation RUAStarRating

- (void)layoutSubviews
{
    CGFloat fontSize = 0;
    NSAttributedString *sixStarsAttrString;
    CGRect sixStarsBounds, selfBounds = self.bounds;
    do {
        sixStarsAttrString = [[NSAttributedString alloc] initWithString:@"★★★★★★" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:++fontSize]}];
        sixStarsBounds = [sixStarsAttrString boundingRectWithSize:CGRectInfinite.size options:kNilOptions context:nil];
        sixStarsBounds.origin = CGPointZero;
    } while (CGRectContainsRect(selfBounds, sixStarsBounds));
    NSLog(@"fontsize: %f", --fontSize);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
★★★☆☆
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
