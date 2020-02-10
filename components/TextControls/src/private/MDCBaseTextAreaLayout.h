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

#import <UIKit/UIKit.h>

#import "MDCTextControl.h"
#import "MDCTextControlAssistiveLabelView.h"

@interface MDCBaseTextAreaLayout : NSObject
@property(nonatomic, assign) CGFloat globalTextMinX;
@property(nonatomic, assign) CGFloat globalTextMaxX;

@property(nonatomic, assign) CGRect labelFrameFloating;
@property(nonatomic, assign) CGRect labelFrameNormal;

@property(nonatomic, assign) CGRect textViewFrame;

@property(nonatomic, assign) CGRect assistiveLabelViewFrame;
@property(nonatomic, strong, nonnull)
    MDCTextControlAssistiveLabelViewLayout *assistiveLabelViewLayout;

@property(nonatomic, assign) CGRect maskedScrollViewContainerViewFrame;
@property(nonatomic, assign) CGRect scrollViewFrame;
@property(nonatomic, assign) CGRect scrollViewContentViewTouchForwardingViewFrame;
@property(nonatomic, assign) CGSize scrollViewContentSize;
@property(nonatomic, assign) CGPoint scrollViewContentOffset;

@property(nonatomic, readonly) CGFloat calculatedHeight;
@property(nonatomic, readonly) CGFloat containerHeight;

@property(nonatomic, strong, nonnull) NSArray<NSNumber *> *verticalGradientLocations;
@property(nonatomic, strong, nonnull) NSArray<NSNumber *> *horizontalGradientLocations;

- (nonnull instancetype)initWithSize:(CGSize)size
                positioningReference:
                    (nonnull id<MDCTextControlVerticalPositioningReference>)positioningReference
                                text:(nullable NSString *)text
                                font:(nonnull UIFont *)font
                        floatingFont:(nonnull UIFont *)floatingFont
                               label:(nonnull UILabel *)label
                          labelState:(MDCTextControlLabelState)labelState
                       labelBehavior:(MDCTextControlLabelBehavior)labelBehavior
                  leftAssistiveLabel:(nonnull UILabel *)leftAssistiveLabel
                 rightAssistiveLabel:(nonnull UILabel *)rightAssistiveLabel
          assistiveLabelDrawPriority:
              (MDCTextControlAssistiveLabelDrawPriority)assistiveLabelDrawPriority
    customAssistiveLabelDrawPriority:(CGFloat)normalizedCustomAssistiveLabelDrawPriority
        preferredNumberOfVisibleRows:(CGFloat)preferredNumberOfVisibleRows
                               isRTL:(BOOL)isRTL
                           isEditing:(BOOL)isEditing;

@end
