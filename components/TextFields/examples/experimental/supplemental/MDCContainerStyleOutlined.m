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
static const CGFloat kFloatingPlaceholderOutlineSidePadding = (CGFloat)5.0;

static const CGFloat kOutlinedContainerStyleThinOutlineThickness = (CGFloat)1.0;
static const CGFloat kOutlinedContainerStyleThickOutlineThickness = (CGFloat)2.0;

static const CGFloat kLayerAnimationDuration = (CGFloat)2.0;

@implementation MDCContainedInputViewColorSchemeOutlined
@end

@interface MDCContainerStyleOutlined () <CAAnimationDelegate>

@property(strong, nonatomic) CAShapeLayer *thinOutline;
@property(strong, nonatomic) CAShapeLayer *thickOutline;

//@property(strong, nonatomic, readonly, class) NSString *outlinePathAnimationKey;
//@property(strong, nonatomic, readonly, class) NSString *outlineStrokeColorAnimationKey;
//@property(strong, nonatomic, readonly, class) NSString *outlineLineWidthAnimationKey;

@end

@implementation MDCContainerStyleOutlined
@synthesize densityInformer = _densityInformer;

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setUpOutlineSublayers];
  }
  return self;
}

- (void)setUpOutlineSublayers {
  self.thinOutline = [[CAShapeLayer alloc] init];
  self.thinOutline.fillColor = [UIColor clearColor].CGColor;
  self.thinOutline.lineWidth = kOutlinedContainerStyleThinOutlineThickness;
      [self outlineLineWidthForState:MDCContainedInputViewStateNormal];
  self.thickOutline = [[CAShapeLayer alloc] init];
  self.thickOutline.fillColor = [UIColor clearColor].CGColor;
  self.thickOutline.lineWidth = kOutlinedContainerStyleThickOutlineThickness;
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

  CABasicAnimation *thickColorAnimation =
      [self.thickOutline animationForKey:self.class.thickOutlineColorAnimationKey];
  CABasicAnimation *thinColorAnimation =
      [self.thinOutline animationForKey:self.class.thinOutlineColorAnimationKey];

  if (flag) {
    if (animation == thinColorAnimation) {
//      CGColorRef toValue = (__bridge CGColorRef)animation.toValue;
      CGFloat toValue = (CGFloat)[animation.toValue floatValue];
      NSLog(@"stroke color completed to %@",@(toValue));
      [self.thinOutline removeAnimationForKey:self.class.thinOutlineColorAnimationKey];
      self.thinOutline.opacity = (float)toValue;
    }
    if (animation == thickColorAnimation) {
      CGFloat toValue = (CGFloat)[animation.toValue floatValue];
      NSLog(@"stroke color completed to %@",@(toValue));
      [self.thickOutline removeAnimationForKey:self.class.thickOutlineColorAnimationKey];
      self.thickOutline.opacity = (float)toValue;
    }
  } else {
    NSLog(@"animation to %@ was cut short",animation.keyPath);
  }
}

#pragma mark Apply Style

- (void)applyStyleToContainedInputView:(id<MDCContainedInputView>)containedInputView
    withContainedInputViewColorScheming:(id<MDCContainedInputViewColorScheming>)colorScheme {
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
  if (self.thinOutline.superlayer != view.layer) {
    [view.layer insertSublayer:self.thinOutline atIndex:0];
  }
  if (self.thickOutline.superlayer != view.layer) {
    [view.layer insertSublayer:self.thickOutline atIndex:0];
  }

  CGColorRef outlineColor = [UIColor clearColor].CGColor;
  if ([colorScheme isKindOfClass:[MDCContainedInputViewColorSchemeOutlined class]]) {
    MDCContainedInputViewColorSchemeOutlined *outlinedScheme =
    (MDCContainedInputViewColorSchemeOutlined *)colorScheme;
    outlineColor = outlinedScheme.outlineColor.CGColor;
  }

  BOOL shouldShowThickUnderline = [self shouldShowThickUnderlineWithState:state];

  CGFloat topRowBottomRowDividerY = CGRectGetMaxY(containerRect);
  UIBezierPath *thinOutlineBezier = [self outlinePathWithViewBounds:view.bounds
                                                      avoidanceRect:CGRectZero
                                            topRowBottomRowDividerY:topRowBottomRowDividerY
                                                          lineWidth:kOutlinedContainerStyleThinOutlineThickness];
  UIBezierPath *thickOutlineBezier = [self outlinePathWithViewBounds:view.bounds
                                                       avoidanceRect:placeholderFrame
                                             topRowBottomRowDividerY:topRowBottomRowDividerY
                                                           lineWidth:kOutlinedContainerStyleThickOutlineThickness];


  //  CGColorRef targetThinOutlineColor = outlineColor;
//  CGColorRef targetThickOutlineColor = outlineColor;
  self.thickOutline.path = thickOutlineBezier.CGPath;
  self.thinOutline.path = thinOutlineBezier.CGPath;
  if (shouldShowThickUnderline) {
//    targetThinOutlineColor = [UIColor clearColor].CGColor;
//    targetThickOutlineColor = outlineColor;
    self.thickOutline.strokeColor = outlineColor;
  } else {
//    targetThinOutlineColor = outlineColor;
//    targetThickOutlineColor = [UIColor clearColor].CGColor;
    self.thinOutline.strokeColor = outlineColor;
  }


  CGFloat targetThickOutlineOpacity = shouldShowThickUnderline ? 1.0 : 0.0;
  CGFloat targetThinOutlineOpacity = shouldShowThickUnderline ? 0.0 : 1.0;
//  NSLog(@"target thick: %@",NSStringFromCGRect(targetThickUnderlineBezier.bounds));
//  NSLog(@"target thin: %@",NSStringFromCGRect(targetThinUnderlineBezier.bounds));

  CABasicAnimation *preexistingThinOutlineOpacityAnimation =
      [self.thinOutline animationForKey:self.class.thinOutlineColorAnimationKey];
  CABasicAnimation *preexistingThickOutlineOpacityAnimation =
      [self.thickOutline animationForKey:self.class.thickOutlineColorAnimationKey];

  [CATransaction begin];
  {
    if (preexistingThinOutlineOpacityAnimation) {
//      CGColorRef toValue = (__bridge CGColorRef)preexistingThinOutlineOpacityAnimation.toValue;
      CGFloat toValue = (CGFloat)[preexistingThinOutlineOpacityAnimation.toValue floatValue];
      if (toValue == targetThinOutlineOpacity) {
        NSLog(@"removing out of date opacity to: %@",@(toValue));
        [self.thinOutline removeAnimationForKey:self.class.thinOutlineColorAnimationKey];
        self.thinOutline.opacity = (float)targetThinOutlineOpacity;
      }
    } else {
      
//      CABasicAnimation *anim = [self opacityAnimationTo:targetThinOutlineOpacity];
//      anim.tim
      NSLog(@"adding stroke opacity to: %@",@(targetThinOutlineOpacity));
      [self.thinOutline addAnimation:[self opacityAnimationTo:targetThinOutlineOpacity]
                                   forKey:self.class.thinOutlineColorAnimationKey];
    }
    if (preexistingThickOutlineOpacityAnimation) {
      CGFloat toValue = (CGFloat)[preexistingThickOutlineOpacityAnimation.toValue floatValue];
      if (toValue == targetThickOutlineOpacity) {
        NSLog(@"removing out of date opacity to: %@",@(toValue));
        [self.thickOutline removeAnimationForKey:self.class.thickOutlineColorAnimationKey];
        self.thickOutline.opacity = (float)targetThickOutlineOpacity;
      }
    } else {
      NSLog(@"adding stroke color to: %@",@(targetThickOutlineOpacity));
      [self.thickOutline addAnimation:[self opacityAnimationTo:targetThickOutlineOpacity]
                              forKey:self.class.thickOutlineColorAnimationKey];
    }
  }
  [CATransaction commit];
}

- (CABasicAnimation *)opacityAnimationTo:(CGFloat)opacity {
  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"opacity"];
  animation.toValue = @(opacity);
  return animation;
}

//- (CABasicAnimation *)pathAnimationTo:(UIBezierPath *)path {
//  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"path"];
//  animation.toValue = (id)(path.CGPath);
//  return animation;
//}
//
//- (CABasicAnimation *)strokeColorAnimationTo:(CGColorRef)strokeColor {
//  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"strokeColor"];
//  animation.toValue = (__bridge id)(strokeColor);
//  return animation;
//}
//
//- (CABasicAnimation *)lineWidthAnimationTo:(CGFloat)lineThickness {
//  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"lineWidth"];
//  animation.toValue = @(lineThickness);
//  return animation;
//}

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
                              avoidanceRect:(CGRect)placeholderFrame
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
  
  BOOL isFloatingPlaceholder =
      (CGRectGetMinY(placeholderFrame) < 0) && (CGRectGetMaxY(placeholderFrame) > 0);
  
  if (isFloatingPlaceholder) {
    CGFloat leftLineBreak =
        CGRectGetMinX(placeholderFrame) - kFloatingPlaceholderOutlineSidePadding;
    CGFloat rightLineBreak =
        CGRectGetMaxX(placeholderFrame) + kFloatingPlaceholderOutlineSidePadding;
    [path addLineToPoint:CGPointMake(leftLineBreak, sublayerMinY)];
    [path moveToPoint:CGPointMake(rightLineBreak, sublayerMinY)];
    [path addLineToPoint:CGPointMake(rightLineBreak, sublayerMinY)];
  } else {
    [path addLineToPoint:topRightCornerPoint1];
  }

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

+(NSString *)thinOutlineColorAnimationKey {
  return @"thinOutlineColorAnimationKey";
}
+(NSString *)thickOutlineColorAnimationKey {
  return @"thinOutlineColorAnimationKey";
}
//+(NSString *)outlinePathAnimationKey {
//  return @"outlinePathAnimationKey";
//}
//+(NSString *)outlineStrokeColorAnimationKey {
//  return @"outlineStrokeColorAnimationKey";
//}
//+(NSString *)outlineLineWidthAnimationKey {
//  return @"outlineLineWidthAnimationKey";
//}

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
