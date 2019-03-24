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

#import "MDCInputTextArea.h"

#import <Foundation/Foundation.h>

#import <MDFInternationalization/MDFInternationalization.h>
#import "MaterialTypography.h"

#import "MDCContainerStylePathDrawingUtils.h"
#import "MDCInputTextAreaLayout.h"
#import "MaterialMath.h"

@interface MDCInputTextArea ()

@property(strong, nonatomic) UIButton *clearButton;
@property(strong, nonatomic) UIImageView *clearButtonImageView;
@property(strong, nonatomic) UILabel *floatingLabel;
@property(strong, nonatomic) UILabel *placeholderLabel;

@property(strong, nonatomic) UILabel *leftUnderlineLabel;
@property(strong, nonatomic) UILabel *rightUnderlineLabel;

@property(strong, nonatomic) MDCInputTextAreaLayout *layout;

@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;

@property(nonatomic, assign) MDCContainedInputViewState containedInputViewState;
@property(nonatomic, assign) MDCContainedInputViewFloatingLabelState floatingLabelState;
@property(nonatomic, assign) BOOL isPlaceholderVisible;

@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, id<MDCContainedInputViewColorScheming>> *colorSchemes;

@property(nonatomic, strong) MDCContainedInputViewFloatingLabelManager *floatingLabelManager;

@end

@implementation MDCInputTextArea
@synthesize preferredMainContentAreaHeight = _preferredMainContentAreaHeight;
@synthesize preferredUnderlineLabelAreaHeight = _preferredUnderlineLabelAreaHeight;
@synthesize underlineLabelDrawPriority = _underlineLabelDrawPriority;
@synthesize customUnderlineLabelDrawPriority = _customUnderlineLabelDrawPriority;
@synthesize containerStyle = _containerStyle;
@synthesize isActivated = _isActivated;
@synthesize isErrored = _isErrored;
@synthesize canFloatingLabelFloat = _canFloatingLabelFloat;

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCInputTextAreaInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCInputTextAreaInit];
  }
  return self;
}

- (void)commonMDCInputTextAreaInit {
  [self initializeProperties];
  [self setUpFloatingLabel];
  [self setUpPlaceholderLabel];
  [self setUpFloatingLabelManager];
  [self setUpUnderlineLabels];
  [self setUpClearButton];
  [self setUpContainerStyle];
}

#pragma mark View Setup

- (void)initializeProperties {
  [self setUpCanFloatingLabelFloat];
  [self setUpLayoutDirection];
  [self setUpFloatingLabelState];
  [self setUpContainedInputViewState];
  [self setUpColorSchemesDictionary];
}

- (void)setUpCanFloatingLabelFloat {
  self.canFloatingLabelFloat = YES;
}

- (void)setUpLayoutDirection {
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
}

- (void)setUpFloatingLabelState {
  self.floatingLabelState = [self determineCurrentFloatingLabelState];
}

- (void)setUpContainedInputViewState {
  self.containedInputViewState = [self determineCurrentContainedInputViewState];
}

- (void)setUpColorSchemesDictionary {
  self.colorSchemes = [[NSMutableDictionary alloc] init];
}

- (void)setUpContainerStyle {
  self.containerStyle = [[MDCContainerStyleBase alloc] init];
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

  id<MDCContainedInputViewColorScheming> activatedColorScheme =
      [containerStyle defaultColorSchemeForState:MDCContainedInputViewStateActivated];
  [self setContainedInputViewColorScheming:activatedColorScheme
                                  forState:MDCContainedInputViewStateActivated];

  id<MDCContainedInputViewColorScheming> erroredColorScheme =
      [containerStyle defaultColorSchemeForState:MDCContainedInputViewStateErrored];
  [self setContainedInputViewColorScheming:erroredColorScheme
                                  forState:MDCContainedInputViewStateErrored];

  id<MDCContainedInputViewColorScheming> disabledColorScheme =
      [containerStyle defaultColorSchemeForState:MDCContainedInputViewStateDisabled];
  [self setContainedInputViewColorScheming:disabledColorScheme
                                  forState:MDCContainedInputViewStateDisabled];
}

- (void)setUpUnderlineLabels {
  CGFloat underlineFontSize = MDCRound([UIFont systemFontSize] * (CGFloat)0.75);
  UIFont *underlineFont = [UIFont systemFontOfSize:underlineFontSize];
  self.leftUnderlineLabel = [[UILabel alloc] init];
  self.leftUnderlineLabel.font = underlineFont;
  self.rightUnderlineLabel = [[UILabel alloc] init];
  self.rightUnderlineLabel.font = underlineFont;
  [self addSubview:self.leftUnderlineLabel];
  [self addSubview:self.rightUnderlineLabel];
}

- (void)setUpFloatingLabel {
  self.floatingLabel = [[UILabel alloc] initWithFrame:self.bounds];
  [self addSubview:self.floatingLabel];
}

- (void)setUpPlaceholderLabel {
  self.placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
  [self addSubview:self.placeholderLabel];
}

- (void)setUpFloatingLabelManager {
  self.floatingLabelManager = [[MDCContainedInputViewFloatingLabelManager alloc] init];
}

- (void)setUpClearButton {
  CGFloat clearButtonSideLength = MDCInputTextAreaLayout.clearButtonSideLength;
  CGRect clearButtonFrame = CGRectMake(0, 0, clearButtonSideLength, clearButtonSideLength);
  self.clearButton = [[UIButton alloc] initWithFrame:clearButtonFrame];
  [self.clearButton addTarget:self
                       action:@selector(clearButtonPressed:)
             forControlEvents:UIControlEventTouchUpInside];

  CGFloat clearButtonImageViewSideLength = MDCInputTextAreaLayout.clearButtonImageViewSideLength;
  CGRect clearButtonImageViewRect =
      CGRectMake(0, 0, clearButtonImageViewSideLength, clearButtonImageViewSideLength);
  self.clearButtonImageView = [[UIImageView alloc] initWithFrame:clearButtonImageViewRect];
  UIImage *clearButtonImage =
      [[self untintedClearButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.clearButtonImageView.image = clearButtonImage;
  [self.clearButton addSubview:self.clearButtonImageView];
  [self addSubview:self.clearButton];
  self.clearButtonImageView.center = self.clearButton.center;
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
  self.floatingLabelState = [self determineCurrentFloatingLabelState];
  self.isPlaceholderVisible = [self shouldPlaceholderBeVisible];
  self.placeholderLabel.font = [self determineEffectiveFont];
  id<MDCContainedInputViewColorScheming> colorScheming =
      [self containedInputViewColorSchemingForState:self.containedInputViewState];
  [self applyMDCContainedInputViewColorScheming:colorScheming];
  CGSize fittingSize = CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX);
  self.layout = [self calculateLayoutWithTextAreaSize:fittingSize];
}

- (void)postLayoutSubviews {
  UIFont *normalFont = [self determineEffectiveFont];
  UIFont *floatingFont = [self.floatingLabelManager floatingFontWithFont:normalFont
                                                          containerStyle:self.containerStyle];
  [self.floatingLabelManager layOutPlaceholderLabel:self.placeholderLabel
                                   placeholderFrame:self.layout.textRectFloatingLabel
                               isPlaceholderVisible:self.isPlaceholderVisible];
  [self.floatingLabelManager layOutFloatingLabel:self.floatingLabel
                                           state:self.floatingLabelState
                                     normalFrame:self.layout.floatingLabelFrameNormal
                                   floatingFrame:self.layout.floatingLabelFrameFloating
                                      normalFont:normalFont
                                    floatingFont:floatingFont];
  id<MDCContainedInputViewColorScheming> colorScheming =
      [self containedInputViewColorSchemingForState:self.containedInputViewState];
  [self.containerStyle applyStyleToContainedInputView:self
                  withContainedInputViewColorScheming:colorScheming];
  self.clearButton.frame = [self clearButtonFrameFromLayout:self.layout
                                         floatingLabelState:self.floatingLabelState];
  self.clearButton.hidden = self.layout.clearButtonHidden;
  self.leftUnderlineLabel.frame = self.layout.leftUnderlineLabelFrame;
  self.rightUnderlineLabel.frame = self.layout.rightUnderlineLabelFrame;
  // TODO: Consider hiding views that don't actually fit in the frame
}

- (CGRect)clearButtonFrameFromLayout:(MDCInputTextAreaLayout *)layout
                  floatingLabelState:(MDCContainedInputViewFloatingLabelState)floatingLabelState {
  CGRect clearButtonFrame = layout.clearButtonFrame;
  if (floatingLabelState == MDCContainedInputViewFloatingLabelStateFloating) {
    clearButtonFrame = layout.clearButtonFrameFloatingLabel;
  }
  return clearButtonFrame;
}

- (MDCInputTextAreaLayout *)calculateLayoutWithTextAreaSize:(CGSize)textFieldSize {
  UIFont *effectiveFont = [self determineEffectiveFont];
  UIFont *floatingFont = [self.floatingLabelManager floatingFontWithFont:effectiveFont
                                                          containerStyle:self.containerStyle];
  CGFloat normalizedCustomUnderlineLabelDrawPriority =
      [self normalizedCustomUnderlineLabelDrawPriority:self.customUnderlineLabelDrawPriority];
  return [[MDCInputTextAreaLayout alloc]
                  initWithTextFieldSize:textFieldSize
                         containerStyle:self.containerStyle
                                   text:self.text
                            placeholder:self.placeholder
                                   font:effectiveFont
                           floatingFont:floatingFont
                          floatingLabel:self.floatingLabel
                  canFloatingLabelFloat:self.canFloatingLabelFloat
                            clearButton:self.clearButton
                        clearButtonMode:self.clearButtonMode
                     leftUnderlineLabel:self.leftUnderlineLabel
                    rightUnderlineLabel:self.rightUnderlineLabel
             underlineLabelDrawPriority:self.underlineLabelDrawPriority
       customUnderlineLabelDrawPriority:normalizedCustomUnderlineLabelDrawPriority
         preferredMainContentAreaHeight:self.preferredMainContentAreaHeight
      preferredUnderlineLabelAreaHeight:self.preferredUnderlineLabelAreaHeight
                                  isRTL:self.isRTL
                              isEditing:self.isEditing];
}

- (CGFloat)normalizedCustomUnderlineLabelDrawPriority:(CGFloat)customPriority {
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
  MDCInputTextAreaLayout *layout = [self calculateLayoutWithTextAreaSize:fittingSize];
  return CGSizeMake(width, layout.calculatedHeight);
}

#pragma mark UITextField Accessor Overrides

- (void)setPlaceholder:(NSString *)placeholder {
  self.placeholderLabel.attributedText = nil;
  self.placeholderLabel.text = [placeholder copy];
}

- (NSString *)placeholder {
  return self.placeholderLabel.text;
}

//- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
//  [super setAttributedPlaceholder:attributedPlaceholder];
  //  self.floatingLabel.text = [attributedPlaceholder string];
//  self.floatingLabel.attributedText = [attributedPlaceholder copy];
//  NSLog(@"setting attributedPlaceholder is not currently supported.");
  // TODO: Evaluate if attributedPlaceholder should be supported.
//}
//
//- (NSAttributedString *)attributedPlaceholder {
//  return self.floatingLabel.attributedText;
//}

#pragma mark Custom Accessors

-(BOOL)isEditing {
  return self.isEditable && [self isFirstResponder];
}

- (UILabel *)leadingUnderlineLabel {
  if ([self isRTL]) {
    return self.rightUnderlineLabel;
  } else {
    return self.leftUnderlineLabel;
  }
}

- (UILabel *)trailingUnderlineLabel {
  if ([self isRTL]) {
    return self.leftUnderlineLabel;
  } else {
    return self.rightUnderlineLabel;
  }
}

- (void)setLayoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection {
  if (_layoutDirection == layoutDirection) {
    return;
  }
  _layoutDirection = layoutDirection;
  [self setNeedsLayout];
}

- (void)setCanFloatingLabelFloat:(BOOL)canFloatingLabelFloat {
  if (_canFloatingLabelFloat == canFloatingLabelFloat) {
    return;
  }
  _canFloatingLabelFloat = canFloatingLabelFloat;
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

- (void)setIsErrored:(BOOL)isErrored {
  if (_isErrored == isErrored) {
    return;
  }
  _isErrored = isErrored;
  [self setNeedsLayout];
}

- (void)setIsActivated:(BOOL)isActivated {
  if (_isActivated == isActivated) {
    return;
  }
  _isActivated = isActivated;
  [self setNeedsLayout];
}

- (CGRect)textRectFromLayout:(MDCInputTextAreaLayout *)layout
          floatingLabelState:(MDCContainedInputViewFloatingLabelState)floatingLabelState {
  CGRect textRect = layout.textRect;
  if (floatingLabelState == MDCContainedInputViewFloatingLabelStateFloating) {
    textRect = layout.textRectFloatingLabel;
  }
  return textRect;
}

- (CGRect)adjustTextAreaFrame:(CGRect)textRect
    withParentClassTextAreaFrame:(CGRect)parentClassTextAreaFrame {
  CGFloat systemDefinedHeight = CGRectGetHeight(parentClassTextAreaFrame);
  CGFloat minY = CGRectGetMidY(textRect) - (systemDefinedHeight * (CGFloat)0.5);
  return CGRectMake(CGRectGetMinX(textRect), minY, CGRectGetWidth(textRect), systemDefinedHeight);
}

- (CGRect)containerFrame {
  return CGRectMake(0, 0, CGRectGetWidth(self.frame), self.layout.topRowBottomRowDividerY);
}

#pragma mark UITextField Layout Overrides

// The implementations for this method and the method below deserve some context! Unfortunately,
// Apple's RTL behavior with these methods is very unintuitive. Imagine you're in an RTL locale and
// you set @c leftView on a standard UITextField. Even though the property that you set is called @c
// leftView, the method @c -rightViewRectForBounds: will be called. They are treating @c leftView as
// @c rightView, even though @c rightView is nil. It's bonkers.

#pragma mark Fonts

- (UIFont *)determineEffectiveFont {
  return self.font ?: [self uiTextFieldDefaultFont];
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
    self.floatingLabel.font = textFont;
    self.leadingUnderlineLabel.font = helperFont;
    self.trailingUnderlineLabel.font = helperFont;
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
  return [self containedInputViewStateWithIsEnabled:self.isEnabled
                                          isErrored:self.isErrored
                                          isEditing:self.isEditing
                                         isSelected:self.isSelected
                                        isActivated:self.isActivated];
}

- (MDCContainedInputViewState)containedInputViewStateWithIsEnabled:(BOOL)isEnabled
                                                         isErrored:(BOOL)isErrored
                                                         isEditing:(BOOL)isEditing
                                                        isSelected:(BOOL)isSelected
                                                       isActivated:(BOOL)isActivated {
  if (isEnabled) {
    if (isErrored) {
      return MDCContainedInputViewStateErrored;
    } else {
      if (isEditing) {
        return MDCContainedInputViewStateFocused;
      } else {
        if (isSelected || isActivated) {
          return MDCContainedInputViewStateActivated;
        } else {
          return MDCContainedInputViewStateNormal;
        }
      }
    }
  } else {
    return MDCContainedInputViewStateDisabled;
  }
}

#pragma mark Clear Button

- (UIImage *)untintedClearButtonImage {
  CGFloat sideLength = MDCInputTextAreaLayout.clearButtonImageViewSideLength;
  CGRect rect = CGRectMake(0, 0, sideLength, sideLength);
  UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
  [[UIColor blackColor] setFill];
  [[MDCContainerStylePathDrawingUtils pathForClearButtonImageWithFrame:rect] fill];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  return image;
}

#pragma mark Placeholder

- (BOOL)shouldPlaceholderBeVisible {
  return [self shouldPlaceholderBeVisibleWithPlaceholder:self.placeholder
                                      floatingLabelState:self.floatingLabelState
                                                    text:self.text
                                               isEditing:self.isEditing];
}


- (MDCContainedInputViewFloatingLabelState)determineCurrentFloatingLabelState {
  return [self floatingLabelStateWithFloatingLabel:self.floatingLabel
                                            text:self.text
                           canFloatingLabelFloat:self.canFloatingLabelFloat
                                       isEditing:self.isEditing];
}

- (BOOL)shouldPlaceholderBeVisibleWithPlaceholder:(NSString *)placeholder
                               floatingLabelState:(MDCContainedInputViewFloatingLabelState)floatingLabelState
                                             text:(NSString *)text
                                        isEditing:(BOOL)isEditing {
  BOOL hasPlaceholder = placeholder.length > 0;
  BOOL hasText = text.length > 0;
  
  if (hasPlaceholder) {
    if (hasText) {
      return NO;
    } else {
      if (floatingLabelState == MDCContainedInputViewFloatingLabelStateNormal) {
        return NO;
      } else {
        return YES;
      }
    }
  } else {
    return NO;
  }
}

- (MDCContainedInputViewFloatingLabelState)floatingLabelStateWithFloatingLabel:(UILabel *)floatingLabel
                                                                          text:(NSString *)text
                                                       canFloatingLabelFloat:
                                                           (BOOL)canFloatingLabelFloat
                                                                   isEditing:(BOOL)isEditing {
  BOOL hasFloatingLabelText = floatingLabel.text.length > 0;
  BOOL hasText = text.length > 0;
  if (hasFloatingLabelText) {
    if (canFloatingLabelFloat) {
      if (isEditing) {
        return MDCContainedInputViewFloatingLabelStateFloating;
      } else {
        if (hasText) {
          return MDCContainedInputViewFloatingLabelStateFloating;
        } else {
          return MDCContainedInputViewFloatingLabelStateNormal;
        }
      }
    } else {
      if (hasText) {
        return MDCContainedInputViewFloatingLabelStateNone;
      } else {
        return MDCContainedInputViewFloatingLabelStateNormal;
      }
    }
  } else {
    return MDCContainedInputViewFloatingLabelStateNone;
  }
}

#pragma mark User Actions

- (void)clearButtonPressed:(UIButton *)clearButton {
  self.text = nil;
}

#pragma mark Internationalization

- (BOOL)isRTL {
  return self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

#pragma mark Theming

- (void)applyMDCContainedInputViewColorScheming:
    (id<MDCContainedInputViewColorScheming>)colorScheming {
  self.textColor = colorScheming.textColor;
  self.leadingUnderlineLabel.textColor = colorScheming.underlineLabelColor;
  self.trailingUnderlineLabel.textColor = colorScheming.underlineLabelColor;
  self.floatingLabel.textColor = colorScheming.floatingLabelColor;
  self.placeholderLabel.textColor = colorScheming.placeholderColor;
  self.clearButtonImageView.tintColor = colorScheming.clearButtonTintColor;
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

@end
