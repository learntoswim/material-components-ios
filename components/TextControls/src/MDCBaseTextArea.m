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

#import "MDCBaseTextArea.h"

#import <CoreGraphics/CoreGraphics.h>
#import <MDFInternationalization/MDFInternationalization.h>
#import <QuartzCore/QuartzCore.h>

#import "MaterialMath.h"
#import "MaterialTypography.h"
#import "private/MDCBaseTextArea+MDCTextControl.h"
#import "private/MDCBaseTextAreaLayout.h"
#import "private/MDCTextControl.h"
#import "private/MDCTextControlAssistiveLabelView.h"
#import "private/MDCTextControlGradientManager.h"
#import "private/MDCTextControlLabelAnimation.h"
#import "private/MDCTextControlStyleBase.h"
//#import "private/UITextField+MDCTextControlDefaults.h"

static const CGFloat kDefaultPreferredNumberOfVisibleRows = (CGFloat)2.0;

@class MDCBaseTextAreaTextView;
@protocol MDCBaseTextAreaTextViewDelegate <NSObject>
- (void)inputChipViewTextViewDidBecomeFirstResponder:(BOOL)didBecome;
- (void)inputChipViewTextViewDidResignFirstResponder:(BOOL)didResign;
@end

@interface MDCBaseTextAreaTextView : UITextView
@property(nonatomic, weak) id<MDCBaseTextAreaTextViewDelegate> inputChipViewTextViewDelegate;
@end

@implementation MDCBaseTextAreaTextView

- (instancetype)init {
  self = [super init];
  if (self) {
    [self commonMDCBaseTextAreaTextViewInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBaseTextAreaTextViewInit];
  }
  return self;
}

- (void)commonMDCBaseTextAreaTextViewInit {
  self.backgroundColor = [UIColor clearColor];
  self.textContainerInset = UIEdgeInsetsZero;
  self.layoutMargins = UIEdgeInsetsZero;
  self.textContainer.lineFragmentPadding = 0;
  self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

  //  self.layer.borderColor = [UIColor redColor].CGColor;
  //  self.layer.borderWidth = 1;
}

- (void)setFont:(UIFont *)font {
  [super setFont:font];
}

- (UIFont *)font {
  return [super font] ?: [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (BOOL)resignFirstResponder {
  BOOL didResignFirstResponder = [super resignFirstResponder];
  [self.inputChipViewTextViewDelegate
      inputChipViewTextViewDidResignFirstResponder:didResignFirstResponder];
  return didResignFirstResponder;
}

- (BOOL)becomeFirstResponder {
  BOOL didBecomeFirstResponder = [super becomeFirstResponder];
  [self.inputChipViewTextViewDelegate
      inputChipViewTextViewDidBecomeFirstResponder:didBecomeFirstResponder];
  return didBecomeFirstResponder;
}

@end

@interface MDCBaseTextArea () <MDCTextControl,
                               MDCBaseTextAreaTextViewDelegate,
                               UIGestureRecognizerDelegate>

#pragma mark MDCTextControl properties
@property(strong, nonatomic) UILabel *label;
@property(nonatomic, strong) MDCTextControlAssistiveLabelView *assistiveLabelView;
@property(strong, nonatomic) MDCBaseTextAreaLayout *layout;
@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;
@property(nonatomic, assign) MDCTextControlState textControlState;
@property(nonatomic, assign) MDCTextControlLabelState labelState;
@property(nonatomic, assign) NSTimeInterval animationDuration;

@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, MDCTextControlColorViewModel *> *colorViewModels;

@property(strong, nonatomic) UIView *maskedScrollViewContainerView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIView *scrollViewContentViewTouchForwardingView;
@property(strong, nonatomic) MDCBaseTextAreaTextView *inputChipViewTextView;
@property(strong, nonatomic) UITouch *lastTouch;
@property(nonatomic, assign) CGPoint lastTouchInitialContentOffset;
@property(nonatomic, assign) CGPoint lastTouchInitialLocation;

@property(nonatomic, strong) MDCTextControlGradientManager *gradientManager;

@end

@implementation MDCBaseTextArea
@synthesize containerStyle = _containerStyle;
@synthesize assistiveLabelDrawPriority = _assistiveLabelDrawPriority;
@synthesize customAssistiveLabelDrawPriority = _customAssistiveLabelDrawPriority;
@synthesize preferredContainerHeight = _preferredContainerHeight;

@synthesize adjustsFontForContentSizeCategory = _adjustsFontForContentSizeCategory;

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBaseTextAreaInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCBaseTextAreaInit];
  }
  return self;
}

- (void)commonMDCBaseTextAreaInit {
  [self initializeProperties];
  [self setUpColorViewModels];
  [self setUpLabel];
  [self setUpAssistiveLabels];
  [self setUpTextAreaSpecificSubviews];
  [self observeUITextViewNotifications];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Setup

- (void)initializeProperties {
  self.animationDuration = kMDCTextControlDefaultAnimationDuration;
  self.labelBehavior = MDCTextControlLabelBehaviorFloats;
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
  self.labelState = [self determineCurrentLabelState];
  self.textControlState = [self determineCurrentTextControlState];
  self.containerStyle = [[MDCTextControlStyleBase alloc] init];
  self.colorViewModels = [[NSMutableDictionary alloc] init];

  self.preferredNumberOfVisibleRows = kDefaultPreferredNumberOfVisibleRows;
  self.gradientManager = [[MDCTextControlGradientManager alloc] init];
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

- (void)setUpTextAreaSpecificSubviews {
  self.maskedScrollViewContainerView = [[UIView alloc] init];
  [self addSubview:self.maskedScrollViewContainerView];

  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.bounces = NO;
  [self.maskedScrollViewContainerView addSubview:self.scrollView];

  self.scrollViewContentViewTouchForwardingView = [[UIView alloc] init];
  [self.scrollView addSubview:self.scrollViewContentViewTouchForwardingView];

  self.inputChipViewTextView = [[MDCBaseTextAreaTextView alloc] init];
  self.inputChipViewTextView.inputChipViewTextViewDelegate = self;
  self.inputChipViewTextView.showsVerticalScrollIndicator = NO;
  self.inputChipViewTextView.showsHorizontalScrollIndicator = NO;
  [self.scrollView addSubview:self.inputChipViewTextView];
}

- (void)observeUITextViewNotifications {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(textViewDidEndEditingWithNotification:)
             name:UITextViewTextDidEndEditingNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(textFieldDidBeginEditingWithNotification:)
             name:UITextViewTextDidBeginEditingNotification
           object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(textViewDidChangeWithNotification:)
                                               name:UITextViewTextDidChangeNotification
                                             object:nil];
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
  CGFloat height = CGRectGetHeight(self.frame);
  offset.y -= offsetFromStart.y;
  if (offset.y < 0) {
    offset.y = 0;
  }
  if (offset.y + height > self.scrollView.contentSize.height) {
    offset.y = self.scrollView.contentSize.height - height;
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

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  self.textView.editable = enabled;
}

#pragma mark UIResponder Overrides

- (BOOL)resignFirstResponder {
  BOOL textFieldDidResign = [self.textView resignFirstResponder];
  return textFieldDidResign;
}

- (BOOL)becomeFirstResponder {
  BOOL textFieldDidBecome = [self.textView becomeFirstResponder];
  return textFieldDidBecome;
}

- (void)handleResponderChange {
  [self setNeedsLayout];
}

- (BOOL)isFirstResponder {
  return self.textView.isFirstResponder;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
}

#pragma mark Layout

- (void)preLayoutSubviews {
  self.textControlState = [self determineCurrentTextControlState];
  self.labelState = [self determineCurrentLabelState];
  MDCTextControlColorViewModel *colorViewModel =
      [self textControlColorViewModelForState:self.textControlState];
  [self applyColorViewModel:colorViewModel withLabelState:self.labelState];
  CGSize fittingSize = CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX);
  self.layout = [self calculateLayoutWithSize:fittingSize];
}

- (void)postLayoutSubviews {
  self.maskedScrollViewContainerView.frame = self.layout.maskedScrollViewContainerViewFrame;
  self.scrollView.frame = self.layout.scrollViewFrame;
  self.scrollViewContentViewTouchForwardingView.frame =
      self.layout.scrollViewContentViewTouchForwardingViewFrame;
  self.textView.frame = self.layout.textViewFrame;
  //  CGRect frame = self.layout.textViewFrame;
  //  CGSize size = [self.textView sizeThatFits:frame.size];
  //  frame.size = size;
  //  self.textView.frame = frame;
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
  self.scrollView.contentSize = self.layout.scrollViewContentSize;
  [self.scrollView setNeedsLayout];
  self.assistiveLabelView.frame = self.layout.assistiveLabelViewFrame;
  self.assistiveLabelView.layout = self.layout.assistiveLabelViewLayout;
  [self.assistiveLabelView setNeedsLayout];
  //  NSLog(@"inset: %@",NSStringFromUIEdgeInsets(self.scrollView.contentInset));
  //  NSLog(@"offset: %@",NSStringFromCGPoint(self.scrollView.contentOffset));
  //  NSLog(@"size: %@\n\n",NSStringFromCGSize(self.scrollView.contentSize));

  [self animateLabel];
  [self.containerStyle applyStyleToTextControl:self animationDuration:self.animationDuration];

  [self layOutGradientLayers];
}

- (MDCBaseTextAreaLayout *)calculateLayoutWithSize:(CGSize)size {
  CGFloat clampedCustomAssistiveLabelDrawPriority =
      [self clampedCustomAssistiveLabelDrawPriority:self.customAssistiveLabelDrawPriority];
  id<MDCTextControlVerticalPositioningReference> positioningReference =
      [self createPositioningReference];
  return [[MDCBaseTextAreaLayout alloc] initWithSize:size
                                positioningReference:positioningReference
                                                text:self.inputChipViewTextView.text
                                                font:self.normalFont
                                        floatingFont:self.floatingFont
                                               label:self.label
                                          labelState:self.labelState
                                       labelBehavior:self.labelBehavior
                                  leftAssistiveLabel:self.assistiveLabelView.leftAssistiveLabel
                                 rightAssistiveLabel:self.assistiveLabelView.rightAssistiveLabel
                          assistiveLabelDrawPriority:self.assistiveLabelDrawPriority
                    customAssistiveLabelDrawPriority:clampedCustomAssistiveLabelDrawPriority
                        preferredNumberOfVisibleRows:self.preferredNumberOfVisibleRows
                                               isRTL:self.isRTL
                                           isEditing:self.isFirstResponder];
}

- (id<MDCTextControlVerticalPositioningReference>)createPositioningReference {
  return [self.containerStyle
      positioningReferenceWithFloatingFontLineHeight:self.floatingFont.lineHeight
                                normalFontLineHeight:self.normalFont.lineHeight
                                       textRowHeight:(self.normalFont.lineHeight +
                                                      self.normalFont.leading)
                                    numberOfTextRows:self.numberOfVisibleTextRows
                                             density:0
                            preferredContainerHeight:self.preferredContainerHeight];
}

- (CGFloat)clampedCustomAssistiveLabelDrawPriority:(CGFloat)customPriority {
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
  MDCBaseTextAreaLayout *layout = [self calculateLayoutWithSize:fittingSize];
  return CGSizeMake(width, layout.calculatedHeight);
}

- (void)layOutGradientLayers {
  CGRect gradientLayerFrame = self.layout.maskedScrollViewContainerViewFrame;
  self.gradientManager.horizontalGradient.frame = gradientLayerFrame;
  self.gradientManager.verticalGradient.frame = gradientLayerFrame;
  self.gradientManager.horizontalGradient.locations = self.layout.horizontalGradientLocations;
  self.gradientManager.verticalGradient.locations = self.layout.verticalGradientLocations;
  self.maskedScrollViewContainerView.layer.mask = [self.gradientManager combinedGradientMaskLayer];
}

#pragma mark Dynamic Type

- (void)setAdjustsFontForContentSizeCategory:(BOOL)adjustsFontForContentSizeCategory {
  if (@available(iOS 10.0, *)) {
    _adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
    self.textView.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
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

#pragma mark MDCTextControlState

- (MDCTextControlState)determineCurrentTextControlState {
  return [self textControlStateWithIsEnabled:(self.enabled && self.inputChipViewTextView.isEditable)
                                   isEditing:self.isFirstResponder];
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

#pragma mark MDCTextControl accessors

- (CGRect)containerFrame {
  return CGRectMake(0, 0, CGRectGetWidth(self.frame), self.layout.containerHeight);
}

#pragma mark Label

- (void)animateLabel {
  __weak MDCBaseTextArea *weakSelf = self;
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
                                  text:self.textView.text
                         canLabelFloat:self.canLabelFloat
                             isEditing:self.isFirstResponder];
}

- (MDCTextControlLabelState)labelStateWithLabelText:(NSString *)labelText
                                               text:(NSString *)text
                                      canLabelFloat:(BOOL)canLabelFloat
                                          isEditing:(BOOL)isEditing {
  BOOL hasLabelText = labelText.length > 0;
  BOOL hasText = text.length > 0;
  if (hasLabelText) {
    if (canLabelFloat) {
      if (isEditing) {
        return MDCTextControlLabelStateFloating;
      } else {
        if (hasText) {
          return MDCTextControlLabelStateFloating;
        } else {
          return MDCTextControlLabelStateNormal;
        }
      }
    } else {
      if (hasText) {
        return MDCTextControlLabelStateNone;
      } else {
        return MDCTextControlLabelStateNormal;
      }
    }
  } else {
    return MDCTextControlLabelStateNone;
  }
}

#pragma mark Custom Accessors

- (UITextView *)textView {
  return self.inputChipViewTextView;
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

- (CGFloat)numberOfVisibleTextRows {
  return self.preferredNumberOfVisibleRows;
}

#pragma mark Notification Listener Methods

- (void)textViewDidEndEditingWithNotification:(NSNotification *)notification {
  if (notification.object != self) {
    return;
  }
}

- (void)textViewDidChangeWithNotification:(NSNotification *)notification {
  if (notification.object != self.textView) {
    return;
  }
  //  NSLog(@"text did change");
  //  [self setNeedsLayout];
}

- (void)textFieldDidBeginEditingWithNotification:(NSNotification *)notification {
  if (notification.object != self) {
    return;
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

#pragma mark User Interaction

- (void)enforceCalculatedScrollViewContentOffset {
  self.scrollView.contentOffset = self.layout.scrollViewContentOffset;
}

#pragma mark Fonts

- (UIFont *)normalFont {
  return self.inputChipViewTextView.font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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
    self.textView.font = textFont;
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

#pragma mark InputChipViewTextViewDelegate

- (void)inputChipViewTextViewDidResignFirstResponder:(BOOL)didBecome {
  [self handleResponderChange];
}

- (void)inputChipViewTextViewDidBecomeFirstResponder:(BOOL)didBecome {
  [self handleResponderChange];
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
  self.textView.textColor = colorViewModel.textColor;
  self.leadingAssistiveLabel.textColor = colorViewModel.leadingAssistiveLabelColor;
  self.trailingAssistiveLabel.textColor = colorViewModel.trailingAssistiveLabelColor;
  self.label.textColor = labelColor;
}

- (void)setTextControlColorViewModel:(MDCTextControlColorViewModel *)TextControlColorViewModel
                            forState:(MDCTextControlState)textControlState {
  self.colorViewModels[@(textControlState)] = TextControlColorViewModel;
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

@end
