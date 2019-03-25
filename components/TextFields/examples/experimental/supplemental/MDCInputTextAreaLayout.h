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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MDCContainedInputView.h"

@protocol MDCContainedInputViewStyle;

NS_ASSUME_NONNULL_BEGIN

@interface MDCInputTextAreaLayout : NSObject

@property(nonatomic, readonly, class) CGFloat clearButtonSideLength;
@property(nonatomic, readonly, class) CGFloat clearButtonImageViewSideLength;

@property(nonatomic, assign) BOOL clearButtonHidden;

@property(nonatomic, assign) CGRect floatingLabelFrameFloating;
@property(nonatomic, assign) CGRect floatingLabelFrameNormal;
@property(nonatomic, assign) CGRect placeholderLabelFrame;

@property(nonatomic, assign) UIEdgeInsets textContainerInsetFloatingLabelNormal;
@property(nonatomic, assign) UIEdgeInsets textContainerInsetFloatingLabelFloating;

@property(nonatomic, assign) CGSize textContainerSizeFloatingLabelNormal;
@property(nonatomic, assign) CGSize textContainerSizeFloatingLabelFloating;

@property(nonatomic, assign) CGRect clearButtonFrame;
@property(nonatomic, assign) CGRect clearButtonFrameFloatingLabel;
@property(nonatomic, assign) CGRect leftUnderlineLabelFrame;
@property(nonatomic, assign) CGRect rightUnderlineLabelFrame;

@property(nonatomic, readonly) CGFloat calculatedHeight;
@property(nonatomic, assign) CGFloat topRowBottomRowDividerY;

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
                            isEditing:(BOOL)isEditing;

@end

NS_ASSUME_NONNULL_END
