//
//  ScanView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "ScanView.h"

@implementation ScanView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        for (int i=0; i<4; i++) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i%2*(SCREEN_WIDTH-60-25)+30, i/2*(SCREEN_WIDTH-60-25)+30, 25, 25)];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"path-%d",i+1]];
            [self addSubview:imageView];
        }
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(33, 33, self.width-66, self.height-66)];
    path.lineWidth = 1;
    [[UIColor colorWithHexString:@"#747474"] setStroke];
    [path stroke];
    
}


@end
