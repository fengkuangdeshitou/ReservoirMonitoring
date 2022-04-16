//
//  HomeProgressView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/14.
//

#import "HomeProgressView.h"

@implementation HomeProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
        self.layer.cornerRadius = frame.size.height/2;
        self.layer.masksToBounds = true;
        
        UIImageView * imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"machine"]];
        imageview.frame = CGRectMake(self.width/2-21, 18, 42, 68);
        [self addSubview:imageview];
        
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath * normalPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x+1.5, rect.origin.y+1.5, rect.size.width-3, rect.size.height-3) cornerRadius:rect.size.height/2];
    normalPath.lineWidth = 3;
    normalPath.lineCapStyle = kCGLineCapRound;
    [[UIColor colorWithHexString:@"#313131"] setStroke];
    [normalPath stroke];
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/2-1.5 startAngle:-M_PI_2 endAngle:-M_PI_2+280*M_PI/180 clockwise:true];
    path.lineWidth = 3;
    path.lineCapStyle = kCGLineCapRound;
    [[UIColor colorWithHexString:COLOR_MAIN_COLOR] setStroke];
    [path stroke];
}


@end
