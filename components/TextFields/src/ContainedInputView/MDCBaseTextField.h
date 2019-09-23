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

/**
 A UITextField subclass that attempts to do the following:
 - Earnestly interpret and actualize the Material guidelines for text fields, which can be found
 here: https://material.io/design/components/text-fields.html#outlined-text-field
 - Feel intuitive for someone used to the conventions of iOS development and UIKit controls.
 - Enable easy set up and reliable and predictable behavior.
 Caution: While not explicitly forbidden by the compiler, subclassing this class is highly
 discouraged and not supported. Please consider alternatives.
 */
@interface MDCBaseTextField : UITextField

/**
 The @c labelText is the text that occupies the area the textfield's text usually occupies when
 there is no text. It is distinct from the placeholder in that it can move above the textfield's
 text area or disappear to reveal the placeholder when editing begins.
 */
@property(strong, nonatomic, nullable) NSString *labelText;

/**
 The text color of the placeholder.
 */
@property(strong, nonatomic, nonnull) UIColor *placeholderColor;

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
 This is an RTL-aware wrapper around UITextField's leftView/rightView property.
 */
@property(strong, nonatomic, nullable) UIView *leadingView;

/**
 This is an RTL-aware wrapper around UITextField's leftView/rightView property.
 */
@property(strong, nonatomic, nullable) UIView *trailingView;

/**
 This is an RTL-aware wrapper around UITextField's leftViewMode/rightViewMode property.
 */
@property(nonatomic, assign) UITextFieldViewMode leadingViewMode;

/**
 This is an RTL-aware wrapper around UITextField's leftViewMode/rightViewMode property.
 */
@property(nonatomic, assign) UITextFieldViewMode trailingViewMode;

/**
 Indicates whether the text field should automatically update its font when the device’s
 UIContentSizeCategory is changed.
 This property is modeled after the adjustsFontForContentSizeCategory property in the
 UIContentSizeCategoryAdjusting protocol added by Apple in iOS 10.0.
 Defaults value is NO.
 */
@property(nonatomic, setter=mdc_setAdjustsFontForContentSizeCategory:)
    BOOL mdc_adjustsFontForContentSizeCategory;

/**
 Sets the floating label color for a given state.
 Floating label color refers to the color of the label when it's in its "floating position," i.e.
 when it's above the text area.
 @param floatingLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setFloatingLabelColor:(nonnull UIColor *)floatingLabelColor
                     forState:(MDCTextControlState)state;

/**
 Returns the floating label color for a given state.
 Floating label color refers to the color of the label when it's in its "floating position," i.e.
 when it's above the text area.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)floatingLabelColorForState:(MDCTextControlState)state;

/**
 Sets the normal label color for a given state.
 Normal label color refers to the color of the label when it's in its "normal position," i.e. when
 it's not floating.
 @param normalLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setNormalLabelColor:(nonnull UIColor *)normalLabelColor forState:(MDCTextControlState)state;

/**
 Returns the normal label color for a given state.
 Normal label color refers to the color of the label when it's in its "normal position," i.e. when
 it's not floating.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)normalLabelColorForState:(MDCTextControlState)state;
/**
 Sets the text color for a given state.
 Text color in this case refers to the color of the input text.
 @param textColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setTextColor:(nonnull UIColor *)textColor forState:(MDCTextControlState)state;
/**
 Returns the text color for a given state.
 Text color in this case refers to the color of the input text.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)textColorForState:(MDCTextControlState)state;
/**
 Sets the assistive label color for a given state.
 @param assistiveLabelColor The UIColor for the given state.
 @param state The MDCTextControlState.
 */
- (void)setAssistiveLabelColor:(nonnull UIColor *)assistiveLabelColor
                      forState:(MDCTextControlState)state;

/**
 Returns the assistive label color for a given state.
 @param state The MDCTextControlState.
 */
- (nonnull UIColor *)assistiveLabelColorForState:(MDCTextControlState)state;

@end
