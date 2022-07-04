//
//  LineAnimatiionView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/7/2.
//

#import "LineAnimatiionView.h"

@interface LineAnimatiionView ()

@property(nonatomic,strong) CAShapeLayer *colorLayer;
@property(nonatomic,strong) CAShapeLayer *grayLayer;

@end

@implementation LineAnimatiionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.duration = 1.5;
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = true;
    }
    return self;
}

- (void)setSource:(AnimationSource)source{
    _source = source;
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

- (void)setDirection:(AnimationStartDirection)direction{
    _direction = direction;
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

- (void)setShowAnimation:(BOOL)showAnimation{
    _showAnimation = showAnimation;
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    linePath.lineWidth = 2.5;
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
            [self drawMainColorAnimationWithPath:linePath
                                       lineWidth:linePath.lineWidth];
            CGFloat time = (self.direction == AnimationStartDirectionTop || self.direction == AnimationStartDirectionBottom) ? 0.6 : 0.25;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self drawGrayColorAnimationWithPath:linePath
                                           lineWidth:linePath.lineWidth+0.5];
            });
//        });
    }else{
        [self.colorLayer removeFromSuperlayer];
        self.colorLayer = nil;
    }
    
    
    [[UIColor colorWithHexString:@"#222222"] setStroke];
    [linePath stroke];
    
}

- (void)drawMainColorAnimationWithPath:(UIBezierPath *)path
                             lineWidth:(CGFloat)lineWidth
{
    if (!_colorLayer) {
        _colorLayer = [CAShapeLayer layer];
    }
    [self.colorLayer setValue:@"LinePathLayer" forKey:@"LinePathLayerID" ];
    self.colorLayer.frame = self.bounds;
    self.colorLayer.path = path.CGPath;
    self.colorLayer.strokeColor = [[UIColor colorWithHexString:COLOR_MAIN_COLOR] CGColor];
    self.colorLayer.fillColor = nil;
    self.colorLayer.lineWidth = lineWidth;
//    pathLayer.lineJoin = kCALineJoinRound;
    self.colorLayer.lineCap = kCALineCapSquare;
    [self.layer addSublayer:self.colorLayer];

    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.duration;
    pathAnimation.repeatCount = CGFLOAT_MAX;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.colorLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

- (void)drawGrayColorAnimationWithPath:(UIBezierPath *)path
                             lineWidth:(CGFloat)lineWidth
{
    if (!_grayLayer) {
        _grayLayer = [CAShapeLayer layer];
    }
    [self.grayLayer setValue:@"LinePathLayer" forKey:@"LinePathLayerID" ];
    self.grayLayer.frame = self.bounds;
    self.grayLayer.path = path.CGPath;
    self.grayLayer.strokeColor = [[UIColor colorWithHexString:@"#222222"] CGColor];
    self.grayLayer.fillColor = nil;
    self.grayLayer.lineWidth = lineWidth;
//    pathLayer.lineJoin = kCALineJoinRound;
    self.grayLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:self.grayLayer];

    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.duration;
    pathAnimation.repeatCount = CGFLOAT_MAX;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.grayLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

@end
