// Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
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

#import "MDCChipViewTypographyThemer.h"

#import "MaterialApplication.h"
#import "MaterialTypography.h"

@implementation MDCChipViewTypographyThemer

+ (void)applyTypographyScheme:(nonnull id<MDCTypographyScheming>)typographyScheme
                   toChipView:(nonnull MDCChipView *)chipView {
  UIFont *titleFont = typographyScheme.body2;
  if (typographyScheme.mdc_adjustsFontForContentSizeCategory) {
    UIContentSizeCategory sizeCategory = UIContentSizeCategoryLarge;
    if (@available(iOS 10.0, *)) {
      sizeCategory = chipView.traitCollection.preferredContentSizeCategory;
    } else if ([UIApplication mdc_safeSharedApplication]) {
      sizeCategory = [UIApplication mdc_safeSharedApplication].preferredContentSizeCategory;
    }
    titleFont = [titleFont mdc_scaledFontForSizeCategory:sizeCategory];
  }
  chipView.titleFont = titleFont;
}

@end
