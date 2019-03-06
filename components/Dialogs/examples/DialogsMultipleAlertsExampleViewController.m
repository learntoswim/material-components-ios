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
#import <UIKit/UIKit.h>

#import "MaterialButtons+Theming.h"
#import "MaterialCollections.h"
#import "MaterialColorScheme.h"
#import "MaterialContainerScheme.h"
#import "MaterialDialogs+Theming.h"
#import "MaterialDialogs.h"
#import "MaterialTypographyScheme.h"

#pragma mark - DialogsMultipleAlertsExampleViewController

@interface DialogsMultipleAlertsExampleViewController : UIViewController <MDCDialogPresentationControllerDelegate, UIPopoverPresentationControllerDelegate>
@property(nonatomic, strong, nullable) id<MDCContainerScheming> containerScheme;
@property(nonatomic, strong, nullable) NSArray *modes;
@property(nonatomic, strong, nullable) MDCButton *button;
@property(nonatomic, strong, nullable) MDCAlertController *blockAlert1;
@property(nonatomic, strong, nullable) MDCAlertController *blockAlert2;
@property(nonatomic, strong, nullable) MDCAlertController *delegateAlert3;
@property(nonatomic, strong, nullable) MDCAlertController *delegateAlert4;
@end

@implementation DialogsMultipleAlertsExampleViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    MDCContainerScheme *scheme = [[MDCContainerScheme alloc] init];
    scheme.colorScheme =
        [[MDCSemanticColorScheme alloc] initWithDefaults:MDCColorSchemeDefaultsMaterial201804];
    _containerScheme = scheme;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  id<MDCColorScheming> colorScheme =
      self.containerScheme.colorScheme
          ?: [[MDCSemanticColorScheme alloc] initWithDefaults:MDCColorSchemeDefaultsMaterial201804];
  self.view.backgroundColor = colorScheme.backgroundColor;

  MDCButton *dismissButton = [[MDCButton alloc] initWithFrame:CGRectZero];
  self.button = dismissButton;
//  dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
  [dismissButton setTitle:@"Show Alert Dialog" forState:UIControlStateNormal];
  [dismissButton addTarget:self
                    action:@selector(showAlert:)
          forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:dismissButton];
  [self.button sizeToFit];
  
  [dismissButton applyTextThemeWithScheme:self.containerScheme];
  

}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.button.center = self.view.center;
}

- (void)showAlert:(UIButton *)button {
  [self showAlert2];
//  NSString *titleString = @"Reset Settings?";
//  NSString *messageString = @"This will reset your device to its default factory settings.";
//
//  MDCAlertController *alert = [MDCAlertController alertControllerWithTitle:titleString
//                                                                   message:messageString];
//  alert.mdc_adjustsFontForContentSizeCategory = YES;
//
//  MDCActionHandler handler = ^(MDCAlertAction *action) {
//    NSLog(@"action pressed: %@", action.title);
//  };
//
//  MDCAlertAction *agreeAaction = [MDCAlertAction actionWithTitle:@"Cancel"
//                                                        emphasis:MDCActionEmphasisLow
//                                                         handler:handler];
//  [alert addAction:agreeAaction];
//
//  MDCAlertAction *disagreeAaction = [MDCAlertAction actionWithTitle:@"Accept"
//                                                           emphasis:MDCActionEmphasisLow
//                                                            handler:handler];
//  [alert addAction:disagreeAaction];
//  [alert applyThemeWithScheme:self.containerScheme];
//
//  [self presentViewController:alert animated:YES completion:NULL];
}

- (void)showAlert1 {
  NSString *titleString = @"Alert 1";
  NSString *messageString = @"The dismissal of this alert will be tracked with blocks.";
  MDCAlertController *alert = [MDCAlertController alertControllerWithTitle:titleString
                                                                   message:messageString];
  __weak __typeof(alert) weakAlert = alert;
  alert.mdc_adjustsFontForContentSizeCategory = YES;
  MDCAlertAction *okAaction = [MDCAlertAction actionWithTitle:@"Ok"
                                                     emphasis:MDCActionEmphasisLow
                                                      handler:^(MDCAlertAction * _Nonnull action) {
                                                        NSLog(@"Dismissed %@",weakAlert);
                                                      }];
  [alert addAction:okAaction];
  [alert applyThemeWithScheme:self.containerScheme];
  [self presentViewController:alert animated:YES completion:NULL];
}

- (void)showAlert2 {
  NSString *titleString = @"Alert 2";
  NSString *messageString = @"The dismissal of this alert will be detected via the delegate method.";

  UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleString message:messageString preferredStyle:UIAlertControllerStyleAlert];
//  alert.mdc_adjustsFontForContentSizeCategory = YES;
  UIAlertAction *okAaction = [UIAlertAction actionWithTitle:@"Ok"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                      NSLog(@"Which alert was dismissed?");
                                                    }];
  [alert addAction:okAaction];
//  [alert applyThemeWithScheme:self.containerScheme];
  [alert setModalPresentationStyle:UIModalPresentationPopover];
  UIPopoverPresentationController *popPresenter = [alert mdc_dialogPresentationController];
  popPresenter.sourceRect = self.button.frame;
  popPresenter.sourceView = self.button;
  popPresenter.delegate = self;
  [self presentViewController:alert animated:YES completion:NULL];

//  MDCAlertController *alert = [MDCAlertController alertControllerWithTitle:titleString
//                                                                   message:messageString];
//  alert.mdc_adjustsFontForContentSizeCategory = YES;
//  MDCAlertAction *okAaction = [MDCAlertAction actionWithTitle:@"Ok"
//                                                     emphasis:MDCActionEmphasisLow
//                                                      handler:^(MDCAlertAction * _Nonnull action) {
//                                                        NSLog(@"Which alert was dismissed?");
//                                                      }];
//  [alert addAction:okAaction];
//  [alert applyThemeWithScheme:self.containerScheme];
//  alert.mdc_dialogPresentationController.dialogPresentationControllerDelegate = self;
//  [self presentViewController:alert animated:YES completion:NULL];
}

- (void)dialogPresentationControllerDidDismiss:
(nonnull MDCDialogPresentationController *)dialogPresentationController {
  UIViewController *presentedViewController = dialogPresentationController.presentedViewController;
  if ([presentedViewController isKindOfClass:[MDCAlertController class]]) {
    MDCAlertController *alert = (MDCAlertController *)presentedViewController;
    NSLog(@"It was this one: %@. We're reacting to the dismissal in the delegate method.",alert);
  }
}

-(BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
  return YES;
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
  NSLog(@"dismissed!");
}


@end


#pragma mark - DialogsTypicalUseExampleViewController - CatalogByConvention

@implementation DialogsMultipleAlertsExampleViewController (CatalogByConvention)

+ (NSDictionary *)catalogMetadata {
  return @{
    @"breadcrumbs" : @[ @"Dialogs", @"Dialogs Multiple Alerts" ],
    @"description" : @"Dialogs inform users about a task and can contain critical information, "
                     @"require decisions, or involve multiple tasks.",
    @"primaryDemo" : @YES,
    @"presentable" : @YES,
  };
}

@end
