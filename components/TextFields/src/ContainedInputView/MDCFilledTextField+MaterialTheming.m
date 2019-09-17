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

#import "MDCFilledTextField+MaterialTheming.h"

#import <Foundation/Foundation.h>

#import "private/MDCBaseTextField+ContainedInputView.h"
#import "private/MDCContainedInputView.h"
#import "private/MDCContainedInputViewStyleFilled.h"

@implementation MDCFilledTextField (MaterialTheming)

- (void)applyThemeWithScheme:(nonnull id<MDCContainerScheming>)containerScheme {
  [self applyTypographyScheme:[self typographySchemeWithContainerScheme:containerScheme]];
  [self applyDefaultColorScheme:[self colorSchemeWithContainerScheme:containerScheme]];
}

- (void)applyErrorThemeWithScheme:(nonnull id<MDCContainerScheming>)containerScheme {
  [self applyTypographyScheme:[self typographySchemeWithContainerScheme:containerScheme]];
  [self applyErrorColorScheme:[self colorSchemeWithContainerScheme:containerScheme]];
}

- (id<MDCColorScheming>)colorSchemeWithContainerScheme:
    (nonnull id<MDCContainerScheming>)containerScheme {
  id<MDCColorScheming> mdcColorScheme = containerScheme.colorScheme;
  if (!mdcColorScheme) {
    mdcColorScheme =
        [[MDCSemanticColorScheme alloc] initWithDefaults:MDCColorSchemeDefaultsMaterial201804];
  }
  return mdcColorScheme;
}

- (id<MDCTypographyScheming>)typographySchemeWithContainerScheme:
    (nonnull id<MDCContainerScheming>)containerScheme {
  id<MDCTypographyScheming> mdcTypographyScheme = containerScheme.typographyScheme;
  if (!mdcTypographyScheme) {
    mdcTypographyScheme =
        [[MDCTypographyScheme alloc] initWithDefaults:MDCTypographySchemeDefaultsMaterial201902];
  }
  return mdcTypographyScheme;
}

- (void)applyTypographyScheme:(id<MDCTypographyScheming>)mdcTypographyScheming {
  self.font = mdcTypographyScheming.subtitle1;
  self.leadingAssistiveLabel.font = mdcTypographyScheming.caption;
  self.trailingAssistiveLabel.font = mdcTypographyScheming.caption;
}

- (void)applyDefaultColorScheme:(id<MDCColorScheming>)colorScheme {
  CGFloat disabledOpacity = 0.60;

  UIColor *textColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.87];
  UIColor *textColorEditing = textColorNormal;
  UIColor *textColorDisabled = [textColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *assistiveLabelColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *assistiveLabelColorEditing = assistiveLabelColorNormal;
  UIColor *assistiveLabelColorDisabled = [assistiveLabelColorNormal colorWithAlphaComponent:(CGFloat)0.60];

  UIColor *floatingLabelColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *floatingLabelColorEditing = [colorScheme.primaryColor colorWithAlphaComponent:(CGFloat)0.87];
  UIColor *floatingLabelColorDisabled = [floatingLabelColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *normalLabelColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *normalLabelColorEditing = normalLabelColorNormal;
  UIColor *normalLabelColorDisabled = [normalLabelColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *underlineColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.42];
  UIColor *underlineColorEditing = colorScheme.primaryColor;
  UIColor *underlineColorDisabled = [underlineColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *filledSublayerFillColorNormal =
      [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.12];
  UIColor *filledSublayerFillColorEditing = filledSublayerFillColorNormal;
  UIColor *filledSublayerFillColorDisabled =
  [filledSublayerFillColorNormal colorWithAlphaComponent:disabledOpacity * (CGFloat)0.12];

  self.tintColor = colorScheme.primaryColor;
  self.placeholderColor = normalLabelColorNormal;

  [self setFloatingLabelColor:floatingLabelColorNormal forState:UIControlStateNormal];
  [self setFloatingLabelColor:floatingLabelColorEditing forState:MDCTextControlStateEditing];
  [self setFloatingLabelColor:floatingLabelColorDisabled forState:UIControlStateDisabled];
  [self setNormalLabelColor:normalLabelColorNormal forState:UIControlStateNormal];
  [self setNormalLabelColor:normalLabelColorEditing forState:MDCTextControlStateEditing];
  [self setNormalLabelColor:normalLabelColorDisabled forState:UIControlStateDisabled];
  [self setTextColor:textColorNormal forState:UIControlStateNormal];
  [self setTextColor:textColorEditing forState:MDCTextControlStateEditing];
  [self setTextColor:textColorDisabled forState:UIControlStateDisabled];
  [self setUnderlineColor:underlineColorNormal forState:UIControlStateNormal];
  [self setUnderlineColor:underlineColorEditing forState:MDCTextControlStateEditing];
  [self setUnderlineColor:underlineColorDisabled forState:UIControlStateDisabled];
  [self setFilledBackgroundColor:filledSublayerFillColorNormal forState:UIControlStateNormal];
  [self setFilledBackgroundColor:filledSublayerFillColorEditing forState:MDCTextControlStateEditing];
  [self setFilledBackgroundColor:filledSublayerFillColorDisabled forState:UIControlStateDisabled];
  [self setAssistiveLabelColor:assistiveLabelColorNormal forState:UIControlStateNormal];
  [self setAssistiveLabelColor:assistiveLabelColorEditing forState:MDCTextControlStateEditing];
  [self setAssistiveLabelColor:assistiveLabelColorDisabled forState:UIControlStateDisabled];
}

- (void)applyErrorColorScheme:(id<MDCColorScheming>)colorScheme {
  UIColor *textColor = colorScheme.errorColor;
  UIColor *assistiveLabelColor = [colorScheme.errorColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *labelColor = colorScheme.errorColor;
  UIColor *labelColorDisabled = [colorScheme.errorColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *labelColorFocused = colorScheme.errorColor;

  UIColor *thinUnderlineFillColor = colorScheme.errorColor;
  UIColor *thickUnderlineFillColor = colorScheme.errorColor;

  UIColor *filledSublayerFillColor =
      [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.15];

  [self setNormalLabelColor:labelColor forState:UIControlStateNormal];
  [self setNormalLabelColor:labelColorFocused forState:MDCTextControlStateEditing];
  [self setNormalLabelColor:labelColorDisabled forState:UIControlStateDisabled];
  [self setFloatingLabelColor:labelColor forState:UIControlStateNormal];
  [self setFloatingLabelColor:labelColorFocused forState:MDCTextControlStateEditing];
  [self setFloatingLabelColor:labelColorDisabled forState:UIControlStateDisabled];
  [self setTextColor:textColor forState:UIControlStateNormal];
  [self setTextColor:textColor forState:MDCTextControlStateEditing];
  [self setTextColor:textColor forState:UIControlStateDisabled];
  [self setUnderlineColor:thinUnderlineFillColor forState:UIControlStateNormal];
  [self setUnderlineColor:thickUnderlineFillColor forState:MDCTextControlStateEditing];
  [self setUnderlineColor:thinUnderlineFillColor forState:UIControlStateDisabled];
  [self setFilledBackgroundColor:filledSublayerFillColor forState:UIControlStateNormal];
  [self setFilledBackgroundColor:filledSublayerFillColor forState:MDCTextControlStateEditing];
  [self setFilledBackgroundColor:filledSublayerFillColor forState:UIControlStateDisabled];
  [self setAssistiveLabelColor:assistiveLabelColor forState:UIControlStateNormal];
  [self setAssistiveLabelColor:assistiveLabelColor forState:MDCTextControlStateEditing];
  [self setAssistiveLabelColor:assistiveLabelColor forState:UIControlStateDisabled];
  self.tintColor = colorScheme.errorColor;
}

@end
