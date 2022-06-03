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
        imageview.frame = CGRectMake(self.width/2-30, 23, 60, 60);
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageview];
        
        self.titleLabel = [[UILabel alloc] init];
        [self addSubview:self.titleLabel];
        self.titleLabel.textAlignment = 1;
        self.titleLabel.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        self.titleLabel.text = @"";
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(imageview.mas_centerX);
                make.top.mas_equalTo(imageview.mas_bottom).offset(8);
                make.height.mas_equalTo(14);
        }];
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
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/2-1.5 startAngle:-M_PI_2 endAngle:-M_PI_2+(360*self.progress)*M_PI/180 clockwise:true];
    path.lineWidth = 3;
    path.lineCapStyle = kCGLineCapRound;
    [[UIColor colorWithHexString:COLOR_MAIN_COLOR] setStroke];
    [path stroke];
}


@end
