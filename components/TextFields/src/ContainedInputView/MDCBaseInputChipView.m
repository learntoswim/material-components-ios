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

#import "MDCBaseInputChipView.h"

#import <CoreGraphics/CoreGraphics.h>
#import <MDFInternationalization/MDFInternationalization.h>
#import <QuartzCore/QuartzCore.h>

#import "MaterialMath.h"
#import "MaterialTypography.h"
#import "private/MDCBaseInputChipView+MDCContainedInputView.h"
#import "private/MDCBaseInputChipViewLayout.h"
#import "private/MDCContainedInputAssistiveLabelView.h"
#import "private/MDCContainedInputView.h"
#import "private/MDCContainedInputViewColorViewModel.h"
#import "private/MDCContainedInputViewLabelAnimation.h"
#import "private/MDCContainedInputViewStyleBase.h"

@class MDCBaseInputChipViewTextField;
@protocol MDCBaseInputChipViewTextFieldDelegate <NSObject>
- (void)inputChipViewTextFieldDidDeleteBackward:(MDCBaseInputChipViewTextField *)textField
                                        oldText:(NSString *)oldText
                                        newText:(NSString *)newText;
- (void)inputChipViewTextFieldDidBecomeFirstResponder:(BOOL)didBecome;
- (void)inputChipViewTextFieldDidResignFirstResponder:(BOOL)didResign;
@end

@interface MDCBaseInputChipViewTextField : UITextField
@property(nonatomic, weak) id<MDCBaseInputChipViewTextFieldDelegate> inputChipViewTextFieldDelegate;
@end

@implementation MDCBaseInputChipViewTextField

- (UIFont *)font {
  return [super font] ?: [self uiTextFieldDefaultFont];
}

- (void)setFont:(UIFont *)font {
  [super setFont:font];
}

- (void)deleteBackward {
  NSString *oldText = self.text;
  [super deleteBackward];
  if ([self.inputChipViewTextFieldDelegate
          respondsToSelector:@selector(inputChipViewTextFieldDidDeleteBackward:oldText:newText:)]) {
    [self.inputChipViewTextFieldDelegate inputChipViewTextFieldDidDeleteBackward:self
                                                                         oldText:oldText
                                                                         newText:self.text];
  }
}

- (BOOL)resignFirstResponder {
  BOOL didResignFirstResponder = [super resignFirstResponder];
  [self.inputChipViewTextFieldDelegate
      inputChipViewTextFieldDidResignFirstResponder:didResignFirstResponder];
  return didResignFirstResponder;
}

- (BOOL)becomeFirstResponder {
  BOOL didBecomeFirstResponder = [super becomeFirstResponder];
  [self.inputChipViewTextFieldDelegate
      inputChipViewTextFieldDidBecomeFirstResponder:didBecomeFirstResponder];
  return didBecomeFirstResponder;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

- (UIFont *)uiTextFieldDefaultFont {
  static dispatch_once_t onceToken;
  static UIFont *font;
  dispatch_once(&onceToken, ^{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    textField.text = @"Text";
    font = textField.font;
  });
  return font;
}

@end

static const CGFloat kChipAnimationDuration = (CGFloat)0.25;

@interface MDCBaseInputChipView () <MDCContainedInputView,
                                    MDCBaseInputChipViewTextFieldDelegate,
                                    UIGestureRecognizerDelegate>

#pragma mark MDCContainedInputView properties
@property(strong, nonatomic) UILabel *label;

@property(nonatomic, strong) MDCContainedInputAssistiveLabelView *assistiveLabelView;

@property(strong, nonatomic) UIView *maskedScrollViewContainerView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIView *scrollViewContentViewTouchForwardingView;
@property(strong, nonatomic) MDCBaseInputChipViewTextField *inputChipViewTextField;

@property(strong, nonatomic) NSMutableArray *mutableChips;
@property(strong, nonatomic) NSMutableArray *chipsToRemove;

@property(strong, nonatomic) MDCBaseInputChipViewLayout *layout;

@property(strong, nonatomic) UITouch *lastTouch;
@property(nonatomic, assign) CGPoint lastTouchInitialContentOffset;
@property(nonatomic, assign) CGPoint lastTouchInitialLocation;

@property(strong, nonatomic) CAGradientLayer *horizontalGradient;
@property(strong, nonatomic) CAGradientLayer *verticalGradient;

//@property(strong, nonatomic) UILabel *leftAssistiveLabel;
//@property(strong, nonatomic) UILabel *rightAssistiveLabel;

@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;

@property(nonatomic, assign) MDCContainedInputViewState containedInputViewState;
@property(nonatomic, assign) MDCContainedInputViewLabelState labelState;

@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, MDCContainedInputViewColorViewModel *> *colorViewModels;

@end

@implementation MDCBaseInputChipView
@synthesize preferredContainerHeight = _preferredContainerHeight;
@synthesize underlineLabelDrawPriority = _underlineLabelDrawPriority;
@synthesize customAssistiveLabelDrawPriority = _customAssistiveLabelDrawPriority;
@synthesize containerStyle = _containerStyle;
@synthesize label = _label;

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInputChipViewInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInputChipViewInit];
  }
  return self;
}

- (void)commonInputChipViewInit {
  [self addObservers];
  [self initializeProperties];
  [self createSubviews];
  [self setUpChipRowHeight];
  [self setUpGradientLayers];
  [self setUpColorViewModels];
  [self setUpAssistiveLabels];
  [self setUpContainerStyle];
}

- (void)setUpColorViewModels {
  self.colorViewModels = [[NSMutableDictionary alloc] init];
  self.colorViewModels[@(MDCContainedInputViewStateNormal)] =
      [[MDCContainedInputViewColorViewModel alloc] initWithState:MDCContainedInputViewStateNormal];
  self.colorViewModels[@(MDCContainedInputViewStateFocused)] =
      [[MDCContainedInputViewColorViewModel alloc] initWithState:MDCContainedInputViewStateFocused];
  self.colorViewModels[@(MDCContainedInputViewStateDisabled)] =
      [[MDCContainedInputViewColorViewModel alloc]
          initWithState:MDCContainedInputViewStateDisabled];
}

- (void)setUpContainerStyle {
  self.containerStyle = [[MDCContainedInputViewStyleBase alloc] init];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Setup

- (void)addObservers {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(textFieldDidEndEditingWithNotification:)
             name:UITextFieldTextDidEndEditingNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(textFieldDidBeginEditingWithNotification:)
             name:UITextFieldTextDidBeginEditingNotification
           object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(textFieldDidChangeWithNotification:)
                                               name:UITextFieldTextDidChangeNotification
                                             object:nil];
}

- (void)initializeProperties {
  [self setUpLayoutDirection];
  [self setUpChipsArray];
  [self setUpChipsToRemoveArray];
}

- (void)setUpChipsArray {
  self.mutableChips = [[NSMutableArray alloc] init];
}

- (void)setUpChipsToRemoveArray {
  self.chipsToRemove = [[NSMutableArray alloc] init];
}

- (void)setUpLayoutDirection {
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
}

- (void)setUpChipRowHeight {
  CGFloat textHeight = (CGFloat)ceil((double)self.inputChipViewTextField.font.lineHeight);
  self.chipRowHeight = textHeight * 2;

  self.chipRowSpacing = 7;
}

- (void)createSubviews {
  self.maskedScrollViewContainerView = [[UIView alloc] init];
  [self addSubview:self.maskedScrollViewContainerView];

  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.bounces = NO;
  [self.maskedScrollViewContainerView addSubview:self.scrollView];

  self.scrollViewContentViewTouchForwardingView = [[UIView alloc] init];
  [self.scrollView addSubview:self.scrollViewContentViewTouchForwardingView];

  self.inputChipViewTextField = [[MDCBaseInputChipViewTextField alloc] init];
  self.inputChipViewTextField.inputChipViewTextFieldDelegate = self;
  [self.scrollView addSubview:self.inputChipViewTextField];

  self.label = [[UILabel alloc] init];
  [self addSubview:self.label];
}

- (void)setContainerStyle:(id<MDCContainedInputViewStyle>)containerStyle {
  id<MDCContainedInputViewStyle> oldStyle = _containerStyle;
  if (oldStyle) {
    [oldStyle removeStyleFrom:self];
  }
  _containerStyle = containerStyle;
  [_containerStyle applyStyleToContainedInputView:self];
}

- (void)setUpAssistiveLabels {
  self.underlineLabelDrawPriority = MDCContainedInputViewAssistiveLabelDrawPriorityTrailing;
  self.assistiveLabelView = [[MDCContainedInputAssistiveLabelView alloc] init];
  CGFloat underlineFontSize = MDCRound([UIFont systemFontSize] * (CGFloat)0.75);
  UIFont *underlineFont = [UIFont systemFontOfSize:underlineFontSize];
  self.assistiveLabelView.leftAssistiveLabel.font = underlineFont;
  self.assistiveLabelView.rightAssistiveLabel.font = underlineFont;
  [self addSubview:self.assistiveLabelView];
}

- (void)setUpGradientLayers {
  UIColor *outer = (id)UIColor.clearColor.CGColor;
  UIColor *inner = (id)UIColor.blackColor.CGColor;
  NSArray *colors = @[ outer, outer, inner, inner, outer, outer ];
  self.horizontalGradient = [CAGradientLayer layer];
  self.horizontalGradient.frame = self.bounds;
  self.horizontalGradient.colors = colors;
  self.horizontalGradient.startPoint = CGPointMake(0.0, 0.5);
  self.horizontalGradient.endPoint = CGPointMake(1.0, 0.5);

  self.verticalGradient = [CAGradientLayer layer];
  self.verticalGradient.frame = self.bounds;
  self.verticalGradient.colors = colors;
  self.verticalGradient.startPoint = CGPointMake(0.5, 0.0);
  self.verticalGradient.endPoint = CGPointMake(0.5, 1.0);
}

#pragma mark UIResponder Overrides

- (BOOL)resignFirstResponder {
  BOOL textFieldDidResign = [self.textField resignFirstResponder];
  return textFieldDidResign;
}

- (BOOL)becomeFirstResponder {
  BOOL textFieldDidBecome = [self.textField becomeFirstResponder];
  return textFieldDidBecome;
}

- (void)handleResponderChange {
  [self setNeedsLayout];
}

- (BOOL)isFirstResponder {
  return self.textField.isFirstResponder;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
}

#pragma mark UIView Overrides

- (void)layoutSubviews {
  [self preLayoutSubviews];
  [super layoutSubviews];
  [self postLayoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [self preferredSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
  return [self preferredSizeWithWidth:CGRectGetWidth(self.bounds)];
}

- (CGSize)preferredSizeWithWidth:(CGFloat)width {
  CGSize fittingSize = CGSizeMake(width, CGFLOAT_MAX);
  MDCBaseInputChipViewLayout *layout = [self calculateLayoutWithSize:fittingSize];
  return CGSizeMake(width, layout.calculatedHeight);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self setUpLayoutDirection];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *result = [super hitTest:point withEvent:event];
  if (result == self.scrollViewContentViewTouchForwardingView) {
    return self;
  }
  return result;
}

#pragma mark UIControl Overrides

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  BOOL result = [super beginTrackingWithTouch:touch withEvent:event];
  self.lastTouchInitialContentOffset = self.scrollView.contentOffset;
  self.lastTouchInitialLocation = [touch locationInView:self];
  //  NSLog(@"begin tracking: %@, radius: %@, pointInside: %@",@(result), @(touch.majorRadius),
  //  NSStringFromCGPoint([touch locationInView:self]));
  return result;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  BOOL result = [super continueTrackingWithTouch:touch withEvent:event];

  CGPoint location = [touch locationInView:self];
  CGPoint offsetFromStart = [self offsetOfPoint:location fromPoint:self.lastTouchInitialLocation];
  //  NSLog(@"offset from start: %@",NSStringFromCGPoint(offsetFromStart));

  CGPoint offset = self.lastTouchInitialContentOffset;
  if (self.chipsWrap) {
    CGFloat height = CGRectGetHeight(self.frame);
    offset.y -= offsetFromStart.y;
    if (offset.y < 0) {
      offset.y = 0;
    }
    if (offset.y + height > self.scrollView.contentSize.height) {
      offset.y = self.scrollView.contentSize.height - height;
    }
    self.scrollView.contentOffset = offset;
  } else {
    CGFloat width = CGRectGetWidth(self.frame);
    offset.x -= offsetFromStart.x;
    if (offset.x < 0) {
      offset.x = 0;
    }
    if (offset.x + width > self.scrollView.contentSize.width) {
      offset.x = self.scrollView.contentSize.width - width;
    }
  }
  self.scrollView.contentOffset = offset;

  return result;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  [super endTrackingWithTouch:touch withEvent:event];

  CGPoint location = [touch locationInView:self];
  CGPoint offset = [self offsetOfPoint:location fromPoint:self.lastTouchInitialLocation];
  CGPoint absoluteOffset = [self absoluteOffsetOfOffset:offset];
  BOOL isProbablyTap = absoluteOffset.x < 15 && absoluteOffset.y < 15;
  if (isProbablyTap) {
    if (!self.isFirstResponder) {
      [self becomeFirstResponder];
    }
    [self enforceCalculatedScrollViewContentOffset];
    //    NSLog(@"ended a tap!");
  } else {
    //    NSLog(@"ended a scroll at %@",NSStringFromCGPoint(self.scrollView.contentOffset));
  }
  //  NSLog(@"end tracking, radius: %@, pointInside: %@", @(touch.majorRadius),
  //  NSStringFromCGPoint([touch locationInView:self]));
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
  [super cancelTrackingWithEvent:event];
}

#pragma mark Layout

- (NSInteger)determineNumberOfVisibleRows {
  if (self.chipsWrap) {
    return self.preferredNumberOfVisibleRows;
  } else {
    return 1;
  }
}

- (MDCBaseInputChipViewLayout *)calculateLayoutWithSize:(CGSize)size {
  CGFloat numberOfVisibleRows = (CGFloat)[self determineNumberOfVisibleRows];
  id<MDCContainerStyleVerticalPositioningReference> positioningReference = [self.containerStyle
      positioningReferenceWithFloatingFontLineHeight:self.floatingFont.lineHeight
                                normalFontLineHeight:self.normalFont.lineHeight
                                       textRowHeight:self.chipRowHeight
                                    numberOfTextRows:numberOfVisibleRows
                                             density:0
                            preferredContainerHeight:self.preferredContainerHeight];

  return [[MDCBaseInputChipViewLayout alloc] initWithSize:size
                                     positioningReference:positioningReference
                                                     text:self.inputChipViewTextField.text
                                              placeholder:self.inputChipViewTextField.placeholder
                                                     font:self.normalFont
                                             floatingFont:self.floatingFont
                                                    label:self.label
                                               labelState:self.labelState
                                            labelBehavior:self.labelBehavior
                                                    chips:self.mutableChips
                                           staleChipViews:self.mutableChips
                                                chipsWrap:self.chipsWrap
                                            chipRowHeight:self.chipRowHeight
                                         interChipSpacing:self.chipRowSpacing
                                       leftAssistiveLabel:self.leftAssistiveLabel
                                      rightAssistiveLabel:self.rightAssistiveLabel
                               underlineLabelDrawPriority:self.underlineLabelDrawPriority
                         customAssistiveLabelDrawPriority:self.customAssistiveLabelDrawPriority
                                 preferredContainerHeight:self.preferredContainerHeight
                             preferredNumberOfVisibleRows:self.preferredNumberOfVisibleRows
                                                    isRTL:self.isRTL
                                                isEditing:self.inputChipViewTextField.isEditing];
}

- (void)preLayoutSubviews {
  self.containedInputViewState = [self determineCurrentContainedInputViewState];
  self.labelState = [self determineCurrentLabelState];
  MDCContainedInputViewColorViewModel *colorViewModel =
      [self containedInputViewColorViewModelForState:self.containedInputViewState];
  [self applyColorViewModel:colorViewModel withLabelState:self.labelState];
  self.layout = [self calculateLayoutWithSize:self.bounds.size];
}

- (MDCContainedInputViewState)determineCurrentContainedInputViewState {
  return [self
      containedInputViewStateWithIsEnabled:(self.enabled && self.inputChipViewTextField.enabled)
                                 isEditing:self.inputChipViewTextField.isEditing];
}

- (MDCContainedInputViewState)containedInputViewStateWithIsEnabled:(BOOL)isEnabled
                                                         isEditing:(BOOL)isEditing {
  if (isEnabled) {
    if (isEditing) {
      return MDCContainedInputViewStateFocused;
    } else {
      return MDCContainedInputViewStateNormal;
    }
  } else {
    return MDCContainedInputViewStateDisabled;
  }
}

- (void)postLayoutSubviews {
  [MDCContainedInputViewLabelAnimation layOutLabel:self.label
                                             state:self.labelState
                                  normalLabelFrame:self.layout.labelFrameNormal
                                floatingLabelFrame:self.layout.labelFrameFloating
                                        normalFont:self.normalFont
                                      floatingFont:self.floatingFont];
  [self.containerStyle applyStyleToContainedInputView:self];

  //  self.leftAssistiveLabel.frame = self.layout.leftAssistiveLabelFrame;
  //  self.rightAssistiveLabel.frame = self.layout.rightAssistiveLabelFrame;

  self.maskedScrollViewContainerView.frame = self.layout.maskedScrollViewContainerViewFrame;
  self.scrollView.frame = self.layout.scrollViewFrame;
  self.scrollViewContentViewTouchForwardingView.frame =
      self.layout.scrollViewContentViewTouchForwardingViewFrame;
  self.textField.frame = self.layout.textFieldFrame;
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
  self.scrollView.contentSize = self.layout.scrollViewContentSize;
  [self animateChipLayoutChangesWithChips:self.mutableChips
                               chipFrames:self.layout.chipFrames
                            chipsToRemove:self.chipsToRemove
                               chipsToAdd:self.chipsToAdd];
  [self.scrollView setNeedsLayout];
  //  NSLog(@"inset: %@",NSStringFromUIEdgeInsets(self.scrollView.contentInset));
  //  NSLog(@"offset: %@",NSStringFromCGPoint(self.scrollView.contentOffset));
  //  NSLog(@"size: %@\n\n",NSStringFromCGSize(self.scrollView.contentSize));

  self.assistiveLabelView.frame = self.layout.assistiveLabelViewFrame;
  self.assistiveLabelView.layout = self.layout.assistiveLabelViewLayout;
  [self.assistiveLabelView setNeedsLayout];

  [self layOutGradientLayers];
}

- (CGRect)containerFrame {
  return CGRectMake(0, 0, CGRectGetWidth(self.frame), self.layout.containerHeight);
}

- (void)layOutGradientLayers {
  CGRect gradientLayerFrame = self.layout.maskedScrollViewContainerViewFrame;
  self.horizontalGradient.frame = gradientLayerFrame;
  self.verticalGradient.frame = gradientLayerFrame;
  self.horizontalGradient.locations = self.layout.horizontalGradientLocations;
  self.verticalGradient.locations = self.layout.verticalGradientLocations;
  CALayer *scrollViewBorderGradient = [self layerCombiningHorizontalGradient:self.horizontalGradient
                                                        withVerticalGradient:self.verticalGradient];
  self.maskedScrollViewContainerView.layer.mask = scrollViewBorderGradient;
}

- (CALayer *)layerCombiningHorizontalGradient:(CAGradientLayer *)horizontalGradient
                         withVerticalGradient:(CAGradientLayer *)verticalGradient {
  horizontalGradient.mask = verticalGradient;
  UIImage *image = [self createImageWithLayer:horizontalGradient];
  CALayer *layer = [self createLayerWithImage:image];
  return layer;
}

- (UIImage *)createImageWithLayer:(CALayer *)layer {
  UIGraphicsBeginImageContext(layer.frame.size);
  [layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

- (CALayer *)createLayerWithImage:(UIImage *)image {
  CALayer *layer = [[CALayer alloc] init];
  layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
  layer.contents = (__bridge id _Nullable)(image.CGImage);
  return layer;
}

- (NSArray<UIView *> *)chipsToAdd {
  NSMutableArray *chips = [[NSMutableArray alloc] init];
  for (UIView *chip in self.mutableChips) {
    if (!chip.superview) {
      [chips addObject:chip];
    }
  }
  return [chips copy];
}

- (void)animateChipLayoutChangesWithChips:(NSArray<UIView *> *)chips
                               chipFrames:(NSArray<NSValue *> *)frames
                            chipsToRemove:(NSArray<UIView *> *)chipsToRemove
                               chipsToAdd:(NSArray<UIView *> *)chipsToAdd {
  // iterate through views, calculate a frame and an isHidden value for each.
  // If the chip is going to be removed don't change the frame.
  // go through and animate each views new status

  [self performChipRemovalOnCompletion:^{
    [self performChipPositioningOnCompletion:^{
      [self performChipAdditionsOnCompletion:nil];
    }];
  }];
}

- (void)performChipRemovalOnCompletion:(void (^)(void))completion {
  if (self.chipsToRemove.count > 0) {
    [UIView animateWithDuration:0  // kChipAnimationDuration
        animations:^{
          for (UIView *chip in self.chipsToRemove) {
            chip.alpha = 0;
          }
        }
        completion:^(BOOL finished) {
          for (UIView *chip in self.chipsToRemove) {
            [chip removeFromSuperview];
          }
          [self.chipsToRemove removeAllObjects];
          if (completion) {
            completion();
          }
        }];
  } else if (completion) {
    completion();
  }
}

- (void)performChipPositioningOnCompletion:(void (^)(void))completion {
  [UIView animateWithDuration:kChipAnimationDuration
      animations:^{
        for (NSUInteger idx = 0; idx < self.mutableChips.count; idx++) {
          UIView *chip = self.mutableChips[idx];
          CGRect frame = CGRectZero;
          if (self.layout.chipFrames.count > idx) {
            frame = [self.layout.chipFrames[idx] CGRectValue];
          }
          chip.frame = frame;
        }
      }
      completion:^(BOOL finished) {
        if (completion) {
          completion();
        }
      }];
}

- (void)performChipAdditionsOnCompletion:(void (^)(void))completion {
  NSArray<UIView *> *chipsToAdd = self.chipsToAdd;
  for (UIView *chip in chipsToAdd) {
    [self.scrollView addSubview:chip];
    chip.alpha = 0;
  }
  if (chipsToAdd.count > 0) {
    [UIView animateWithDuration:0  // kChipAnimationDuration
        animations:^{
          for (UIView *chip in chipsToAdd) {
            chip.alpha = 1;
          }
        }
        completion:^(BOOL finished) {
          if (completion) {
            completion();
          }
        }];
  } else if (completion) {
    completion();
  }
}

#pragma mark Chip Adding

- (void)addChip:(UIView *)chipView {
  [self.mutableChips addObject:chipView];
  self.textField.text = nil;
  [self setNeedsLayout];
}

- (void)removeChips:(NSArray<UIView *> *)chips {
  [self.chipsToRemove addObjectsFromArray:chips];
  [self.mutableChips removeObjectsInArray:chips];
  [self setNeedsLayout];
}

#pragma mark Notification Listener Methods

- (void)textFieldDidEndEditingWithNotification:(NSNotification *)notification {
  if (notification.object != self) {
    return;
  }
}

- (void)textFieldDidChangeWithNotification:(NSNotification *)notification {
  if (notification.object != self.textField) {
    return;
  }
  //  NSLog(@"text did change");
  [self setNeedsLayout];
  // get size needed to display text.
  // size text field accordingly
  // alter text field frame and scroll view offset accordingly
}

- (void)textFieldDidBeginEditingWithNotification:(NSNotification *)notification {
  if (notification.object != self) {
    return;
  }
}

#pragma mark Label

- (BOOL)canLabelFloat {
  return self.labelBehavior == MDCTextControlLabelBehaviorFloats;
}

- (MDCContainedInputViewLabelState)determineCurrentLabelState {
  return [self labelStateWithLabelText:self.label.text
                         textFieldText:self.textField.text
                         canLabelFloat:self.canLabelFloat
                             isEditing:self.textField.isEditing
                                 chips:self.mutableChips];
}

- (MDCContainedInputViewLabelState)labelStateWithLabelText:(NSString *)labelText
                                             textFieldText:(NSString *)text
                                             canLabelFloat:(BOOL)canLabelFloat
                                                 isEditing:(BOOL)isEditing
                                                     chips:(NSArray<UIView *> *)chips {
  BOOL hasLabelText = labelText.length > 0;
  BOOL hasText = text.length > 0;
  BOOL hasChips = chips.count > 0;
  if (hasLabelText) {
    if (canLabelFloat) {
      if (isEditing) {
        return MDCContainedInputViewLabelStateFloating;
      } else {
        if (hasText || hasChips) {
          return MDCContainedInputViewLabelStateFloating;
        } else {
          return MDCContainedInputViewLabelStateNormal;
        }
      }
    } else {
      if (hasText || hasChips) {
        return MDCContainedInputViewLabelStateNone;
      } else {
        return MDCContainedInputViewLabelStateNormal;
      }
    }
  } else {
    return MDCContainedInputViewLabelStateNone;
  }
}

#pragma mark Accessors

- (CGFloat)numberOfTextRows {
  return self.preferredNumberOfVisibleRows;
}

- (UITextField *)textField {
  return self.inputChipViewTextField;
}

- (UILabel *)leftAssistiveLabel {
  return self.assistiveLabelView.leftAssistiveLabel;
}

- (UILabel *)rightAssistiveLabel {
  return self.assistiveLabelView.rightAssistiveLabel;
}

- (UILabel *)leadingAssistiveLabel {
  if ([self isRTL]) {
    return self.rightAssistiveLabel;
  } else {
    return self.leftAssistiveLabel;
  }
}

- (UILabel *)trailingAssistiveLabel {
  if ([self isRTL]) {
    return self.leftAssistiveLabel;
  } else {
    return self.rightAssistiveLabel;
  }
}

#pragma mark User Interaction

- (void)enforceCalculatedScrollViewContentOffset {
  [self.scrollView setContentOffset:self.layout.scrollViewContentOffset animated:NO];
}

#pragma mark Internationalization

- (BOOL)isRTL {
  return self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

#pragma mark Fonts

- (UIFont *)normalFont {
  return self.inputChipViewTextField.font;
}

- (UIFont *)floatingFont {
  return [self.containerStyle floatingFontWithFont:self.normalFont];
}

- (UIFont *)uiTextFieldDefaultFont {
  static dispatch_once_t onceToken;
  static UIFont *font;
  dispatch_once(&onceToken, ^{
    font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
  });
  return font;
}

#pragma mark Dynamic Type

- (void)mdc_setAdjustsFontForContentSizeCategory:(BOOL)adjusts {
  _mdc_adjustsFontForContentSizeCategory = adjusts;
  if (_mdc_adjustsFontForContentSizeCategory) {
    [self startObservingUIContentSizeCategory];
  } else {
    [self stopObservingUIContentSizeCategory];
  }
  [self updateFontsForDynamicType];
}

- (void)updateFontsForDynamicType {
  if (self.mdc_adjustsFontForContentSizeCategory) {
    UIFont *textFont = [UIFont mdc_preferredFontForMaterialTextStyle:MDCFontTextStyleBody1];
    UIFont *helperFont = [UIFont mdc_preferredFontForMaterialTextStyle:MDCFontTextStyleCaption];
    self.textField.font = textFont;
    self.label.font = textFont;
    self.leadingAssistiveLabel.font = helperFont;
    self.leadingAssistiveLabel.font = helperFont;
  }
  [self setNeedsLayout];
}

- (void)startObservingUIContentSizeCategory {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateFontsForDynamicType)
                                               name:UIContentSizeCategoryDidChangeNotification
                                             object:nil];
}

- (void)stopObservingUIContentSizeCategory {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIContentSizeCategoryDidChangeNotification
                                                object:nil];
}

#pragma mark Custom UIView Geometry Methods

- (CGPoint)offsetOfPoint:(CGPoint)point1 fromPoint:(CGPoint)point2 {
  return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

- (CGPoint)absoluteOffsetOfOffset:(CGPoint)offset {
  if (offset.x < 0) {
    offset.x = offset.x * -1;
  }
  if (offset.y < 0) {
    offset.y = offset.y * -1;
  }
  return offset;
}

#pragma mark InputChipViewTextFieldDelegate

- (void)inputChipViewTextFieldDidDeleteBackward:(MDCBaseInputChipViewTextField *)textField
                                        oldText:(NSString *)oldText
                                        newText:(NSString *)newText {
  if ([self.delegate respondsToSelector:@selector(inputChipViewDidDeleteBackwards:
                                                                          oldText:newText:)]) {
    [self.delegate inputChipViewDidDeleteBackwards:self oldText:oldText newText:newText];
  }
}

- (void)inputChipViewTextFieldDidResignFirstResponder:(BOOL)didBecome {
  [self handleResponderChange];
}

- (void)inputChipViewTextFieldDidBecomeFirstResponder:(BOOL)didBecome {
  [self handleResponderChange];
}

- (NSArray<UIView *> *)chips {
  return [self.mutableChips copy];
}

#pragma mark Theming

- (void)applyColorViewModel:(MDCContainedInputViewColorViewModel *)colorViewModel
             withLabelState:(MDCContainedInputViewLabelState)labelState {
  UIColor *labelColor = [UIColor clearColor];
  if (labelState == MDCContainedInputViewLabelStateNormal) {
    labelColor = colorViewModel.normalLabelColor;
  } else if (labelState == MDCContainedInputViewLabelStateFloating) {
    labelColor = colorViewModel.floatingLabelColor;
  }
  self.textField.textColor = colorViewModel.textColor;
  self.leadingAssistiveLabel.textColor = colorViewModel.assistiveLabelColor;
  self.trailingAssistiveLabel.textColor = colorViewModel.assistiveLabelColor;
  self.label.textColor = labelColor;
}

- (void)setContainedInputViewColorViewModel:(MDCContainedInputViewColorViewModel *)colorViewModel
                                   forState:(MDCContainedInputViewState)containedInputViewState {
  self.colorViewModels[@(containedInputViewState)] = colorViewModel;
}

- (MDCContainedInputViewColorViewModel *)containedInputViewColorViewModelForState:
    (MDCContainedInputViewState)containedInputViewState {
  MDCContainedInputViewColorViewModel *colorViewModel =
      self.colorViewModels[@(containedInputViewState)];
  if (!colorViewModel) {
    colorViewModel =
        [[MDCContainedInputViewColorViewModel alloc] initWithState:containedInputViewState];
  }
  return colorViewModel;
}

- (void)setLabelColor:(nonnull UIColor *)labelColor forState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  MDCContainedInputViewColorViewModel *colorViewModel =
      [self containedInputViewColorViewModelForState:containedInputViewState];
  colorViewModel.floatingLabelColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)labelColorForState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  MDCContainedInputViewColorViewModel *colorViewModel =
      [self containedInputViewColorViewModelForState:containedInputViewState];
  return colorViewModel.floatingLabelColor;
}

- (void)setTextColor:(nonnull UIColor *)labelColor forState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  MDCContainedInputViewColorViewModel *colorViewModel =
      [self containedInputViewColorViewModelForState:containedInputViewState];
  colorViewModel.textColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)textColorForState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  MDCContainedInputViewColorViewModel *colorViewModel =
      [self containedInputViewColorViewModelForState:containedInputViewState];
  return colorViewModel.textColor;
}

@end
