//
//  HomeItemView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/13.
//

#import "HomeItemView.h"

@implementation HomeItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 21)];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#F6F6F6"];
        self.titleLabel.textAlignment = 1;
        [self addSubview:self.titleLabel];
        
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)-3, frame.size.width, 17)];
        self.descLabel.font = [UIFont systemFontOfSize:12];
        self.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
        self.descLabel.textAlignment = 1;
        [self addSubview:self.descLabel];
        
        self.statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.statusButton.frame = CGRectMake(frame.size.width/2-30, CGRectGetMaxY(self.descLabel.frame)+4, 60, 60);
        [self addSubview:self.statusButton];
    }
    return self;
}

- (void)setIsFlip:(BOOL)isFlip{
    _isFlip = isFlip;
    if (isFlip) {
        self.statusButton.frame = CGRectMake(self.frame.size.width/2-30, 0, 60, 60);
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.statusButton.frame)+4, self.frame.size.width, 21);
        self.descLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)-3, self.frame.size.width, 17);

    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
