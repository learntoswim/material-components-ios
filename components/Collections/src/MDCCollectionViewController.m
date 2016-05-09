/*
 Copyright 2016-present Google Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "MDCCollectionViewController.h"

#import "MDCCollectionViewFlowLayout.h"
#import "MaterialCollectionCells.h"
#import "MaterialInk.h"
#import "private/MDCCollectionInfoBarView.h"
#import "private/MDCCollectionStringResources.h"
#import "private/MDCCollectionViewEditor.h"
#import "private/MDCCollectionViewStyler.h"

#import <tgmath.h>

@interface MDCCollectionViewController () <MDCCollectionInfoBarViewDelegate,
                                           MDCInkTouchControllerDelegate>

@end

@implementation MDCCollectionViewController {
  MDCInkTouchController *_inkTouchController;
  MDCCollectionInfoBarView *_headerInfoBar;
  MDCCollectionInfoBarView *_footerInfoBar;
  BOOL _headerInfoBarDismissed;
  CGPoint _inkTouchLocation;
}

@synthesize collectionViewLayout = _collectionViewLayout;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  self = [super initWithCollectionViewLayout:layout];
  if (self) {
    [self commonMDCCollectionViewControllerInit:self.collectionViewLayout];
  }
  return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithCollectionViewLayout:self.collectionViewLayout];
  if (self) {
    [self commonMDCCollectionViewControllerInit:self.collectionViewLayout];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCollectionViewLayout:self.collectionViewLayout];
  if (self) {
    [self commonMDCCollectionViewControllerInit:self.collectionViewLayout];
  }
  return self;
}

- (void)commonMDCCollectionViewControllerInit:(UICollectionViewLayout *)layout {
  _collectionViewLayout = layout;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.alwaysBounceVertical = YES;

  _styler = [[MDCCollectionViewStyler alloc] initWithCollectionView:self.collectionView];
  _styler.delegate = self;

  _editor = [[MDCCollectionViewEditor alloc] initWithCollectionView:self.collectionView];
  _editor.delegate = self;

  // Set up ink touch controller.
  _inkTouchController = [[MDCInkTouchController alloc] initWithView:self.collectionView];
  _inkTouchController.delegate = self;
}

- (UICollectionViewLayout *)collectionViewLayout {
  if (!_collectionViewLayout) {
    _collectionViewLayout = [[MDCCollectionViewFlowLayout alloc] init];
  }
  return _collectionViewLayout;
}

#pragma mark - <MDCCollectionInfoBarViewDelegate>

- (void)updateControllerWithInfoBar:(MDCCollectionInfoBarView *)infoBar {
  // Updates info bar styling for header/footer.
  if ([infoBar.kind isEqualToString:MDCCollectionInfoBarKindHeader]) {
    _headerInfoBar = infoBar;
    _headerInfoBar.message = MDCCollectionStringResources(infoBarGestureHintString);
    _headerInfoBar.style = MDCCollectionInfoBarViewStyleHUD;
    [self updateHeaderInfoBarIfNecessary];
  } else if ([infoBar.kind isEqualToString:MDCCollectionInfoBarKindFooter]) {
    _footerInfoBar = infoBar;
    _footerInfoBar.message = MDCCollectionStringResources(deleteButtonString);
    _footerInfoBar.style = MDCCollectionInfoBarViewStyleActionable;
    [self updateFooterInfoBarIfNecessary];
  }
}

- (void)didTapInfoBar:(MDCCollectionInfoBarView *)infoBar {
  if ([infoBar isEqual:_footerInfoBar]) {
    [self deleteIndexPaths:self.collectionView.indexPathsForSelectedItems];
  }
}

- (void)infoBar:(MDCCollectionInfoBarView *)infoBar
    willShowAnimated:(BOOL)animated
     willAutoDismiss:(BOOL)willAutoDismiss {
  if ([infoBar.kind isEqualToString:MDCCollectionInfoBarKindFooter]) {
    [self updateContentWithBottomInset:MDCCollectionInfoBarFooterHeight];
  }
}

- (void)infoBar:(MDCCollectionInfoBarView *)infoBar
    willDismissAnimated:(BOOL)animated
        willAutoDismiss:(BOOL)willAutoDismiss {
  if ([infoBar.kind isEqualToString:MDCCollectionInfoBarKindHeader]) {
    _headerInfoBarDismissed = willAutoDismiss;
  } else {
    [self updateContentWithBottomInset:-MDCCollectionInfoBarFooterHeight];
  }
}

#pragma mark - <MDCCollectionViewStylingDelegate>

- (MDCCollectionViewCellStyle)collectionView:(UICollectionView *)collectionView
                         cellStyleForSection:(NSInteger)section {
  return _styler.cellStyle;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *attr =
      [collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
  CGSize size = [self sizeWithAttribute:attr];
  size = [self inlaidSizeAtIndexPath:indexPath withSize:size];
  return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
  return [self insetsAtSectionIndex:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
    if (_styler.cellLayoutType == MDCCollectionViewCellLayoutTypeGrid) {
      return _styler.gridPadding;
    }
    return [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];
  }
  return 0;
}

- (CGSize)sizeWithAttribute:(UICollectionViewLayoutAttributes *)attr {
  CGFloat height = MDCCellDefaultOneLineHeight;
  if ([_styler.delegate respondsToSelector:
                            @selector(collectionView:cellHeightAtIndexPath:)]) {
    height = [_styler.delegate collectionView:self.collectionView
                        cellHeightAtIndexPath:attr.indexPath];
  }

  CGFloat width = [self cellWidthAtSectionIndex:attr.indexPath.section];
  return CGSizeMake(width, height);
}

- (CGFloat)cellWidthAtSectionIndex:(NSInteger)section {
  CGFloat bounds = CGRectGetWidth(UIEdgeInsetsInsetRect(self.collectionView.bounds,
                                                        self.collectionView.contentInset));
  UIEdgeInsets sectionInsets = [self insetsAtSectionIndex:section];
  CGFloat insets = sectionInsets.left + sectionInsets.right;
  if (_styler.cellLayoutType == MDCCollectionViewCellLayoutTypeGrid) {
    CGFloat cellWidth =
        bounds - insets - (_styler.gridPadding * (_styler.gridColumnCount - 1));
    return cellWidth / _styler.gridColumnCount;
  }
  return bounds - insets;
}

- (UIEdgeInsets)insetsAtSectionIndex:(NSInteger)section {
  // Determine insets based on cell style.
  CGFloat inset = (CGFloat)floor(MDCCollectionViewCellStyleCardSectionInset);
  UIEdgeInsets insets = UIEdgeInsetsZero;
  NSInteger numberOfSections = self.collectionView.numberOfSections;
  BOOL isTop = (section == 0);
  BOOL isBottom = (section == numberOfSections - 1);
  MDCCollectionViewCellStyle cellStyle = [_styler cellStyleAtSectionIndex:section];
  BOOL isCardStyle = cellStyle == MDCCollectionViewCellStyleCard;
  BOOL isGroupedStyle = cellStyle == MDCCollectionViewCellStyleGrouped;
  // Set left/right insets.
  if (isCardStyle) {
    insets.left = inset;
    insets.right = inset;
  }
  // Set top/bottom insets.
  if (isCardStyle || isGroupedStyle) {
    insets.top = (CGFloat)floor((isTop) ? inset : inset / 2.0f);
    insets.bottom = (CGFloat)floor((isBottom) ? inset : inset / 2.0f);
  }
  return insets;
}

- (CGSize)inlaidSizeAtIndexPath:(NSIndexPath *)indexPath
                       withSize:(CGSize)size {
  // If object is inlaid, return its adjusted size.
  UICollectionView *collectionView = self.collectionView;
  if ([_styler isItemInlaidAtIndexPath:indexPath]) {
    CGFloat inset = MDCCollectionViewCellStyleCardSectionInset;
    UIEdgeInsets inlayInsets = UIEdgeInsetsZero;
    BOOL prevCellIsInlaid = NO;
    BOOL nextCellIsInlaid = NO;

    BOOL hasSectionHeader = NO;
    if ([self respondsToSelector:
                  @selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
      CGSize headerSize = [self collectionView:collectionView
                                        layout:_collectionViewLayout
               referenceSizeForHeaderInSection:indexPath.section];
      hasSectionHeader = !CGSizeEqualToSize(headerSize, CGSizeZero);
    }

    BOOL hasSectionFooter = NO;
    if ([self respondsToSelector:
                  @selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
      CGSize footerSize = [self collectionView:collectionView
                                        layout:_collectionViewLayout
               referenceSizeForFooterInSection:indexPath.section];
      hasSectionFooter = !CGSizeEqualToSize(footerSize, CGSizeZero);
    }

    // Check if previous cell is inlaid.
    if (indexPath.item > 0 || hasSectionHeader) {
      NSIndexPath *prevIndexPath =
          [NSIndexPath indexPathForItem:(indexPath.item - 1)
                              inSection:indexPath.section];
      prevCellIsInlaid = [_styler isItemInlaidAtIndexPath:prevIndexPath];
      inlayInsets.top = prevCellIsInlaid ? inset / 2 : inset;
    }

    // Check if next cell is inlaid.
    if (indexPath.item < [collectionView numberOfItemsInSection:indexPath.section] - 1 ||
        hasSectionFooter) {
      NSIndexPath *nextIndexPath =
          [NSIndexPath indexPathForItem:(indexPath.item + 1)
                              inSection:indexPath.section];
      nextCellIsInlaid = [_styler isItemInlaidAtIndexPath:nextIndexPath];
      inlayInsets.bottom = nextCellIsInlaid ? inset / 2 : inset;
    }

    // Apply top/bottom height adjustments to inlaid object.
    size.height += inlayInsets.top + inlayInsets.bottom;
  }
  return size;
}

#pragma mark - <MDCInkTouchControllerDelegate>

- (BOOL)inkTouchController:(MDCInkTouchController *)inkTouchController
    shouldProcessInkTouchesAtTouchLocation:(CGPoint)location {
  // Only store touch location and do not allow ink processing. This ink location will be used when
  // manually starting/stopping the ink animation during cell highlight/unhighlight states.
  _inkTouchLocation = location;
  return NO;
}

- (MDCInkView *)inkTouchController:(MDCInkTouchController *)inkTouchController
            inkViewAtTouchLocation:(CGPoint)location {
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  MDCInkView *ink = nil;
  if ([cell isKindOfClass:[MDCCollectionViewCell class]]) {
    MDCCollectionViewCell *inkCell = (MDCCollectionViewCell *)cell;
    if ([inkCell respondsToSelector:@selector(inkView)]) {
      // Set cell ink.
      ink = [cell performSelector:@selector(inkView)];
    }
  }

  if ([_styler.delegate respondsToSelector:
                            @selector(collectionView:inkTouchController:inkViewAtIndexPath:)]) {
    return [_styler.delegate collectionView:self.collectionView
                         inkTouchController:inkTouchController
                         inkViewAtIndexPath:indexPath];
  }

  return ink;
}

#pragma mark - <UICollectionViewDataSource>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
  // Editing info bar.
  if ([kind isEqualToString:MDCCollectionInfoBarKindHeader] ||
      [kind isEqualToString:MDCCollectionInfoBarKindFooter]) {
    NSString *identifier = NSStringFromClass([MDCCollectionInfoBarView class]);
    identifier = [identifier stringByAppendingFormat:@".%@", kind];
    [collectionView registerClass:[MDCCollectionInfoBarView class]
        forSupplementaryViewOfKind:kind
               withReuseIdentifier:identifier];

    UICollectionReusableView *supplementaryView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:identifier
                                                  forIndexPath:indexPath];

    // Update info bar.
    if ([supplementaryView isKindOfClass:[MDCCollectionInfoBarView class]]) {
      MDCCollectionInfoBarView *infoBar = (MDCCollectionInfoBarView *)supplementaryView;
      infoBar.delegate = self;
      infoBar.kind = kind;
      [self updateControllerWithInfoBar:infoBar];
    }
    return supplementaryView;
  }
  return nil;
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  if ([_styler.delegate respondsToSelector:
                            @selector(collectionView:hidesInkViewAtIndexPath:)]) {
    return ![_styler.delegate collectionView:self.collectionView
                     hidesInkViewAtIndexPath:indexPath];
  }
  return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
    didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  // Start cell ink show animation.
  MDCInkView *inkView = [self inkTouchController:_inkTouchController
                          inkViewAtTouchLocation:_inkTouchLocation];
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  CGPoint location = [self.collectionView convertPoint:_inkTouchLocation toView:cell];
  [inkView startTouchBeganAnimationAtPoint:location completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView
    didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  // Start cell ink evaporate animation.
  MDCInkView *inkView = [self inkTouchController:_inkTouchController
                          inkViewAtTouchLocation:_inkTouchLocation];
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  CGPoint location = [self.collectionView convertPoint:_inkTouchLocation toView:cell];
  [inkView startTouchEndedAnimationAtPoint:location completion:nil];
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (_editor.isEditing) {
    if ([self collectionView:collectionView canEditItemAtIndexPath:indexPath]) {
      return [self collectionView:collectionView canSelectItemDuringEditingAtIndexPath:indexPath];
    }
    return NO;
  }
  return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
  return collectionView.allowsMultipleSelection;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self updateFooterInfoBarIfNecessary];
}

- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self updateFooterInfoBarIfNecessary];
}

#pragma mark - <MDCCollectionViewEditingDelegate>

- (BOOL)collectionViewAllowsEditing:(UICollectionView *)collectionView {
  return NO;
}

- (void)collectionViewWillBeginEditing:(UICollectionView *)collectionView {
  // Inlay all items.
  _styler.allowsItemInlay = YES;
  _styler.allowsMultipleItemInlays = YES;
  [_styler applyInlayToAllItemsAnimated:YES];
  [self updateHeaderInfoBarIfNecessary];
}

- (void)collectionViewWillEndEditing:(UICollectionView *)collectionView {
  // Remove inlay of all items.
  [_styler removeInlayFromAllItemsAnimated:YES];
  [self updateFooterInfoBarIfNecessary];
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    canEditItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self collectionViewAllowsEditing:collectionView];
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    canSelectItemDuringEditingAtIndexPath:(NSIndexPath *)indexPath {
  if ([self collectionViewAllowsEditing:collectionView]) {
    return [self collectionView:collectionView canEditItemAtIndexPath:indexPath];
  }
  return NO;
}

#pragma mark - Item Moving

- (BOOL)collectionViewAllowsReordering:(UICollectionView *)collectionView {
  return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
  return ([self collectionViewAllowsEditing:collectionView] &&
          [self collectionViewAllowsReordering:collectionView]);
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    canMoveItemAtIndexPath:(NSIndexPath *)indexPath
               toIndexPath:(NSIndexPath *)newIndexPath {
  // First ensure both source and target items can be moved.
  return ([self collectionView:collectionView canMoveItemAtIndexPath:indexPath] &&
          [self collectionView:collectionView
              canMoveItemAtIndexPath:newIndexPath]);
}

- (void)collectionView:(UICollectionView *)collectionView
    didMoveItemAtIndexPath:(NSIndexPath *)indexPath
               toIndexPath:(NSIndexPath *)newIndexPath {
  [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

#pragma mark - Swipe-To-Dismiss-Items

- (BOOL)collectionViewAllowsSwipeToDismissItem:(UICollectionView *)collectionView {
  return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    canSwipeToDismissItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self collectionViewAllowsSwipeToDismissItem:collectionView];
}

- (void)collectionView:(UICollectionView *)collectionView
    didEndSwipeToDismissItemAtIndexPath:(NSIndexPath *)indexPath {
  [self deleteIndexPaths:@[ indexPath ]];
}

#pragma mark - Swipe-To-Dismiss-Sections

- (BOOL)collectionViewAllowsSwipeToDismissSection:(UICollectionView *)collectionView {
  return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
    canSwipeToDismissSection:(NSInteger)section {
  return [self collectionViewAllowsSwipeToDismissSection:collectionView];
}

- (void)collectionView:(UICollectionView *)collectionView
    didEndSwipeToDismissSection:(NSInteger)section {
  [self deleteSections:[NSIndexSet indexSetWithIndex:section]];
}

#pragma mark - Private

- (void)deleteIndexPaths:(NSArray *)indexPaths {
  if ([self respondsToSelector:@selector(collectionView:willDeleteItemsAtIndexPaths:)]) {
    void (^batchUpdates)() = ^{
      // Notify delegate to delete data.
      [self collectionView:self.collectionView willDeleteItemsAtIndexPaths:indexPaths];

      // Delete index paths.
      [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    };

    void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
      [self updateFooterInfoBarIfNecessary];
      // Notify delegate of deletion.
      if ([self respondsToSelector:@selector(collectionView:didDeleteItemsAtIndexPaths:)]) {
        [self collectionView:self.collectionView didDeleteItemsAtIndexPaths:indexPaths];
      }
    };

    // Animate deletion.
    [self.collectionView performBatchUpdates:batchUpdates completion:completionBlock];
  }
}

- (void)deleteSections:(NSIndexSet *)sections {
  if ([self respondsToSelector:@selector(collectionView:willDeleteSections:)]) {
    void (^batchUpdates)() = ^{
      // Notify delegate to delete data.
      [self collectionView:self.collectionView willDeleteSections:sections];

      // Delete sections.
      [self.collectionView deleteSections:sections];
    };

    void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
      [self updateFooterInfoBarIfNecessary];
      // Notify delegate of deletion.
      if ([self respondsToSelector:@selector(collectionView:didDeleteSections:)]) {
        [self collectionView:self.collectionView didDeleteSections:sections];
      }
    };

    // Animate deletion.
    [self.collectionView performBatchUpdates:batchUpdates completion:completionBlock];
  }
}

- (void)updateHeaderInfoBarIfNecessary {
  if (_editor.isEditing) {
    // Show HUD only once before autodissmissing.
    BOOL allowsSwipeToDismissItem = NO;
    if ([self respondsToSelector:@selector(collectionViewAllowsSwipeToDismissItem:)]) {
      allowsSwipeToDismissItem = [self collectionViewAllowsSwipeToDismissItem:self.collectionView];
    }

    if (!_headerInfoBar.isVisible && !_headerInfoBarDismissed && allowsSwipeToDismissItem) {
      [_headerInfoBar showAnimated:YES];
    } else {
      [_headerInfoBar dismissAnimated:YES];
    }
  }
}

- (void)updateFooterInfoBarIfNecessary {
  NSInteger selectedItemCount = [self.collectionView.indexPathsForSelectedItems count];
  if (_editor.isEditing) {
    // Invalidate layout to add info bar if necessary.
    [self.collectionView.collectionViewLayout invalidateLayout];
    if (_footerInfoBar) {
      if (selectedItemCount > 0 && !_footerInfoBar.isVisible) {
        [_footerInfoBar showAnimated:YES];
      } else if (selectedItemCount == 0 && _footerInfoBar.isVisible) {
        [_footerInfoBar dismissAnimated:YES];
      }
    }
  } else if (selectedItemCount == 0 && _footerInfoBar.isVisible) {
    [_footerInfoBar dismissAnimated:YES];
  }
}

- (void)updateContentWithBottomInset:(CGFloat)inset {
  // Update bottom inset to account for footer info bar.
  UIEdgeInsets contentInset = self.collectionView.contentInset;
  contentInset.bottom += inset;
  [UIView animateWithDuration:MDCCollectionInfoBarAnimationDuration
                   animations:^{
                     self.collectionView.contentInset = contentInset;
                   }];
}

@end
