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

#import "MDCOutlinedTextArea+MaterialTheming.h"

#import <Foundation/Foundation.h>

#import "private/MDCBaseTextField+MDCTextControl.h"
#import "private/MDCTextControl.h"
#import "private/MDCTextControlStyleOutlined.h"

@implementation MDCOutlinedTextArea (MaterialTheming)

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
  self.textView.font = mdcTypographyScheming.subtitle1;
  self.leadingAssistiveLabel.font = mdcTypographyScheming.caption;
  self.trailingAssistiveLabel.font = mdcTypographyScheming.caption;
}

- (void)applyDefaultColorScheme:(id<MDCColorScheming>)colorScheme {
  CGFloat disabledOpacity = (CGFloat)0.60;

  UIColor *textColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.87];
  UIColor *textColorEditing = textColorNormal;
  UIColor *textColorDisabled = [textColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *assistiveLabelColorNormal =
      [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *assistiveLabelColorEditing = assistiveLabelColorNormal;
  UIColor *assistiveLabelColorDisabled =
      [assistiveLabelColorNormal colorWithAlphaComponent:(CGFloat)0.60];

  UIColor *floatingLabelColorNormal =
      [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *floatingLabelColorEditing =
      [colorScheme.primaryColor colorWithAlphaComponent:(CGFloat)0.87];
  UIColor *floatingLabelColorDisabled =
      [floatingLabelColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *normalLabelColorNormal =
      [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *normalLabelColorEditing = normalLabelColorNormal;
  UIColor *normalLabelColorDisabled =
      [normalLabelColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *outlineColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.42];
  UIColor *outlineColorEditing = colorScheme.primaryColor;
  UIColor *outlineColorDisabled = [outlineColorNormal colorWithAlphaComponent:disabledOpacity];

  self.textView.tintColor = colorScheme.primaryColor;

  [self setFloatingLabelColor:floatingLabelColorNormal forState:MDCTextControlStateNormal];
  [self setFloatingLabelColor:floatingLabelColorEditing forState:MDCTextControlStateEditing];
  [self setFloatingLabelColor:floatingLabelColorDisabled forState:MDCTextControlStateDisabled];
  [self setNormalLabelColor:normalLabelColorNormal forState:MDCTextControlStateNormal];
  [self setNormalLabelColor:normalLabelColorEditing forState:MDCTextControlStateEditing];
  [self setNormalLabelColor:normalLabelColorDisabled forState:MDCTextControlStateDisabled];
  [self setTextColor:textColorNormal forState:MDCTextControlStateNormal];
  [self setTextColor:textColorEditing forState:MDCTextControlStateEditing];
  [self setTextColor:textColorDisabled forState:MDCTextControlStateDisabled];
  [self setOutlineColor:outlineColorNormal forState:MDCTextControlStateNormal];
  [self setOutlineColor:outlineColorEditing forState:MDCTextControlStateEditing];
  [self setOutlineColor:outlineColorDisabled forState:MDCTextControlStateDisabled];
  [self setLeadingAssistiveLabelColor:assistiveLabelColorNormal forState:MDCTextControlStateNormal];
  [self setLeadingAssistiveLabelColor:assistiveLabelColorEditing
                             forState:MDCTextControlStateEditing];
  [self setLeadingAssistiveLabelColor:assistiveLabelColorDisabled
                             forState:MDCTextControlStateDisabled];
  [self setTrailingAssistiveLabelColor:assistiveLabelColorNormal
                              forState:MDCTextControlStateNormal];
  [self setTrailingAssistiveLabelColor:assistiveLabelColorEditing
                              forState:MDCTextControlStateEditing];
  [self setTrailingAssistiveLabelColor:assistiveLabelColorDisabled
                              forState:MDCTextControlStateDisabled];
}

- (void)applyErrorColorScheme:(id<MDCColorScheming>)colorScheme {
  CGFloat disabledOpacity = (CGFloat)0.60;

  UIColor *textColorNormal = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.87];
  UIColor *textColorEditing = textColorNormal;
  UIColor *textColorDisabled = [textColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *assistiveLabelColorNormal = colorScheme.errorColor;
  UIColor *assistiveLabelColorEditing = assistiveLabelColorNormal;
  UIColor *assistiveLabelColorDisabled =
      [assistiveLabelColorNormal colorWithAlphaComponent:(CGFloat)0.60];

  UIColor *floatingLabelColorNormal = colorScheme.errorColor;
  UIColor *floatingLabelColorEditing = floatingLabelColorNormal;
  UIColor *floatingLabelColorDisabled =
      [floatingLabelColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *normalLabelColorNormal =
      [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.60];
  UIColor *normalLabelColorEditing = normalLabelColorNormal;
  UIColor *normalLabelColorDisabled =
      [normalLabelColorNormal colorWithAlphaComponent:disabledOpacity];

  UIColor *outlineColorNormal = colorScheme.errorColor;
  UIColor *outlineColorEditing = outlineColorNormal;
  UIColor *outlineColorDisabled = [outlineColorNormal colorWithAlphaComponent:disabledOpacity];

  self.textView.tintColor = colorScheme.primaryColor;

  [self setFloatingLabelColor:floatingLabelColorNormal forState:MDCTextControlStateNormal];
  [self setFloatingLabelColor:floatingLabelColorEditing forState:MDCTextControlStateEditing];
  [self setFloatingLabelColor:floatingLabelColorDisabled forState:MDCTextControlStateDisabled];
  [self setNormalLabelColor:normalLabelColorNormal forState:MDCTextControlStateNormal];
  [self setNormalLabelColor:normalLabelColorEditing forState:MDCTextControlStateEditing];
  [self setNormalLabelColor:normalLabelColorDisabled forState:MDCTextControlStateDisabled];
  [self setTextColor:textColorNormal forState:MDCTextControlStateNormal];
  [self setTextColor:textColorEditing forState:MDCTextControlStateEditing];
  [self setTextColor:textColorDisabled forState:MDCTextControlStateDisabled];
  [self setOutlineColor:outlineColorNormal forState:MDCTextControlStateNormal];
  [self setOutlineColor:outlineColorEditing forState:MDCTextControlStateEditing];
  [self setOutlineColor:outlineColorDisabled forState:MDCTextControlStateDisabled];
  [self setLeadingAssistiveLabelColor:assistiveLabelColorNormal forState:MDCTextControlStateNormal];
  [self setLeadingAssistiveLabelColor:assistiveLabelColorEditing
                             forState:MDCTextControlStateEditing];
  [self setLeadingAssistiveLabelColor:assistiveLabelColorDisabled
                             forState:MDCTextControlStateDisabled];
  [self setTrailingAssistiveLabelColor:assistiveLabelColorNormal
                              forState:MDCTextControlStateNormal];
  [self setTrailingAssistiveLabelColor:assistiveLabelColorEditing
                              forState:MDCTextControlStateEditing];
  [self setTrailingAssistiveLabelColor:assistiveLabelColorDisabled
                              forState:MDCTextControlStateDisabled];
}

@end
