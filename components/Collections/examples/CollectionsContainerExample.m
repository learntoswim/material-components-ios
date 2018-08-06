/*
 Copyright 2016-present the Material Components for iOS authors. All Rights Reserved.

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

#import "MaterialCollections.h"
#import "supplemental/CollectionsContainerExample.h"

#import "MaterialTypography.h"

static const CGFloat kCellVerticalEdgePadding = 16;
static const CGFloat kCellLeadingTextPadding = 16;

static const CGFloat kMaxCellHeight = 96;


static const NSInteger kSectionCount = 2;
static const NSInteger kSectionItemCount = 2;
static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

@implementation CollectionsContainerExample {
  MDCCollectionViewController *_collectionsController;
  NSMutableArray <NSMutableArray *>*_content;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  // Create gray view to contain collection view.
  UIView *container =
      [[UIView alloc] initWithFrame:CGRectMake(0, 97, self.view.bounds.size.width, self.view.bounds.size.height)];

  container.backgroundColor = [UIColor lightGrayColor];
  container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:container];

  // Create collection view controller.
  _collectionsController = [[MDCCollectionViewController alloc] init];
  _collectionsController.collectionView.dataSource = self;
  _collectionsController.collectionView.delegate = self;
  [container addSubview:_collectionsController.view];
  [_collectionsController.view setFrame:container.bounds];

  // Register cell class.
  [_collectionsController.collectionView registerClass:[MDCCollectionViewTextCell class]
                            forCellWithReuseIdentifier:kReusableIdentifierItem];

  // Populate content.
  _content = [NSMutableArray array];
  for (NSInteger i = 0; i < kSectionCount; i++) {
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger j = 0; j < kSectionItemCount; j++) {
      NSString *itemString = [NSString stringWithFormat:@"Section-%ld Item-%ld", (long)i, (long)j];
      [items addObject:itemString];
    }
    [_content addObject:items];
  }

  // Customize collection view settings.
  _collectionsController.styler.cellStyle = MDCCollectionViewCellStyleCard;
}

#pragma mark - <UICollectionViewDataSource>

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  
  if ([self heightForCell] > kMaxCellHeight) {
    NSLog(@"will truncate");
  }

  
  return CGSizeMake(_collectionsController.view.frame.size.width, MIN([self heightForCell], MDCCellDefaultThreeLineHeight));
}

- (CGFloat)heightForCell {
  CGFloat maxWidth = CGRectGetWidth(_collectionsController.collectionView.bounds) - kCellLeadingTextPadding * 2;
  CGFloat maxHeight = MDCCellDefaultThreeLineHeight;
  CGSize maxSize = CGSizeMake(maxWidth, maxHeight);
  
  CGFloat titleHeight = [self heightForLabel:@"Turn on Web & App Activity to start customizing"
                                    withFont:[MDCTypography titleFont]
                                 maximumSize:maxSize];
  CGFloat subtitleHeight = [self heightForLabel:@"To get updates just for you, like your commute, weather, sports, and more, turn on Web & App Activity in Settings"
                                       withFont:[MDCTypography subheadFont]
                                    maximumSize:maxSize];
  
  CGFloat extraPadding = kCellVerticalEdgePadding * 2;
  if (titleHeight > 0 && subtitleHeight > 0) {
    extraPadding = extraPadding + kCellVerticalEdgePadding;
  }
  
  return titleHeight + subtitleHeight + extraPadding;
}

- (CGFloat)heightForLabel:(NSString *)text withFont:(UIFont *)font maximumSize:(CGSize)size {
  if (text.length == 0) {
    return 0;
  }
  
  CGRect boundingRect = [text boundingRectWithSize:size
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : font}
                                           context:nil];
  return CGRectGetHeight(boundingRect);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return [_content count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 1;//[_content[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MDCCollectionViewTextCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                                forIndexPath:indexPath];
  cell.textLabel.text = @"Turn on Web & App Activity to start customizing";
  cell.textLabel.font = [MDCTypography titleFont];
  cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  cell.textLabel.numberOfLines = 0;
  cell.detailTextLabel.text = @"To get updates just for you, like your commute, weather, sports, and more, turn on Web & App Activity in Settings";
  cell.detailTextLabel.font = [MDCTypography subheadFont];
  cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  cell.detailTextLabel.numberOfLines = 0;
  cell.layer.borderColor = [UIColor blackColor].CGColor;
  cell.layer.borderWidth = 1;
  return cell;
}

#pragma mark - CatalogByConvention

+ (NSArray *)catalogBreadcrumbs {
  return @[ @"Collections", @"Collections in a Container" ];
}

+ (BOOL)catalogIsPrimaryDemo {
  return NO;
}

+ (BOOL)catalogIsPresentable {
  return NO;
}

@end
