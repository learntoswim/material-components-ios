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

static const CGFloat kEstimatedUiTextFieldClearButtonSideLength = 19.0;

#import "UITextField+MDCTextControlDefaults.h"

UITextField *MDCTextControlUITextFieldPrototype(void);
UITextField *MDCTextControlUITextFieldPrototype(void) {
  static dispatch_once_t onceToken;
  static UITextField *textField;
  dispatch_once(&onceToken, ^{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    textField.text = @"text";
    textField.placeholder = @"placeholder";
  });
  return textField;
}

@implementation UITextField (MDCTextControlDefaults)

- (UIColor *)mdc_defaultPlaceholderColor {
  UIColor *defaultPlaceholderColor = nil;
#if defined(__IPHONE_12_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0)
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      static dispatch_once_t darkOnceToken;
      static UIColor *darkColor;
      static NSDictionary *attributes;
      dispatch_once(&darkOnceToken, ^{
        NSAttributedString *attributedPlaceholder =
            MDCTextControlUITextFieldPrototype().attributedPlaceholder;
        attributes =
            [attributedPlaceholder attributesAtIndex:0
                               longestEffectiveRange:nil
                                             inRange:NSMakeRange(0, attributedPlaceholder.length)];

        darkColor = attributes[NSForegroundColorAttributeName];
      });
      defaultPlaceholderColor = darkColor;
    }
  }
#endif

  if (!defaultPlaceholderColor) {
    static dispatch_once_t lightOnceToken;
    static UIColor *lightColor;
    static NSDictionary *attributes;
    dispatch_once(&lightOnceToken, ^{
      NSAttributedString *attributedPlaceholder =
          MDCTextControlUITextFieldPrototype().attributedPlaceholder;
      attributes =
          [attributedPlaceholder attributesAtIndex:0
                             longestEffectiveRange:nil
                                           inRange:NSMakeRange(0, attributedPlaceholder.length)];

      lightColor = attributes[NSForegroundColorAttributeName];
    });
    defaultPlaceholderColor = lightColor;
  }

  return defaultPlaceholderColor;
}

+ (CGFloat)mdc_clearButtonSideLength {
  static dispatch_once_t onceToken;
  static CGRect systemClearButtonRect;
  UITextField *textField = MDCTextControlUITextFieldPrototype();
  dispatch_once(&onceToken, ^{
    systemClearButtonRect = [textField clearButtonRectForBounds:textField.bounds];
  });
  CGFloat sideLength = CGRectGetHeight(systemClearButtonRect);
  return sideLength > 0 ? sideLength : kEstimatedUiTextFieldClearButtonSideLength;
}

+ (UIFont *)mdc_defaultFont {
  return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
