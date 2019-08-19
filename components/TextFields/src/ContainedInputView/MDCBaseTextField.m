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

#import "MDCBaseTextField.h"

#import <Foundation/Foundation.h>

#import <MDFInternationalization/MDFInternationalization.h>

#import "private/MDCBaseTextFieldLayout.h"
#import "private/MDCContainedInputAssistiveLabelView.h"
#import "private/MDCContainedInputViewClearButton.h"
#import "private/MDCContainedInputViewLabelAnimator.h"
#import "private/MDCContainedInputViewStyleBase.h"
#import "private/MDCContainedInputViewStylePathDrawingUtils.h"
#import "MaterialMath.h"
#import "MaterialTypography.h"

@interface MDCBaseTextField () <MDCContainedInputView>

@property(strong, nonatomic) MDCContainedInputViewClearButton *clearButton;
@property(strong, nonatomic) UILabel *label;
@property(strong, nonatomic) UILabel *placeholderLabel;

@property(strong, nonatomic) MDCBaseTextFieldLayout *layout;

@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;

@property(nonatomic, assign) MDCContainedInputViewState containedInputViewState;
@property(nonatomic, assign) MDCContainedInputViewLabelState labelState;
@property(nonatomic, assign) BOOL isPlaceholderVisible;

@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, id<MDCContainedInputViewColorScheming>> *colorSchemes;

//@property(nonatomic, strong) MDCContainedInputViewLabelAnimator *labelAnimator;

@property(nonatomic, strong) MDCContainedInputAssistiveLabelView *underlineLabelView;

@end

@implementation MDCBaseTextField
@synthesize labelAnimator = _labelAnimator;
@synthesize preferredContainerHeight = _preferredContainerHeight;
@synthesize underlineLabelDrawPriority = _underlineLabelDrawPriority;
@synthesize customAssistiveLabelDrawPriority = _customAssistiveLabelDrawPriority;
@synthesize containerStyle = _containerStyle;
@synthesize labelBehavior = _labelBehavior;

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBaseTextFieldInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCBaseTextFieldInit];
  }
  return self;
}

- (void)commonMDCBaseTextFieldInit {
  [self initializeProperties];
  [self setUpFloatingLabel];
  [self setUpPlaceholderLabel];
  [self setUpLabelAnimator];
  [self setUpAssistiveLabels];
  [self setUpClearButton];
  [self setUpContainerStyle];
}

#pragma mark View Setup

- (void)initializeProperties {
  [self setUpLabelBehavior];
  [self setUpLayoutDirection];
  [self setUpLabelState];
  [self setUpContainedInputViewState];
  [self setUpColorSchemesDictionary];
}

- (void)setUpLabelBehavior {
  self.labelBehavior = MDCTextControlLabelBehaviorFloats;
}

- (void)setUpLayoutDirection {
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
}

- (void)setUpLabelState {
  self.labelState = [self determineCurrentLabelState];
}

- (void)setUpContainedInputViewState {
  self.containedInputViewState = [self determineCurrentContainedInputViewState];
}

- (void)setUpColorSchemesDictionary {
  self.colorSchemes = [[NSMutableDictionary alloc] init];
}

- (void)setUpContainerStyle {
  self.containerStyle = [[MDCContainedInputViewStyleBase alloc] init];
}

- (void)setUpStateDependentColorSchemesForStyle:(id<MDCContainedInputViewStyle>)containerStyle {
  id<MDCContainedInputViewColorScheming> normalColorScheme =
      [containerStyle defaultColorSchemeForState:MDCContainedInputViewStateNormal];
  [self setContainedInputViewColorScheming:normalColorScheme
                                  forState:MDCContainedInputViewStateNormal];

  id<MDCContainedInputViewColorScheming> focusedColorScheme =
      [containerStyle defaultColorSchemeForState:MDCContainedInputViewStateFocused];
  [self setContainedInputViewColorScheming:focusedColorScheme
                                  forState:MDCContainedInputViewStateFocused];

  id<MDCContainedInputViewColorScheming> disabledColorScheme =
      [containerStyle defaultColorSchemeForState:MDCContainedInputViewStateDisabled];
  [self setContainedInputViewColorScheming:disabledColorScheme
                                  forState:MDCContainedInputViewStateDisabled];
}

- (void)setUpAssistiveLabels {
  self.underlineLabelDrawPriority = MDCContainedInputViewAssistiveLabelDrawPriorityTrailing;
  self.underlineLabelView = [[MDCContainedInputAssistiveLabelView alloc] init];
  CGFloat underlineFontSize = MDCRound([UIFont systemFontSize] * (CGFloat)0.75);
  UIFont *underlineFont = [UIFont systemFontOfSize:underlineFontSize];
  self.underlineLabelView.leftAssistiveLabel.font = underlineFont;
  self.underlineLabelView.rightAssistiveLabel.font = underlineFont;
  [self addSubview:self.underlineLabelView];
}

- (UILabel *)leftAssistiveLabel {
  return self.underlineLabelView.leftAssistiveLabel;
}

- (UILabel *)rightAssistiveLabel {
  return self.underlineLabelView.rightAssistiveLabel;
}

- (void)setUpFloatingLabel {
  self.label = [[UILabel alloc] initWithFrame:self.bounds];
  [self addSubview:self.label];
}

- (void)setUpPlaceholderLabel {
  self.placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
  [self addSubview:self.placeholderLabel];
}

- (void)setUpLabelAnimator {
  self.labelAnimator = [[MDCContainedInputViewLabelAnimator alloc] init];
}

- (void)setUpClearButton {
  self.clearButton = [[MDCContainedInputViewClearButton alloc] init];
  [self.clearButton addTarget:self
                       action:@selector(clearButtonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.clearButton];
}

#pragma mark UIView Overrides

- (void)layoutSubviews {
  [self preLayoutSubviews];
  [super layoutSubviews];
  [self postLayoutSubviews];
}

// UITextField's sizeToFit calls this method and then also calls setNeedsLayout.
// When the system calls this method the size parameter is the view's current size.
- (CGSize)sizeThatFits:(CGSize)size {
  return [self preferredSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
  return [self preferredSizeWithWidth:CGRectGetWidth(self.bounds)];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self setUpLayoutDirection];
}

#pragma mark Layout

- (void)preLayoutSubviews {
  self.containedInputViewState = [self determineCurrentContainedInputViewState];
  self.labelState = [self determineCurrentLabelState];
  self.isPlaceholderVisible = [self shouldPlaceholderBeVisible];
  self.placeholderLabel.font = self.normalFont;
  id<MDCContainedInputViewColorScheming> colorScheming =
      [self containedInputViewColorSchemingForState:self.containedInputViewState];
  [self applyMDCContainedInputViewColorScheming:colorScheming];
  CGSize fittingSize = CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX);
  
  self.layout = [self calculateLayoutWithTextFieldSize:fittingSize];
}

- (void)postLayoutSubviews {
  CGRect placeholderFrame = [self placeholderRectFromLayout:self.layout labelState:self.labelState];
  self.placeholderLabel.attributedText = self.attributedPlaceholder;
  [self.labelAnimator layOutPlaceholderLabel:self.placeholderLabel
                            placeholderFrame:placeholderFrame
                        isPlaceholderVisible:self.isPlaceholderVisible];
  [self.labelAnimator layOutLabel:self.label
                            state:self.labelState
                 normalLabelFrame:self.layout.labelFrameNormal
               floatingLabelFrame:self.layout.labelFrameFloating
                       normalFont:self.normalFont
                     floatingFont:self.floatingFont];
  id<MDCContainedInputViewColorScheming> colorScheming =
      [self containedInputViewColorSchemingForState:self.containedInputViewState];
  [self.containerStyle applyStyleToContainedInputView:self
                  withContainedInputViewColorScheming:colorScheming];
  self.clearButton.frame = [self clearButtonFrameFromLayout:self.layout labelState:self.labelState];
  self.clearButton.hidden = self.layout.clearButtonHidden;
  self.underlineLabelView.frame = self.layout.underlineLabelViewFrame;
  self.underlineLabelView.layout = self.layout.underlineLabelViewLayout;
  self.leftView.hidden = self.layout.leftViewHidden;
  self.rightView.hidden = self.layout.rightViewHidden;
  // TODO: Consider hiding views that don't actually fit in the frame
}

- (CGRect)textRectFromLayout:(MDCBaseTextFieldLayout *)layout
                  labelState:(MDCContainedInputViewLabelState)labelState {
  CGRect textRect = layout.textRectNormal;
  if (labelState == MDCContainedInputViewLabelStateFloating) {
    textRect = layout.textRectFloating;
  }
  return textRect;
}

- (CGRect)placeholderRectFromLayout:(MDCBaseTextFieldLayout *)layout
                         labelState:(MDCContainedInputViewLabelState)labelState {
  CGRect placeholderRect = layout.placeholderFrameNormal;
  if (labelState == MDCContainedInputViewLabelStateFloating) {
    placeholderRect = layout.placeholderFrameFloating;
  }
  return placeholderRect;
}

- (CGRect)adjustTextAreaFrame:(CGRect)textRect
    withParentClassTextAreaFrame:(CGRect)parentClassTextAreaFrame {
  CGFloat systemDefinedHeight = CGRectGetHeight(parentClassTextAreaFrame);
  CGFloat minY = CGRectGetMidY(textRect) - (systemDefinedHeight * (CGFloat)0.5);
  return CGRectMake(CGRectGetMinX(textRect), minY, CGRectGetWidth(textRect), systemDefinedHeight);
}

- (CGRect)clearButtonFrameFromLayout:(MDCBaseTextFieldLayout *)layout
                          labelState:(MDCContainedInputViewLabelState)labelState {
  CGRect clearButtonFrame = layout.clearButtonFrameNormal;
  if (labelState == MDCContainedInputViewLabelStateFloating) {
    clearButtonFrame = layout.clearButtonFrameFloating;
  }
  return clearButtonFrame;
}

- (MDCBaseTextFieldLayout *)calculateLayoutWithTextFieldSize:(CGSize)textFieldSize {
  CGFloat normalizedCustomAssistiveLabelDrawPriority =
      [self normalizedCustomAssistiveLabelDrawPriority:self.customAssistiveLabelDrawPriority];
  return [[MDCBaseTextFieldLayout alloc]
                 initWithTextFieldSize:textFieldSize
                        containerStyle:self.containerStyle
                                  text:self.text
                           placeholder:self.placeholder
                                  font:self.normalFont
                          floatingFont:self.floatingFont
                                 label:self.label
                            labelState:self.labelState
                         labelBehavior:self.labelBehavior
                              leftView:self.leftView
                          leftViewMode:self.leftViewMode
                             rightView:self.rightView
                         rightViewMode:self.rightViewMode
                           clearButton:self.clearButton
                       clearButtonMode:self.clearButtonMode
                    leftAssistiveLabel:self.leftAssistiveLabel
                   rightAssistiveLabel:self.rightAssistiveLabel
            underlineLabelDrawPriority:self.underlineLabelDrawPriority
      customAssistiveLabelDrawPriority:normalizedCustomAssistiveLabelDrawPriority
              preferredContainerHeight:self.preferredContainerHeight
                                 isRTL:self.isRTL
                             isEditing:self.isEditing];
}

- (CGFloat)normalizedCustomAssistiveLabelDrawPriority:(CGFloat)customPriority {
  CGFloat value = customPriority;
  if (value < 0) {
    value = 0;
  } else if (value > 1) {
    value = 1;
  }
  return value;
}

- (CGSize)preferredSizeWithWidth:(CGFloat)width {
  CGSize fittingSize = CGSizeMake(width, CGFLOAT_MAX);
  MDCBaseTextFieldLayout *inputTextFieldLayout =
      [self calculateLayoutWithTextFieldSize:fittingSize];
  return CGSizeMake(width, inputTextFieldLayout.calculatedHeight);
}

#pragma mark UITextField Accessor Overrides

- (void)setPlaceholder:(NSString *)placeholder {
  self.placeholderLabel.attributedText = nil;
  self.placeholderLabel.text = [placeholder copy];
}

- (NSString *)placeholder {
  return self.placeholderLabel.text;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
  [super setAttributedPlaceholder:attributedPlaceholder];
  //  self.label.text = [attributedPlaceholder string];
//    self.label.attributedText = [attributedPlaceholder copy];
  //  NSLog(@"setting attributedPlaceholder is not currently supported.");
  // TODO: Evaluate if attributedPlaceholder should be supported.
  //}
  //
  //- (NSAttributedString *)attributedPlaceholder {
  //  return self.label.attributedText;
}

- (void)setLeftViewMode:(UITextFieldViewMode)leftViewMode {
  NSLog(@"Setting leftViewMode is not recommended. Consider setting leadingViewMode and "
        @"trailingViewMode instead.");
  [self mdc_setLeftViewMode:leftViewMode];
}

- (void)setRightViewMode:(UITextFieldViewMode)rightViewMode {
  NSLog(@"Setting rightViewMode is not recommended. Consider setting leadingViewMode and "
        @"trailingViewMode instead.");
  [self mdc_setRightViewMode:rightViewMode];
}

- (void)setLeftView:(UIView *)leftView {
  NSLog(@"Setting rightView and leftView are not recommended. Consider setting leadingView and "
        @"trailingView instead.");
  [self mdc_setLeftView:leftView];
}

- (void)setRightView:(UIView *)rightView {
  NSLog(@"Setting rightView and leftView are not recommended. Consider setting leadingView and "
        @"trailingView instead.");
  [self mdc_setRightView:rightView];
}

#pragma mark Custom Accessors

- (UILabel *)leadingAssistiveLabel {
  if ([self isRTL]) {
    return self.underlineLabelView.rightAssistiveLabel;
  } else {
    return self.underlineLabelView.leftAssistiveLabel;
  }
}

- (UILabel *)trailingAssistiveLabel {
  if ([self isRTL]) {
    return self.underlineLabelView.leftAssistiveLabel;
  } else {
    return self.underlineLabelView.rightAssistiveLabel;
  }
}

- (void)setTrailingView:(UIView *)trailingView {
  if ([self isRTL]) {
    [self mdc_setLeftView:trailingView];
  } else {
    [self mdc_setRightView:trailingView];
  }
}

- (UIView *)trailingView {
  if ([self isRTL]) {
    return self.leftView;
  } else {
    return self.rightView;
  }
}

- (void)setLeadingView:(UIView *)leadingView {
  if ([self isRTL]) {
    [self mdc_setRightView:leadingView];
  } else {
    [self mdc_setLeftView:leadingView];
  }
}

- (UIView *)leadingView {
  if ([self isRTL]) {
    return self.rightView;
  } else {
    return self.leftView;
  }
}

- (void)mdc_setLeftView:(UIView *)leftView {
  [super setLeftView:leftView];
  // TODO: Determine if a call to setNeedsLayout is necessary or if super calls it
}

- (void)mdc_setRightView:(UIView *)rightView {
  [super setRightView:rightView];
  // TODO: Determine if a call to setNeedsLayout is necessary or if super calls it
}

- (void)setTrailingViewMode:(UITextFieldViewMode)trailingViewMode {
  if ([self isRTL]) {
    [self mdc_setLeftViewMode:trailingViewMode];
  } else {
    [self mdc_setRightViewMode:trailingViewMode];
  }
}

- (UITextFieldViewMode)trailingViewMode {
  if ([self isRTL]) {
    return self.leftViewMode;
  } else {
    return self.rightViewMode;
  }
}

- (void)setLeadingViewMode:(UITextFieldViewMode)leadingViewMode {
  if ([self isRTL]) {
    [self mdc_setRightViewMode:leadingViewMode];
  } else {
    [self mdc_setLeftViewMode:leadingViewMode];
  }
}

- (UITextFieldViewMode)leadingViewMode {
  if ([self isRTL]) {
    return self.rightViewMode;
  } else {
    return self.leftViewMode;
  }
}

- (void)mdc_setLeftViewMode:(UITextFieldViewMode)leftViewMode {
  [super setLeftViewMode:leftViewMode];
}

- (void)mdc_setRightViewMode:(UITextFieldViewMode)rightViewMode {
  [super setRightViewMode:rightViewMode];
}

- (void)setLayoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection {
  if (_layoutDirection == layoutDirection) {
    return;
  }
  _layoutDirection = layoutDirection;
  [self setNeedsLayout];
}

- (void)setLabelBehavior:(MDCTextControlLabelBehavior)labelBehavior {
  if (_labelBehavior == labelBehavior) {
    return;
  }
  _labelBehavior = labelBehavior;
  [self setNeedsLayout];
}

- (void)setContainerStyle:(id<MDCContainedInputViewStyle>)containerStyle {
  id<MDCContainedInputViewStyle> oldStyle = _containerStyle;
  if (oldStyle) {
    [oldStyle removeStyleFrom:self];
  }
  _containerStyle = containerStyle;
  [self setUpStateDependentColorSchemesForStyle:_containerStyle];
  id<MDCContainedInputViewColorScheming> colorScheme =
      [self containedInputViewColorSchemingForState:self.containedInputViewState];
  [_containerStyle applyStyleToContainedInputView:self
              withContainedInputViewColorScheming:colorScheme];
}

#pragma mark MDCContainedInputView accessors

- (CGRect)containerFrame {
  return CGRectMake(0, 0, CGRectGetWidth(self.frame), self.layout.topRowBottomRowDividerY);
}

- (CGFloat)numberOfTextRows {
  return 1;
}

#pragma mark UITextField Layout Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
  CGRect textRect = [self textRectFromLayout:self.layout labelState:self.labelState];
  return [self adjustTextAreaFrame:textRect
      withParentClassTextAreaFrame:[super textRectForBounds:bounds]];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  CGRect textRect = [self textRectFromLayout:self.layout labelState:self.labelState];
  return [self adjustTextAreaFrame:textRect
      withParentClassTextAreaFrame:[super editingRectForBounds:bounds]];
}

// The implementations for this method and the method below deserve some context! Unfortunately,
// Apple's RTL behavior with these methods is very unintuitive. Imagine you're in an RTL locale and
// you set @c leftView on a standard UITextField. Even though the property that you set is called @c
// leftView, the method @c -rightViewRectForBounds: will be called. They are treating @c leftView as
// @c rightView, even though @c rightView is nil. It's bonkers.
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  if ([self isRTL]) {
    return self.layout.rightViewFrame;
  } else {
    return self.layout.leftViewFrame;
  }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  if ([self isRTL]) {
    return self.layout.leftViewFrame;
  } else {
    return self.layout.rightViewFrame;
  }
}

- (CGRect)borderRectForBounds:(CGRect)bounds {
  if (!self.containerStyle) {
    return [super borderRectForBounds:bounds];
  }
  return CGRectZero;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  if (self.labelState == MDCContainedInputViewLabelStateNormal) {
    return CGRectZero;
  }
  return [super placeholderRectForBounds:bounds];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
  id<MDCContainedInputViewColorScheming> colorScheme =
      [self containedInputViewColorSchemingForState:self.containedInputViewState];
  NSDictionary *attributes = @{
    NSFontAttributeName : self.font,
    NSForegroundColorAttributeName : colorScheme.placeholderColor
  };
  [self.placeholder drawInRect:rect withAttributes:attributes];
}

#pragma mark Fonts

- (UIFont *)normalFont {
  return self.font ?: [self uiTextFieldDefaultFont];
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
    self.font = textFont;
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

#pragma mark Text Field State

- (MDCContainedInputViewState)determineCurrentContainedInputViewState {
  return [self containedInputViewStateWithIsEnabled:self.isEnabled isEditing:self.isEditing];
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

#pragma mark Floating Label

- (BOOL)canLabelFloat {
  return self.labelBehavior == MDCTextControlLabelBehaviorFloats;
}

- (BOOL)shouldPlaceholderBeVisible {
  return [self shouldPlaceholderBeVisibleWithPlaceholder:self.placeholder
                                              labelState:self.labelState
                                                    text:self.text
                                               isEditing:self.isEditing];
}

- (MDCContainedInputViewLabelState)determineCurrentLabelState {
  return [self labelStateWithLabel:self.label
                              text:self.text
                     canLabelFloat:self.canLabelFloat
                         isEditing:self.isEditing];
}

- (BOOL)shouldPlaceholderBeVisibleWithPlaceholder:(NSString *)placeholder
                                       labelState:(MDCContainedInputViewLabelState)labelState
                                             text:(NSString *)text
                                        isEditing:(BOOL)isEditing {
  BOOL hasPlaceholder = placeholder.length > 0;
  BOOL hasText = text.length > 0;

  if (hasPlaceholder) {
    if (hasText) {
      return NO;
    } else {
      if (labelState == MDCContainedInputViewLabelStateNormal) {
        return NO;
      } else {
        return YES;
      }
    }
  } else {
    return NO;
  }
}

- (MDCContainedInputViewLabelState)labelStateWithLabel:(UILabel *)label
                                                  text:(NSString *)text
                                         canLabelFloat:(BOOL)canLabelFloat
                                             isEditing:(BOOL)isEditing {
  BOOL hasFloatingLabelText = label.text.length > 0;
  BOOL hasText = text.length > 0;
  if (hasFloatingLabelText) {
    if (canLabelFloat) {
      if (isEditing) {
        return MDCContainedInputViewLabelStateFloating;
      } else {
        if (hasText) {
          return MDCContainedInputViewLabelStateFloating;
        } else {
          return MDCContainedInputViewLabelStateNormal;
        }
      }
    } else {
      if (hasText) {
        return MDCContainedInputViewLabelStateNone;
      } else {
        return MDCContainedInputViewLabelStateNormal;
      }
    }
  } else {
    return MDCContainedInputViewLabelStateNone;
  }
}

#pragma mark User Actions

- (void)clearButtonPressed:(UIButton *)clearButton {
  self.text = nil;
  [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

#pragma mark Internationalization

- (BOOL)isRTL {
  return self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

#pragma mark Theming

- (void)applyMDCContainedInputViewColorScheming:
    (id<MDCContainedInputViewColorScheming>)colorScheming {
  self.textColor = colorScheming.textColor;
  self.leadingAssistiveLabel.textColor = colorScheming.underlineLabelColor;
  self.leadingAssistiveLabel.textColor = colorScheming.underlineLabelColor;
  self.label.textColor = colorScheming.floatingLabelColor;
  self.placeholderLabel.textColor = colorScheming.placeholderColor;
  self.clearButton.tintColor = colorScheming.clearButtonTintColor;
}

- (void)setContainedInputViewColorScheming:
            (id<MDCContainedInputViewColorScheming>)simpleTextFieldColorScheming
                                  forState:(MDCContainedInputViewState)containedInputViewState {
  self.colorSchemes[@(containedInputViewState)] = simpleTextFieldColorScheming;
}

- (id<MDCContainedInputViewColorScheming>)containedInputViewColorSchemingForState:
    (MDCContainedInputViewState)containedInputViewState {
  id<MDCContainedInputViewColorScheming> colorScheme =
      self.colorSchemes[@(containedInputViewState)];
  if (!colorScheme) {
    colorScheme = [self.containerStyle defaultColorSchemeForState:containedInputViewState];
  }
  return colorScheme;
}

#pragma mark Color Accessors

- (void)setLabelColor:(nonnull UIColor *)labelColor forState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  id<MDCContainedInputViewColorScheming> colorScheme =
      [self containedInputViewColorSchemingForState:containedInputViewState];
  colorScheme.floatingLabelColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)labelColorForState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  id<MDCContainedInputViewColorScheming> colorScheme =
      [self containedInputViewColorSchemingForState:containedInputViewState];
  return colorScheme.floatingLabelColor;
}

- (void)setTextColor:(nonnull UIColor *)labelColor forState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  id<MDCContainedInputViewColorScheming> colorScheme =
      [self containedInputViewColorSchemingForState:containedInputViewState];
  colorScheme.textColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)textColorForState:(UIControlState)state {
  MDCContainedInputViewState containedInputViewState =
      MDCContainedInputViewStateWithUIControlState(state);
  id<MDCContainedInputViewColorScheming> colorScheme =
      [self containedInputViewColorSchemingForState:containedInputViewState];
  return colorScheme.textColor;
}

@end
