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

#import "MDCTextControlInputChipViewContentViewController.h"

#import "MaterialButtons.h"
#import "MaterialChips.h"

#import "MDCBaseInputChipView.h"
#import "MaterialButtons+Theming.h"
#import "MaterialColorScheme.h"

#import "MDCFilledInputChipView+MaterialTheming.h"
#import "MDCFilledInputChipView.h"
#import "MDCOutlinedInputChipView+MaterialTheming.h"
#import "MDCOutlinedInputChipView.h"

@interface MDCTextControlInputChipViewContentViewController () <MDCInputChipViewDelegate,
                                                                UITextFieldDelegate>
@end

@implementation MDCTextControlInputChipViewContentViewController

#pragma mark Setup

- (MDCFilledInputChipView *)createMaterialFilledInputChipView {
  MDCFilledInputChipView *inputChipView = [[MDCFilledInputChipView alloc] init];
  inputChipView.labelBehavior = MDCTextControlLabelBehaviorFloats;
  inputChipView.label.text = @"Phone number";
  inputChipView.leadingAssistiveLabel.text = @"This is a string.";
  inputChipView.chipRowHeight = self.chipHeight;
  [inputChipView applyThemeWithScheme:self.containerScheme];
  return inputChipView;
}

- (MDCOutlinedInputChipView *)createMaterialOutlinedInputChipView {
  MDCOutlinedInputChipView *inputChipView = [[MDCOutlinedInputChipView alloc] init];
  inputChipView.label.text = @"Phone number";
  inputChipView.chipRowHeight = self.chipHeight;
  [inputChipView applyThemeWithScheme:self.containerScheme];
  return inputChipView;
}

- (MDCBaseInputChipView *)createDefaultBaseInputChipView {
  MDCBaseInputChipView *inputChipView = [[MDCBaseInputChipView alloc] init];
  inputChipView.label.text = @"This is a floating label";
  inputChipView.chipRowHeight = self.chipHeight;
  return inputChipView;
}

#pragma mark UIViewController Overrides

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self.allInputChipViews enumerateObjectsUsingBlock:^(MDCBaseInputChipView *inputChipView, NSUInteger idx, BOOL *stop) {
    for (UIView *chip in inputChipView.chips) {
      if ([chip isKindOfClass:[MDCChipView class]]) {
        MDCChipView *chipView = (MDCChipView *)chip;
        if (@available(iOS 10.0, *)) {
          chipView.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:self.traitCollection];
        }
      }
      [chip sizeToFit];
      NSLog(@"chip.height = %@",@(chip.frame.size.height));
    }
    inputChipView.chipRowHeight = self.chipHeight;
    NSLog(@"inputChipView.chipRowHeight = %@",@(inputChipView.chipRowHeight));
  }];
}

#pragma mark Overrides

- (void)initializeScrollViewSubviewsArray {
  [super initializeScrollViewSubviewsArray];

  MDCFilledInputChipView *wrappingFilledInputChipView = [self createMaterialFilledInputChipView];
  wrappingFilledInputChipView.chipsWrap = YES;
  wrappingFilledInputChipView.delegate = self;
  wrappingFilledInputChipView.textField.delegate = self;
  MDCFilledInputChipView *nonWrappingFilledInputChipView = [self createMaterialFilledInputChipView];
  nonWrappingFilledInputChipView.delegate = self;
  nonWrappingFilledInputChipView.textField.delegate = self;

  MDCFilledInputChipView *wrappingOutlinedInputChipView = [self createMaterialFilledInputChipView];
  wrappingOutlinedInputChipView.chipsWrap = YES;
  wrappingOutlinedInputChipView.delegate = self;
  wrappingOutlinedInputChipView.textField.delegate = self;

  MDCOutlinedInputChipView *nonWrappingOutlinedInputChipView =
      [self createMaterialOutlinedInputChipView];
  nonWrappingOutlinedInputChipView.delegate = self;
  nonWrappingOutlinedInputChipView.textField.delegate = self;

  NSArray *inputChipViewRelatedScrollViewSubviews = @[
    [self createLabelWithText:@"Wrapping MDCFilledInputChipView:"],
    wrappingFilledInputChipView,
    [self createLabelWithText:@"Non-Wrapping MDCFilledInputChipView:"],
    nonWrappingFilledInputChipView,
    [self createLabelWithText:@"Wrapping MDCOutlinedInputChipView:"],
    wrappingOutlinedInputChipView,
    [self createLabelWithText:@"Non-Wrapping MDCOutlinedInputChipView:"],
    nonWrappingOutlinedInputChipView,
    [self createLabelWithText:@"MDCBaseInputChipView:"],
    [self createDefaultBaseInputChipView],
  ];
  NSMutableArray *mutableScrollViewSubviews = [self.scrollViewSubviews mutableCopy];
  self.scrollViewSubviews =
      [mutableScrollViewSubviews arrayByAddingObjectsFromArray:inputChipViewRelatedScrollViewSubviews];
}

- (void)applyThemesToScrollViewSubviews {
  [super applyThemesToScrollViewSubviews];

  [self applyThemesToInputChipViews];
}

- (void)resizeScrollViewSubviews {
  [super resizeScrollViewSubviews];

  [self resizeInputChipViews];
}

- (void)enforcePreferredFonts {
  [super enforcePreferredFonts];

  if (@available(iOS 10.0, *)) {
    [self.allInputChipViews
        enumerateObjectsUsingBlock:^(MDCBaseInputChipView *inputChipView, NSUInteger idx, BOOL *stop) {
          inputChipView.textField.adjustsFontForContentSizeCategory = YES;
          inputChipView.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody
                                        compatibleWithTraitCollection:inputChipView.traitCollection];
          inputChipView.leadingAssistiveLabel.font =
              [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
                  compatibleWithTraitCollection:inputChipView.traitCollection];
          inputChipView.trailingAssistiveLabel.font =
              [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
                  compatibleWithTraitCollection:inputChipView.traitCollection];
        }];
  }
}

- (void)handleResignFirstResponderTapped {
  [super handleResignFirstResponderTapped];

  [self.allInputChipViews
      enumerateObjectsUsingBlock:^(MDCBaseInputChipView *inputChipView, NSUInteger idx, BOOL *stop) {
        [inputChipView resignFirstResponder];
      }];
}

- (void)handleDisableButtonTapped {
  [super handleDisableButtonTapped];

  [self.allInputChipViews enumerateObjectsUsingBlock:^(MDCBaseInputChipView *_Nonnull inputChipView,
                                                       NSUInteger idx, BOOL *_Nonnull stop) {
    inputChipView.enabled = !self.isDisabled;
  }];
}

#pragma mark Private helper methods

- (void)resizeInputChipViews {
  CGFloat inputChipViewWidth = CGRectGetWidth(self.view.frame) - (2 * self.defaultPadding);
  [self.allInputChipViews
      enumerateObjectsUsingBlock:^(MDCBaseInputChipView *inputChipView, NSUInteger idx, BOOL *stop) {
        CGFloat inputChipViewMinX = CGRectGetMinX(inputChipView.frame);
        CGFloat inputChipViewMinY = CGRectGetMinY(inputChipView.frame);
        CGFloat viewHeight = CGRectGetHeight(inputChipView.frame);
        CGRect viewFrame = CGRectMake(inputChipViewMinX, inputChipViewMinY, inputChipViewWidth, viewHeight);
        inputChipView.frame = viewFrame;
        [inputChipView sizeToFit];
      }];
}

- (void)applyThemesToInputChipViews {
  [self.allInputChipViews
      enumerateObjectsUsingBlock:^(MDCBaseInputChipView *inputChipView, NSUInteger idx, BOOL *stop) {
        BOOL isEven = idx % 2 == 0;
        if (self.isErrored) {
          if ([inputChipView isKindOfClass:[MDCFilledInputChipView class]]) {
            MDCFilledInputChipView *filledInputChipView = (MDCFilledInputChipView *)inputChipView;
            [filledInputChipView applyErrorThemeWithScheme:self.containerScheme];
          } else if ([inputChipView isKindOfClass:[MDCOutlinedInputChipView class]]) {
            MDCOutlinedInputChipView *outlinedInputChipView = (MDCOutlinedInputChipView *)inputChipView;
            [outlinedInputChipView applyErrorThemeWithScheme:self.containerScheme];
          }
          if (isEven) {
            inputChipView.leadingAssistiveLabel.text = @"Suspendisse quam elit, mattis sit amet justo "
                                                  @"vel, venenatis lobortis massa. Donec metus "
                                                  @"dolor.";
          } else {
            inputChipView.leadingAssistiveLabel.text = @"This is an error.";
          }
        } else {
          if ([inputChipView isKindOfClass:[MDCFilledInputChipView class]]) {
            MDCFilledInputChipView *filledInputChipView = (MDCFilledInputChipView *)inputChipView;
            [filledInputChipView applyThemeWithScheme:self.containerScheme];
          } else if ([inputChipView isKindOfClass:[MDCOutlinedInputChipView class]]) {
            MDCOutlinedInputChipView *outlinedInputChipView = (MDCOutlinedInputChipView *)inputChipView;
            [outlinedInputChipView applyThemeWithScheme:self.containerScheme];
          }
          if (isEven) {
            inputChipView.leadingAssistiveLabel.text = @"This is helper text.";
          } else {
            inputChipView.leadingAssistiveLabel.text = nil;
          }
        }
      }];
}

- (NSArray<MDCBaseInputChipView *> *)allInputChipViews {
  return [self allScrollViewSubviewsOfClass:[MDCBaseInputChipView class]];
}

#pragma mark Chip

- (CGFloat)chipHeight {
  UIFont *chipFont = self.allInputChipViews.firstObject.textField.font;
  if (@available(iOS 10.0, *)) {
    chipFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody compatibleWithTraitCollection:self.traitCollection];
  }
  MDCChipView *chip = [self createChipWithText:@"Test"
                                          font:chipFont];
  return CGRectGetHeight(chip.frame) + (CGFloat)0;
}

- (MDCChipView *)createChipWithText:(NSString *)text font:(UIFont *)font {
  MDCChipView *chipView = [[MDCChipView alloc] init];
  chipView.titleLabel.text = text;
  chipView.titleFont = font;
  [chipView sizeToFit];
  [chipView addTarget:self
                action:@selector(selectedChip:)
      forControlEvents:UIControlEventTouchUpInside];
  return chipView;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField.text.length <= 0) {
    return NO;
  }
  MDCChipView *chipView = [self createChipWithText:textField.text font:textField.font];
  MDCBaseInputChipView *inputChipView = [self inputChipViewWithTextField:textField];
  [inputChipView addChip:chipView];
  return NO;
}

- (MDCBaseInputChipView *)inputChipViewWithTextField:(UITextField *)textField {
  for (MDCBaseInputChipView *inputChipView in self.allInputChipViews) {
    if (inputChipView.textField == textField) {
      return inputChipView;
    }
  }
  return nil;
}

#pragma mark User Interaction

- (void)selectedChip:(MDCChipView *)chip {
  chip.selected = !chip.selected;
  NSLog(@"%@", @(chip.isHighlighted));
}

#pragma mark MDCInputChipViewDelegate

- (void)inputChipViewDidDeleteBackwards:(nonnull MDCBaseInputChipView *)inputChipView
                                oldText:(nullable NSString *)oldText
                                newText:(nullable NSString *)newText {
  BOOL isEmpty = newText.length == 0;
  BOOL isNewlyEmpty = oldText.length > 0 && newText.length == 0;
  if (isEmpty) {
    if (!isNewlyEmpty) {
      NSArray<MDCChipView *> *selectedChips = [self selectedChipsWithChips:inputChipView.chips];
      if (selectedChips.count > 0) {
        [inputChipView removeChips:selectedChips];
      } else if (inputChipView.chips.count > 0) {
        [self selectChip:inputChipView.chips.lastObject];
      }
    }
  }
}

- (NSArray<MDCChipView *> *)selectedChipsWithChips:(NSArray<UIView *> *)chips {
  NSMutableArray *selectedChips = [NSMutableArray new];
  for (UIView *view in chips) {
    if ([view isKindOfClass:[MDCChipView class]]) {
      MDCChipView *chipView = (MDCChipView *)view;
      if (chipView.isSelected) {
        [selectedChips addObject:chipView];
      }
    }
  }
  return [selectedChips copy];
}

- (void)selectChip:(UIView *)chip {
  if ([chip isKindOfClass:[MDCChipView class]]) {
    MDCChipView *chipView = (MDCChipView *)chip;
    chipView.selected = YES;
  }
  UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                  [chip accessibilityLabel]);
}

@end
