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

#import <XCTest/XCTest.h>
#import "MaterialTabs.h"
#import "MDCTabBarDisplayDelegate.h"
#import "MDCItemBar.h"

@interface MDCTabBarDisplayDelegate : NSObject <MDCTabBarDisplayDelegate>
@property (nonatomic, assign) BOOL willDisplayItemWasCalled;
@property (nonatomic, assign) BOOL didEndDisplayingItemWasCalled;
@end

@implementation MDCTabBarDisplayDelegate

-(void)tabBar:(MDCTabBar *)tabBar willDisplayItem:(UITabBarItem *)item {
  self.willDisplayItemWasCalled = YES;
}

-(void)tabBar:(MDCTabBar *)tabBar didEndDisplayingItem:(UITabBarItem *)item {
  self.didEndDisplayingItemWasCalled = YES;
}

@end

@interface MDCTabBarDisplayDelegateTests : XCTestCase
@property (strong, nonatomic) MDCTabBarDisplayDelegate *displayDelegate;
@end

@implementation MDCTabBarDisplayDelegateTests

- (void)testMDCTabBarDisplayDelegateTabBarWillDisplayItem {
  // Given
  MDCTabBar *tabBar = [[MDCTabBar alloc] initWithFrame:CGRectZero];
  MDCTabBarDisplayDelegate *displayDelegate = [[MDCTabBarDisplayDelegate alloc] init];
  tabBar.displayDelegate = displayDelegate;
  CGFloat tabBarHeight = [MDCTabBar defaultHeightForItemAppearance:tabBar.itemAppearance];
  tabBar.frame = CGRectMake(0, 0, 200, tabBarHeight);

  // When
  UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"first tab" image:nil tag:0];
  UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"second tab" image:nil tag:0];
  tabBar.items = @[ item1, item2];
  [tabBar setNeedsLayout];
  [tabBar layoutIfNeeded];

  // Then
  XCTAssertTrue(displayDelegate.willDisplayItemWasCalled);
}

- (void)testMDCTabBarDisplayDelegateTabBarDidEndDisplayingItem {
  // Given
  MDCTabBar *tabBar = [[MDCTabBar alloc] initWithFrame:CGRectZero];
  MDCTabBarDisplayDelegate *displayDelegate = [[MDCTabBarDisplayDelegate alloc] init];
  tabBar.displayDelegate = displayDelegate;
  CGFloat tabBarHeight = [MDCTabBar defaultHeightForItemAppearance:tabBar.itemAppearance];
  tabBar.frame = CGRectMake(0, 0, 200, tabBarHeight);
  
  // When
  UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"first tab" image:nil tag:0];
  UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"second tab" image:nil tag:0];
  UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"third tab" image:nil tag:0];
  UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:@"fourth tab" image:nil tag:0];
  tabBar.items = @[ item1, item2 ];
  [tabBar setNeedsLayout];
  [tabBar layoutIfNeeded];
  tabBar.items = @[ item3, item4 ];
  [tabBar setNeedsLayout];
  [tabBar layoutIfNeeded];

  // Then
  XCTAssertTrue(displayDelegate.didEndDisplayingItemWasCalled);
}

@end
