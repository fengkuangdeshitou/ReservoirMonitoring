//
//  LineAnimatiionView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/7/2.
//

#import "LineAnimatiionView.h"

@interface LineAnimatiionView ()<CAAnimationDelegate>

@property(nonatomic,strong) UIView * pointView;
@property(nonatomic,strong) CAKeyframeAnimation * animation;
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
        self.pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        self.pointView.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        self.pointView.layer.cornerRadius = 3;
        self.pointView.hidden = true;
        [self addSubview:self.pointView];
        self.animation = [CAKeyframeAnimation animation];
        self.animation.keyPath = @"position";
        self.animation.duration = self.duration;
        self.animation.repeatCount = CGFLOAT_MAX;
        self.animation.removedOnCompletion = YES;
        self.animation.fillMode = kCAFillModeForwards;
        self.animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        self.animation.calculationMode = kCAAnimationPaced;
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
            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height)];
        }else if (self.direction == AnimationStartDirectionRightBottom){
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.origin.y)];
        }
    }else if (self.source == AnimationSourceSolar){
//        if (self.direction == AnimationStartDirectionTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
//        }else if(self.direction == AnimationStartDirectionBottom){
//            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
//            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
//        }
    }else if (self.source == AnimationSourceGenerator){
//        if (self.direction == AnimationStartDirectionRightTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.4)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height)];
//        }else if (self.direction == AnimationStartDirectionLeftBottom){
//            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height)];
//            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.6)];
//            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.6)];
//            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.origin.y)];
//        }
    }else if (self.source == AnimationSourceEV){
//        if (self.direction == AnimationStartDirectionRightTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.6)];
            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height)];
//        }else if (self.direction == AnimationStartDirectionLeftBottom){
//            [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height)];
//            [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.6)];
//            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.6)];
//            [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.origin.y)];
//        }
    }else if (self.source == AnimationSourceNonbackup){
//        if (self.direction == AnimationStartDirectionTop) {
            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
//        }else if (self.direction == AnimationStartDirectionBottom){
//            [linePath moveToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
//            [linePath addLineToPoint:CGPointMake(rect.size.width/2, rect.origin.y)];
//        }
    }else if (self.source == AnimationSourceBackupLoads) {
        [linePath moveToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.origin.y)];
        [linePath addLineToPoint:CGPointMake(rect.origin.x+linePath.lineWidth/2+self.pointView.width/2, rect.size.height*0.6)];
        [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height*0.6)];
        [linePath addLineToPoint:CGPointMake(rect.size.width-linePath.lineWidth/2-self.pointView.width/2, rect.size.height)];
    }
        
    if (self.showAnimation) {
        self.animation.path = linePath.CGPath;
        self.pointView.hidden = false;
        [self.pointView.layer addAnimation:self.animation forKey:@"animation"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self drawMainColorAnimationWithPath:linePath
                                       lineWidth:linePath.lineWidth];
            CGFloat time = (self.direction == AnimationStartDirectionTop || self.direction == AnimationStartDirectionBottom) ? 0.6 : 0.25;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self drawGrayColorAnimationWithPath:linePath
                                           lineWidth:linePath.lineWidth+0.5];
            });
        });
    }else{
        [self removeAllAnimation];
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
    self.colorLayer.lineCap = kCALineCapSquare;
    [self.layer addSublayer:self.colorLayer];

    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.duration;
    pathAnimation.repeatCount = 1;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.delegate = self;
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
    self.grayLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:self.grayLayer];

    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.duration;
    pathAnimation.repeatCount = CGFLOAT_MAX;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.grayLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void)removeAllAnimation{
    [self.colorLayer removeAllAnimations];
    [self.colorLayer removeFromSuperlayer];
    self.colorLayer = nil;
    [self.grayLayer removeAllAnimations];
    [self.grayLayer removeFromSuperlayer];
    self.grayLayer = nil;
    [self.pointView.layer removeAnimationForKey:@"animation"];
    self.pointView.hidden = true;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        [self removeAllAnimation];
        [self setNeedsDisplay];
    }
}

@end
