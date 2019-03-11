// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MDCContainedInputView.h"

#import "MDCContainerStylePathDrawingUtils.h"

#import "MDCContainerStyleOutlined.h"

#import <Foundation/Foundation.h>

static const CGFloat kOutlinedContainerStyleCornerRadius = (CGFloat)4.0;
//static const CGFloat kFloatingPlaceholderOutlineSidePadding = (CGFloat)5.0;

static const CGFloat kOutlinedContainerStyleThinOutlineThickness = (CGFloat)1.0;
static const CGFloat kOutlinedContainerStyleThickOutlineThickness = (CGFloat)2.0;

static const CGFloat kLayerAnimationDuration = (CGFloat)2.0;

@implementation MDCContainedInputViewColorSchemeOutlined
@end

@interface MDCContainerStyleOutlined () <CAAnimationDelegate>

@property(strong, nonatomic) CAShapeLayer *outlinedSublayer;
@property(strong, nonatomic) CAShapeLayer *mask;
@property(strong, nonatomic) CAShapeLayer *mask2;
@property(strong, nonatomic) CAShapeLayer *mask3;
@property(strong, nonatomic) CAShapeLayer *mask4;
@property(strong, nonatomic) CAShapeLayer *mask5;

@property(strong, nonatomic, readonly, class) NSString *outlinePathAnimationKey;
@property(strong, nonatomic, readonly, class) NSString *outlineStrokeColorAnimationKey;
@property(strong, nonatomic, readonly, class) NSString *outlineLineWidthAnimationKey;

@end

@implementation MDCContainerStyleOutlined
@synthesize densityInformer = _densityInformer;

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setUpOutlineSublayer];
  }
  return self;
}

- (void)setUpOutlineSublayer {
  self.outlinedSublayer = [[CAShapeLayer alloc] init];
  self.outlinedSublayer.fillColor = [UIColor clearColor].CGColor;
  self.outlinedSublayer.lineWidth =
      [self outlineLineWidthForState:MDCContainedInputViewStateNormal];

  self.mask = [[CAShapeLayer alloc] init];

  self.mask2 = [[CAShapeLayer alloc] init];
  self.mask2.backgroundColor = [UIColor blackColor].CGColor;
  [self.mask addSublayer:self.mask2];

  self.mask3 = [[CAShapeLayer alloc] init];
  self.mask3.backgroundColor = [UIColor blackColor].CGColor;
  [self.mask addSublayer:self.mask3];

  self.mask4 = [[CAShapeLayer alloc] init];
  self.mask4.backgroundColor = [UIColor blackColor].CGColor;
  [self.mask addSublayer:self.mask4];

  self.mask5 = [[CAShapeLayer alloc] init];
  self.mask5.backgroundColor = [UIColor blackColor].CGColor;
  [self.mask addSublayer:self.mask5];
}

- (id<MDCContainedInputViewColorScheming>)defaultColorSchemeForState:
    (MDCContainedInputViewState)state {
  MDCContainedInputViewColorSchemeOutlined *colorScheme =
      [[MDCContainedInputViewColorSchemeOutlined alloc] init];
  UIColor *outlineColor = [UIColor blackColor];
  switch (state) {
    case MDCContainedInputViewStateNormal:
      break;
    case MDCContainedInputViewStateActivated:
      break;
    case MDCContainedInputViewStateDisabled:
      break;
    case MDCContainedInputViewStateErrored:
      outlineColor = colorScheme.errorColor;
      break;
    case MDCContainedInputViewStateFocused:
      //      outlineColor = [UIColor blackColor]//colorScheme.primaryColor;
      break;
    default:
      break;
  }
  colorScheme.outlineColor = outlineColor;
  return (id<MDCContainedInputViewColorScheming>)colorScheme;
}


#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (![anim isKindOfClass:[CABasicAnimation class]]) {
    return;
  }

  CABasicAnimation *animation = (CABasicAnimation *)anim;

  CABasicAnimation *pathAnimation =
      [self.outlinedSublayer animationForKey:self.class.outlinePathAnimationKey];
  CABasicAnimation *strokeColorAnimation =
      [self.outlinedSublayer animationForKey:self.class.outlineStrokeColorAnimationKey];
  CABasicAnimation *lineWidthAnimation =
      [self.outlinedSublayer animationForKey:self.class.outlineLineWidthAnimationKey];

  if (flag) {
    if (animation == pathAnimation) {
      CGPathRef toValue = (__bridge CGPathRef)animation.toValue;
      NSLog(@"path completed to %@",NSStringFromCGRect([UIBezierPath bezierPathWithCGPath:toValue].bounds));
      self.outlinedSublayer.path = toValue;
      [self.outlinedSublayer removeAnimationForKey:self.class.outlinePathAnimationKey];
    }
    if (animation == strokeColorAnimation) {
      CGColorRef toValue = (__bridge CGColorRef)animation.toValue;
      NSLog(@"stroke color completed to %@",[[CIColor colorWithCGColor:toValue] stringRepresentation]);
      self.outlinedSublayer.strokeColor = toValue;
      [self.outlinedSublayer removeAnimationForKey:self.class.outlineStrokeColorAnimationKey];
    }
    if (animation == lineWidthAnimation) {
      CGFloat toValue = (CGFloat)[animation.toValue floatValue];
      NSLog(@"line width completed to %@",@(toValue));
      self.outlinedSublayer.lineWidth = toValue;
      [self.outlinedSublayer removeAnimationForKey:self.class.outlineLineWidthAnimationKey];
    }
  } else {
    NSLog(@"animation to %@ was cut short",animation.keyPath);
  }
}

#pragma mark Apply Style

- (void)applyStyleToContainedInputView:(id<MDCContainedInputView>)containedInputView
    withContainedInputViewColorScheming:(id<MDCContainedInputViewColorScheming>)colorScheme {
  NSLog(@"LAYOUT");
  UIView *uiView = nil;
  if (![containedInputView isKindOfClass:[UIView class]]) {
    [self removeStyleFrom:containedInputView];
    return;
  }
  uiView = (UIView *)containedInputView;
  CGRect placeholderFrame = containedInputView.placeholderLabel.frame;
  [self applyStyleToView:uiView
                   state:containedInputView.containedInputViewState
             colorScheme:colorScheme
           containerRect:containedInputView.containerRect
        placeholderFrame:placeholderFrame];
}

- (void)applyStyleToView:(UIView *)view
                   state:(MDCContainedInputViewState)state
             colorScheme:(id<MDCContainedInputViewColorScheming>)colorScheme
           containerRect:(CGRect)containerRect
        placeholderFrame:(CGRect)placeholderFrame {
  CGColorRef targetStrokeColor = self.outlinedSublayer.strokeColor;
  if ([colorScheme isKindOfClass:[MDCContainedInputViewColorSchemeOutlined class]]) {
    MDCContainedInputViewColorSchemeOutlined *outlinedScheme =
    (MDCContainedInputViewColorSchemeOutlined *)colorScheme;
    targetStrokeColor = outlinedScheme.outlineColor.CGColor;
  }

  CGFloat topRowBottomRowDividerY = CGRectGetMaxY(containerRect);
  if (self.outlinedSublayer.superlayer != view.layer) {
    [view.layer insertSublayer:self.outlinedSublayer atIndex:0];
  }
  
  BOOL shouldShowThickUnderline = [self shouldShowThickUnderlineWithState:state];
  CGFloat targetLineThickness = shouldShowThickUnderline ? kOutlinedContainerStyleThickOutlineThickness : kOutlinedContainerStyleThinOutlineThickness;
  UIBezierPath *targetOutlineBezier = [self outlinePathWithViewBounds:view.bounds
                                                     placeholderFrame:placeholderFrame
                                              topRowBottomRowDividerY:topRowBottomRowDividerY
                                                            lineWidth:targetLineThickness];
//  NSLog(@"target thick: %@",NSStringFromCGRect(targetThickUnderlineBezier.bounds));
//  NSLog(@"target thin: %@",NSStringFromCGRect(targetThinUnderlineBezier.bounds));

  self.mask.backgroundColor = [UIColor clearColor].CGColor;
  self.mask.frame = view.bounds;
//  [self.outlinedSublayer addSublayer:self.mask];
  self.outlinedSublayer.mask = self.mask;
//  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:placeholderFrame cornerRadius:0];
//  self.mask2.fillRule = kCAFillRuleEvenOdd;
  
  //left
  self.mask2.frame = CGRectMake(-5, -5, CGRectGetMinX(placeholderFrame)+5, CGRectGetHeight(view.bounds)+10);
//  self.mask2.backgroundColor = [UIColor redColor].CGColor;
  //top
  self.mask3.frame = CGRectMake(CGRectGetMinX(placeholderFrame), CGRectGetMinY(placeholderFrame) - CGRectGetHeight(view.bounds),
                                CGRectGetWidth(placeholderFrame), CGRectGetHeight(view.bounds));
//  self.mask3.backgroundColor = [UIColor blueColor].CGColor;
  //right
  self.mask4.frame = CGRectMake(CGRectGetMaxX(placeholderFrame), -5, CGRectGetWidth(view.bounds)+5, CGRectGetHeight(view.bounds)+10);
//  self.mask4.backgroundColor = [UIColor purpleColor].CGColor;
  //bottom
  self.mask5.frame = CGRectMake(CGRectGetMinX(placeholderFrame), CGRectGetMaxY(placeholderFrame),
                                CGRectGetWidth(placeholderFrame), CGRectGetHeight(view.bounds));
//  self.mask5.backgroundColor = [UIColor yellowColor].CGColor;

  
//  self.mask.frame = view.bounds;
//  self.mask.mask = self.mask2;
//  self.mask2.frame = placeholderFrame;
//  self.mask.backgroundColor = [UIColor blueColor].CGColor;
  CABasicAnimation *preexistingPathAnimation =
      [self.outlinedSublayer animationForKey:self.class.outlinePathAnimationKey];
  CABasicAnimation *preexistingStrokeColorAnimation =
      [self.outlinedSublayer animationForKey:self.class.outlineStrokeColorAnimationKey];
  CABasicAnimation *preexistingLineWidthAnimation =
      [self.outlinedSublayer animationForKey:self.class.outlineLineWidthAnimationKey];

//  self.outlinedSublayer.strokeStart = 0.5;
  
  [CATransaction begin];
  {
    if (preexistingPathAnimation) {
      CGPathRef toValue = (__bridge CGPathRef)preexistingPathAnimation.toValue;
      if (!CGPathEqualToPath(toValue, targetOutlineBezier.CGPath)) {
        NSLog(@"removing out of date path to: %@",NSStringFromCGRect([UIBezierPath bezierPathWithCGPath:toValue].bounds));
        [self.outlinedSublayer removeAnimationForKey:self.class.outlinePathAnimationKey];
        self.outlinedSublayer.path = targetOutlineBezier.CGPath;
//        [self.outlinedSublayer addAnimation:[self pathAnimationTo:targetOutlineBezier]
//                                     forKey:self.class.outlinePathAnimationKey];
      }
    } else {
      NSLog(@"adding path to: %@",NSStringFromCGRect(targetOutlineBezier.bounds));
      [self.outlinedSublayer addAnimation:[self pathAnimationTo:targetOutlineBezier]
                                   forKey:self.class.outlinePathAnimationKey];
    }
    if (preexistingStrokeColorAnimation) {
      CGColorRef toValue = (__bridge CGColorRef)preexistingStrokeColorAnimation.toValue;
      if (!CGColorEqualToColor(toValue, targetStrokeColor)) {
        NSLog(@"removing out of date stroke color to: %@",[[CIColor colorWithCGColor:toValue] stringRepresentation]);
        [self.outlinedSublayer removeAnimationForKey:self.class.outlineStrokeColorAnimationKey];
        self.outlinedSublayer.strokeColor = targetStrokeColor;
//        [self.outlinedSublayer addAnimation:[self strokeColorAnimationTo:targetStrokeColor]
//                                     forKey:self.class.outlineStrokeColorAnimationKey];
      }
    } else {
      NSLog(@"adding stroke color to: %@",[[CIColor colorWithCGColor:targetStrokeColor] stringRepresentation]);
      [self.outlinedSublayer addAnimation:[self strokeColorAnimationTo:targetStrokeColor]
                                   forKey:self.class.outlineStrokeColorAnimationKey];
    }
    if (preexistingLineWidthAnimation) {
      CGFloat toValue = (CGFloat)[preexistingLineWidthAnimation.toValue floatValue];
      if (toValue != targetLineThickness) {
        NSLog(@"removing out of date line width to: %@",@(toValue));
        [self.outlinedSublayer removeAnimationForKey:self.class.outlineLineWidthAnimationKey];
        self.outlinedSublayer.lineWidth = targetLineThickness;
//        [self.outlinedSublayer addAnimation:[self lineWidthAnimationTo:targetLineThickness]
//                                     forKey:self.class.outlineLineWidthAnimationKey];
      }
    } else {
      NSLog(@"adding line width to: %@",@(targetLineThickness));
      [self.outlinedSublayer addAnimation:[self lineWidthAnimationTo:targetLineThickness]
                                   forKey:self.class.outlineLineWidthAnimationKey];
    }

  }
  [CATransaction commit];
}

- (CABasicAnimation *)pathAnimationTo:(UIBezierPath *)path {
  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"path"];
  animation.toValue = (id)(path.CGPath);
  return animation;
}

- (CABasicAnimation *)strokeColorAnimationTo:(CGColorRef)strokeColor {
  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"strokeColor"];
  animation.toValue = (__bridge id)(strokeColor);
  return animation;
}

- (CABasicAnimation *)lineWidthAnimationTo:(CGFloat)lineThickness {
  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"lineWidth"];
  animation.toValue = @(lineThickness);
  return animation;
}

- (CABasicAnimation *)basicAnimationWithKeyPath:(NSString *)keyPath {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
  animation.duration = kLayerAnimationDuration;
  animation.timingFunction =
  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.repeatCount = 0;
  animation.removedOnCompletion = NO;
  animation.delegate = self;
  animation.fillMode = kCAFillModeForwards;
  return animation;
}

- (BOOL)shouldShowThickUnderlineWithState:(MDCContainedInputViewState)state {
  BOOL shouldShow = NO;
  switch (state) {
    case MDCContainedInputViewStateActivated:
    case MDCContainedInputViewStateErrored:
    case MDCContainedInputViewStateFocused:
      shouldShow = YES;
      break;
    case MDCContainedInputViewStateNormal:
    case MDCContainedInputViewStateDisabled:
    default:
      break;
  }
  return shouldShow;
}

- (UIBezierPath *)outlinePathWithViewBounds:(CGRect)viewBounds
                           placeholderFrame:(CGRect)placeholderFrame
                    topRowBottomRowDividerY:(CGFloat)topRowBottomRowDividerY
                                  lineWidth:(CGFloat)lineWidth {
  UIBezierPath *path = [[UIBezierPath alloc] init];
  CGFloat radius = kOutlinedContainerStyleCornerRadius;
  CGFloat textFieldWidth = CGRectGetWidth(viewBounds);
  CGFloat sublayerMinY = 0;
  CGFloat sublayerMaxY = topRowBottomRowDividerY;

  CGPoint startingPoint = CGPointMake(radius, sublayerMinY);
  CGPoint topRightCornerPoint1 = CGPointMake(textFieldWidth - radius, sublayerMinY);
  [path moveToPoint:startingPoint];

//  BOOL isFloatingPlaceholder =
//      (CGRectGetMinY(placeholderFrame) < 0) && (CGRectGetMaxY(placeholderFrame) > 0);
  
//  if (isFloatingPlaceholder) {
//    CGFloat leftLineBreak =
//        CGRectGetMinX(placeholderFrame) - kFloatingPlaceholderOutlineSidePadding;
//    [path addLineToPoint:CGPointMake(leftLineBreak, sublayerMinY)];
//
//    CGFloat rightLineBreak =
//        CGRectGetMaxX(placeholderFrame) + kFloatingPlaceholderOutlineSidePadding;
//    [path moveToPoint:CGPointMake(rightLineBreak, sublayerMinY)];
//    [path addLineToPoint:CGPointMake(rightLineBreak, sublayerMinY)];
//    [path addLineToPoint:topRightCornerPoint1];
//  } else {
    [path addLineToPoint:CGPointMake(topRightCornerPoint1.x, topRightCornerPoint1.y)];
//  }

  CGPoint topRightCornerPoint2 = CGPointMake(textFieldWidth, sublayerMinY + radius);
  [MDCContainerStylePathDrawingUtils addTopRightCornerToPath:path
                                                   fromPoint:topRightCornerPoint1
                                                     toPoint:topRightCornerPoint2
                                                  withRadius:radius];

  CGPoint bottomRightCornerPoint1 = CGPointMake(textFieldWidth, sublayerMaxY - radius);
  CGPoint bottomRightCornerPoint2 = CGPointMake(textFieldWidth - radius, sublayerMaxY);
  [path addLineToPoint:bottomRightCornerPoint1];
  [MDCContainerStylePathDrawingUtils addBottomRightCornerToPath:path
                                                      fromPoint:bottomRightCornerPoint1
                                                        toPoint:bottomRightCornerPoint2
                                                     withRadius:radius];

  CGPoint bottomLeftCornerPoint1 = CGPointMake(radius, sublayerMaxY);
  CGPoint bottomLeftCornerPoint2 = CGPointMake(0, sublayerMaxY - radius);
  [path addLineToPoint:bottomLeftCornerPoint1];
  [MDCContainerStylePathDrawingUtils addBottomLeftCornerToPath:path
                                                     fromPoint:bottomLeftCornerPoint1
                                                       toPoint:bottomLeftCornerPoint2
                                                    withRadius:radius];

  CGPoint topLeftCornerPoint1 = CGPointMake(0, sublayerMinY + radius);
  CGPoint topLeftCornerPoint2 = CGPointMake(radius, sublayerMinY);
  [path addLineToPoint:topLeftCornerPoint1];
  [MDCContainerStylePathDrawingUtils addTopLeftCornerToPath:path
                                                  fromPoint:topLeftCornerPoint1
                                                    toPoint:topLeftCornerPoint2
                                                 withRadius:radius];
  [path addLineToPoint:startingPoint];
  return path;
}

- (CGFloat)outlineLineWidthForState:(MDCContainedInputViewState)containedInputViewState {
  CGFloat defaultLineWidth = 1;
  switch (containedInputViewState) {
    case MDCContainedInputViewStateActivated:
    case MDCContainedInputViewStateErrored:
    case MDCContainedInputViewStateFocused:
      defaultLineWidth = 2;
      break;
    case MDCContainedInputViewStateNormal:
    case MDCContainedInputViewStateDisabled:
    default:
      break;
  }
  return defaultLineWidth;
}

+(NSString *)outlinePathAnimationKey {
  return @"outlinePathAnimationKey";
}
+(NSString *)outlineStrokeColorAnimationKey {
  return @"outlineStrokeColorAnimationKey";
}
+(NSString *)outlineLineWidthAnimationKey {
  return @"outlineLineWidthAnimationKey";
}

- (id<MDCContainedInputViewStyleDensityInforming>)densityInformer {
  if (_densityInformer) {
    return _densityInformer;
  }
  return [[MDCContainerStyleOutlinedDensityInformer alloc] init];
}

@end

@implementation MDCContainerStyleOutlinedDensityInformer

- (CGFloat)floatingPlaceholderMinYWithFloatingPlaceholderHeight:(CGFloat)floatingPlaceholderHeight {
  return (CGFloat)0 - ((CGFloat)0.5 * floatingPlaceholderHeight);
}

- (CGFloat)contentAreaTopPaddingFloatingPlaceholderWithFloatingPlaceholderMaxY:
    (CGFloat)floatingPlaceholderMaxY {
  return [self contentAreaVerticalPaddingNormalWithFloatingPlaceholderMaxY:floatingPlaceholderMaxY];
}

@end
