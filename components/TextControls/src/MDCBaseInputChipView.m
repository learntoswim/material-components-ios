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
#import "private/MDCBaseInputChipViewTextField.h"

static const CGFloat kMinInterChipVerticalSpacing = (CGFloat)3.0;
static const CGFloat kMaxInterChipVerticalSpacing = (CGFloat)8.0;

@interface MDCBaseInputChipView () <MDCTextControl,
                                    MDCBaseInputChipViewTextFieldDelegate,
                                    UIGestureRecognizerDelegate,
                                    UIScrollViewDelegate>

#pragma mark MDCTextControl properties

@property(strong, nonatomic) UILabel *label;
@property(nonatomic, strong) MDCTextControlAssistiveLabelView *assistiveLabelView;
@property(strong, nonatomic) MDCBaseInputChipViewLayout *layout;
@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;
@property(nonatomic, assign) MDCTextControlState textControlState;
@property(nonatomic, assign) MDCTextControlLabelState labelState;
@property(nonatomic, strong)
NSMutableDictionary<NSNumber *, MDCTextControlColorViewModel *> *colorViewModels;
@property(nonatomic, assign) NSTimeInterval animationDuration;

@property(strong, nonatomic) UIView *maskedScrollViewContainerView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIView *scrollViewContentViewTouchForwardingView;
@property(strong, nonatomic) MDCBaseInputChipViewTextField *inputChipViewTextField;
@property(nonatomic, assign) CGPoint lastTouchInitialContentOffset;
@property(nonatomic, assign) CGPoint lastTouchInitialLocation;
@property(nonatomic, strong) MDCTextControlGradientManager *gradientManager;

@property(strong, nonatomic) NSMutableArray *mutableChips;
@property(strong, nonatomic) NSMutableArray *chipsToRemove;

@property(strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property(nonatomic, assign) CGFloat interChipVerticalSpacing;
@property(nonatomic, assign) CGFloat density;

@end

@implementation MDCBaseInputChipView
@synthesize containerStyle = _containerStyle;
@synthesize assistiveLabelDrawPriority = _assistiveLabelDrawPriority;
@synthesize customAssistiveLabelDrawPriority = _customAssistiveLabelDrawPriority;
@synthesize preferredContainerHeight = _preferredContainerHeight;
@synthesize adjustsFontForContentSizeCategory = _adjustsFontForContentSizeCategory;

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
  [self initializeProperties];
  [self setUpTapGesture];
  [self setUpColorViewModels];
  [self setUpLabel];
  [self setUpAssistiveLabels];
  [self createSubviews];
  [self setUpChipRowHeight];
  [self observeUITextFieldNotifications];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Setup

- (void)initializeProperties {
  self.animationDuration = kMDCTextControlDefaultAnimationDuration;
  self.labelBehavior = MDCTextControlLabelBehaviorFloats;
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
  self.labelState = [self determineCurrentLabelState];
  self.textControlState = [self determineCurrentTextControlState];
  self.containerStyle = [[MDCTextControlStyleBase alloc] init];
  self.colorViewModels = [[NSMutableDictionary alloc] init];

  self.gradientManager = [[MDCTextControlGradientManager alloc] init];
  self.mutableChips = [[NSMutableArray alloc] init];
  self.chipsToRemove = [[NSMutableArray alloc] init];
  self.preferredNumberOfVisibleRows = kMDCTextControlDefaultMultilineNumberOfVisibleRows;
}

- (void)setUpTapGesture {
  self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  [self addGestureRecognizer:self.tapGesture];
}

- (void)setUpColorViewModels {
  self.colorViewModels[@(MDCTextControlStateNormal)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateNormal];
  self.colorViewModels[@(MDCTextControlStateEditing)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateEditing];
  self.colorViewModels[@(MDCTextControlStateDisabled)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateDisabled];
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

- (void)setUpLabel {
  self.label = [[UILabel alloc] init];
  [self addSubview:self.label];
}

- (void)observeUITextFieldNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(textFieldDidChangeWithNotification:)
                                               name:UITextFieldTextDidChangeNotification
                                             object:nil];
}

- (void)setUpChipRowHeight {
  CGFloat textHeight = (CGFloat)ceil((double)self.inputChipViewTextField.font.lineHeight);
  self.chipRowHeight = textHeight * 2;
}

- (void)createSubviews {
  self.maskedScrollViewContainerView = [[UIView alloc] init];
  [self addSubview:self.maskedScrollViewContainerView];

  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.bounces = NO;
  self.scrollView.delegate = self;
  self.scrollView.scrollsToTop = NO;
  [self.maskedScrollViewContainerView addSubview:self.scrollView];

  self.scrollViewContentViewTouchForwardingView = [[UIView alloc] init];
  [self.scrollView addSubview:self.scrollViewContentViewTouchForwardingView];

  self.inputChipViewTextField = [[MDCBaseInputChipViewTextField alloc] init];
  self.inputChipViewTextField.inputChipViewTextFieldDelegate = self;
  [self.scrollView addSubview:self.inputChipViewTextField];
}

#pragma mark UIResponder Overrides

- (BOOL)resignFirstResponder {
  return [self.textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
  return [self.textField becomeFirstResponder];
}

- (BOOL)isFirstResponder {
  return self.textField.isFirstResponder;
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
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *result = [super hitTest:point withEvent:event];
  if (result == self.scrollViewContentViewTouchForwardingView) {
    return self;
  }
  return result;
}

#pragma mark UIControl Overrides

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  self.textField.enabled = enabled;
  [self setNeedsLayout];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  BOOL result = [super beginTrackingWithTouch:touch withEvent:event];
  self.lastTouchInitialContentOffset = self.scrollView.contentOffset;
  self.lastTouchInitialLocation = [touch locationInView:self];
  return result;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  BOOL result = [super continueTrackingWithTouch:touch withEvent:event];

  CGPoint location = [touch locationInView:self];
  CGPoint offsetFromStart = [self offsetOfPoint:location fromPoint:self.lastTouchInitialLocation];

  CGPoint newContentOffset = self.lastTouchInitialContentOffset;
  if (self.chipsWrap) {
    CGFloat height = CGRectGetHeight(self.scrollView.frame);
    newContentOffset.y -= offsetFromStart.y;
    if (newContentOffset.y < 0) {
      newContentOffset.y = 0;
    }
    if (newContentOffset.y + height > self.scrollView.contentSize.height) {
      newContentOffset.y = self.scrollView.contentSize.height - height;
    }
  } else {
    if (self.isRTL) {
      CGFloat width = CGRectGetWidth(self.scrollView.frame);
      newContentOffset.x -= offsetFromStart.x;
      CGFloat minOffset = 0;
      CGFloat maxOffset = self.scrollView.contentSize.width - width;
      if (newContentOffset.x > maxOffset) {
        newContentOffset.x = maxOffset;
      }
      if (newContentOffset.x < minOffset) {
        newContentOffset.x = minOffset;
      }
    } else {
      CGFloat width = CGRectGetWidth(self.frame);
      newContentOffset.x -= offsetFromStart.x;
      CGFloat minOffset = 0;
      if (newContentOffset.x < minOffset) {
        newContentOffset.x = minOffset;
      }
      CGFloat maxOffset = self.scrollView.contentSize.width - width;
      if (newContentOffset.x > maxOffset) {
        newContentOffset.x = maxOffset;
      }
    }
  }
  self.scrollView.contentOffset = newContentOffset;

  return result;
}

#pragma mark Layout

- (MDCBaseInputChipViewLayout *)calculateLayoutWithSize:(CGSize)size {
  CGFloat numberOfVisibleRows = [self determineNumberOfVisibleRows];
  id<MDCTextControlVerticalPositioningReference> positioningReference = [self.containerStyle
      positioningReferenceWithFloatingFontLineHeight:self.floatingFont.lineHeight
                                normalFontLineHeight:self.normalFont.lineHeight
                                       textRowHeight:self.chipRowHeight
                                    numberOfTextRows:numberOfVisibleRows
                                             density:self.density
                            preferredContainerHeight:self.preferredContainerHeight];

  return
      [[MDCBaseInputChipViewLayout alloc] initWithSize:size
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
                              interChipVerticalSpacing:self.interChipVerticalSpacing
                                    leftAssistiveLabel:self.assistiveLabelView.leftAssistiveLabel
                                   rightAssistiveLabel:self.assistiveLabelView.rightAssistiveLabel
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
  self.interChipVerticalSpacing = [self determineInterChipVerticalSpacing];
  MDCTextControlColorViewModel *colorViewModel =
      [self textControlColorViewModelForState:self.textControlState];
  [self applyColorViewModel:colorViewModel withLabelState:self.labelState];
  self.layout = [self calculateLayoutWithSize:self.bounds.size];
}

- (void)postLayoutSubviews {
  self.maskedScrollViewContainerView.frame = self.layout.maskedScrollViewContainerViewFrame;
  self.scrollView.frame = self.layout.scrollViewFrame;
  self.scrollViewContentViewTouchForwardingView.frame =
      self.layout.scrollViewContentViewTouchForwardingViewFrame;
  self.textField.frame = self.layout.textFieldFrame;
  self.scrollView.contentSize = self.layout.scrollViewContentSize;
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;

  self.label.hidden = self.labelState == MDCTextControlLabelStateNone;

  [self animateChipLayoutChangesWithChips:self.mutableChips
                               chipFrames:self.layout.chipFrames
                            chipsToRemove:self.chipsToRemove
                               chipsToAdd:self.chipsToAdd];
  [self.scrollView setNeedsLayout];

  self.assistiveLabelView.frame = self.layout.assistiveLabelViewFrame;
  self.assistiveLabelView.layout = self.layout.assistiveLabelViewLayout;
  [self.assistiveLabelView setNeedsLayout];

  [self animateLabel];
  [self.containerStyle applyStyleToTextControl:self animationDuration:self.animationDuration];

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

- (void)animateChipLayoutChangesWithChips:(NSArray<UIView *> *)chips
                               chipFrames:(NSArray<NSValue *> *)frames
                            chipsToRemove:(NSArray<UIView *> *)chipsToRemove
                               chipsToAdd:(NSArray<UIView *> *)chipsToAdd {
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

- (void)enforceCalculatedScrollViewContentOffset {
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
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

- (CGPoint)offsetOfPoint:(CGPoint)point1 fromPoint:(CGPoint)point2 {
  return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

- (CGFloat)determineNumberOfVisibleRows {
  if (self.chipsWrap && self.preferredNumberOfVisibleRows >= 1) {
    return self.preferredNumberOfVisibleRows;
  } else {
    return 1;
  }
}

- (CGFloat)determineInterChipVerticalSpacing {
  return MDCTextControlPaddingValueWithMinimumPadding(kMinInterChipVerticalSpacing,
                                                      kMaxInterChipVerticalSpacing,
                                                      self.density);
}

#pragma mark Chip Adding/Removing

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

- (NSArray<UIView *> *)chipsToAdd {
  NSMutableArray *chips = [[NSMutableArray alloc] init];
  for (UIView *chip in self.mutableChips) {
    if (!chip.superview) {
      [chips addObject:chip];
    }
  }
  return [chips copy];
}

#pragma mark Label

- (void)animateLabel {
  __weak MDCBaseInputChipView *weakSelf = self;
  [MDCTextControlLabelAnimation animateLabel:self.label
                                       state:self.labelState
                            normalLabelFrame:self.layout.labelFrameNormal
                          floatingLabelFrame:self.layout.labelFrameFloating
                                  normalFont:self.normalFont
                                floatingFont:self.floatingFont
                           animationDuration:self.animationDuration
                                  completion:^(BOOL finished) {
                                    if (finished) {
                                      // Ensure that the label position is correct in case of
                                      // competing animations.
                                      [weakSelf positionLabel];
                                    }
                                  }];
}

- (void)positionLabel {
  if (self.labelState == MDCTextControlLabelStateFloating) {
    self.label.frame = self.layout.labelFrameFloating;
    self.label.hidden = NO;
  } else if (self.labelState == MDCTextControlLabelStateNormal) {
    self.label.frame = self.layout.labelFrameNormal;
    self.label.hidden = NO;
  } else {
    self.label.frame = CGRectZero;
    self.label.hidden = YES;
  }
}

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

#pragma mark MDCTextControlState

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

#pragma mark MDCTextControl Accessors

- (void)setContainerStyle:(id<MDCTextControlStyle>)containerStyle {
  id<MDCTextControlStyle> oldStyle = _containerStyle;
  if (oldStyle) {
    [oldStyle removeStyleFrom:self];
  }
  _containerStyle = containerStyle;
  [_containerStyle applyStyleToTextControl:self animationDuration:self.animationDuration];
}

- (CGFloat)numberOfVisibleTextRows {
  return self.preferredNumberOfVisibleRows;
}

- (UILabel *)leadingAssistiveLabel {
  if ([self isRTL]) {
    return self.assistiveLabelView.rightAssistiveLabel;
  } else {
    return self.assistiveLabelView.leftAssistiveLabel;
  }
}

- (UILabel *)trailingAssistiveLabel {
  if ([self isRTL]) {
    return self.assistiveLabelView.leftAssistiveLabel;
  } else {
    return self.assistiveLabelView.rightAssistiveLabel;
  }
}

#pragma mark Misc Accessors

- (UITextField *)textField {
  return self.inputChipViewTextField;
}

#pragma mark Fonts

- (UIFont *)normalFont {
  return self.inputChipViewTextField.font ?: MDCTextControlDefaultUITextFieldFont();
}

- (UIFont *)floatingFont {
  return [self.containerStyle floatingFontWithNormalFont:self.normalFont];
}

#pragma mark Dynamic Type

- (void)setAdjustsFontForContentSizeCategory:(BOOL)adjustsFontForContentSizeCategory {
  if (@available(iOS 10.0, *)) {
    _adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
    self.textField.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
    self.leadingAssistiveLabel.adjustsFontForContentSizeCategory =
        adjustsFontForContentSizeCategory;
    self.trailingAssistiveLabel.adjustsFontForContentSizeCategory =
        adjustsFontForContentSizeCategory;
  }
}

#pragma mark Internationalization

- (BOOL)isRTL {
  return self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

#pragma mark Coloring

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

#pragma mark Color Accessors

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

- (UIColor *)leadingAssistiveLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.leadingAssistiveLabelColor;
}

- (void)setTrailingAssistiveLabelColor:(nonnull UIColor *)assistiveLabelColor
                              forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.trailingAssistiveLabelColor = assistiveLabelColor;
  [self setNeedsLayout];
}

- (UIColor *)trailingAssistiveLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.trailingAssistiveLabelColor;
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
  [self setNeedsLayout];
}

- (void)inputChipViewTextFieldDidBecomeFirstResponder:(BOOL)didBecome {
  [self setNeedsLayout];
}

- (NSArray<UIView *> *)chips {
  return [self.mutableChips copy];
}

#pragma mark UITextField Notifications

- (void)textFieldDidChangeWithNotification:(NSNotification *)notification {
  if (notification.object != self.textField) {
    return;
  }
  [self setNeedsLayout];
}

#pragma mark User Actions

- (void)handleTap:(UITapGestureRecognizer *)tap {
  if (tap.state == UIGestureRecognizerStateEnded) {
    if (!self.isFirstResponder) {
      [self becomeFirstResponder];
    }
    [self enforceCalculatedScrollViewContentOffset];
  }
}

@end
