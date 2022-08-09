//
//  RefreshBackFooter.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/8/9.
//

#import "RefreshBackFooter.h"

@implementation RefreshBackFooter

- (void)prepare{
    [super prepare];
    self.stateLabel.text = @"Loading";
    self.stateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
