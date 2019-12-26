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
#import "private/MDCBaseInputChipView+MDCTextControl.h"
#import "private/MDCBaseInputChipViewLayout.h"
#import "private/MDCTextControl.h"
#import "private/MDCTextControlAssistiveLabelView.h"
#import "private/MDCTextControlColorViewModel.h"
#import "private/MDCTextControlGradientManager.h"
#import "private/MDCTextControlLabelAnimation.h"
#import "private/MDCTextControlStyleBase.h"
#import "private/UITextField+MDCTextControlDefaults.h"

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

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBaseInputChipViewTextFieldInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCBaseInputChipViewTextFieldInit];
  }
  return self;
}

- (void)commonMDCBaseInputChipViewTextFieldInit {
  self.font = [UITextField mdc_defaultFont];
}

- (void)setFont:(UIFont *)font {
  UIFont *newFont = font;
  if (!newFont) {
    newFont = [UITextField mdc_defaultFont];
  }
  [super setFont:newFont];
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

- (CGRect)editingRectForBounds:(CGRect)bounds {
  CGRect rect = [super editingRectForBounds:bounds];
  return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  CGRect rect = [super textRectForBounds:bounds];
  return rect;
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

@end

@interface MDCBaseInputChipView () <MDCTextControl,
                                    MDCBaseInputChipViewTextFieldDelegate,
                                    UIGestureRecognizerDelegate,
                                    UIScrollViewDelegate>

#pragma mark MDCTextControl properties

@property(strong, nonatomic) UILabel *label;

@property(nonatomic, strong) MDCTextControlAssistiveLabelView *assistiveLabelView;

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

@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;

@property(nonatomic, assign) MDCTextControlState textControlState;
@property(nonatomic, assign) MDCTextControlLabelState labelState;

@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, MDCTextControlColorViewModel *> *colorViewModels;

@property(nonatomic, strong) MDCTextControlGradientManager *gradientManager;

@end

@implementation MDCBaseInputChipView
@synthesize preferredContainerHeight = _preferredContainerHeight;
@synthesize assistiveLabelDrawPriority = _assistiveLabelDrawPriority;
@synthesize customAssistiveLabelDrawPriority = _customAssistiveLabelDrawPriority;
@synthesize containerStyle = _containerStyle;
@synthesize label = _label;

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBaseInputChipViewInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCBaseInputChipViewInit];
  }
  return self;
}

- (void)commonMDCBaseInputChipViewInit {
  [self addObservers];
  [self initializeProperties];
  [self createSubviews];
  [self setUpChipRowHeight];
  [self setUpGradientManager];
  [self setUpColorViewModels];
  [self setUpAssistiveLabels];
  [self setUpContainerStyle];
}

- (void)setUpColorViewModels {
  self.colorViewModels = [[NSMutableDictionary alloc] init];
  self.colorViewModels[@(MDCTextControlStateNormal)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateNormal];
  self.colorViewModels[@(MDCTextControlStateEditing)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateEditing];
  self.colorViewModels[@(MDCTextControlStateDisabled)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateDisabled];
}

- (void)setUpContainerStyle {
  self.containerStyle = [[MDCTextControlStyleBase alloc] init];
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
  self.scrollView.delegate = self;
  self.scrollView.scrollsToTop = NO;
  //  self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  [self.maskedScrollViewContainerView addSubview:self.scrollView];

  self.scrollViewContentViewTouchForwardingView = [[UIView alloc] init];
  [self.scrollView addSubview:self.scrollViewContentViewTouchForwardingView];

  self.inputChipViewTextField = [[MDCBaseInputChipViewTextField alloc] init];
  self.inputChipViewTextField.inputChipViewTextFieldDelegate = self;
  [self.scrollView addSubview:self.inputChipViewTextField];

  self.label = [[UILabel alloc] init];
  [self addSubview:self.label];
}

- (void)setContainerStyle:(id<MDCTextControlStyle>)containerStyle {
  id<MDCTextControlStyle> oldStyle = _containerStyle;
  if (oldStyle) {
    [oldStyle removeStyleFrom:self];
  }
  _containerStyle = containerStyle;
  [_containerStyle applyStyleToTextControl:self];
}

- (void)setUpAssistiveLabels {
  self.assistiveLabelDrawPriority = MDCTextControlAssistiveLabelDrawPriorityTrailing;
  self.assistiveLabelView = [[MDCTextControlAssistiveLabelView alloc] init];
  CGFloat assistiveFontSize = MDCRound([UIFont systemFontSize] * (CGFloat)0.75);
  UIFont *assistiveFont = [UIFont systemFontOfSize:assistiveFontSize];
  self.assistiveLabelView.leftAssistiveLabel.font = assistiveFont;
  self.assistiveLabelView.rightAssistiveLabel.font = assistiveFont;
  [self addSubview:self.assistiveLabelView];
}

- (void)setUpGradientManager {
  self.gradientManager = [[MDCTextControlGradientManager alloc] init];
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
  NSLog(@"self.scrollView.contentOffset = %@", NSStringFromCGPoint(self.scrollView.contentOffset));
  self.lastTouchInitialContentOffset = self.scrollView.contentOffset;
  NSLog(@"self.lastTouchInitialContentOffset = %@",
        NSStringFromCGPoint(self.lastTouchInitialContentOffset));
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

  CGPoint newContentOffset = self.lastTouchInitialContentOffset;
  if (self.chipsWrap) {
    CGFloat height = CGRectGetHeight(self.frame);
    newContentOffset.y -= offsetFromStart.y;
    if (newContentOffset.y < 0) {
      newContentOffset.y = 0;
    }
    if (newContentOffset.y + height > self.scrollView.contentSize.height) {
      newContentOffset.y = self.scrollView.contentSize.height - height;
    }
    //    self.scrollView.contentOffset = newContentOffset;
  } else {
    if (self.isRTL) {
      CGFloat width = CGRectGetWidth(self.frame);
      newContentOffset.x -= offsetFromStart.x;
      //      NSLog(@"offset.x = %@",@(newContentOffset.x));
      CGFloat maxOffset = 0;
      if (newContentOffset.x > maxOffset) {
        //        NSLog(@"max offset: %@",@(maxOffset));
        newContentOffset.x = maxOffset;
      }
      CGFloat minOffset = (CGFloat)-1.0 * (self.scrollView.contentSize.width - width);
      if (newContentOffset.x < minOffset) {
        //        NSLog(@"min offset: %@",@(minOffset));
        newContentOffset.x = minOffset;
      }
    } else {
      CGFloat width = CGRectGetWidth(self.frame);
      newContentOffset.x -= offsetFromStart.x;
      //      NSLog(@"offset.x = %@",@(newContentOffset.x));
      CGFloat minOffset = 0;
      if (newContentOffset.x < minOffset) {
        //        NSLog(@"min offset: %@",@(minOffset));
        newContentOffset.x = minOffset;
      }
      CGFloat maxOffset = self.scrollView.contentSize.width - width;
      if (newContentOffset.x > maxOffset) {
        //        NSLog(@"max offset: %@",@(maxOffset));
        newContentOffset.x = maxOffset;
      }
    }
    //    NSLog(@"set content offset");
  }
  self.scrollView.contentOffset = newContentOffset;

  return result;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  [super endTrackingWithTouch:touch withEvent:event];
  if ([self isTouchMostLikelyTap:touch]) {
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

- (BOOL)isTouchMostLikelyTap:(UITouch *)touch {
  CGPoint location = [touch locationInView:self];
  CGPoint offset = [self offsetOfPoint:location fromPoint:self.lastTouchInitialLocation];
  CGPoint absoluteOffset = [self absoluteOffsetOfOffset:offset];
  return absoluteOffset.x < 15 && absoluteOffset.y < 15;
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
  id<MDCTextControlVerticalPositioningReference> positioningReference = [self.containerStyle
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
                               assistiveLabelDrawPriority:self.assistiveLabelDrawPriority
                         customAssistiveLabelDrawPriority:self.customAssistiveLabelDrawPriority
                                 preferredContainerHeight:self.preferredContainerHeight
                             preferredNumberOfVisibleRows:self.preferredNumberOfVisibleRows
                                                    isRTL:self.isRTL
                                                isEditing:self.inputChipViewTextField.isEditing];
}

- (void)preLayoutSubviews {
  self.textControlState = [self determineCurrentTextControlState];
  self.labelState = [self determineCurrentLabelState];
  MDCTextControlColorViewModel *colorViewModel =
      [self textControlColorViewModelForState:self.textControlState];
  [self applyColorViewModel:colorViewModel withLabelState:self.labelState];
  self.layout = [self calculateLayoutWithSize:self.bounds.size];
}

- (MDCTextControlState)determineCurrentTextControlState {
  return [self textControlStateWithIsEnabled:(self.enabled && self.inputChipViewTextField.enabled)
                                   isEditing:self.inputChipViewTextField.isEditing];
}

- (MDCTextControlState)textControlStateWithIsEnabled:(BOOL)isEnabled isEditing:(BOOL)isEditing {
  if (isEnabled) {
    if (isEditing) {
      return MDCTextControlStateEditing;
    } else {
      return MDCTextControlStateNormal;
    }
  } else {
    return MDCTextControlStateDisabled;
  }
}

- (void)postLayoutSubviews {
  [MDCTextControlLabelAnimation layOutLabel:self.label
                                      state:self.labelState
                           normalLabelFrame:self.layout.labelFrameNormal
                         floatingLabelFrame:self.layout.labelFrameFloating
                                 normalFont:self.normalFont
                               floatingFont:self.floatingFont];
  [self.containerStyle applyStyleToTextControl:self];

  //  self.leftAssistiveLabel.frame = self.layout.leftAssistiveLabelFrame;
  //  self.rightAssistiveLabel.frame = self.layout.rightAssistiveLabelFrame;

  self.maskedScrollViewContainerView.frame = self.layout.maskedScrollViewContainerViewFrame;
  self.scrollView.frame = self.layout.scrollViewFrame;
  self.scrollViewContentViewTouchForwardingView.frame =
      self.layout.scrollViewContentViewTouchForwardingViewFrame;
  self.textField.frame = self.layout.textFieldFrame;
  self.scrollView.contentSize = self.layout.scrollViewContentSize;
  //  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;

  NSLog(@"post layout subviews: %@", NSStringFromCGPoint(self.scrollView.contentOffset));
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
  self.gradientManager.horizontalGradient.frame = gradientLayerFrame;
  self.gradientManager.verticalGradient.frame = gradientLayerFrame;
  self.gradientManager.horizontalGradient.locations = self.layout.horizontalGradientLocations;
  self.gradientManager.verticalGradient.locations = self.layout.verticalGradientLocations;
  self.maskedScrollViewContainerView.layer.mask = [self.gradientManager combinedGradientMaskLayer];
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
    [UIView animateWithDuration:0
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
  [UIView animateWithDuration:0
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
    [UIView animateWithDuration:0
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

- (MDCTextControlLabelState)determineCurrentLabelState {
  return [self labelStateWithLabelText:self.label.text
                         textFieldText:self.textField.text
                         canLabelFloat:self.canLabelFloat
                             isEditing:self.textField.isEditing
                                 chips:self.mutableChips];
}

- (MDCTextControlLabelState)labelStateWithLabelText:(NSString *)labelText
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
        return MDCTextControlLabelStateFloating;
      } else {
        if (hasText || hasChips) {
          return MDCTextControlLabelStateFloating;
        } else {
          return MDCTextControlLabelStateNormal;
        }
      }
    } else {
      if (hasText || hasChips) {
        return MDCTextControlLabelStateNone;
      } else {
        return MDCTextControlLabelStateNormal;
      }
    }
  } else {
    return MDCTextControlLabelStateNone;
  }
}

#pragma mark Accessors

- (CGFloat)numberOfVisibleTextRows {
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
  NSLog(@"enforce!!!!");
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
  //  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
}

#pragma mark Internationalization

- (BOOL)isRTL {
  return self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

#pragma mark Fonts

- (UIFont *)normalFont {
  return self.inputChipViewTextField.font ?: [UITextField mdc_defaultFont];
}

- (UIFont *)floatingFont {
  return [self.containerStyle floatingFontWithNormalFont:self.normalFont];
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

- (void)applyColorViewModel:(MDCTextControlColorViewModel *)colorViewModel
             withLabelState:(MDCTextControlLabelState)labelState {
  UIColor *labelColor = [UIColor clearColor];
  if (labelState == MDCTextControlLabelStateNormal) {
    labelColor = colorViewModel.normalLabelColor;
  } else if (labelState == MDCTextControlLabelStateFloating) {
    labelColor = colorViewModel.floatingLabelColor;
  }
  self.textField.textColor = colorViewModel.textColor;
  self.leadingAssistiveLabel.textColor = colorViewModel.leadingAssistiveLabelColor;
  self.trailingAssistiveLabel.textColor = colorViewModel.trailingAssistiveLabelColor;
  self.label.textColor = labelColor;
}

- (void)setTextControlColorViewModel:(MDCTextControlColorViewModel *)colorViewModel
                            forState:(MDCTextControlState)textControlState {
  self.colorViewModels[@(textControlState)] = colorViewModel;
}

- (MDCTextControlColorViewModel *)textControlColorViewModelForState:
    (MDCTextControlState)textControlState {
  MDCTextControlColorViewModel *colorViewModel = self.colorViewModels[@(textControlState)];
  if (!colorViewModel) {
    colorViewModel = [[MDCTextControlColorViewModel alloc] initWithState:textControlState];
  }
  return colorViewModel;
}

- (void)setNormalLabelColor:(nonnull UIColor *)labelColor forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.normalLabelColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)normalLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.normalLabelColor;
}

- (void)setFloatingLabelColor:(nonnull UIColor *)labelColor forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.floatingLabelColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)floatingLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.floatingLabelColor;
}

- (void)setTextColor:(nonnull UIColor *)labelColor forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.textColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)textColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.textColor;
}

- (void)setLeadingAssistiveLabelColor:(nonnull UIColor *)assistiveLabelColor
                             forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.leadingAssistiveLabelColor = assistiveLabelColor;
  [self setNeedsLayout];
}

- (UIColor *)trailingAssistiveLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.trailingAssistiveLabelColor;
}

- (void)setTrailingAssistiveLabelColor:(nonnull UIColor *)assistiveLabelColor
                              forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.trailingAssistiveLabelColor = assistiveLabelColor;
  [self setNeedsLayout];
}

- (UIColor *)leadingAssistiveLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.leadingAssistiveLabelColor;
}

@end
