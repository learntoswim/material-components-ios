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

#import "MDCBaseInputChipViewLayout.h"

#import <MDFInternationalization/MDFInternationalization.h>
#import "MDCBaseInputChipView.h"
#import "MaterialMath.h"

static const CGFloat kEstimatedCursorWidth = (CGFloat)2.0;

static const CGFloat kHorizontalPadding = (CGFloat)12.0;

static const CGFloat kGradientBlurLength = 6;

@interface MDCBaseInputChipViewLayout ()

@property(nonatomic, assign) CGFloat calculatedHeight;
@property(nonatomic, assign) CGFloat minimumHeight;
@property(nonatomic, assign) CGFloat containerHeight;

@end

@implementation MDCBaseInputChipViewLayout

- (instancetype)initWithSize:(CGSize)size
                positioningReference:
                    (nonnull id<MDCTextControlVerticalPositioningReference>)positioningReference
                                text:(NSString *)text
                         placeholder:(NSString *)placeholder
                                font:(UIFont *)font
                        floatingFont:(UIFont *)floatingFont
                               label:(UILabel *)label
                          labelState:(MDCTextControlLabelState)labelState
                       labelBehavior:(MDCTextControlLabelBehavior)labelBehavior
                               chips:(NSArray<UIView *> *)chips
                      staleChipViews:(NSArray<UIView *> *)staleChipViews
                           chipsWrap:(BOOL)chipsWrap
                       chipRowHeight:(CGFloat)chipRowHeight
                    interChipSpacing:(CGFloat)interChipSpacing
                  leftAssistiveLabel:(UILabel *)leftAssistiveLabel
                 rightAssistiveLabel:(UILabel *)rightAssistiveLabel
          assistiveLabelDrawPriority:
              (MDCTextControlAssistiveLabelDrawPriority)assistiveLabelDrawPriority
    customAssistiveLabelDrawPriority:(CGFloat)normalizedCustomAssistiveLabelDrawPriority
            preferredContainerHeight:(CGFloat)preferredContainerHeight
        preferredNumberOfVisibleRows:(CGFloat)preferredNumberOfVisibleRows
                               isRTL:(BOOL)isRTL
                           isEditing:(BOOL)isEditing {
  self = [super init];
  if (self) {
    [self calculateLayoutWithSize:size
                    positioningReference:positioningReference
                                    text:text
                             placeholder:placeholder
                                    font:font
                            floatingFont:floatingFont
                                   label:label
                              labelState:labelState
                           labelBehavior:labelBehavior
                                   chips:chips
                          staleChipViews:staleChipViews
                               chipsWrap:chipsWrap
                           chipRowHeight:chipRowHeight
                        interChipSpacing:interChipSpacing
                      leftAssistiveLabel:leftAssistiveLabel
                     rightAssistiveLabel:rightAssistiveLabel
              assistiveLabelDrawPriority:assistiveLabelDrawPriority
        customAssistiveLabelDrawPriority:normalizedCustomAssistiveLabelDrawPriority
                preferredContainerHeight:preferredContainerHeight
            preferredNumberOfVisibleRows:(CGFloat)preferredNumberOfVisibleRows
                                   isRTL:isRTL
                               isEditing:isEditing];
  }
  return self;
}

- (void)calculateLayoutWithSize:(CGSize)size
                positioningReference:
                    (nonnull id<MDCTextControlVerticalPositioningReference>)positioningReference
                                text:(NSString *)text
                         placeholder:(NSString *)placeholder
                                font:(UIFont *)font
                        floatingFont:(UIFont *)floatingFont
                               label:(UILabel *)label
                          labelState:(MDCTextControlLabelState)labelState
                       labelBehavior:(MDCTextControlLabelBehavior)labelBehavior
                               chips:(NSArray<UIView *> *)chips
                      staleChipViews:(NSArray<UIView *> *)staleChipViews
                           chipsWrap:(BOOL)chipsWrap
                       chipRowHeight:(CGFloat)chipRowHeight
                    interChipSpacing:(CGFloat)interChipSpacing
                  leftAssistiveLabel:(UILabel *)leftAssistiveLabel
                 rightAssistiveLabel:(UILabel *)rightAssistiveLabel
          assistiveLabelDrawPriority:
              (MDCTextControlAssistiveLabelDrawPriority)assistiveLabelDrawPriority
    customAssistiveLabelDrawPriority:(CGFloat)customAssistiveLabelDrawPriority
            preferredContainerHeight:(CGFloat)preferredContainerHeight
        preferredNumberOfVisibleRows:(CGFloat)preferredNumberOfVisibleRows
                               isRTL:(BOOL)isRTL
                           isEditing:(BOOL)isEditing {
  CGFloat globalChipRowMinX = kHorizontalPadding;
  CGFloat globalChipRowMaxX =
      isRTL ? size.width - kHorizontalPadding : size.width - kHorizontalPadding;
  CGFloat maxTextWidth = globalChipRowMaxX - globalChipRowMinX;

  CGRect labelFrameFloating =
      [self floatingLabelFrameWithText:label.text
                                        floatingFont:floatingFont
                                   globalChipRowMinX:globalChipRowMinX
                                   globalChipRowMaxX:globalChipRowMaxX
          paddingBetweenContainerTopAndFloatingLabel:positioningReference
                                                         .paddingBetweenContainerTopAndFloatingLabel
                                               isRTL:isRTL];
  CGFloat floatingLabelMaxY = CGRectGetMaxY(labelFrameFloating);

  CGFloat initialChipRowMinYWithFloatingLabel =
      floatingLabelMaxY + positioningReference.paddingBetweenFloatingLabelAndEditingText;

  CGFloat bottomPadding = positioningReference.paddingBetweenEditingTextAndContainerBottom;

  CGRect labelFrameNormal =
      [self normalLabelFrameWithText:label.text
                                              font:font
                                 globalChipRowMinX:globalChipRowMinX
                                 globalChipRowMaxX:globalChipRowMaxX
          paddingBetweenContainerTopAndNormalLabel:positioningReference
                                                       .paddingBetweenContainerTopAndNormalLabel
                                             isRTL:isRTL];

  CGFloat initialChipRowMinYNormal = 0;
  CGFloat halfOfNormalLabelHeight = (CGFloat)0.5 * font.lineHeight;
  CGFloat halfOfChipRowHeight = ((CGFloat)0.5 * chipRowHeight);
  initialChipRowMinYNormal = positioningReference.paddingBetweenContainerTopAndNormalLabel +
                             halfOfNormalLabelHeight - halfOfChipRowHeight;
  CGFloat initialChipRowMinY = initialChipRowMinYNormal;
  if (labelState == MDCTextControlLabelStateFloating) {
    initialChipRowMinY = initialChipRowMinYWithFloatingLabel;
  }

  CGSize scrollViewSize = CGSizeMake(size.width, positioningReference.containerHeight);
  CGSize textSize = [self textSizeWithText:text font:font maxWidth:maxTextWidth];

  NSArray<NSValue *> *chipFrames = [self determineChipFramesWithChips:chips
                                                            chipsWrap:chipsWrap
                                                        chipRowHeight:chipRowHeight
                                                     interChipSpacing:interChipSpacing
                                                   initialChipRowMinY:initialChipRowMinY
                                                    globalChipRowMinX:globalChipRowMinX
                                                    globalChipRowMaxX:globalChipRowMaxX
                                                                isRTL:isRTL];

  CGRect textFieldFrame = [self textFieldFrameWithSize:scrollViewSize
                                            chipFrames:chipFrames
                                             chipsWrap:chipsWrap
                                         chipRowHeight:chipRowHeight
                                      interChipSpacing:interChipSpacing
                                    initialChipRowMinY:initialChipRowMinY
                                     globalChipRowMinX:globalChipRowMinX
                                     globalChipRowMaxX:globalChipRowMaxX
                                              textSize:textSize
                                                 isRTL:isRTL];

  CGPoint contentOffset = [self scrollViewContentOffsetWithSize:scrollViewSize
                                                      chipsWrap:chipsWrap
                                                  chipRowHeight:chipRowHeight
                                               interChipSpacing:interChipSpacing
                                                 textFieldFrame:textFieldFrame
                                             initialChipRowMinY:initialChipRowMinY
                                              globalChipRowMinX:globalChipRowMinX
                                              globalChipRowMaxX:globalChipRowMaxX
                                                  bottomPadding:bottomPadding
                                                          isRTL:isRTL];
  CGSize contentSize = [self scrollViewContentSizeWithSize:scrollViewSize
                                             contentOffset:contentOffset
                                                chipFrames:chipFrames
                                                 chipsWrap:chipsWrap
                                            textFieldFrame:textFieldFrame
                                                     isRTL:isRTL];

  self.assistiveLabelViewLayout = [[MDCContainedInputAssistiveLabelViewLayout alloc]
                         initWithWidth:size.width
                    leftAssistiveLabel:leftAssistiveLabel
                   rightAssistiveLabel:rightAssistiveLabel
            assistiveLabelDrawPriority:assistiveLabelDrawPriority
      customAssistiveLabelDrawPriority:customAssistiveLabelDrawPriority
                     horizontalPadding:kHorizontalPadding
           paddingAboveAssistiveLabels:positioningReference.paddingAboveAssistiveLabels
           paddingBelowAssistiveLabels:positioningReference.paddingBelowAssistiveLabels
                                 isRTL:isRTL];
  self.assistiveLabelViewFrame = CGRectMake(0, positioningReference.containerHeight, size.width,
                                            self.assistiveLabelViewLayout.calculatedHeight);
  self.containerHeight = positioningReference.containerHeight;
  self.chipFrames = chipFrames;
  self.textFieldFrame = textFieldFrame;
  self.scrollViewContentOffset = contentOffset;
  self.scrollViewContentSize = contentSize;
  self.scrollViewContentViewTouchForwardingViewFrame =
      CGRectMake(0, 0, contentSize.width, contentSize.height);
  self.labelFrameFloating = labelFrameFloating;
  self.labelFrameNormal = labelFrameNormal;
  self.globalChipRowMinX = globalChipRowMinX;
  self.globalChipRowMaxX = globalChipRowMaxX;
  CGRect scrollViewRect = CGRectMake(0, 0, size.width, positioningReference.containerHeight);
  self.maskedScrollViewContainerViewFrame = scrollViewRect;
  self.scrollViewFrame = scrollViewRect;

  self.horizontalGradientLocations =
      [self determineHorizontalGradientLocationsWithGlobalChipRowMinX:globalChipRowMinX
                                                    globalChipRowMaxX:globalChipRowMaxX
                                                            viewWidth:size.width];
  CGFloat topFadeStartingY = bottomPadding;
  if (labelState == MDCTextControlLabelStateFloating) {
    topFadeStartingY = floatingLabelMaxY;
  }
  self.verticalGradientLocations =
      [self determineVerticalGradientLocationsWithViewHeight:positioningReference.containerHeight
                                            topFadeStartingY:topFadeStartingY
                                         bottomFadeStartingY:bottomPadding];
}

- (CGFloat)calculatedHeight {
  CGFloat maxY = self.containerHeight;
  CGFloat assistiveLabelViewMaxY = CGRectGetMaxY(self.assistiveLabelViewFrame);
  if (assistiveLabelViewMaxY > maxY) {
    maxY = assistiveLabelViewMaxY;
  }
  return maxY;
}

- (CGRect)normalLabelFrameWithText:(NSString *)text
                                        font:(UIFont *)font
                           globalChipRowMinX:(CGFloat)globalChipRowMinX
                           globalChipRowMaxX:(CGFloat)globalChipRowMaxX
    paddingBetweenContainerTopAndNormalLabel:(CGFloat)paddingBetweenContainerTopAndNormalLabel
                                       isRTL:(BOOL)isRTL {
  CGFloat maxTextWidth = globalChipRowMaxX - globalChipRowMinX;
  CGSize textSize = [self textSizeWithText:text font:font maxWidth:maxTextWidth];
  CGFloat normalLabelMinX = globalChipRowMinX;
  if (isRTL) {
    normalLabelMinX = globalChipRowMaxX - textSize.width;
  }
  CGFloat normalLabelMinY = paddingBetweenContainerTopAndNormalLabel;
  return CGRectMake(normalLabelMinX, normalLabelMinY, textSize.width, textSize.height);
}

- (CGRect)floatingLabelFrameWithText:(NSString *)text
                                  floatingFont:(UIFont *)floatingFont
                             globalChipRowMinX:(CGFloat)globalChipRowMinX
                             globalChipRowMaxX:(CGFloat)globalChipRowMaxX
    paddingBetweenContainerTopAndFloatingLabel:(CGFloat)paddingBetweenContainerTopAndFloatingLabel
                                         isRTL:(BOOL)isRTL {
  CGFloat maxTextWidth = globalChipRowMaxX - globalChipRowMinX;
  CGSize textSize = [self textSizeWithText:text font:floatingFont maxWidth:maxTextWidth];
  CGFloat floatingLabelMinY = paddingBetweenContainerTopAndFloatingLabel;
  CGFloat floatingLabelMinX = globalChipRowMinX;
  if (isRTL) {
    floatingLabelMinX = globalChipRowMaxX - textSize.width;
  }
  return CGRectMake(floatingLabelMinX, floatingLabelMinY, textSize.width, textSize.height);
}

- (CGFloat)textHeightWithFont:(UIFont *)font {
  return (CGFloat)ceil((double)font.lineHeight);
}

- (NSArray<NSValue *> *)determineChipFramesWithChips:(NSArray<UIView *> *)chips
                                           chipsWrap:(BOOL)chipsWrap
                                       chipRowHeight:(CGFloat)chipRowHeight
                                    interChipSpacing:(CGFloat)interChipSpacing
                                  initialChipRowMinY:(CGFloat)initialChipRowMinY
                                   globalChipRowMinX:(CGFloat)globalChipRowMinX
                                   globalChipRowMaxX:(CGFloat)globalChipRowMaxX
                                               isRTL:(BOOL)isRTL {
  NSMutableArray<NSValue *> *frames = [[NSMutableArray alloc] initWithCapacity:chips.count];

  if (isRTL) {
    if (chipsWrap) {
      CGFloat chipMaxX = globalChipRowMaxX;
      CGFloat chipMidY = initialChipRowMinY + ((CGFloat)0.5 * chipRowHeight);
      CGFloat chipMinY = 0;
      CGRect chipFrame = CGRectZero;
      CGFloat row = 0;
      for (UIView *chip in chips) {
        CGFloat chipWidth = CGRectGetWidth(chip.frame);
        CGFloat chipHeight = CGRectGetHeight(chip.frame);
        CGFloat chipMinX = chipMaxX - chipWidth;
        BOOL chipIsTooLong = chipMinX < globalChipRowMinX;
        BOOL firstChipInRow = chipMaxX == globalChipRowMaxX;
        BOOL isNewRow = chipIsTooLong && !firstChipInRow;
        if (isNewRow) {
          row++;
          chipMaxX = globalChipRowMaxX;
          chipMidY = initialChipRowMinY + (row * (chipRowHeight + interChipSpacing)) +
                     ((CGFloat)0.5 * chipRowHeight);
          chipMinY = chipMidY - ((CGFloat)0.5 * chipHeight);
          chipMinX = MDCFloor(chipMaxX - chipWidth);
          chipFrame = CGRectMake(chipMinX, chipMinY, chipWidth, chipHeight);
          chipMaxX = CGRectGetMaxX(chipFrame);
        } else {
          chipMinY = chipMidY - ((CGFloat)0.5 * chipHeight);
          chipMinX = MDCFloor(chipMaxX - chipWidth);
          chipFrame = CGRectMake(chipMinX, chipMinY, chipWidth, chipHeight);
        }
        chipMaxX = chipMinX - interChipSpacing;
        NSValue *chipFrameValue = [NSValue valueWithCGRect:chipFrame];
        [frames addObject:chipFrameValue];
      }
    } else {
      CGFloat chipMaxX = globalChipRowMaxX;
      CGFloat chipCenterY = initialChipRowMinY + (chipRowHeight * (CGFloat)0.5);
      for (UIView *chip in chips) {
        CGFloat chipWidth = CGRectGetWidth(chip.frame);
        CGFloat chipHeight = CGRectGetHeight(chip.frame);
        CGFloat chipMinY = chipCenterY - ((CGFloat)0.5 * chipHeight);
        CGFloat chipMinX = MDCFloor(chipMaxX - chipWidth);
        CGRect chipFrame = CGRectMake(chipMinX, chipMinY, chipWidth, chipHeight);
        NSValue *chipFrameValue = [NSValue valueWithCGRect:chipFrame];
        [frames addObject:chipFrameValue];
        chipMaxX = chipMinX - interChipSpacing;
      }
    }
  } else {
    if (chipsWrap) {
      CGFloat chipMinX = globalChipRowMinX;
      CGFloat chipMidY = initialChipRowMinY + ((CGFloat)0.5 * chipRowHeight);
      CGFloat chipMinY = 0;
      CGRect chipFrame = CGRectZero;
      CGFloat row = 0;
      for (UIView *chip in chips) {
        CGFloat chipWidth = CGRectGetWidth(chip.frame);
        CGFloat chipHeight = CGRectGetHeight(chip.frame);
        CGFloat chipMaxX = chipMinX + chipWidth;
        BOOL chipIsTooLong = chipMaxX > globalChipRowMaxX;
        BOOL firstChipInRow = chipMinX == globalChipRowMinX;
        BOOL isNewRow = chipIsTooLong && !firstChipInRow;
        if (isNewRow) {
          row++;
          chipMinX = globalChipRowMinX;
          chipMidY = initialChipRowMinY + (row * (chipRowHeight + interChipSpacing)) +
                     ((CGFloat)0.5 * chipRowHeight);
          chipMinY = chipMidY - ((CGFloat)0.5 * chipHeight);
          chipFrame = CGRectMake(chipMinX, chipMinY, chipWidth, chipHeight);
          chipMaxX = CGRectGetMaxX(chipFrame);
        } else {
          chipMinY = chipMidY - ((CGFloat)0.5 * chipHeight);
          chipFrame = CGRectMake(chipMinX, chipMinY, chipWidth, chipHeight);
        }
        chipMinX = chipMaxX + interChipSpacing;
        NSValue *chipFrameValue = [NSValue valueWithCGRect:chipFrame];
        [frames addObject:chipFrameValue];
      }
    } else {
      CGFloat chipMinX = globalChipRowMinX;
      CGFloat chipCenterY = initialChipRowMinY + (chipRowHeight * (CGFloat)0.5);
      for (UIView *chip in chips) {
        CGFloat chipWidth = CGRectGetWidth(chip.frame);
        CGFloat chipHeight = CGRectGetHeight(chip.frame);
        CGFloat chipMinY = chipCenterY - ((CGFloat)0.5 * chipHeight);
        CGRect chipFrame = CGRectMake(chipMinX, chipMinY, chipWidth, chipHeight);
        NSValue *chipFrameValue = [NSValue valueWithCGRect:chipFrame];
        [frames addObject:chipFrameValue];
        CGFloat chipMaxX = MDCCeil(CGRectGetMaxX(chipFrame));
        chipMinX = chipMaxX + interChipSpacing;
      }
    }
  }
  return [frames copy];
}

- (CGSize)textSizeWithText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
  CGSize fittingSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  NSDictionary *attributes = @{NSFontAttributeName : font};
  CGRect rect = [text boundingRectWithSize:fittingSize
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attributes
                                   context:nil];
  CGFloat maxTextFieldHeight = font.lineHeight;
  CGFloat textFieldWidth = MDCCeil(CGRectGetWidth(rect)) + kEstimatedCursorWidth;
  CGFloat textFieldHeight = MDCCeil(CGRectGetHeight(rect));
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

- (CGSize)scrollViewContentSizeWithSize:(CGSize)scrollViewSize
                          contentOffset:(CGPoint)contentOffset
                             chipFrames:(NSArray<NSValue *> *)chipFrames
                              chipsWrap:(BOOL)chipsWrap
                         textFieldFrame:(CGRect)textFieldFrame
                                  isRTL:(BOOL)isRTL {
  CGSize contentSize = scrollViewSize;
  if (isRTL) {
    if (chipsWrap) {
      if (contentOffset.y > 0) {
        contentSize.height += contentOffset.y;
      }
      return contentSize;
    } else {
      NSLog(@"co: %@", @(contentOffset.x));
      if (contentOffset.x < 0) {
        contentSize.width += (contentOffset.x * -1);
        NSLog(@"size.width: %@", @(contentSize.width));
      }
      return contentSize;
    }
  } else {
    if (chipsWrap) {
      if (contentOffset.y > 0) {
        contentSize.height += contentOffset.y;
      }
      return contentSize;
    } else {
      NSLog(@"co: %@", @(contentOffset.x));
      if (contentOffset.x > 0) {
        contentSize.width += contentOffset.x;
        NSLog(@"size.width: %@", @(contentSize.width));
      }
      return contentSize;
    }
  }
}

- (CGRect)textFieldFrameWithSize:(CGSize)size
                      chipFrames:(NSArray<NSValue *> *)chipFrames
                       chipsWrap:(BOOL)chipsWrap
                   chipRowHeight:(CGFloat)chipRowHeight
                interChipSpacing:(CGFloat)interChipSpacing
              initialChipRowMinY:(CGFloat)initialChipRowMinY
               globalChipRowMinX:(CGFloat)globalChipRowMinX
               globalChipRowMaxX:(CGFloat)globalChipRowMaxX
                        textSize:(CGSize)textSize
                           isRTL:(BOOL)isRTL {
  if (isRTL) {
    if (chipsWrap) {
      CGFloat textFieldMinX = 0;
      CGFloat textFieldMaxX = 0;
      CGFloat textFieldMinY = 0;
      CGFloat textFieldMidY = 0;
      if (chipFrames.count > 0) {
        CGRect lastChipFrame = [[chipFrames lastObject] CGRectValue];
        CGFloat lastChipMidY = CGRectGetMidY(lastChipFrame);
        textFieldMidY = lastChipMidY;
        textFieldMinY = textFieldMidY - ((CGFloat)0.5 * textSize.height);
        textFieldMaxX = CGRectGetMinX(lastChipFrame) - interChipSpacing;
        textFieldMinX = textFieldMaxX - textSize.width;
        BOOL textFieldShouldMoveToNextRow = textFieldMinX < globalChipRowMinX;
        if (textFieldShouldMoveToNextRow) {
          NSInteger currentRow = [self chipRowWithRect:lastChipFrame
                                    initialChipRowMinY:initialChipRowMinY
                                         chipRowHeight:chipRowHeight
                                      interChipSpacing:interChipSpacing];
          NSInteger nextRow = currentRow + 1;
          CGFloat nextRowMinY =
              initialChipRowMinY + ((CGFloat)(nextRow) * (chipRowHeight + interChipSpacing));
          textFieldMidY = nextRowMinY + ((CGFloat)0.5 * chipRowHeight);
          textFieldMinY = textFieldMidY - ((CGFloat)0.5 * textSize.height);
          textFieldMaxX = globalChipRowMaxX;
          textFieldMinX = textFieldMaxX - textSize.width;
          BOOL textFieldIsStillTooBig = textFieldMaxX < globalChipRowMinX;
          if (textFieldIsStillTooBig) {
            CGFloat difference = globalChipRowMinX - textFieldMinX;
            textSize.width = textSize.width - difference;
          }
        }
        return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
      } else {
        textFieldMaxX = globalChipRowMaxX;
        textFieldMinX = textFieldMaxX - textSize.width;
        textFieldMidY = initialChipRowMinY + ((CGFloat)0.5 * chipRowHeight);
        textFieldMinY = textFieldMidY - ((CGFloat)0.5 * textSize.height);
        return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
      }
      return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
    } else {
      CGFloat textFieldMaxX = 0;
      if (chipFrames.count > 0) {
        CGRect lastFrame = [[chipFrames lastObject] CGRectValue];
        textFieldMaxX = MDCFloor(CGRectGetMinX(lastFrame)) - interChipSpacing;
      } else {
        textFieldMaxX = globalChipRowMaxX;
      }
      CGFloat textFieldCenterY = initialChipRowMinY + ((CGFloat)0.5 * chipRowHeight);
      CGFloat textFieldMinY = textFieldCenterY - ((CGFloat)0.5 * textSize.height);
      CGFloat textFieldMinX = textFieldMaxX - textSize.width;
      return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
    }
  } else {
    if (chipsWrap) {
      CGFloat textFieldMinX = 0;
      CGFloat textFieldMaxX = 0;
      CGFloat textFieldMinY = 0;
      CGFloat textFieldMidY = 0;
      if (chipFrames.count > 0) {
        CGRect lastChipFrame = [[chipFrames lastObject] CGRectValue];
        CGFloat lastChipMidY = CGRectGetMidY(lastChipFrame);
        textFieldMidY = lastChipMidY;
        textFieldMinY = textFieldMidY - ((CGFloat)0.5 * textSize.height);
        textFieldMinX = CGRectGetMaxX(lastChipFrame) + interChipSpacing;
        textFieldMaxX = textFieldMinX + textSize.width;
        BOOL textFieldShouldMoveToNextRow = textFieldMaxX > globalChipRowMaxX;
        if (textFieldShouldMoveToNextRow) {
          NSInteger currentRow = [self chipRowWithRect:lastChipFrame
                                    initialChipRowMinY:initialChipRowMinY
                                         chipRowHeight:chipRowHeight
                                      interChipSpacing:interChipSpacing];
          NSInteger nextRow = currentRow + 1;
          CGFloat nextRowMinY =
              initialChipRowMinY + ((CGFloat)(nextRow) * (chipRowHeight + interChipSpacing));
          textFieldMidY = nextRowMinY + ((CGFloat)0.5 * chipRowHeight);
          textFieldMinY = textFieldMidY - ((CGFloat)0.5 * textSize.height);
          textFieldMinX = globalChipRowMinX;
          textFieldMaxX = textFieldMinX + textSize.width;
          BOOL textFieldIsStillTooBig = textFieldMaxX > globalChipRowMaxX;
          if (textFieldIsStillTooBig) {
            CGFloat difference = textFieldMaxX - globalChipRowMaxX;
            textSize.width = textSize.width - difference;
          }
        }
        return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
      } else {
        textFieldMinX = globalChipRowMinX;
        textFieldMidY = initialChipRowMinY + ((CGFloat)0.5 * chipRowHeight);
        textFieldMinY = textFieldMidY - ((CGFloat)0.5 * textSize.height);
        return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
      }
      return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
    } else {
      CGFloat textFieldMinX = 0;
      if (chipFrames.count > 0) {
        CGRect lastFrame = [[chipFrames lastObject] CGRectValue];
        textFieldMinX = MDCCeil(CGRectGetMaxX(lastFrame)) + interChipSpacing;
      } else {
        textFieldMinX = globalChipRowMinX;
      }
      CGFloat textFieldCenterY = initialChipRowMinY + ((CGFloat)0.5 * chipRowHeight);
      CGFloat textFieldMinY = textFieldCenterY - ((CGFloat)0.5 * textSize.height);
      return CGRectMake(textFieldMinX, textFieldMinY, textSize.width, textSize.height);
    }
  }
  return CGRectZero;
}

- (CGPoint)scrollViewContentOffsetWithSize:(CGSize)size
                                 chipsWrap:(BOOL)chipsWrap
                             chipRowHeight:(CGFloat)chipRowHeight
                          interChipSpacing:(CGFloat)interChipSpacing
                            textFieldFrame:(CGRect)textFieldFrame
                        initialChipRowMinY:(CGFloat)initialChipRowMinY
                         globalChipRowMinX:(CGFloat)globalChipRowMinX
                         globalChipRowMaxX:(CGFloat)globalChipRowMaxX
                             bottomPadding:(CGFloat)bottomPadding
                                     isRTL:(BOOL)isRTL {
  CGPoint contentOffset = CGPointZero;
  if (chipsWrap) {
    NSInteger row = [self chipRowWithRect:textFieldFrame
                       initialChipRowMinY:initialChipRowMinY
                            chipRowHeight:chipRowHeight
                         interChipSpacing:interChipSpacing];
    CGFloat lastRowMaxY = initialChipRowMinY + ((row + 1) * (chipRowHeight + interChipSpacing));
    CGFloat boundsMaxY = size.height;
    if (lastRowMaxY > boundsMaxY) {
      CGFloat difference = lastRowMaxY - boundsMaxY;
      contentOffset = CGPointMake(0, (difference + bottomPadding));
    }
  } else {
    CGFloat textFieldMinX = CGRectGetMinX(textFieldFrame);
    CGFloat textFieldMaxX = CGRectGetMaxX(textFieldFrame);
    if (isRTL) {
      if (textFieldMaxX > globalChipRowMaxX) {
        NSLog(@"if %@ > %@", @(textFieldMaxX), @(globalChipRowMaxX));
        CGFloat difference = textFieldMaxX - globalChipRowMaxX;
        contentOffset = CGPointMake(difference, 0);
        NSLog(@"%@", @(contentOffset.x));
      } else if (textFieldMinX < globalChipRowMinX) {
        NSLog(@"else if %@ < %@", @(textFieldMinX), @(globalChipRowMinX));
        CGFloat difference = globalChipRowMinX - textFieldMinX;
        contentOffset = CGPointMake((-1 * difference), 0);
        NSLog(@"%@", @(contentOffset.x));
      }
    } else {
      if (textFieldMaxX > globalChipRowMaxX) {
        NSLog(@"if %@ > %@", @(textFieldMaxX), @(globalChipRowMaxX));
        CGFloat difference = textFieldMaxX - globalChipRowMaxX;
        contentOffset = CGPointMake(difference, 0);
        NSLog(@"%@", @(contentOffset.x));
      } else if (textFieldMinX < globalChipRowMinX) {
        NSLog(@"else if %@ < %@", @(textFieldMinX), @(globalChipRowMinX));
        CGFloat difference = globalChipRowMinX - textFieldMinX;
        contentOffset = CGPointMake((-1 * difference), 0);
        NSLog(@"%@", @(contentOffset.x));
      }
    }
  }
  return contentOffset;
}

- (NSInteger)chipRowWithRect:(CGRect)rect
          initialChipRowMinY:(CGFloat)initialChipRowMinY
               chipRowHeight:(CGFloat)chipRowHeight
            interChipSpacing:(CGFloat)interChipSpacing {
  CGFloat viewMidY = CGRectGetMidY(rect);
  CGFloat midYAdjustedForContentInset = MDCRound(viewMidY - initialChipRowMinY);
  NSInteger row =
      (NSInteger)midYAdjustedForContentInset / (NSInteger)(chipRowHeight + interChipSpacing);
  return row;
}

- (NSArray<NSNumber *> *)
    determineHorizontalGradientLocationsWithGlobalChipRowMinX:(CGFloat)globalChipRowMinX
                                            globalChipRowMaxX:(CGFloat)globalChipRowMaxX
                                                    viewWidth:(CGFloat)viewWidth {
  CGFloat leftFadeStart = (globalChipRowMinX - kGradientBlurLength) / viewWidth;
  if (leftFadeStart < 0) {
    leftFadeStart = 0;
  }
  CGFloat leftFadeEnd = globalChipRowMinX / viewWidth;
  if (leftFadeEnd < 0) {
    leftFadeEnd = 0;
  }
  CGFloat rightFadeStart = (globalChipRowMaxX) / viewWidth;
  if (rightFadeStart >= 1) {
    rightFadeStart = 1;
  }
  CGFloat rightFadeEnd = (globalChipRowMaxX + kGradientBlurLength) / viewWidth;
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

- (NSArray<NSNumber *> *)determineVerticalGradientLocationsWithViewHeight:(CGFloat)viewHeight
                                                         topFadeStartingY:(CGFloat)floatingLabelMaxY
                                                      bottomFadeStartingY:
                                                          (CGFloat)bottomFadeStartingY {
  CGFloat topFadeStartRatioNumerator = floatingLabelMaxY;

  CGFloat topFadeStart = topFadeStartRatioNumerator / viewHeight;
  if (topFadeStart <= 0) {
    topFadeStart = 0;
  }
  CGFloat topFadeEnd = (topFadeStartRatioNumerator + kGradientBlurLength) / viewHeight;
  if (topFadeEnd <= 0) {
    topFadeEnd = 0;
  }
  CGFloat bottomFadeStart = (viewHeight - bottomFadeStartingY) / viewHeight;
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

@end
