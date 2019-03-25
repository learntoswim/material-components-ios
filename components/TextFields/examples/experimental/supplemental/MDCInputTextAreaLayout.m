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

#import "MDCInputTextAreaLayout.h"

#import "MDCContainedInputView.h"
#import "MDCInputTextField.h"

#import "MaterialMath.h"

static const CGFloat kLeadingMargin = (CGFloat)12.0;
static const CGFloat kTrailingMargin = (CGFloat)12.0;
static const CGFloat kFloatingLabelXOffsetFromTextArea = (CGFloat)3.0;
static const CGFloat kClearButtonTouchTargetSideLength = (CGFloat)30.0;
static const CGFloat kClearButtonInnerImageViewSideLength = (CGFloat)18.0;

@interface MDCInputTextAreaLayout ()
@end

@implementation MDCInputTextAreaLayout

#pragma mark Object Lifecycle

- (instancetype)initWithTextAreaSize:(CGSize)textAreaSize
                       containerStyle:(id<MDCContainedInputViewStyle>)containerStyle
                                 text:(NSString *)text
                          placeholder:(NSString *)placeholder
                                 font:(UIFont *)font
                         floatingFont:(UIFont *)floatingFont
                        floatingLabel:(UILabel *)floatingLabel
                   floatingLabelState:(MDCContainedInputViewFloatingLabelState)floatingLabelState
                canFloatingLabelFloat:(BOOL)canFloatingLabelFloat
    intrinsicContentSizeNumberOfLines:(NSInteger)intrinsicContentSizeNumberOfLines
                          clearButton:(UIButton *)clearButton
                      clearButtonMode:(UITextFieldViewMode)clearButtonMode
                   leftUnderlineLabel:(UILabel *)leftUnderlineLabel
                  rightUnderlineLabel:(UILabel *)rightUnderlineLabel
           underlineLabelDrawPriority:
               (MDCContainedInputViewUnderlineLabelDrawPriority)underlineLabelDrawPriority
     customUnderlineLabelDrawPriority:(CGFloat)customUnderlineLabelDrawPriority
       preferredMainContentAreaHeight:(CGFloat)preferredMainContentAreaHeight
    preferredUnderlineLabelAreaHeight:(CGFloat)preferredUnderlineLabelAreaHeight
                                isRTL:(BOOL)isRTL
                            isEditing:(BOOL)isEditing {
  self = [super init];
  if (self) {
    [self calculateLayoutWithTextAreaSize:textAreaSize
                            containerStyle:containerStyle
                                      text:text
                               placeholder:placeholder
                                      font:font
                              floatingFont:floatingFont
                             floatingLabel:floatingLabel
                        floatingLabelState:floatingLabelState
                     canFloatingLabelFloat:canFloatingLabelFloat
         intrinsicContentSizeNumberOfLines:intrinsicContentSizeNumberOfLines
                               clearButton:clearButton
                           clearButtonMode:clearButtonMode
                        leftUnderlineLabel:leftUnderlineLabel
                       rightUnderlineLabel:rightUnderlineLabel
                underlineLabelDrawPriority:underlineLabelDrawPriority
          customUnderlineLabelDrawPriority:customUnderlineLabelDrawPriority
            preferredMainContentAreaHeight:preferredMainContentAreaHeight
         preferredUnderlineLabelAreaHeight:preferredUnderlineLabelAreaHeight
                                     isRTL:isRTL
                                 isEditing:isEditing];
    return self;
  }
  return nil;
}

#pragma mark Layout Calculation

- (void)calculateLayoutWithTextAreaSize:(CGSize)size
                          containerStyle:(id<MDCContainedInputViewStyle>)containerStyle
                                    text:(NSString *)text
                             placeholder:(NSString *)placeholder
                                    font:(UIFont *)font
                            floatingFont:(UIFont *)floatingFont
                           floatingLabel:(UILabel *)floatingLabel
                      floatingLabelState:(MDCContainedInputViewFloatingLabelState)floatingLabelState
                   canFloatingLabelFloat:(BOOL)canFloatingLabelFloat
       intrinsicContentSizeNumberOfLines:(NSInteger)intrinsicContentSizeNumberOfLines
                             clearButton:(UIButton *)clearButton
                         clearButtonMode:(UITextFieldViewMode)clearButtonMode
                      leftUnderlineLabel:(UILabel *)leftUnderlineLabel
                     rightUnderlineLabel:(UILabel *)rightUnderlineLabel
              underlineLabelDrawPriority:
                  (MDCContainedInputViewUnderlineLabelDrawPriority)underlineLabelDrawPriority
        customUnderlineLabelDrawPriority:(CGFloat)customUnderlineLabelDrawPriority
          preferredMainContentAreaHeight:(CGFloat)preferredMainContentAreaHeight
       preferredUnderlineLabelAreaHeight:(CGFloat)preferredUnderlineLabelAreaHeight
                                   isRTL:(BOOL)isRTL
                               isEditing:(BOOL)isEditing {
  CGFloat textContainerMinX = isRTL ? kTrailingMargin : kLeadingMargin;
  CGFloat textContainerMaxX = isRTL ? size.width - kLeadingMargin : size.width - kTrailingMargin;
  CGFloat maxTextWidth = textContainerMaxX - textContainerMinX;
  CGRect floatingLabelFrameFloating = [self floatingLabelFrameWithText:floatingLabel.text
                                                                  font:floatingFont
                                                     textContainerMinX:textContainerMinX
                                                     textContainerMaxX:textContainerMaxX
                                                        containerStyle:containerStyle
                                                                 isRTL:isRTL];
  CGFloat floatingLabelMaxY = CGRectGetMaxY(floatingLabelFrameFloating);
  CGFloat textAreaMinYWithFloatingLabel = [containerStyle.densityInformer
                                                 contentAreaTopPaddingFloatingLabelWithFloatingLabelMaxY:floatingLabelMaxY];
  CGFloat textAreaMaxYWithFloatingLabel = intrinsicContentSizeNumberOfLines * font.lineHeight;
  if (textAreaMaxYWithFloatingLabel == 0) {
    CGFloat textAreaHeight =
        [self textSizeWithText:text font:font maxWidth:maxTextWidth allowWrapping:YES].height;
    textAreaMaxYWithFloatingLabel = textAreaMinYWithFloatingLabel + textAreaHeight;
  }
  
  CGFloat bottomPadding = [containerStyle.densityInformer
                           contentAreaVerticalPaddingNormalWithFloatingLabelMaxY:floatingLabelMaxY];
  CGFloat intrinsicMainContentAreaHeight = textAreaMaxYWithFloatingLabel + bottomPadding;

  CGFloat contentAreaMaxY = 0;
  if (preferredMainContentAreaHeight > intrinsicMainContentAreaHeight) {
    contentAreaMaxY = preferredMainContentAreaHeight;
  } else {
    contentAreaMaxY = intrinsicMainContentAreaHeight;
  }

  CGRect floatingLabelFrameNormal =
  [self normalFloatingLabelFrameWithFloatingLabelFrame:floatingLabelFrameFloating
                                                  text:floatingLabel.text
                                                  font:font
                                     textContainerMinX:textContainerMinX
                                     textContainerMaxX:textContainerMaxX
                                     contentAreaHeight:contentAreaMaxY
                                        containerStyle:containerStyle
                                                 isRTL:isRTL];

//  CGFloat textAreaMinYNormal =
//  CGRectGetMidY(floatingLabelFrameNormal) - ((CGFloat)0.5 * font.lineHeight);
//  CGFloat textAreaMinY = textAreaMinYNormal;
//  if (floatingLabelState == MDCContainedInputViewFloatingLabelStateFloating) {
//    textAreaMinY = textAreaMinYWithFloatingLabel;
//  }


//  CGSize scrollViewSize = CGSizeMake(size.width, contentAreaMaxY);

//  CGPoint contentOffset = [self scrollViewContentOffsetWithSize:scrollViewSize
//                                                      chipsWrap:chipsWrap
//                                                  chipRowHeight:chipRowHeight
//                                               interChipSpacing:interChipSpacing
//                                                 textFieldFrame:textFieldFrame
//                                             textAreaMinY:textAreaMinY
//                                              textContainerMinX:textContainerMinX
//                                              textContainerMaxX:textContainerMaxX
//                                                  bottomPadding:bottomPadding
//                                                          isRTL:isRTL];
//  CGSize contentSize = [self scrollViewContentSizeWithSize:scrollViewSize
//                                             contentOffset:contentOffset
//                                                chipFrames:chipFrames
//                                            textFieldFrame:textFieldFrame];

  self.topRowBottomRowDividerY = contentAreaMaxY;
  
  CGFloat leftMargin = isRTL ? kTrailingMargin : kLeadingMargin;
  CGFloat rightMargin = isRTL ? kLeadingMargin : kTrailingMargin;
  self.textContainerInsetFloatingLabelNormal =
      UIEdgeInsetsMake(textAreaMinYWithFloatingLabel, leftMargin, 0, rightMargin);
  self.textContainerInsetFloatingLabelFloating =
      UIEdgeInsetsMake(textAreaMinYWithFloatingLabel, leftMargin, 0, rightMargin);
  self.textContainerSizeFloatingLabelNormal = CGSizeMake(0, 0);
  self.textContainerSizeFloatingLabelFloating = CGSizeMake(0, 0);
  
  
  
//  self.contentAreaMaxY = contentAreaMaxY;
//  self.scrollViewContentOffset = contentOffset;
//  self.scrollViewContentSize = contentSize;
//  self.scrollViewContentViewTouchForwardingViewFrame =
//  CGRectMake(0, 0, contentSize.width, contentSize.height);
  self.floatingLabelFrameFloating = floatingLabelFrameFloating;
  self.floatingLabelFrameNormal = floatingLabelFrameNormal;
//  CGRect scrollViewRect = CGRectMake(0, 0, size.width, contentAreaMaxY);
//  self.maskedScrollViewContainerViewFrame = scrollViewRect;
//  self.scrollViewFrame = scrollViewRect;
}

//- (CGFloat)textAreaHeightWithText:(NSString *)text
//                             font:(UIFont *)font
//                            width:(CGFloat)width {
//
//}

- (CGRect)normalFloatingLabelFrameWithFloatingLabelFrame:(CGRect)floatingLabelFrame
                                                    text:(NSString *)text
                                                    font:(UIFont *)font
                                     textContainerMinX:(CGFloat)textContainerMinX
                                     textContainerMaxX:(CGFloat)textContainerMaxX
                                     contentAreaHeight:(CGFloat)contentAreaHeight
                                        containerStyle:
(id<MDCContainedInputViewStyle>)containerStyle
                                                 isRTL:(BOOL)isRTL {
  CGFloat maxTextWidth = textContainerMaxX - textContainerMinX;
  CGSize placeholderSize = [self textSizeWithText:text font:font maxWidth:maxTextWidth allowWrapping:NO];
  CGFloat placeholderMinX = textContainerMinX;
  if (isRTL) {
    placeholderMinX = textContainerMaxX - placeholderSize.width;
  }
  CGFloat placeholderMinY = 0;
  placeholderMinY = [containerStyle.densityInformer
                    contentAreaVerticalPaddingNormalWithFloatingLabelMaxY:CGRectGetMaxY(floatingLabelFrame)];
  return CGRectMake(placeholderMinX, placeholderMinY, placeholderSize.width,
                    placeholderSize.height);
}

- (CGRect)floatingLabelFrameWithText:(NSString *)text
                                font:(UIFont *)font
                   textContainerMinX:(CGFloat)textContainerMinX
                   textContainerMaxX:(CGFloat)textContainerMaxX
                      containerStyle:(id<MDCContainedInputViewStyle>)containerStyle
                               isRTL:(BOOL)isRTL {
  CGFloat maxTextWidth = textContainerMaxX - textContainerMinX - kFloatingLabelXOffsetFromTextArea;
  CGSize placeholderSize = [self textSizeWithText:text font:font maxWidth:maxTextWidth allowWrapping:NO];
  CGFloat placeholderMinY = [containerStyle.densityInformer
                             floatingLabelMinYWithFloatingLabelHeight:placeholderSize.height];
  CGFloat placeholderMinX = textContainerMinX + kFloatingLabelXOffsetFromTextArea;
  if (isRTL) {
    placeholderMinX = textContainerMaxX - kFloatingLabelXOffsetFromTextArea - placeholderSize.width;
  }
  return CGRectMake(placeholderMinX, placeholderMinY, placeholderSize.width,
                    placeholderSize.height);
}

- (CGSize)textSizeWithText:(NSString *)text
                      font:(UIFont *)font
                  maxWidth:(CGFloat)maxWidth
             allowWrapping:(BOOL)allowWrapping {
  CGFloat fittingWidth = allowWrapping ? maxWidth : CGFLOAT_MAX;
  CGSize fittingSize = CGSizeMake(fittingWidth, CGFLOAT_MAX);
  NSDictionary *attributes = @{NSFontAttributeName : font};
  CGRect rect = [text boundingRectWithSize:fittingSize
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attributes
                                   context:nil];
  CGFloat maxTextFieldHeight = allowWrapping ? CGFLOAT_MAX : font.lineHeight;
  CGFloat textFieldWidth = MDCCeil(CGRectGetWidth(rect));
  CGFloat textFieldHeight = MDCCeil(CGRectGetHeight(rect));
  if (!allowWrapping && textFieldWidth > maxWidth) {
    textFieldWidth = maxWidth;
  }
  if (textFieldHeight > maxTextFieldHeight) {
    textFieldHeight = maxTextFieldHeight;
  }
  rect.size.width = textFieldWidth;
  rect.size.height = textFieldHeight;
  return rect.size;
}


- (CGSize)underlineLabelSizeWithLabel:(UILabel *)label constrainedToWidth:(CGFloat)maxWidth {
  if (maxWidth <= 0 || label.text.length <= 0 || label.hidden) {
    return CGSizeZero;
  }
  CGSize fittingSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
  CGSize size = [label sizeThatFits:fittingSize];
  if (size.width > maxWidth) {
    size.width = maxWidth;
  }
  return size;
}

- (CGFloat)leadingUnderlineLabelWidthWithCombinedUnderlineLabelsWidth:
               (CGFloat)totalUnderlineLabelsWidth
                                                   customDrawPriority:(CGFloat)customDrawPriority {
  return customDrawPriority * totalUnderlineLabelsWidth;
}

- (CGFloat)minXForLeftUnderlineLabel:(UILabel *)label isRTL:(BOOL)isRTL {
  return isRTL ? kTrailingMargin : kLeadingMargin;
}

- (CGFloat)maxXForRightUnderlineLabel:(UILabel *)label isRTL:(BOOL)isRTL {
  return isRTL ? kTrailingMargin : kLeadingMargin;
}

- (CGFloat)minXForLeftView:(UIView *)leftView isRTL:(BOOL)isRTL {
  return isRTL ? kTrailingMargin : kLeadingMargin;
}

- (CGFloat)minXForRightView:(UIView *)rightView
             textFieldWidth:(CGFloat)textFieldWidth
                      isRTL:(BOOL)isRTL {
  CGFloat rightMargin = isRTL ? kLeadingMargin : kTrailingMargin;
  CGFloat maxX = textFieldWidth - rightMargin;
  return maxX - CGRectGetWidth(rightView.frame);
}

- (CGFloat)minYForSubviewWithHeight:(CGFloat)height centerY:(CGFloat)centerY {
  return (CGFloat)round((double)(centerY - ((CGFloat)0.5 * height)));
}

- (BOOL)shouldAttemptToDisplaySideView:(UIView *)subview
                              viewMode:(UITextFieldViewMode)viewMode
                             isEditing:(BOOL)isEditing {
  BOOL shouldAttemptToDisplaySideView = NO;
  if (subview && !CGSizeEqualToSize(CGSizeZero, subview.frame.size)) {
    switch (viewMode) {
      case UITextFieldViewModeWhileEditing:
        shouldAttemptToDisplaySideView = isEditing;
        break;
      case UITextFieldViewModeUnlessEditing:
        shouldAttemptToDisplaySideView = !isEditing;
        break;
      case UITextFieldViewModeAlways:
        shouldAttemptToDisplaySideView = YES;
        break;
      case UITextFieldViewModeNever:
        shouldAttemptToDisplaySideView = NO;
        break;
      default:
        break;
    }
  }
  return shouldAttemptToDisplaySideView;
}

- (BOOL)shouldAttemptToDisplayClearButton:(UIButton *)clearButton
                                 viewMode:(UITextFieldViewMode)viewMode
                                isEditing:(BOOL)isEditing
                                     text:(NSString *)text {
  BOOL hasText = text.length > 0;
  BOOL shouldAttemptToDisplayClearButton = NO;
  switch (viewMode) {
    case UITextFieldViewModeWhileEditing:
      shouldAttemptToDisplayClearButton = isEditing && hasText;
      break;
    case UITextFieldViewModeUnlessEditing:
      shouldAttemptToDisplayClearButton = !isEditing;
      break;
    case UITextFieldViewModeAlways:
      shouldAttemptToDisplayClearButton = YES;
      break;
    case UITextFieldViewModeNever:
      shouldAttemptToDisplayClearButton = NO;
      break;
    default:
      break;
  }
  return shouldAttemptToDisplayClearButton;
}

- (CGSize)floatingLabelSizeWithText:(NSString *)placeholder
                           maxWidth:(CGFloat)maxWidth
                               font:(UIFont *)font {
  if (!font) {
    return CGSizeZero;
  }
  CGSize fittingSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
  NSDictionary *attributes = @{NSFontAttributeName : font};
  CGRect rect = [placeholder boundingRectWithSize:fittingSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil];
  rect.size.height = font.lineHeight;
  return rect.size;
}

- (CGRect)floatingLabelFrameWithText:(NSString *)text
                      containerStyle:(id<MDCContainedInputViewStyle>)containerStyle
                  floatingLabelState:(MDCContainedInputViewFloatingLabelState)floatingLabelState
                                font:(UIFont *)font
                        floatingFont:(UIFont *)floatingFont
                   floatingLabelMinY:(CGFloat)floatingLabelMinY
               lowestPlaceholderMinX:(CGFloat)lowestPlaceholderMinX
              highestPlaceholderMaxX:(CGFloat)highestPlaceholderMaxX
                        textRectRect:(CGRect)textRectRect
                               isRTL:(BOOL)isRTL {
  CGFloat maxWidth = highestPlaceholderMaxX - lowestPlaceholderMinX;
  CGFloat textRectMidY = CGRectGetMidY(textRectRect);
  CGSize size = CGSizeZero;
  CGRect rect = CGRectZero;
  CGFloat originX = 0;
  CGFloat originY = 0;
  switch (floatingLabelState) {
    case MDCContainedInputViewFloatingLabelStateNone:
      break;
    case MDCContainedInputViewFloatingLabelStateFloating:
      size = [self floatingLabelSizeWithText:text maxWidth:maxWidth font:floatingFont];
      originY = floatingLabelMinY;
      if (isRTL) {
        originX = highestPlaceholderMaxX - size.width;
      } else {
        originX = lowestPlaceholderMinX;
      }
      rect = CGRectMake(originX, originY, size.width, size.height);
      break;
    case MDCContainedInputViewFloatingLabelStateNormal:
      size = [self floatingLabelSizeWithText:text maxWidth:maxWidth font:font];
      originY = textRectMidY - ((CGFloat)0.5 * size.height);
      if (isRTL) {
        originX = highestPlaceholderMaxX - size.width;
      } else {
        originX = lowestPlaceholderMinX;
      }
      rect = CGRectMake(originX, originY, size.width, size.height);
      break;
    default:
      break;
  }
  return rect;
}

- (CGFloat)textHeightWithFont:(UIFont *)font {
  return (CGFloat)ceil((double)font.lineHeight);
}

- (CGFloat)calculatedHeight {
  CGFloat maxY = 0;
  CGFloat floatingLabelFrameFloatingMaxY = CGRectGetMaxY(self.floatingLabelFrameFloating);
  if (floatingLabelFrameFloatingMaxY > maxY) {
    maxY = floatingLabelFrameFloatingMaxY;
  }
  CGFloat floatingLabelFrameNormalMaxY = CGRectGetMaxY(self.floatingLabelFrameNormal);
  if (floatingLabelFrameFloatingMaxY > maxY) {
    maxY = floatingLabelFrameNormalMaxY;
  }
  CGFloat clearButtonFrameMaxY = CGRectGetMaxY(self.clearButtonFrame);
  if (clearButtonFrameMaxY > maxY) {
    maxY = clearButtonFrameMaxY;
  }
  CGFloat leftUnderlineLabelFrameMaxY = CGRectGetMaxY(self.leftUnderlineLabelFrame);
  if (leftUnderlineLabelFrameMaxY > maxY) {
    maxY = leftUnderlineLabelFrameMaxY;
  }
  CGFloat rightUnderlineLabelFrameMaxY = CGRectGetMaxY(self.rightUnderlineLabelFrame);
  if (rightUnderlineLabelFrameMaxY > maxY) {
    maxY = rightUnderlineLabelFrameMaxY;
  }
  if (self.topRowBottomRowDividerY > maxY) {
    maxY = self.topRowBottomRowDividerY;
  }
  return maxY;
}

+ (CGFloat)clearButtonImageViewSideLength {
  return kClearButtonInnerImageViewSideLength;
}

+ (CGFloat)clearButtonSideLength {
  return kClearButtonTouchTargetSideLength;
}

@end
