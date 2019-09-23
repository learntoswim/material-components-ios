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

#import "MDCContainedInputViewStyleFilled.h"

#import <Foundation/Foundation.h>

#import "MDCContainedInputView.h"
#import "MDCContainedInputViewStylePathDrawingUtils.h"
#import "MDCContainedInputViewVerticalPositioningGuideFilled.h"

static const CGFloat kFilledContainerStyleTopCornerRadius = (CGFloat)4.0;
static const CGFloat kFilledContainerStyleUnderlineWidthThin = (CGFloat)1.0;
static const CGFloat kFilledContainerStyleUnderlineWidthThick = (CGFloat)2.0;

static const CGFloat kFilledFloatingLabelScaleFactor = 0.75;

@interface MDCContainedInputViewStyleFilled () <CAAnimationDelegate>

@property(strong, nonatomic) CAShapeLayer *filledSublayer;
@property(strong, nonatomic) CAShapeLayer *thinUnderlineLayer;
@property(strong, nonatomic) CAShapeLayer *thickUnderlineLayer;

@property(strong, nonatomic, readonly, class) NSString *thickUnderlineGrowKey;
@property(strong, nonatomic, readonly, class) NSString *thickUnderlineShrinkKey;
@property(strong, nonatomic, readonly, class) NSString *thinUnderlineGrowKey;
@property(strong, nonatomic, readonly, class) NSString *thinUnderlineShrinkKey;

@property(strong, nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *underlineColors;
@property(strong, nonatomic) NSMutableDictionary<NSNumber *, UIColor *> *filledBackgroundColors;

@end

@implementation MDCContainedInputViewStyleFilled

- (instancetype)init {
  self = [super init];
  if (self) {
    [self commonMDCContainedInputViewStyleFilledInit];
  }
  return self;
}

- (void)commonMDCContainedInputViewStyleFilledInit {
  [self setUpUnderlineColors];
  [self setUpFilledBackgroundColors];
  [self setUpSublayers];
}

- (void)setUpUnderlineColors {
  self.underlineColors = [NSMutableDictionary new];
  UIColor *underlineColor = [UIColor blackColor];
  self.underlineColors[@(MDCTextControlStateNormal)] = underlineColor;
  self.underlineColors[@(MDCTextControlStateEditing)] = underlineColor;
  self.underlineColors[@(MDCTextControlStateDisabled)] = underlineColor;
}

- (void)setUpFilledBackgroundColors {
  self.filledBackgroundColors = [NSMutableDictionary new];
  UIColor *filledBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:(CGFloat)0.1];
  self.filledBackgroundColors[@(MDCTextControlStateNormal)] = filledBackgroundColor;
  self.filledBackgroundColors[@(MDCTextControlStateEditing)] = filledBackgroundColor;
  self.filledBackgroundColors[@(MDCTextControlStateDisabled)] = filledBackgroundColor;
}

- (void)setUpSublayers {
  self.filledSublayer = [[CAShapeLayer alloc] init];
  self.filledSublayer.lineWidth = 0.0;
  self.thinUnderlineLayer = [[CAShapeLayer alloc] init];
  [self.filledSublayer addSublayer:self.thinUnderlineLayer];
  self.thickUnderlineLayer = [[CAShapeLayer alloc] init];
  [self.filledSublayer addSublayer:self.thickUnderlineLayer];
}

#pragma mark Accessors

- (UIColor *)underlineColorForState:(MDCTextControlState)state {
  return self.underlineColors[@(state)];
}

- (void)setUnderlineColor:(nonnull UIColor *)underlineColor
                 forState:(MDCTextControlState)state {
  self.underlineColors[@(state)] = underlineColor;
}

- (UIColor *)filledBackgroundColorForState:(MDCTextControlState)state {
  return self.filledBackgroundColors[@(state)];
}

- (void)setFilledBackgroundColor:(nonnull UIColor *)filledBackgroundColor
                        forState:(MDCTextControlState)state {
  self.filledBackgroundColors[@(state)] = filledBackgroundColor;
}

- (void)applyStyleToContainedInputView:(id<MDCContainedInputView>)containedInputView {
  if (![containedInputView isKindOfClass:[UIView class]]) {
    [self removeStyleFrom:containedInputView];
    return;
  }
  UIView *uiView = (UIView *)containedInputView;
  [self applyStyleToView:uiView
                   state:containedInputView.textControlState
          containerFrame:containedInputView.containerFrame];
}

- (void)removeStyleFrom:(id<MDCContainedInputView>)containedInputView {
  [self.filledSublayer removeFromSuperlayer];
  [self.thinUnderlineLayer removeFromSuperlayer];
  [self.thickUnderlineLayer removeFromSuperlayer];
}

- (void)applyStyleToView:(UIView *)view
                   state:(MDCTextControlState)state
          containerFrame:(CGRect)containerFrame {
  self.filledSublayer.fillColor = [self.filledBackgroundColors[@(state)] CGColor];
  self.thinUnderlineLayer.fillColor = [self.underlineColors[@(state)] CGColor];
  self.thickUnderlineLayer.fillColor = [self.underlineColors[@(state)] CGColor];

  CGFloat containerHeight = CGRectGetMaxY(containerFrame);
  UIBezierPath *filledSublayerBezier = [self filledSublayerPathWithTextFieldBounds:view.bounds
                                                                   containerHeight:containerHeight];
  self.filledSublayer.path = filledSublayerBezier.CGPath;
  if (self.filledSublayer.superlayer != view.layer) {
    [view.layer insertSublayer:self.filledSublayer atIndex:0];
  }

  BOOL shouldShowThickUnderline = [self shouldShowThickUnderlineWithState:state];
  CGFloat viewWidth = CGRectGetWidth(view.bounds);
  CGFloat thickUnderlineWidth = shouldShowThickUnderline ? viewWidth : 0;
  UIBezierPath *targetThickUnderlineBezier =
      [self filledSublayerUnderlinePathWithViewBounds:view.bounds
                                      containerHeight:containerHeight
                                   underlineThickness:kFilledContainerStyleUnderlineWidthThick
                                       underlineWidth:thickUnderlineWidth];
  CGFloat thinUnderlineThickness =
      shouldShowThickUnderline ? 0 : kFilledContainerStyleUnderlineWidthThin;
  UIBezierPath *targetThinUnderlineBezier =
      [self filledSublayerUnderlinePathWithViewBounds:view.bounds
                                      containerHeight:containerHeight
                                   underlineThickness:thinUnderlineThickness
                                       underlineWidth:viewWidth];
  //  NSLog(@"target thick: %@",NSStringFromCGRect(targetThickUnderlineBezier.bounds));
  //  NSLog(@"target thin: %@",NSStringFromCGRect(targetThinUnderlineBezier.bounds));

  CABasicAnimation *preexistingThickUnderlineShrinkAnimation =
      (CABasicAnimation *)[self.thickUnderlineLayer
          animationForKey:self.class.thickUnderlineShrinkKey];
  CABasicAnimation *preexistingThickUnderlineGrowAnimation =
      (CABasicAnimation *)[self.thickUnderlineLayer
          animationForKey:self.class.thickUnderlineGrowKey];

  CABasicAnimation *preexistingThinUnderlineGrowAnimation =
      (CABasicAnimation *)[self.thinUnderlineLayer animationForKey:self.class.thinUnderlineGrowKey];
  CABasicAnimation *preexistingThinUnderlineShrinkAnimation =
      (CABasicAnimation *)[self.thinUnderlineLayer
          animationForKey:self.class.thinUnderlineShrinkKey];

  [CATransaction begin];
  {
    if (shouldShowThickUnderline) {
      if (preexistingThickUnderlineShrinkAnimation) {
        //        NSLog(@"removing thick shrink");
        [self.thickUnderlineLayer removeAnimationForKey:self.class.thickUnderlineShrinkKey];
      }
      BOOL needsThickUnderlineGrowAnimation = NO;
      if (preexistingThickUnderlineGrowAnimation) {
        CGPathRef toValue = (__bridge CGPathRef)preexistingThickUnderlineGrowAnimation.toValue;
        if (!CGPathEqualToPath(toValue, targetThickUnderlineBezier.CGPath)) {
          //          NSLog(@"removing out of date thick grow to:
          //          %@",NSStringFromCGRect([UIBezierPath bezierPathWithCGPath:toValue].bounds));
          [self.thickUnderlineLayer removeAnimationForKey:self.class.thickUnderlineGrowKey];
          needsThickUnderlineGrowAnimation = YES;
          self.thickUnderlineLayer.path = targetThickUnderlineBezier.CGPath;
        }
      } else {
        needsThickUnderlineGrowAnimation = YES;
      }
      if (needsThickUnderlineGrowAnimation) {
        //        NSLog(@"adding thick grow to:
        //        %@",NSStringFromCGRect(targetThickUnderlineBezier.bounds));
        [self.thickUnderlineLayer addAnimation:[self pathAnimationTo:targetThickUnderlineBezier]
                                        forKey:self.class.thickUnderlineGrowKey];
      }

      if (preexistingThinUnderlineGrowAnimation) {
        //        NSLog(@"removing thin grow");
        [self.thinUnderlineLayer removeAnimationForKey:self.class.thinUnderlineGrowKey];
      }
      BOOL needsThinUnderlineShrinkAnimation = NO;
      if (preexistingThinUnderlineShrinkAnimation) {
        CGPathRef toValue = (__bridge CGPathRef)preexistingThinUnderlineShrinkAnimation.toValue;
        if (!CGPathEqualToPath(toValue, targetThinUnderlineBezier.CGPath)) {
          //          NSLog(@"removing out of date thin shrink to:
          //          %@",NSStringFromCGRect([UIBezierPath bezierPathWithCGPath:toValue].bounds));
          [self.thinUnderlineLayer removeAnimationForKey:self.class.thinUnderlineShrinkKey];
          needsThinUnderlineShrinkAnimation = YES;
          self.thinUnderlineLayer.path = targetThinUnderlineBezier.CGPath;
        }
      } else {
        needsThinUnderlineShrinkAnimation = YES;
      }
      if (needsThinUnderlineShrinkAnimation) {
        //        NSLog(@"adding thin shrink to:
        //        %@",NSStringFromCGRect(targetThinUnderlineBezier.bounds));
        [self.thinUnderlineLayer addAnimation:[self pathAnimationTo:targetThinUnderlineBezier]
                                       forKey:self.class.thinUnderlineShrinkKey];
      }

    } else {
      if (preexistingThickUnderlineGrowAnimation) {
        //        NSLog(@"removing thick grow");
        [self.thickUnderlineLayer removeAnimationForKey:self.class.thickUnderlineGrowKey];
      }
      BOOL needsThickUnderlineShrinkAnimation = NO;
      if (preexistingThickUnderlineShrinkAnimation) {
        CGPathRef toValue = (__bridge CGPathRef)preexistingThickUnderlineShrinkAnimation.toValue;
        if (!CGPathEqualToPath(toValue, targetThickUnderlineBezier.CGPath)) {
          //          NSLog(@"removing out of date thick shrink to:
          //          %@",NSStringFromCGRect([UIBezierPath bezierPathWithCGPath:toValue].bounds));
          [self.thickUnderlineLayer removeAnimationForKey:self.class.thickUnderlineShrinkKey];
          needsThickUnderlineShrinkAnimation = YES;
          self.thickUnderlineLayer.path = targetThickUnderlineBezier.CGPath;
        }
      } else {
        needsThickUnderlineShrinkAnimation = YES;
      }
      if (needsThickUnderlineShrinkAnimation) {
        //        NSLog(@"adding thick shrink to:
        //        %@",NSStringFromCGRect(targetThickUnderlineBezier.bounds));
        [self.thickUnderlineLayer addAnimation:[self pathAnimationTo:targetThickUnderlineBezier]
                                        forKey:self.class.thickUnderlineShrinkKey];
      }

      if (preexistingThinUnderlineShrinkAnimation) {
        //        NSLog(@"removing thin shrink");
        [self.thinUnderlineLayer removeAnimationForKey:self.class.thinUnderlineShrinkKey];
      }
      BOOL needsThickUnderlineGrowAnimation = NO;
      if (preexistingThinUnderlineGrowAnimation) {
        CGPathRef toValue = (__bridge CGPathRef)preexistingThinUnderlineGrowAnimation.toValue;
        if (!CGPathEqualToPath(toValue, targetThinUnderlineBezier.CGPath)) {
          //          NSLog(@"removing out of date thin grow to:
          //          %@",NSStringFromCGRect([UIBezierPath bezierPathWithCGPath:toValue].bounds));
          [self.thinUnderlineLayer removeAnimationForKey:self.class.thinUnderlineGrowKey];
          needsThickUnderlineGrowAnimation = YES;
          self.thinUnderlineLayer.path = targetThinUnderlineBezier.CGPath;
        }
      } else {
        needsThickUnderlineGrowAnimation = YES;
      }
      if (needsThickUnderlineGrowAnimation) {
        //        NSLog(@"adding thin grow to:
        //        %@",NSStringFromCGRect(targetThinUnderlineBezier.bounds));
        [self.thinUnderlineLayer addAnimation:[self pathAnimationTo:targetThinUnderlineBezier]
                                       forKey:self.class.thinUnderlineGrowKey];
      }
    }
  }
  [CATransaction commit];
}

- (CABasicAnimation *)pathAnimationTo:(UIBezierPath *)path {
  CABasicAnimation *animation = [self basicAnimationWithKeyPath:@"path"];
  animation.toValue = (id)(path.CGPath);
  return animation;
}

- (CABasicAnimation *)basicAnimationWithKeyPath:(NSString *)keyPath {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
  animation.duration = kMDCContainedInputViewDefaultAnimationDuration;
  animation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.repeatCount = 0;
  animation.removedOnCompletion = NO;
  animation.delegate = self;
  animation.fillMode = kCAFillModeForwards;
  return animation;
}

- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (![anim isKindOfClass:[CABasicAnimation class]]) {
    return;
  }

  CABasicAnimation *animation = (CABasicAnimation *)anim;
  CGPathRef toValue = (__bridge CGPathRef)animation.toValue;

  CABasicAnimation *thickGrowAnimation = (CABasicAnimation *)[self.thickUnderlineLayer
      animationForKey:self.class.thickUnderlineGrowKey];
  CABasicAnimation *thickShrinkAnimation = (CABasicAnimation *)[self.thickUnderlineLayer
      animationForKey:self.class.thickUnderlineShrinkKey];
  CABasicAnimation *thinGrowAnimation =
      (CABasicAnimation *)[self.thinUnderlineLayer animationForKey:self.class.thinUnderlineGrowKey];
  CABasicAnimation *thinShrinkAnimation = (CABasicAnimation *)[self.thinUnderlineLayer
      animationForKey:self.class.thinUnderlineShrinkKey];

  if (flag) {
    if ((animation == thickGrowAnimation) || (animation == thickShrinkAnimation)) {
      //      NSLog(@"thick animation completed to %@",NSStringFromCGRect([UIBezierPath
      //      bezierPathWithCGPath:toValue].bounds));
      self.thickUnderlineLayer.path = toValue;
    }
    if ((animation == thinGrowAnimation) || (animation == thinShrinkAnimation)) {
      //      NSLog(@"thin animation completed to %@",NSStringFromCGRect([UIBezierPath
      //      bezierPathWithCGPath:toValue].bounds));
      self.thinUnderlineLayer.path = toValue;
    }
  } else {
    //    NSLog(@"animation to %@ was cut short",NSStringFromCGRect([UIBezierPath
    //    bezierPathWithCGPath:toValue].bounds));
  }
}

- (BOOL)shouldShowThickUnderlineWithState:(MDCTextControlState)state {
  BOOL shouldShow = NO;
  switch (state) {
    case MDCTextControlStateEditing:
      shouldShow = YES;
      break;
    case MDCTextControlStateNormal:
    case MDCTextControlStateDisabled:
    default:
      break;
  }
  return shouldShow;
}

- (UIBezierPath *)filledSublayerPathWithTextFieldBounds:(CGRect)viewBounds
                                        containerHeight:(CGFloat)containerHeight {
  UIBezierPath *path = [[UIBezierPath alloc] init];
  CGFloat topRadius = kFilledContainerStyleTopCornerRadius;
  CGFloat bottomRadius = 0;
  CGFloat textFieldWidth = CGRectGetWidth(viewBounds);
  CGFloat sublayerMinY = 0;
  CGFloat sublayerMaxY = containerHeight;

  CGPoint startingPoint = CGPointMake(topRadius, sublayerMinY);
  CGPoint topRightCornerPoint1 = CGPointMake(textFieldWidth - topRadius, sublayerMinY);
  [path moveToPoint:startingPoint];
  [path addLineToPoint:topRightCornerPoint1];

  CGPoint topRightCornerPoint2 = CGPointMake(textFieldWidth, sublayerMinY + topRadius);
  [MDCContainedInputViewStylePathDrawingUtils addTopRightCornerToPath:path
                                                            fromPoint:topRightCornerPoint1
                                                              toPoint:topRightCornerPoint2
                                                           withRadius:topRadius];

  CGPoint bottomRightCornerPoint1 = CGPointMake(textFieldWidth, sublayerMaxY - bottomRadius);
  CGPoint bottomRightCornerPoint2 = CGPointMake(textFieldWidth - bottomRadius, sublayerMaxY);
  [path addLineToPoint:bottomRightCornerPoint1];
  [MDCContainedInputViewStylePathDrawingUtils addBottomRightCornerToPath:path
                                                               fromPoint:bottomRightCornerPoint1
                                                                 toPoint:bottomRightCornerPoint2
                                                              withRadius:bottomRadius];

  CGPoint bottomLeftCornerPoint1 = CGPointMake(bottomRadius, sublayerMaxY);
  CGPoint bottomLeftCornerPoint2 = CGPointMake(0, sublayerMaxY - bottomRadius);
  [path addLineToPoint:bottomLeftCornerPoint1];
  [MDCContainedInputViewStylePathDrawingUtils addBottomLeftCornerToPath:path
                                                              fromPoint:bottomLeftCornerPoint1
                                                                toPoint:bottomLeftCornerPoint2
                                                             withRadius:bottomRadius];

  CGPoint topLeftCornerPoint1 = CGPointMake(0, sublayerMinY + topRadius);
  CGPoint topLeftCornerPoint2 = CGPointMake(topRadius, sublayerMinY);
  [path addLineToPoint:topLeftCornerPoint1];
  [MDCContainedInputViewStylePathDrawingUtils addTopLeftCornerToPath:path
                                                           fromPoint:topLeftCornerPoint1
                                                             toPoint:topLeftCornerPoint2
                                                          withRadius:topRadius];

  return path;
}

- (UIBezierPath *)filledSublayerUnderlinePathWithViewBounds:(CGRect)viewBounds
                                            containerHeight:(CGFloat)containerHeight
                                         underlineThickness:(CGFloat)underlineThickness
                                             underlineWidth:(CGFloat)underlineWidth {
  UIBezierPath *path = [[UIBezierPath alloc] init];
  CGFloat viewWidth = CGRectGetWidth(viewBounds);
  CGFloat halfViewWidth = (CGFloat)0.5 * viewWidth;
  CGFloat halfUnderlineWidth = underlineWidth * (CGFloat)0.5;
  CGFloat sublayerMinX = halfViewWidth - halfUnderlineWidth;
  CGFloat sublayerMaxX = sublayerMinX + underlineWidth;
  CGFloat sublayerMaxY = containerHeight;
  CGFloat sublayerMinY = sublayerMaxY - underlineThickness;

  CGPoint startingPoint = CGPointMake(sublayerMinX, sublayerMinY);
  CGPoint topRightCornerPoint1 = CGPointMake(sublayerMaxX, sublayerMinY);
  [path moveToPoint:startingPoint];
  [path addLineToPoint:topRightCornerPoint1];

  CGPoint topRightCornerPoint2 = CGPointMake(sublayerMaxX, sublayerMinY);
  [MDCContainedInputViewStylePathDrawingUtils addTopRightCornerToPath:path
                                                            fromPoint:topRightCornerPoint1
                                                              toPoint:topRightCornerPoint2
                                                           withRadius:0];

  CGPoint bottomRightCornerPoint1 = CGPointMake(sublayerMaxX, sublayerMaxY);
  CGPoint bottomRightCornerPoint2 = CGPointMake(sublayerMaxX, sublayerMaxY);
  [path addLineToPoint:bottomRightCornerPoint1];
  [MDCContainedInputViewStylePathDrawingUtils addBottomRightCornerToPath:path
                                                               fromPoint:bottomRightCornerPoint1
                                                                 toPoint:bottomRightCornerPoint2
                                                              withRadius:0];

  CGPoint bottomLeftCornerPoint1 = CGPointMake(sublayerMinX, sublayerMaxY);
  CGPoint bottomLeftCornerPoint2 = CGPointMake(sublayerMinX, sublayerMaxY);
  [path addLineToPoint:bottomLeftCornerPoint1];
  [MDCContainedInputViewStylePathDrawingUtils addBottomLeftCornerToPath:path
                                                              fromPoint:bottomLeftCornerPoint1
                                                                toPoint:bottomLeftCornerPoint2
                                                             withRadius:0];

  CGPoint topLeftCornerPoint1 = CGPointMake(sublayerMinX, sublayerMinY);
  CGPoint topLeftCornerPoint2 = CGPointMake(sublayerMinX, sublayerMinY);
  [path addLineToPoint:topLeftCornerPoint1];
  [MDCContainedInputViewStylePathDrawingUtils addTopLeftCornerToPath:path
                                                           fromPoint:topLeftCornerPoint1
                                                             toPoint:topLeftCornerPoint2
                                                          withRadius:0];

  return path;
}

+ (NSString *)thinUnderlineShrinkKey {
  return @"thinUnderlineShrinkKey";
}
+ (NSString *)thinUnderlineGrowKey {
  return @"thinUnderlineGrowKey";
}
+ (NSString *)thickUnderlineShrinkKey {
  return @"thickUnderlineShrinkKey";
}
+ (NSString *)thickUnderlineGrowKey {
  return @"thickUnderlineGrowKey";
}

- (id<MDCContainerStyleVerticalPositioningReference>)
    positioningReferenceWithFloatingFontLineHeight:(CGFloat)floatingLabelHeight
                              normalFontLineHeight:(CGFloat)normalFontLineHeight
                                     textRowHeight:(CGFloat)textRowHeight
                                  numberOfTextRows:(CGFloat)numberOfTextRows
                                           density:(CGFloat)density
                          preferredContainerHeight:(CGFloat)preferredContainerHeight {
  return [[MDCContainedInputViewVerticalPositioningGuideFilled alloc]
      initWithFloatingFontLineHeight:floatingLabelHeight
                normalFontLineHeight:normalFontLineHeight
                       textRowHeight:textRowHeight
                    numberOfTextRows:numberOfTextRows
                             density:density
            preferredContainerHeight:preferredContainerHeight];
}

- (UIFont *)floatingFontWithFont:(UIFont *)font {
  CGFloat scaleFactor = kFilledFloatingLabelScaleFactor;
  CGFloat floatingFontSize = font.pointSize * scaleFactor;
  return [font fontWithSize:floatingFontSize];
}

@end
