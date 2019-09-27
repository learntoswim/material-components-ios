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

#import "MDCTextControlTextFieldPrototypes.h"

UIFont *MDCTextControlDefaultFont() {
  UIFont *font = MDCTextControlUITextFieldPrototype().font;
  if (!font) {
    static dispatch_once_t onceToken;
    static UIFont *backupSystemFont;
    dispatch_once(&onceToken, ^{
      backupSystemFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    });
    font = backupSystemFont;
  }
  return font;
}

UITextField *MDCTextControlUITextFieldPrototype() {
  static dispatch_once_t onceToken;
  static UITextField *textField;
  dispatch_once(&onceToken, ^{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    textField.text = @"text";
    textField.placeholder = @"placeholder";
  });
  return textField;
}

NSDictionary *MDCTextControlUITextFieldDefaultPlaceholderAttributes() {
  static dispatch_once_t onceToken;
  static NSDictionary *attributes;
  dispatch_once(&onceToken, ^{
    NSAttributedString *attributedPlaceholder =
        MDCTextControlUITextFieldPrototype().attributedPlaceholder;
    attributes =
        [attributedPlaceholder attributesAtIndex:0
                           longestEffectiveRange:nil
                                         inRange:NSMakeRange(0, attributedPlaceholder.length)];
  });
  return attributes ?: @{};
}
