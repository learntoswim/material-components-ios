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

#import "MDCTextControlLabelBehavior.h"
#import "MDCTextControlState.h"

@class MDCBaseInputChipView;
@protocol MDCInputChipViewDelegate <NSObject>
- (void)inputChipViewDidDeleteBackwards:(nonnull MDCBaseInputChipView *)inputChipView
                                oldText:(nullable NSString *)oldText
                                newText:(nullable NSString *)newText;
@end

@interface MDCBaseInputChipView : UIControl

@property(strong, nonatomic, nonnull, readonly) NSArray<UIView *> *chips;

@property(weak, nonatomic, nullable) id<MDCInputChipViewDelegate> delegate;

/**
 The @c label is a label that occupies the area the text usually occupies when there is no
 text. It is distinct from the placeholder in that it can move above the text area or disappear to
 reveal the placeholder when editing begins.
 */
@property(strong, nonatomic, readonly, nonnull) UILabel *label;

/**
 This property determines the behavior of the textfield's label during editing.
 @note The default is MDCTextControlLabelBehaviorFloats.
 */
@property(nonatomic, assign) MDCTextControlLabelBehavior labelBehavior;

/**
 The @c leadingAssistiveLabel is a label below the text on the leading edge of the view. It can be
 used to display helper or error text.
 */
@property(strong, nonatomic, readonly, nonnull) UILabel *leadingAssistiveLabel;

/**
 The @c trailingAssistiveLabel is a label below the text on the trailing edge of the view. It can be
 used to display helper or error text.
 */
@property(strong, nonatomic, readonly, nonnull) UILabel *trailingAssistiveLabel;

/**
 Sets the floating label color for a given state. Floating label color refers to the color of the
 label when it's in its "floating position," i.e. when it's floating.
 @param floatingLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setFloatingLabelColor:(nonnull UIColor *)floatingLabelColor
                     forState:(MDCTextControlState)state;

/**
 Returns the floating label color for a given state. Floating label color refers to the color of the
 label when it's in its "floating position," i.e. when it's floating.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)floatingLabelColorForState:(MDCTextControlState)state;

/**
 Sets the normal label color for a given state. Normal label color refers to the color of the label
 when it's in its "normal position," i.e. when it's not floating.
 @param normalLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setNormalLabelColor:(nonnull UIColor *)normalLabelColor forState:(MDCTextControlState)state;

/**
 Returns the normal label color for a given state. Normal label color refers to the color of the
 label when it's in its "normal position," i.e. when it's not floating.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)normalLabelColorForState:(MDCTextControlState)state;

/**
 Sets the text color for a given state.
 @param textColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setTextColor:(nonnull UIColor *)textColor forState:(MDCTextControlState)state;
/**
 Returns the text color for a given state.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)textColorForState:(MDCTextControlState)state;

/**
 Sets the leading assistive label text color.
 @param leadingAssistiveLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setLeadingAssistiveLabelColor:(nonnull UIColor *)leadingAssistiveLabelColor
                             forState:(MDCTextControlState)state;

/**
 Returns the leading assistive label color for a given state.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)leadingAssistiveLabelColorForState:(MDCTextControlState)state;

/**
 Sets the trailing assistive label text color.
 @param trailingAssistiveLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setTrailingAssistiveLabelColor:(nonnull UIColor *)trailingAssistiveLabelColor
                              forState:(MDCTextControlState)state;

/**
 Returns the trailing assistive label color for a given state.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)trailingAssistiveLabelColorForState:(MDCTextControlState)state;

@property(strong, nonatomic, readonly, nonnull) UITextField *textField;
@property(nonatomic, assign) BOOL chipsWrap;
@property(nonatomic, assign) CGFloat chipRowHeight;
@property(nonatomic, assign) CGFloat chipRowSpacing;
- (void)addChip:(nonnull UIView *)chip;
- (void)removeChips:(nonnull NSArray<UIView *> *)chips;
@property(nonatomic, assign) CGFloat preferredContainerHeight;
@property(nonatomic, assign) NSInteger preferredNumberOfVisibleRows;

/**
 Indicates whether the text field should automatically update its font when the device’s
 UIContentSizeCategory is changed.
 This property is modeled after the adjustsFontForContentSizeCategory property in the
 UIContentSizeCategoryAdjusting protocol added by Apple in iOS 10.0.
 Defaults value is NO.
 */
@property(nonatomic, setter=mdc_setAdjustsFontForContentSizeCategory:)
    BOOL mdc_adjustsFontForContentSizeCategory;

@end
