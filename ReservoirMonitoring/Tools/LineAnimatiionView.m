//
//  LineAnimatiionView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/7/2.
//

#import "LineAnimatiionView.h"

@implementation LineAnimatiionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.duration = 1;
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = true;
    }
    return self;
}

- (void)setSource:(AnimationSource)source{
    _source = source;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setDirection:(AnimationStartDirection)direction{
    _direction = direction;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    linePath.lineWidth = 2;
    if (self.source == AnimationSourceGrid) {
        if (self.direction == AnimationStartDirectionLeftTop) {
            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height)];
        }else if (self.direction == AnimationStartDirectionRightBottom){
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.origin.y)];
        }
    }else if (self.source == AnimationSourceSolar){
        if (self.direction == AnimationStartDirectionTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
        }else if(self.direction == AnimationStartDirectionBottom){
            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
        }
    }else if (self.source == AnimationSourceGenerator){
        if (self.direction == AnimationStartDirectionRightTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height)];
        }else if (self.direction == AnimationStartDirectionLeftBottom){
            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.origin.y)];
        }
    }else if (self.source == AnimationSourceEV){
        if (self.direction == AnimationStartDirectionRightTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height)];
        }else if (self.direction == AnimationStartDirectionLeftBottom){
            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.origin.y)];
        }
    }else if (self.source == AnimationSourceNonbackup){
        if (self.direction == AnimationStartDirectionTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
        }else if (self.direction == AnimationStartDirectionBottom){
            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
        }
    }else if (self.source == AnimationSourceBackupLoads) {
        if (self.direction == AnimationStartDirectionLeftTop) {
            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height)];
        }else if (self.direction == AnimationStartDirectionRightBottom){
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2, rect.origin.y)];
        }
    }
        
    if (self.showAnimation) {
//        [self drawAnimationWithPath:linePath color:[UIColor colorWithHexString:COLOR_MAIN_COLOR] lineWidth:4 lineCap:kCALineCapRound];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            [self drawAnimationWithPath:linePath color:[UIColor colorWithHexString:@"#0C0C0C"] lineWidth:6 lineCap:kCALineCapRound];
            [self drawAnimationWithPath:linePath color:[UIColor colorWithHexString:COLOR_MAIN_COLOR] lineWidth:linePath.lineWidth lineCap:kCALineCapSquare];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self drawAnimationWithPath:linePath color:[UIColor colorWithHexString:@"#222222"] lineWidth:linePath.lineWidth lineCap:kCALineCapSquare];
//
            });
//        });
    }
    
    
    [[UIColor colorWithHexString:@"#222222"] setStroke];
    [linePath stroke];
    
}

- (void)drawAnimationWithPath:(UIBezierPath *)path
                        color:(UIColor *)color
                    lineWidth:(CGFloat)lineWidth
                      lineCap:(CAShapeLayerLineCap)lineCap
{
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    [pathLayer setValue:@"LinePathLayer" forKey:@"LinePathLayerID" ];
    pathLayer.frame = self.bounds;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [color CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = lineWidth;
//    pathLayer.lineJoin = kCALineJoinRound;
    pathLayer.lineCap = lineCap;
    [self.layer addSublayer:pathLayer];

    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.duration;
    pathAnimation.repeatCount = CGFLOAT_MAX;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

@end
