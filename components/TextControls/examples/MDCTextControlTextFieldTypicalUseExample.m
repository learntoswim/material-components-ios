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

#import "MaterialButtons.h"
#import "MaterialContainerScheme.h"
#import "MaterialTextControls+Theming.h"
#import "MaterialTextControls.h"

static NSString *const kExampleTitle = @"MDCTextControl TextFields";
static CGFloat const kDefaultPadding = 15.0;

@protocol MDCTraitEnvironmentChangeDelegate
- (void)
    childViewControllerDidRequestPreferredContentSizeCategoryDecrement:
        (UIViewController *)childViewController
                                                        decreaseButton:(MDCButton *)decreaseButton
                                                        increaseButton:(MDCButton *)increaseButton;
- (void)
    childViewControllerDidRequestPreferredContentSizeCategoryIncrement:
        (UIViewController *)childViewController
                                                        decreaseButton:(MDCButton *)decreaseButton
                                                        increaseButton:(MDCButton *)increaseButton;
@end

/**
 Typical use example showing how to place an @c MDCBaseTextField in a UIViewController.
 */
@interface MDCTextControlTextFieldTypicalUseExampleContentViewController : UIViewController

@property(nonatomic, weak) id<MDCTraitEnvironmentChangeDelegate> traitEnvironmentChangeDelegate;

/** The MDCBaseTextField for this example. */
@property(nonatomic, strong) MDCBaseTextField *baseTextField;

/** The MDCFilledTextField for this example. */
@property(nonatomic, strong) MDCFilledTextField *filledTextField;

/** The MDCOutlinedTextField for this example. */
@property(nonatomic, strong) MDCOutlinedTextField *outlinedTextField;

/** The UIButton that makes the textfield stop being the first responder. */
@property(nonatomic, strong) MDCButton *resignFirstResponderButton;

@property(nonatomic, strong) MDCButton *decreaseContentSizeButton;
@property(nonatomic, strong) MDCButton *increaseContentSizeButton;

/** The container scheme injected into this example. */
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;

@end

@implementation MDCTextControlTextFieldTypicalUseExampleContentViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.increaseContentSizeButton = [self createIncreaseContentSizeButton];
  [self.view addSubview:self.increaseContentSizeButton];
  self.decreaseContentSizeButton = [self createDecreaseContentSizeButton];
  [self.view addSubview:self.decreaseContentSizeButton];

  self.resignFirstResponderButton = [self createFirstResponderButton];
  [self.view addSubview:self.resignFirstResponderButton];

  self.baseTextField = [[MDCBaseTextField alloc] initWithFrame:self.placeholderTextFieldFrame];
  self.baseTextField.borderStyle = UITextBorderStyleRoundedRect;
  self.baseTextField.label.text = @"This is a label";
  self.baseTextField.placeholder = @"This is placeholder text";
  self.baseTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.baseTextField.leadingAssistiveLabel.text = @"This is leading assistive text";
  [self.view addSubview:self.baseTextField];

  self.filledTextField = [[MDCFilledTextField alloc] initWithFrame:self.placeholderTextFieldFrame];
  self.filledTextField.label.text = @"This is a label";
  self.filledTextField.placeholder = @"This is placeholder text";
  self.filledTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.filledTextField.leadingAssistiveLabel.text = @"This is leading assistive text";
  [self.view addSubview:self.filledTextField];

  self.outlinedTextField =
      [[MDCOutlinedTextField alloc] initWithFrame:self.placeholderTextFieldFrame];
  self.outlinedTextField.label.text = @"This is a label";
  self.outlinedTextField.placeholder = @"This is placeholder text";
  self.outlinedTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
  self.outlinedTextField.leadingAssistiveLabel.text = @"This is leading assistive text";
  [self.view addSubview:self.outlinedTextField];
}

- (MDCButton *)createDecreaseContentSizeButton {
  return [self createContentSizeButtonWithTitle:@"Decrease size"
                                       selector:@selector(decreaseContentSizeButtonTapped:)];
}

- (MDCButton *)createIncreaseContentSizeButton {
  return [self createContentSizeButtonWithTitle:@"Increase size"
                                       selector:@selector(increaseContentSizeButtonTapped:)];
}

- (MDCButton *)createContentSizeButtonWithTitle:(NSString *)title selector:(SEL)selector {
  MDCButton *button = [[MDCButton alloc] init];
  [button setTitle:title forState:UIControlStateNormal];
  [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
  [button sizeToFit];
  button.enabled = NO;
  if (@available(iOS 10.0, *)) {
    button.enabled = YES;
  }
  return button;
}

- (void)increaseContentSizeButtonTapped:(id)sender {
  [self.traitEnvironmentChangeDelegate
      childViewControllerDidRequestPreferredContentSizeCategoryIncrement:self
                                                          decreaseButton:
                                                              self.decreaseContentSizeButton
                                                          increaseButton:
                                                              self.increaseContentSizeButton];
}

- (void)decreaseContentSizeButtonTapped:(id)sender {
  [self.traitEnvironmentChangeDelegate
      childViewControllerDidRequestPreferredContentSizeCategoryDecrement:self
                                                          decreaseButton:
                                                              self.decreaseContentSizeButton
                                                          increaseButton:
                                                              self.increaseContentSizeButton];
}

- (void)usePreferredFonts {
  if (@available(iOS 10.0, *)) {
    self.filledTextField.adjustsFontForContentSizeCategory = YES;
    self.filledTextField.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleBody
            compatibleWithTraitCollection:self.filledTextField.traitCollection];
    self.filledTextField.leadingAssistiveLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
            compatibleWithTraitCollection:self.filledTextField.traitCollection];
    self.filledTextField.trailingAssistiveLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
            compatibleWithTraitCollection:self.filledTextField.traitCollection];

    self.outlinedTextField.adjustsFontForContentSizeCategory = YES;
    self.outlinedTextField.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleBody
            compatibleWithTraitCollection:self.outlinedTextField.traitCollection];
    self.outlinedTextField.leadingAssistiveLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
            compatibleWithTraitCollection:self.outlinedTextField.traitCollection];
    self.outlinedTextField.trailingAssistiveLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
            compatibleWithTraitCollection:self.outlinedTextField.traitCollection];

    self.baseTextField.adjustsFontForContentSizeCategory = YES;
    self.baseTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody
                                  compatibleWithTraitCollection:self.baseTextField.traitCollection];
    self.baseTextField.leadingAssistiveLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
            compatibleWithTraitCollection:self.baseTextField.traitCollection];
    self.baseTextField.trailingAssistiveLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2
            compatibleWithTraitCollection:self.baseTextField.traitCollection];
  }
}

- (MDCButton *)createFirstResponderButton {
  MDCButton *button = [[MDCButton alloc] init];
  [button setTitle:@"Resign first responder" forState:UIControlStateNormal];
  [button addTarget:self
                action:@selector(resignFirstResponderButtonTapped:)
      forControlEvents:UIControlEventTouchUpInside];
  [button sizeToFit];
  return button;
}

- (void)resignFirstResponderButtonTapped:(UIButton *)button {
  [self.baseTextField resignFirstResponder];
  [self.filledTextField resignFirstResponder];
  [self.outlinedTextField resignFirstResponder];
}

- (CGFloat)preferredResignFirstResponderMinY {
  if (@available(iOS 11.0, *)) {
    return (CGFloat)(self.view.safeAreaInsets.top + kDefaultPadding);
  } else {
    return (CGFloat)self.topLayoutGuide.length;
  }
}

- (CGFloat)preferredTextFieldWidth {
  return CGRectGetWidth(self.view.frame) - (2 * kDefaultPadding);
}

- (CGRect)placeholderTextFieldFrame {
  return CGRectMake(0, 0, self.preferredTextFieldWidth, 0);
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  [self.filledTextField applyThemeWithScheme:self.containerScheme];
  [self.outlinedTextField applyThemeWithScheme:self.containerScheme];
  [self usePreferredFonts];

  [self.resignFirstResponderButton sizeToFit];
  [self.decreaseContentSizeButton sizeToFit];
  [self.increaseContentSizeButton sizeToFit];
  [self.baseTextField sizeToFit];
  [self.filledTextField sizeToFit];
  [self.outlinedTextField sizeToFit];

  self.resignFirstResponderButton.frame =
      CGRectMake(kDefaultPadding, self.preferredResignFirstResponderMinY,
                 CGRectGetWidth(self.resignFirstResponderButton.frame),
                 CGRectGetHeight(self.resignFirstResponderButton.frame));

  CGFloat padding = (CGFloat)15.0;
  self.decreaseContentSizeButton.frame =
      CGRectMake(padding, CGRectGetMaxY(self.resignFirstResponderButton.frame) + kDefaultPadding,
                 CGRectGetWidth(self.decreaseContentSizeButton.frame),
                 CGRectGetHeight(self.decreaseContentSizeButton.frame));

  self.increaseContentSizeButton.frame =
      CGRectMake(CGRectGetMaxX(self.decreaseContentSizeButton.frame) + padding,
                 CGRectGetMinY(self.decreaseContentSizeButton.frame),
                 CGRectGetWidth(self.increaseContentSizeButton.frame),
                 CGRectGetHeight(self.increaseContentSizeButton.frame));

  self.filledTextField.frame = CGRectMake(
      kDefaultPadding, CGRectGetMaxY(self.increaseContentSizeButton.frame) + kDefaultPadding,
      CGRectGetWidth(self.filledTextField.frame), CGRectGetHeight(self.filledTextField.frame));

  self.outlinedTextField.frame = CGRectMake(
      kDefaultPadding, CGRectGetMaxY(self.filledTextField.frame) + kDefaultPadding,
      CGRectGetWidth(self.outlinedTextField.frame), CGRectGetHeight(self.outlinedTextField.frame));

  self.baseTextField.frame = CGRectMake(
      kDefaultPadding, CGRectGetMaxY(self.outlinedTextField.frame) + kDefaultPadding,
      CGRectGetWidth(self.baseTextField.frame), CGRectGetHeight(self.baseTextField.frame));
}

@end

/** This view controller manages a child view controller that contains the actual example content.
 * It overrides the child view controller's trait collection based off the user's behavior. */
@interface MDCTextControlTextFieldTypicalUseExample
    : UIViewController <MDCTraitEnvironmentChangeDelegate>

/** The container scheme injected into this example. */
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;

@end

@interface MDCTextControlTextFieldTypicalUseExample ()
@property(nonatomic, strong) NSArray *contentSizeCategories;
@end

@implementation MDCTextControlTextFieldTypicalUseExample

#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = kExampleTitle;
  [self setUpChildViewController];
  [self setUpContentSizeCategories];
  [self setUpContainerScheme];
  self.view.backgroundColor = self.containerScheme.colorScheme.backgroundColor;
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  CGFloat viewWidth = CGRectGetWidth(self.view.frame);
  CGFloat viewHeight = CGRectGetHeight(self.view.frame);
  self.contentViewController.view.frame =
      CGRectMake(0, self.preferredContentMinY, viewWidth, viewHeight - self.preferredContentMinY);
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  [self.contentViewController.view setNeedsLayout];
}

#pragma mark Setup

- (void)setUpChildViewController {
  MDCTextControlTextFieldTypicalUseExampleContentViewController *viewController =
      [[MDCTextControlTextFieldTypicalUseExampleContentViewController alloc] init];
  [self addChildViewController:viewController];
  viewController.traitEnvironmentChangeDelegate = self;
  [self.view addSubview:viewController.view];
}

- (void)setUpContainerScheme {
  if (!self.containerScheme) {
    MDCContainerScheme *containerScheme = [[MDCContainerScheme alloc] init];
    containerScheme.colorScheme =
        [[MDCSemanticColorScheme alloc] initWithDefaults:MDCColorSchemeDefaultsMaterial201907];
    self.containerScheme = containerScheme;
  }
}

- (void)setUpContentSizeCategories {
  self.contentSizeCategories = @[
    UIContentSizeCategoryExtraSmall, UIContentSizeCategorySmall, UIContentSizeCategoryMedium,
    UIContentSizeCategoryLarge, UIContentSizeCategoryExtraLarge,
    UIContentSizeCategoryExtraExtraLarge, UIContentSizeCategoryExtraExtraExtraLarge,
    UIContentSizeCategoryAccessibilityMedium, UIContentSizeCategoryAccessibilityLarge,
    UIContentSizeCategoryAccessibilityExtraLarge, UIContentSizeCategoryAccessibilityExtraExtraLarge,
    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge
  ];
}

- (void)increaseContentSizeForChildViewController:(UIViewController *)childViewController
                                   decreaseButton:(MDCButton *)decreaseButton
                                   increaseButton:(MDCButton *)increaseButton {
  UIContentSizeCategory contentSizeCategory =
      [self contentSizeCategoryForViewController:childViewController];
  if (contentSizeCategory) {
    NSInteger idx = [self.contentSizeCategories indexOfObject:contentSizeCategory];
    if (idx < (NSInteger)self.contentSizeCategories.count - 1) {
      idx += 1;
      UIContentSizeCategory newContentSizeCategory = self.contentSizeCategories[idx];
      [self setContentSizeCategory:newContentSizeCategory
             onChildViewController:childViewController];
      increaseButton.enabled = idx != (NSInteger)self.contentSizeCategories.count - 1;
      decreaseButton.enabled = idx > 0;
    }
  }
}

- (void)decreaseContentSizeForChildViewController:(UIViewController *)childViewController
                                   decreaseButton:(MDCButton *)decreaseButton
                                   increaseButton:(MDCButton *)increaseButton {
  UIContentSizeCategory contentSizeCategory =
      [self contentSizeCategoryForViewController:childViewController];
  if (contentSizeCategory) {
    NSInteger idx = [self.contentSizeCategories indexOfObject:contentSizeCategory];
    if (idx > (NSInteger)0) {
      idx -= 1;
      UIContentSizeCategory newContentSizeCategory = self.contentSizeCategories[idx];
      [self setContentSizeCategory:newContentSizeCategory
             onChildViewController:childViewController];
      increaseButton.enabled = idx != (NSInteger)self.contentSizeCategories.count - 1;
      decreaseButton.enabled = idx > 0;
    }
  }
}

#pragma mark Accessors

- (void)setContentSizeCategory:(UIContentSizeCategory)contentSizeCategory
         onChildViewController:(UIViewController *)viewController {
  if (@available(iOS 10.0, *)) {
    UITraitCollection *contentSizeCategoryTraitCollection =
        [UITraitCollection traitCollectionWithPreferredContentSizeCategory:contentSizeCategory];
    UITraitCollection *currentTraitCollection = viewController.traitCollection;
    NSArray *traitCollections = @[ currentTraitCollection, contentSizeCategoryTraitCollection ];
    UITraitCollection *traitCollection =
        [UITraitCollection traitCollectionWithTraitsFromCollections:traitCollections];
    [self setOverrideTraitCollection:traitCollection forChildViewController:viewController];
    [self.view setNeedsLayout];
  }
}

- (UIContentSizeCategory)contentSizeCategoryForViewController:(UIViewController *)viewController {
  if (@available(iOS 10.0, *)) {
    return viewController.traitCollection.preferredContentSizeCategory;
  }
  return nil;
}

- (void)setContainerScheme:(id<MDCContainerScheming>)containerScheme {
  self.contentViewController.containerScheme = containerScheme;
}

- (id<MDCContainerScheming>)containerScheme {
  return self.contentViewController.containerScheme;
}

- (MDCTextControlTextFieldTypicalUseExampleContentViewController *)contentViewController {
  return (
      MDCTextControlTextFieldTypicalUseExampleContentViewController *)[[self childViewControllers]
      firstObject];
}

- (CGFloat)preferredContentMinY {
  if (@available(iOS 11.0, *)) {
    return (CGFloat)(self.view.safeAreaInsets.top + kDefaultPadding);
  } else {
    return (CGFloat)self.topLayoutGuide.length;
  }
}

#pragma mark - MDCTraitEnvironmentChangeDelegate

- (void)
    childViewControllerDidRequestPreferredContentSizeCategoryDecrement:
        (UIViewController *)childViewController
                                                        decreaseButton:(MDCButton *)decreaseButton
                                                        increaseButton:(MDCButton *)increaseButton {
  [self decreaseContentSizeForChildViewController:childViewController
                                   decreaseButton:decreaseButton
                                   increaseButton:increaseButton];
}
- (void)
    childViewControllerDidRequestPreferredContentSizeCategoryIncrement:
        (UIViewController *)childViewController
                                                        decreaseButton:(MDCButton *)decreaseButton
                                                        increaseButton:(MDCButton *)increaseButton {
  [self increaseContentSizeForChildViewController:childViewController
                                   decreaseButton:decreaseButton
                                   increaseButton:increaseButton];
}

@end

#pragma mark - CatalogByConvention

@implementation MDCTextControlTextFieldTypicalUseExample (CatalogByConvention)

+ (NSDictionary *)catalogMetadata {
  return @{
    @"breadcrumbs" : @[ @"Text Controls", kExampleTitle ],
    @"primaryDemo" : @NO,
    @"presentable" : @NO,
  };
}

@end
