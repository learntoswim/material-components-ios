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
#import "MaterialTextControlsPrivate+BaseStyle.h"
#import "MaterialTextControlsPrivate+Shared.h"
#import "MaterialTypography.h"
#import "private/MDCBaseInputChipViewLayout.h"
#import "private/MDCBaseInputChipViewTextField.h"

static const CGFloat kMinInterChipVerticalSpacing = (CGFloat)3.0;
static const CGFloat kMaxInterChipVerticalSpacing = (CGFloat)8.0;
static const CGFloat kMDCBaseInputChipViewDefaultMultilineNumberOfVisibleRows = (CGFloat)2.0;

@interface MDCBaseInputChipView () <MDCTextControl,
                                    MDCBaseInputChipViewTextFieldDelegate,
                                    UIGestureRecognizerDelegate>

#pragma mark MDCTextControl properties

@property(strong, nonatomic) UILabel *label;
@property(nonatomic, strong) MDCTextControlAssistiveLabelView *assistiveLabelView;
@property(strong, nonatomic) MDCBaseInputChipViewLayout *layout;
@property(nonatomic, assign) MDCTextControlState textControlState;
@property(nonatomic, assign) MDCTextControlLabelPosition labelPosition;
@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, MDCTextControlColorViewModel *> *colorViewModels;
@property(nonatomic, assign) CGRect labelFrame;
@property(nonatomic, assign) NSTimeInterval animationDuration;

@property(strong, nonatomic) UIView *maskedScrollViewContainerView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) MDCBaseInputChipViewTextField *inputChipViewTextField;
@property(nonatomic, strong) MDCTextControlGradientManager *gradientManager;

@property(strong, nonatomic) NSMutableArray *mutableChips;
@property(strong, nonatomic) NSMutableArray *chipsToRemove;

@property(strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property(nonatomic, assign) CGFloat interChipVerticalSpacing;
@property(nonatomic, assign) CGFloat density;
@property(nonatomic, assign) CGSize mostRecentlyComputedIntrinsicContentSize;

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
  [self setUpColorViewModels];
  [self setUpLabel];
  [self setUpAssistiveLabels];
  [self createSubviews];
  [self setUpChipRowHeight];
  [self observeUITextFieldNotifications];
  [self observeContentSizeCategoryNotifications];
  [self setUpTapGesture];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Setup

- (void)initializeProperties {
  self.animationDuration = kMDCTextControlDefaultAnimationDuration;
  self.labelBehavior = MDCTextControlLabelBehaviorFloats;
  self.labelPosition = [self determineCurrentLabelPosition];
  self.textControlState = [self determineCurrentTextControlState];
  self.containerStyle = [[MDCTextControlStyleBase alloc] init];
  self.colorViewModels = [[NSMutableDictionary alloc] init];

  self.gradientManager = [[MDCTextControlGradientManager alloc] init];
  self.mutableChips = [[NSMutableArray alloc] init];
  self.chipsToRemove = [[NSMutableArray alloc] init];
  self.preferredNumberOfVisibleRows = kMDCBaseInputChipViewDefaultMultilineNumberOfVisibleRows;
}

- (void)setUpTapGesture {
  self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleTap:)];
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
  self.assistiveLabelView.leadingAssistiveLabel.font = assistiveFont;
  self.assistiveLabelView.trailingAssistiveLabel.font = assistiveFont;
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
  self.scrollView.scrollsToTop = NO;
  [self.maskedScrollViewContainerView addSubview:self.scrollView];

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
  self.mostRecentlyComputedIntrinsicContentSize =
      [self preferredSizeWithWidth:CGRectGetWidth(self.bounds)];
  return self.mostRecentlyComputedIntrinsicContentSize;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self setNeedsLayout];
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute {
  [super setSemanticContentAttribute:semanticContentAttribute];
  [self setNeedsLayout];
}

#pragma mark UIControl Overrides

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  self.textField.enabled = enabled;
  [self setNeedsLayout];
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

  return [[MDCBaseInputChipViewLayout alloc] initWithSize:size
                                     positioningReference:positioningReference
                                                     text:self.inputChipViewTextField.text
                                              placeholder:self.inputChipViewTextField.placeholder
                                                     font:self.normalFont
                                             floatingFont:self.floatingFont
                                                    label:self.label
                                               labelState:self.labelPosition
                                            labelBehavior:self.labelBehavior
                                                    chips:self.mutableChips
                                           staleChipViews:self.mutableChips
                                                chipsWrap:self.chipsWrap
                                            chipRowHeight:self.chipRowHeight
                                 interChipVerticalSpacing:self.interChipVerticalSpacing
                                    leadingAssistiveLabel:self.leadingAssistiveLabel
                                   trailingAssistiveLabel:self.trailingAssistiveLabel
                               assistiveLabelDrawPriority:self.assistiveLabelDrawPriority
                         customAssistiveLabelDrawPriority:self.customAssistiveLabelDrawPriority
                                 preferredContainerHeight:self.preferredContainerHeight
                             preferredNumberOfVisibleRows:self.preferredNumberOfVisibleRows
                                                    isRTL:self.shouldLayoutForRTL
                                                isEditing:self.inputChipViewTextField.isEditing];
}

- (void)preLayoutSubviews {
  self.textControlState = [self determineCurrentTextControlState];
  self.labelPosition = [self determineCurrentLabelPosition];
  self.interChipVerticalSpacing = [self determineInterChipVerticalSpacing];
  MDCTextControlColorViewModel *colorViewModel =
      [self textControlColorViewModelForState:self.textControlState];
  [self applyColorViewModel:colorViewModel withLabelState:self.labelPosition];
  self.layout = [self calculateLayoutWithSize:self.bounds.size];
  self.labelFrame = [self.layout labelFrameWithLabelPosition:self.labelPosition];

}

- (void)postLayoutSubviews {
  self.maskedScrollViewContainerView.frame = self.layout.maskedScrollViewContainerViewFrame;
  self.scrollView.frame = self.layout.scrollViewFrame;
  self.textField.frame = self.layout.textFieldFrame;
  self.scrollView.contentSize = self.layout.scrollViewContentSize;
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;

  self.label.hidden = self.labelPosition == MDCTextControlLabelPositionNone;

  [self updateChips];

  self.assistiveLabelView.frame = self.layout.assistiveLabelViewFrame;
  self.assistiveLabelView.layout = self.layout.assistiveLabelViewLayout;
  [self.assistiveLabelView setNeedsLayout];

  [self animateLabel];
  [self.containerStyle applyStyleToTextControl:self animationDuration:self.animationDuration];

  [self layOutGradientLayers];
}

- (CGSize)preferredSizeWithWidth:(CGFloat)width {
  CGSize fittingSize = CGSizeMake(width, CGFLOAT_MAX);
  MDCBaseInputChipViewLayout *layout = [self calculateLayoutWithSize:fittingSize];
  return CGSizeMake(width, layout.calculatedHeight);
}

- (BOOL)widthHasChangedSinceIntrinsicContentSizeWasLastComputed {
  return CGRectGetWidth(self.bounds) != self.mostRecentlyComputedIntrinsicContentSize.width;
}

- (BOOL)calculatedHeightHasChangedSinceIntrinsicContentSizeWasLastComputed {
  return self.layout.calculatedHeight != self.mostRecentlyComputedIntrinsicContentSize.height;
}

- (BOOL)shouldLayoutForRTL {
  if (self.semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
    return YES;
  } else if (self.semanticContentAttribute == UISemanticContentAttributeForceLeftToRight) {
    return NO;
  } else {
    return self.mdf_effectiveUserInterfaceLayoutDirection ==
           UIUserInterfaceLayoutDirectionRightToLeft;
  }
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

- (void)enforceCalculatedScrollViewContentOffset {
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
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
                                                      kMaxInterChipVerticalSpacing, self.density);
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
    if (chip.superview != self.scrollView) {
      [chips addObject:chip];
    }
  }
  return [chips copy];
}

- (NSArray<UIView *> *)chips {
  return [self.mutableChips copy];
}

- (void)updateChips {
  [self performChipRemoval];
  [self performChipPositioning];
  [self performChipAddition];
}

- (void)performChipRemoval {
  for (UIView *chip in self.chipsToRemove) {
    [chip removeFromSuperview];
  }
  [self.chipsToRemove removeAllObjects];
}

- (void)performChipPositioning {
  for (NSUInteger idx = 0; idx < self.mutableChips.count; idx++) {
    UIView *chip = self.mutableChips[idx];
    CGRect frame = CGRectZero;
    if (self.layout.chipFrames.count > idx) {
      frame = [self.layout.chipFrames[idx] CGRectValue];
    }
    chip.frame = frame;
  }
}

- (void)performChipAddition {
  NSArray<UIView *> *chipsToAdd = self.chipsToAdd;
  for (UIView *chip in chipsToAdd) {
    [self.scrollView addSubview:chip];
  }
}

#pragma mark Label

- (void)animateLabel {
  __weak MDCBaseInputChipView *weakSelf = self;
  [MDCTextControlLabelAnimation animateLabel:self.label
                                       state:self.labelPosition
                            normalLabelFrame:self.layout.labelFrameNormal
                          floatingLabelFrame:self.layout.labelFrameFloating
                                  normalFont:self.normalFont
                                floatingFont:self.floatingFont
                           animationDuration:self.animationDuration
                                  completion:^(BOOL finished) {
                                    if (finished) {
                                      weakSelf.label.frame = weakSelf.labelFrame;
                                    }
                                  }];
}

- (BOOL)canLabelFloat {
  return self.labelBehavior == MDCTextControlLabelBehaviorFloats;
}

- (MDCTextControlLabelPosition)determineCurrentLabelPosition {
  BOOL hasTextFieldText = self.textField.text.length > 0;
  BOOL hasChips = self.mutableChips.count > 0;
  BOOL hasText = hasTextFieldText || hasChips;
  return MDCTextControlLabelPositionWith(self.label.text.length > 0,
                                         hasText,
                                         self.canLabelFloat,
                                         self.textField.isEditing);
}

#pragma mark MDCTextControlState

- (MDCTextControlState)determineCurrentTextControlState {
  return MDCTextControlStateWith((self.enabled && self.inputChipViewTextField.enabled), self.inputChipViewTextField.isEditing);
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

- (CGFloat)numberOfLinesOfVisibleText {
  return self.preferredNumberOfVisibleRows;
}

- (UILabel *)leadingAssistiveLabel {
  return self.assistiveLabelView.leadingAssistiveLabel;
}

- (UILabel *)trailingAssistiveLabel {
  return self.assistiveLabelView.trailingAssistiveLabel;
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

- (void)observeContentSizeCategoryNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(contentSizeCategoryDidChange:)
                                               name:UIContentSizeCategoryDidChangeNotification
                                             object:nil];
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification {
  [self setNeedsLayout];
}

#pragma mark Coloring

- (void)applyColorViewModel:(MDCTextControlColorViewModel *)colorViewModel
             withLabelState:(MDCTextControlLabelPosition)labelState {
  UIColor *labelColor = [UIColor clearColor];
  if (labelState == MDCTextControlLabelPositionNormal) {
    labelColor = colorViewModel.normalLabelColor;
  } else if (labelState == MDCTextControlLabelPositionFloating) {
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
