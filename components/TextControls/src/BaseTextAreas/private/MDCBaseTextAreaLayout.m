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

#import "MDCBaseTextAreaLayout.h"

#import <MDFInternationalization/MDFInternationalization.h>
#import "MDCBaseInputChipView.h"

static const CGFloat kHorizontalPadding = (CGFloat)12.0;

static const CGFloat kGradientBlurLength = 4;

@interface MDCBaseTextAreaLayout ()

@property(nonatomic, assign) CGFloat calculatedHeight;
@property(nonatomic, assign) CGFloat minimumHeight;
@property(nonatomic, assign) CGFloat containerHeight;

@end

@implementation MDCBaseTextAreaLayout

- (nonnull instancetype)initWithSize:(CGSize)size
                positioningReference:
                    (nonnull id<MDCTextControlVerticalPositioningReference>)positioningReference
                                text:(nullable NSString *)text
                                font:(nonnull UIFont *)font
                        floatingFont:(nonnull UIFont *)floatingFont
                               label:(nonnull UILabel *)label
                          labelState:(MDCTextControlLabelState)labelState
                       labelBehavior:(MDCTextControlLabelBehavior)labelBehavior
               leadingAssistiveLabel:(UILabel *)leadingAssistiveLabel
              trailingAssistiveLabel:(UILabel *)trailingAssistiveLabel
          assistiveLabelDrawPriority:
              (MDCTextControlAssistiveLabelDrawPriority)assistiveLabelDrawPriority
    customAssistiveLabelDrawPriority:(CGFloat)normalizedCustomAssistiveLabelDrawPriority
                               isRTL:(BOOL)isRTL
                           isEditing:(BOOL)isEditing {
  self = [super init];
  if (self) {
    [self calculateLayoutWithSize:size
                    positioningReference:positioningReference
                                    text:text
                                    font:font
                            floatingFont:floatingFont
                                   label:label
                              labelState:labelState
                           labelBehavior:labelBehavior
                   leadingAssistiveLabel:leadingAssistiveLabel
                  trailingAssistiveLabel:trailingAssistiveLabel
              assistiveLabelDrawPriority:assistiveLabelDrawPriority
        customAssistiveLabelDrawPriority:normalizedCustomAssistiveLabelDrawPriority
                                   isRTL:isRTL
                               isEditing:isEditing];
  }
  return self;
}

- (void)calculateLayoutWithSize:(CGSize)size
                positioningReference:
                    (id<MDCTextControlVerticalPositioningReference>)positioningReference
                                text:(NSString *)text
                                font:(UIFont *)font
                        floatingFont:(UIFont *)floatingFont
                               label:(UILabel *)label
                          labelState:(MDCTextControlLabelState)labelState
                       labelBehavior:(MDCTextControlLabelBehavior)labelBehavior
               leadingAssistiveLabel:(UILabel *)leadingAssistiveLabel
              trailingAssistiveLabel:(UILabel *)trailingAssistiveLabel
          assistiveLabelDrawPriority:
              (MDCTextControlAssistiveLabelDrawPriority)assistiveLabelDrawPriority
    customAssistiveLabelDrawPriority:(CGFloat)customAssistiveLabelDrawPriority
                               isRTL:(BOOL)isRTL
                           isEditing:(BOOL)isEditing {
  CGFloat globalTextMinX = isRTL ? kHorizontalPadding : kHorizontalPadding;
  CGFloat globalTextMaxX =
      isRTL ? size.width - kHorizontalPadding : size.width - kHorizontalPadding;
  CGRect floatingLabelFrame =
      [self floatingLabelFrameWithText:label.text
                                        floatingFont:floatingFont
                                      globalTextMinX:globalTextMinX
                                      globalTextMaxX:globalTextMaxX
          paddingBetweenContainerTopAndFloatingLabel:positioningReference
                                                         .paddingBetweenContainerTopAndFloatingLabel
                                               isRTL:isRTL];
  CGFloat floatingLabelMaxY = CGRectGetMaxY(floatingLabelFrame);

  CGFloat bottomPadding = positioningReference.paddingBetweenEditingTextAndContainerBottom;

  CGRect normalLabelFrame =
      [self normalLabelFrameWithLabelText:label.text
                                              font:font
                                    globalTextMinX:globalTextMinX
                                    globalTextMaxX:globalTextMaxX
          paddingBetweenContainerTopAndNormalLabel:positioningReference
                                                       .paddingBetweenContainerTopAndNormalLabel
                                             isRTL:isRTL];

  CGFloat halfOfNormalLineHeight = (CGFloat)0.5 * font.lineHeight;
  CGFloat textViewMinYNormal = CGRectGetMidY(normalLabelFrame) - halfOfNormalLineHeight;
  CGFloat textViewMinY = textViewMinYNormal;
  if (labelState == MDCTextControlLabelStateFloating) {
    textViewMinY = floatingLabelMaxY + positioningReference.paddingBetweenFloatingLabelAndEditingText;
  }

  CGFloat textViewHeight =
      positioningReference.containerHeight - bottomPadding - textViewMinY;
  CGRect textViewFrame = CGRectMake(globalTextMinX, textViewMinY,
                                    globalTextMaxX - globalTextMinX, textViewHeight);

  self.assistiveLabelViewLayout = [[MDCTextControlAssistiveLabelViewLayout alloc]
                         initWithWidth:size.width
                 leadingAssistiveLabel:leadingAssistiveLabel
                trailingAssistiveLabel:trailingAssistiveLabel
            assistiveLabelDrawPriority:assistiveLabelDrawPriority
      customAssistiveLabelDrawPriority:customAssistiveLabelDrawPriority
                     horizontalPadding:kHorizontalPadding
           paddingAboveAssistiveLabels:positioningReference.paddingAboveAssistiveLabels
           paddingBelowAssistiveLabels:positioningReference.paddingBelowAssistiveLabels
                                 isRTL:isRTL];
  self.assistiveLabelViewFrame = CGRectMake(0, positioningReference.containerHeight, size.width,
                                            self.assistiveLabelViewLayout.calculatedHeight);

  self.containerHeight = positioningReference.containerHeight;
  self.textViewFrame = textViewFrame;
  self.labelFrameFloating = floatingLabelFrame;
  self.labelFrameNormal = normalLabelFrame;

  self.horizontalGradientLocations = [self
      determineHorizontalGradientLocationsWithGlobalTextMinX:globalTextMinX
                                              globalTextMaxX:globalTextMaxX
                                                   viewWidth:size.width
                                                  viewHeight:positioningReference.containerHeight];
  self.verticalGradientLocations = [self
      determineVerticalGradientLocationsWithGlobalTextMinX:globalTextMinX
                                            globalTextMaxX:globalTextMaxX
                                                 viewWidth:size.width
                                                viewHeight:positioningReference.containerHeight
                                         floatingLabelMaxY:floatingLabelMaxY
                                             bottomPadding:bottomPadding
                                      positioningReference:positioningReference];
  return;
}

- (CGFloat)calculatedHeight {
  CGFloat maxY = self.containerHeight;
  CGFloat assistiveLabelViewMaxY = CGRectGetMaxY(self.assistiveLabelViewFrame);
  if (assistiveLabelViewMaxY > maxY) {
    maxY = assistiveLabelViewMaxY;
  }
  return maxY;
}

- (CGRect)normalLabelFrameWithLabelText:(NSString *)labelText
                                        font:(UIFont *)font
                              globalTextMinX:(CGFloat)globalTextMinX
                              globalTextMaxX:(CGFloat)globalTextMaxX
    paddingBetweenContainerTopAndNormalLabel:(CGFloat)paddingBetweenContainerTopAndNormalLabel
                                       isRTL:(BOOL)isRTL {
  CGFloat maxTextWidth = globalTextMaxX - globalTextMinX;
  CGSize normalLabelSize = [self textSizeWithText:labelText font:font maxWidth:maxTextWidth];
  CGFloat normalLabelMinX = globalTextMinX;
  if (isRTL) {
    normalLabelMinX = globalTextMaxX - normalLabelSize.width;
  }
  CGFloat normalLabelMinY = paddingBetweenContainerTopAndNormalLabel;
  return CGRectMake(normalLabelMinX, normalLabelMinY, normalLabelSize.width,
                    normalLabelSize.height);
}

- (CGRect)floatingLabelFrameWithText:(NSString *)text
                                  floatingFont:(UIFont *)floatingFont
                                globalTextMinX:(CGFloat)globalTextMinX
                                globalTextMaxX:(CGFloat)globalTextMaxX
    paddingBetweenContainerTopAndFloatingLabel:(CGFloat)paddingBetweenContainerTopAndFloatingLabel
                                         isRTL:(BOOL)isRTL {
  CGFloat maxTextWidth = globalTextMaxX - globalTextMinX;
  CGSize floatingLabelSize = [self textSizeWithText:text font:floatingFont maxWidth:maxTextWidth];
  CGFloat textMinY = paddingBetweenContainerTopAndFloatingLabel;
  CGFloat textMinX = globalTextMinX;
  if (isRTL) {
    textMinX = globalTextMaxX - floatingLabelSize.width;
  }
  return CGRectMake(textMinX, textMinY, floatingLabelSize.width, floatingLabelSize.height);
}

- (CGFloat)textHeightWithFont:(UIFont *)font {
  return (CGFloat)ceil((double)font.lineHeight);
}

- (CGSize)textSizeWithText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
  CGSize fittingSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  NSDictionary *attributes = @{NSFontAttributeName : font};
  CGRect rect = [text boundingRectWithSize:fittingSize
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attributes
                                   context:nil];
  CGFloat maxTextFieldHeight = font.lineHeight;
  CGFloat textFieldWidth = CGRectGetWidth(rect);
  CGFloat textFieldHeight = CGRectGetHeight(rect);
  if (textFieldWidth > maxWidth) {
    textFieldWidth = maxWidth;
  }
  if (textFieldHeight > maxTextFieldHeight) {
    textFieldHeight = maxTextFieldHeight;
  }
  rect.size.width = textFieldWidth;
  rect.size.height = textFieldHeight;
  return rect.size;
}

- (NSArray<NSNumber *> *)
    determineHorizontalGradientLocationsWithGlobalTextMinX:(CGFloat)globalTextMinX
                                            globalTextMaxX:(CGFloat)globalTextMaxX
                                                 viewWidth:(CGFloat)viewWidth
                                                viewHeight:(CGFloat)viewHeight {
  CGFloat leftFadeStart = (globalTextMinX - kGradientBlurLength) / viewWidth;
  if (leftFadeStart < 0) {
    leftFadeStart = 0;
  }
  CGFloat leftFadeEnd = globalTextMinX / viewWidth;
  if (leftFadeEnd < 0) {
    leftFadeEnd = 0;
  }
  CGFloat rightFadeStart = (globalTextMaxX) / viewWidth;
  if (rightFadeStart >= 1) {
    rightFadeStart = 1;
  }
  CGFloat rightFadeEnd = (globalTextMaxX + kGradientBlurLength) / viewWidth;
  if (rightFadeEnd >= 1) {
    rightFadeEnd = 1;
  }

  return @[
    @(0),
    @(leftFadeStart),
    @(leftFadeEnd),
    @(rightFadeStart),
    @(rightFadeEnd),
    @(1),
  ];
}

- (NSArray<NSNumber *> *)
    determineVerticalGradientLocationsWithGlobalTextMinX:(CGFloat)globalTextMinX
                                          globalTextMaxX:(CGFloat)globalTextMaxX
                                               viewWidth:(CGFloat)viewWidth
                                              viewHeight:(CGFloat)viewHeight
                                       floatingLabelMaxY:(CGFloat)floatingLabelMaxY
                                           bottomPadding:(CGFloat)bottomPadding
                                    positioningReference:
                                        (id<MDCTextControlVerticalPositioningReference>)
                                            positioningReference {
  CGFloat topFadeStart = floatingLabelMaxY / viewHeight;
  if (topFadeStart <= 0) {
    topFadeStart = 0;
  }
  CGFloat topFadeEnd = (floatingLabelMaxY + kGradientBlurLength) / viewHeight;
  if (topFadeEnd <= 0) {
    topFadeEnd = 0;
  }
  CGFloat bottomFadeStart = (viewHeight - bottomPadding) / viewHeight;
  if (bottomFadeStart >= 1) {
    bottomFadeStart = 1;
  }
  CGFloat bottomFadeEnd = (viewHeight - kGradientBlurLength) / viewHeight;
  if (bottomFadeEnd >= 1) {
    bottomFadeEnd = 1;
  }

  return @[
    @(0),
    @(topFadeStart),
    @(topFadeEnd),
    @(bottomFadeStart),
    @(bottomFadeEnd),
    @(1),
  ];
}

- (CGRect)labelFrameWithLabelState:(MDCTextControlLabelState)labelState {
  if (labelState == MDCTextControlLabelStateFloating) {
    return self.labelFrameFloating;
  } else if (labelState == MDCTextControlLabelStateNormal) {
    return self.labelFrameNormal;
  } else {
    return CGRectZero;
  }
}

@end
