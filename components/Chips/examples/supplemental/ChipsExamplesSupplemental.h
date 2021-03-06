// Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.
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
#import "MaterialContainerScheme.h"

@class MDCChipView;
@class ChipModel;

@interface ExampleChipCollectionViewController : UICollectionViewController
@end

@interface ChipsChoiceExampleViewController
    : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSArray<NSString *> *titles;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsActionExampleViewController
    : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSArray<NSString *> *titles;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsCollectionExampleViewController
    : ExampleChipCollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSArray<NSString *> *titles;
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsCustomizedExampleViewController
    : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSArray<NSString *> *titles;
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsFilterExampleViewController
    : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) NSArray<NSString *> *titles;
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsFilterAnimatedExampleViewController
    : ChipsFilterExampleViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@end

@interface ChipsInputExampleViewController : UIViewController
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsSizingExampleViewController : UIViewController
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsTypicalUseViewController
    : ExampleChipCollectionViewController <UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSArray<ChipModel *> *model;
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end

@interface ChipsShapingExampleViewController : UIViewController
@property(nonatomic, strong) id<MDCContainerScheming> containerScheme;
@end
