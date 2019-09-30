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

#import "MDCTextControlVerticalPositioningReferenceOutlined.h"

static const CGFloat kMinPaddingBetweenFloatingLabelAndEditingText = (CGFloat)8.0;
static const CGFloat kMaxPaddingBetweenFloatingLabelAndEditingText = (CGFloat)12.0;
static const CGFloat kMinPaddingAroundAssistiveLabels = (CGFloat)3.0;
static const CGFloat kMaxPaddingAroundAssistiveLabels = (CGFloat)6.0;

@interface MDCTextControlVerticalPositioningReferenceOutlined ()
@property(nonatomic, assign) CGFloat paddingAroundAssistiveLabels;
@end

@implementation MDCTextControlVerticalPositioningReferenceOutlined
@synthesize paddingBetweenContainerTopAndFloatingLabel = _paddingBetweenContainerTopAndFloatingLabel;
@synthesize paddingBetweenContainerTopAndNormalLabel = _paddingBetweenContainerTopAndNormalLabel;
@synthesize paddingBetweenFloatingLabelAndEditingText = _paddingBetweenFloatingLabelAndEditingText;
@synthesize paddingBetweenEditingTextAndContainerBottom = _paddingBetweenEditingTextAndContainerBottom;
@synthesize containerHeight = _containerHeight;

- (instancetype)initWithFloatingFontLineHeight:(CGFloat)floatingLabelHeight
                          normalFontLineHeight:(CGFloat)normalFontLineHeight
                                 textRowHeight:(CGFloat)textRowHeight
                              numberOfTextRows:(CGFloat)numberOfTextRows
                                       density:(CGFloat)density
                      preferredContainerHeight:(CGFloat)preferredContainerHeight {
  self = [super init];
  if (self) {
    [self calculatePaddingValuesWithFoatingFontLineHeight:floatingLabelHeight
                                  normalFontLineHeight:normalFontLineHeight
                                         textRowHeight:textRowHeight
                                      numberOfTextRows:numberOfTextRows
                                               density:density
                              preferredContainerHeight:preferredContainerHeight];
  }
  return self;
}

- (void)calculatePaddingValuesWithFoatingFontLineHeight:(CGFloat)floatingLabelHeight
                                normalFontLineHeight:(CGFloat)normalFontLineHeight
                                       textRowHeight:(CGFloat)textRowHeight
                                    numberOfTextRows:(CGFloat)numberOfTextRows
                                             density:(CGFloat)density
                            preferredContainerHeight:(CGFloat)preferredContainerHeight {
  BOOL isMultiline = numberOfTextRows > 1 || numberOfTextRows == 0;
  CGFloat standardizedDensity = [self standardizeDensity:density];

  _paddingBetweenContainerTopAndFloatingLabel = (CGFloat)0 - ((CGFloat)0.5 * floatingLabelHeight);

  CGFloat paddingBetweenFloatingLabelAndEditingTextRange =
      kMaxPaddingBetweenFloatingLabelAndEditingText - kMinPaddingBetweenFloatingLabelAndEditingText;
  CGFloat paddingBetweenFloatingLabelAndEditingTextAddition =
      paddingBetweenFloatingLabelAndEditingTextRange * (1 - standardizedDensity);
  _paddingBetweenFloatingLabelAndEditingText =
      kMinPaddingBetweenFloatingLabelAndEditingText + paddingBetweenFloatingLabelAndEditingTextAddition;

  _paddingBetweenContainerTopAndNormalLabel =
      _paddingBetweenFloatingLabelAndEditingText + ((CGFloat)0.5 * floatingLabelHeight);
  _paddingBetweenEditingTextAndContainerBottom = _paddingBetweenContainerTopAndNormalLabel;

  CGFloat paddingAroundAssistiveLabelsRange =
      kMaxPaddingAroundAssistiveLabels - kMinPaddingAroundAssistiveLabels;
  CGFloat paddingAroundAssistiveLabelsAddition =
      paddingAroundAssistiveLabelsRange * (1 - standardizedDensity);
  _paddingAroundAssistiveLabels =
      kMinPaddingAroundAssistiveLabels + paddingAroundAssistiveLabelsAddition;

  CGFloat containerHeightWithPaddingsDeterminedByDensity =
      [self calculateContainerHeightWithFoatingLabelHeight:floatingLabelHeight
                                             textRowHeight:textRowHeight
                                          numberOfTextRows:numberOfTextRows
                         paddingBetweenContainerTopAndFloatingLabel:_paddingBetweenContainerTopAndFloatingLabel
                        paddingBetweenFloatingLabelAndEditingText:_paddingBetweenFloatingLabelAndEditingText
                               paddingBetweenEditingTextAndContainerBottom:_paddingBetweenEditingTextAndContainerBottom];
  if (preferredContainerHeight > 0) {
    if (preferredContainerHeight > containerHeightWithPaddingsDeterminedByDensity) {
      if (!isMultiline) {
        CGFloat difference =
            preferredContainerHeight - containerHeightWithPaddingsDeterminedByDensity;
        CGFloat sumOfPaddingValues = _paddingBetweenContainerTopAndFloatingLabel +
                                     _paddingBetweenFloatingLabelAndEditingText +
                                     _paddingBetweenEditingTextAndContainerBottom;
        _paddingBetweenContainerTopAndFloatingLabel =
            _paddingBetweenContainerTopAndFloatingLabel +
            ((_paddingBetweenContainerTopAndFloatingLabel / sumOfPaddingValues) * difference);
        _paddingBetweenFloatingLabelAndEditingText =
            _paddingBetweenFloatingLabelAndEditingText +
            ((_paddingBetweenFloatingLabelAndEditingText / sumOfPaddingValues) * difference);
        _paddingBetweenEditingTextAndContainerBottom =
            _paddingBetweenEditingTextAndContainerBottom +
            ((_paddingBetweenEditingTextAndContainerBottom / sumOfPaddingValues) * difference);
      }
    }
  }

  _containerHeight = containerHeightWithPaddingsDeterminedByDensity;
  if (preferredContainerHeight > containerHeightWithPaddingsDeterminedByDensity) {
    _containerHeight = preferredContainerHeight;
  }

  CGFloat halfOfNormalFontLineHeight = (CGFloat)0.5 * normalFontLineHeight;
  if (isMultiline) {
    CGFloat heightWithOneRow =
        [self calculateContainerHeightWithFoatingLabelHeight:floatingLabelHeight
                                               textRowHeight:textRowHeight
                                            numberOfTextRows:1
                           paddingBetweenContainerTopAndFloatingLabel:_paddingBetweenContainerTopAndFloatingLabel
                          paddingBetweenFloatingLabelAndEditingText:_paddingBetweenFloatingLabelAndEditingText
                                 paddingBetweenEditingTextAndContainerBottom:_paddingBetweenEditingTextAndContainerBottom];
    CGFloat halfOfHeightWithOneRow = (CGFloat)0.5 * heightWithOneRow;
    _paddingBetweenContainerTopAndNormalLabel = halfOfHeightWithOneRow - halfOfNormalFontLineHeight;
  } else {
    CGFloat halfOfContainerHeight = (CGFloat)0.5 * _containerHeight;
    _paddingBetweenContainerTopAndNormalLabel = halfOfContainerHeight - halfOfNormalFontLineHeight;
  }
}

- (CGFloat)standardizeDensity:(CGFloat)density {
  CGFloat standardizedDensity = density;
  if (standardizedDensity < 0) {
    standardizedDensity = 0;
  } else if (standardizedDensity > 1) {
    standardizedDensity = 1;
  }
  return standardizedDensity;
}

- (CGFloat)calculateContainerHeightWithFoatingLabelHeight:(CGFloat)floatingLabelHeight
                                            textRowHeight:(CGFloat)textRowHeight
                                         numberOfTextRows:(CGFloat)numberOfTextRows
                        paddingBetweenContainerTopAndFloatingLabel:(CGFloat)paddingBetweenContainerTopAndFloatingLabel
                       paddingBetweenFloatingLabelAndEditingText:
                           (CGFloat)paddingBetweenFloatingLabelAndEditingText
                              paddingBetweenEditingTextAndContainerBottom:(CGFloat)paddingBetweenEditingTextAndContainerBottom {
  CGFloat totalTextHeight = numberOfTextRows * textRowHeight;
  return paddingBetweenContainerTopAndFloatingLabel + floatingLabelHeight +
         paddingBetweenFloatingLabelAndEditingText + totalTextHeight + paddingBetweenEditingTextAndContainerBottom;
}

- (CGFloat)paddingBetweenContainerTopAndFloatingLabel {
  return _paddingBetweenContainerTopAndFloatingLabel;
}

- (CGFloat)paddingBetweenContainerTopAndNormalLabel {
  return _paddingBetweenContainerTopAndNormalLabel;
}

- (CGFloat)paddingBetweenFloatingLabelAndEditingText {
  return _paddingBetweenFloatingLabelAndEditingText;
}

- (CGFloat)paddingBetweenEditingTextAndContainerBottom {
  return _paddingBetweenEditingTextAndContainerBottom;
}

- (CGFloat)paddingAboveAssistiveLabels {
  return self.paddingAroundAssistiveLabels;
}

- (CGFloat)paddingBelowAssistiveLabels {
  return self.paddingAroundAssistiveLabels;
}

- (CGFloat)containerHeight {
  return _containerHeight;
}

@end
