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

#import "MDCButton.h"

#import "MaterialInk.h"
#import "MaterialShadowElevations.h"
#import "MaterialShadowLayer.h"
#import "MaterialTypography.h"
#import "Private/MDCButton+Subclassing.h"

// TODO(ajsecord): Animate title color when animating between enabled/disabled states.
// Non-trivial: http://corecocoa.wordpress.com/2011/10/04/animatable-text-color-of-uilabel/

static NSString *const MDCButtonEnabledBackgroundColorKey = @"MDCButtonEnabledBackgroundColorKey";
static NSString *const MDCButtonDisabledBackgroundColorLightKey =
    @"MDCButtonDisabledBackgroundColorLightKey";
static NSString *const MDCButtonDisabledBackgroundColorDarkKey =
    @"MDCButtonDisabledBackgroundColorDarkKey";
static NSString *const MDCButtonInkViewInkColorKey = @"MDCButtonInkViewInkColorKey";
static NSString *const MDCButtonShouldRaiseOnTouchKey = @"MDCButtonShouldRaiseOnTouchKey";
static NSString *const MDCButtonUppercaseTitleKey = @"MDCButtonUppercaseTitleKey";
static NSString *const MDCButtonUnderlyingColorKey = @"MDCButtonUnderlyingColorKey";
static NSString *const MDCButtonUserElevationsKey = @"MDCButtonUserElevationsKey";

// MDCButtonUserZIndicesKey provides backward compatibility with old z-index shadows values.
// TODO: Remove from MDC, it is only useful for internal clients.
static NSString *const MDCButtonUserZIndicesKey = @"MDCButtonUserZIndicesKey";

static const NSTimeInterval MDCButtonAnimationDuration = 0.2;

// http://www.google.com/design/spec/components/buttons.html#buttons-main-buttons
static const CGFloat MDCButtonDisabledAlpha = 0.1f;
static const uint32_t MDCButtonDefaultBackgroundColor = 0x2196F3;

// Checks whether the provided floating point number is exactly zero.
static inline BOOL MDCButtonFloatIsExactlyZero(CGFloat value) {
  return (value == 0.f);
}

// Creates a UIColor from a 24-bit RGB color encoded as an integer.
static inline UIColor *MDCColorFromRGB(uint32_t rgbValue) {
  return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                         green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0
                          blue:((float)((rgbValue & 0x0000FF) >> 0)) / 255.0
                         alpha:1.0];
}

@interface MDCButton () {
  NSMutableDictionary *_userElevations;    // For each UIControlState.
  NSMutableDictionary *_backgroundColors;  // For each UIControlState.

  // Cached accessibility settings.
  NSMutableDictionary *_accessibilityLabelForState;
  NSString *_accessibilityLabelExplicitValue;
}
@property(nonatomic, strong) MDCInkView *inkView;
@end

@implementation MDCButton

+ (Class)layerClass {
  return [MDCShadowLayer class];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  _disabledAlpha = MDCButtonDisabledAlpha;
  _shouldRaiseOnTouch = YES;
  _uppercaseTitle = YES;
  _userElevations = [NSMutableDictionary dictionary];
  _backgroundColors = [NSMutableDictionary dictionary];
  _accessibilityLabelForState = [NSMutableDictionary dictionary];

  [self setElevation:MDCShadowElevationNone forState:UIControlStateDisabled];

  // Disable default highlight state.
  self.adjustsImageWhenHighlighted = NO;
  self.showsTouchWhenHighlighted = NO;

  // Set up title label attributes.
  self.titleLabel.font = [MDCTypography buttonFont];
  [self updateTitleColor];
  [self updateDisabledTitleColor];

  // Default content insets
  self.contentEdgeInsets = [self defaultContentEdgeInsets];

  self.layer.shadowPath = [self boundingPath].CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;

  // Set up ink layer.
  _inkView = [[MDCInkView alloc] initWithFrame:self.bounds];

  _inkView.maxRippleRadius = 0;
  [self insertSubview:_inkView belowSubview:self.imageView];

  // UIButton has a drag enter/exit boundary that is outside of the frame of the button itself.
  // Because this is not exposed externally, we can't use -touchesMoved: to calculate when to
  // change ink state. So instead we fall back on adding target/actions for these specific events.
  [self addTarget:self
                action:@selector(touchDragEnter:forEvent:)
      forControlEvents:UIControlEventTouchDragEnter];
  [self addTarget:self
                action:@selector(touchDragExit:forEvent:)
      forControlEvents:UIControlEventTouchDragExit];

  // Block users from activating multiple buttons simultaneously by default.
  self.exclusiveTouch = YES;

  // Default background colors.
  [self setBackgroundColor:MDCColorFromRGB(MDCButtonDefaultBackgroundColor)
                  forState:UIControlStateNormal];

  self.inkColor = [UIColor colorWithWhite:1 alpha:CGColorGetAlpha(self.inkView.inkColor.CGColor)];
}

- (void)dealloc {
  [self removeTarget:self
                action:@selector(touchDragEnter:forEvent:)
      forControlEvents:UIControlEventTouchDragEnter];
  [self removeTarget:self
                action:@selector(touchDragExit:forEvent:)
      forControlEvents:UIControlEventTouchDragExit];
}

- (void)setCustomTitleColor:(UIColor *)customTitleColor {
  _customTitleColor = customTitleColor;
  [self updateTitleColor];
}

- (void)setUnderlyingColor:(UIColor *)underlyingColor {
  _underlyingColor = underlyingColor;
  [self updateTitleColor];
  [self updateDisabledTitleColor];
  [self updateAlphaAndBackgroundColorAnimated:NO];
}

- (void)setDisabledAlpha:(CGFloat)disabledAlpha {
  _disabledAlpha = disabledAlpha;
  [self updateAlphaAndBackgroundColorAnimated:NO];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];

    // TODO(randallli): Add backward compatibility to background colors
    //    if ([aDecoder containsValueForKey:MDCButtonEnabledBackgroundColorKey]) {
    //      self.enabledBackgroundColor =
    //          [aDecoder decodeObjectForKey:MDCButtonEnabledBackgroundColorKey];
    //    }
    //    if ([aDecoder containsValueForKey:MDCButtonDisabledBackgroundColorLightKey]) {
    //      self.disabledBackgroundColorLight =
    //          [aDecoder decodeObjectForKey:MDCButtonDisabledBackgroundColorLightKey];
    //    }
    //    if ([aDecoder containsValueForKey:MDCButtonDisabledBackgroundColorDarkKey]) {
    //      self.disabledBackgroundColorDark =
    //          [aDecoder decodeObjectForKey:MDCButtonDisabledBackgroundColorDarkKey];
    //    }
    if ([aDecoder containsValueForKey:MDCButtonInkViewInkColorKey]) {
      self.inkView.inkColor = [aDecoder decodeObjectForKey:MDCButtonInkViewInkColorKey];
    }

    if ([aDecoder containsValueForKey:MDCButtonShouldRaiseOnTouchKey]) {
      self.shouldRaiseOnTouch = [aDecoder decodeBoolForKey:MDCButtonShouldRaiseOnTouchKey];
    }
    if ([aDecoder containsValueForKey:MDCButtonUppercaseTitleKey]) {
      self.uppercaseTitle = [aDecoder decodeBoolForKey:MDCButtonUppercaseTitleKey];
    }
    if ([aDecoder containsValueForKey:MDCButtonUnderlyingColorKey]) {
      self.underlyingColor = [aDecoder decodeObjectForKey:MDCButtonUnderlyingColorKey];
    }

    if ([aDecoder containsValueForKey:MDCButtonUserElevationsKey]) {
      _userElevations = [aDecoder decodeObjectForKey:MDCButtonUserElevationsKey];
    }
    // For backward compatibility
    if ([aDecoder containsValueForKey:MDCButtonUserZIndicesKey]) {
      NSMutableDictionary *userZIndices = [aDecoder decodeObjectForKey:MDCButtonUserZIndicesKey];
      NSArray *userZIndicesStates = [userZIndices allKeys];
      for (NSNumber *stateNum in userZIndicesStates) {
        NSNumber *zIndex = userZIndices[stateNum];
        CGFloat elevation = (float)pow(2.f, [zIndex floatValue]);
        [_userElevations setObject:@(elevation) forKey:stateNum];
      }
    }
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];

  if (_inkView.inkColor) {
    [aCoder encodeObject:_inkView.inkColor forKey:MDCButtonInkViewInkColorKey];
  }

  [aCoder encodeBool:_shouldRaiseOnTouch forKey:MDCButtonShouldRaiseOnTouchKey];
  [aCoder encodeBool:_uppercaseTitle forKey:MDCButtonUppercaseTitleKey];
  if (_underlyingColor) {
    [aCoder encodeObject:_underlyingColor forKey:MDCButtonUnderlyingColorKey];
  }
  [aCoder encodeObject:_userElevations forKey:MDCButtonUserElevationsKey];
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  self.layer.shadowPath = [self boundingPath].CGPath;
  self.layer.cornerRadius = [self cornerRadius];

  // Calculate center based on contentEdgeInsets
  _inkView.usesCustomInkCenter = YES;
  CGRect contentRect = [self contentRectForBounds:self.bounds];
  _inkView.customInkCenter = CGPointMake(CGRectGetMidX(contentRect), CGRectGetMidY(contentRect));
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, _hitAreaInsets), point);
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];

  [self handleBeginTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];

  // Drag events handled by -touchDragExit:forEvent: and -touchDragEnter:forEvent:
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  CGPoint location = [self locationFromTouches:touches];

  BOOL inside = CGRectContainsPoint(self.bounds, location);
  if (inside) {
    [_inkView evaporateWithCompletion:nil];
    if (_shouldRaiseOnTouch) {
      [self moveButtonToHeightForState:UIControlStateNormal];
    }
  } else {
    [self evaporateInkToPoint:location];
  }
}

// Note - in some cases, event may be nil (e.g. view removed from window).
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];

  [self evaporateInkToPoint:[self locationFromTouches:touches]];
}

#pragma mark - UIButton methods

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  [super setBackgroundColor:backgroundColor];
  [self updateTitleColor];
}

- (void)setEnabled:(BOOL)enabled {
  [self setEnabled:enabled animated:NO];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated {
  [super setEnabled:enabled];
  [self updateAlphaAndBackgroundColorAnimated:animated];
}

#pragma mark - Title Uppercasing

- (void)setUppercaseTitle:(BOOL)uppercaseTitle {
  _uppercaseTitle = uppercaseTitle;
  if (_uppercaseTitle) {
    // This ensures existing titles will get upper cased
    UIControlState allControlStates =
        (UIControlStateHighlighted | UIControlStateDisabled | UIControlStateSelected);
    for (UIControlState state = 0; state < allControlStates; ++state) {
      NSString *title = [self titleForState:state];
      if (title) {
        [self setTitle:title forState:state];
      }
    }
  }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
  // Intercept any setting of the title and store a copy in case the accessibilityLabel
  // is requested and the original non-uppercased version needs to be returned.
  if ([title length]) {
    _accessibilityLabelForState[@(state)] = [title copy];
  } else {
    [_accessibilityLabelForState removeObjectForKey:@(state)];
  }

  if (_uppercaseTitle) {
    title = [title uppercaseStringWithLocale:[NSLocale currentLocale]];
  }
  [super setTitle:title forState:state];
}

- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state {
  // Intercept any setting of the title and store a copy in case the accessibilityLabel
  // is requested and the original non-uppercased version needs to be returned.
  if ([title length]) {
    _accessibilityLabelForState[@(state)] = [[title string] copy];
  } else {
    [_accessibilityLabelForState removeObjectForKey:@(state)];
  }

  if (_uppercaseTitle) {
    // Store the attributes.
    NSMutableArray *attributes = [NSMutableArray array];
    [title enumerateAttributesInRange:NSMakeRange(0, [title length])
                              options:0
                           usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                             [attributes addObject:@{
                               @"attrs" : attrs,
                               @"range" : [NSValue valueWithRange:range]
                             }];
                           }];

    // Make the title text uppercase.
    NSString *uppercaseTitle = [[title string] uppercaseStringWithLocale:[NSLocale currentLocale]];

    // Apply the text and attributes to a mutable copy of the title attributed string.
    NSMutableAttributedString *mutableTitle = [title mutableCopy];
    [mutableTitle replaceCharactersInRange:NSMakeRange(0, [title length])
                                withString:uppercaseTitle];
    for (NSDictionary *attribute in attributes) {
      [mutableTitle setAttributes:attribute[@"attrs"] range:[attribute[@"range"] rangeValue]];
    }

    title = [mutableTitle copy];
  }
  [super setAttributedTitle:title forState:state];
}

#pragma mark - Accessibility

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
  // Intercept any explicit setting of the accessibilityLabel so it can be returned
  // later before the accessibiilityLabel is inferred from the setTitle:forState:
  // argument values.
  _accessibilityLabelExplicitValue = [accessibilityLabel copy];
  [super setAccessibilityLabel:accessibilityLabel];
}

- (NSString *)accessibilityLabel {
  if (!_uppercaseTitle) {
    return [super accessibilityLabel];
  }

  NSString *label = _accessibilityLabelExplicitValue;
  if ([label length]) {
    return label;
  }

  label = _accessibilityLabelForState[@(self.state)];
  if ([label length]) {
    return label;
  }

  label = _accessibilityLabelForState[@(UIControlStateNormal)];
  if ([label length]) {
    return label;
  }

  label = [super accessibilityLabel];
  if ([label length]) {
    return label;
  }

  return nil;
}

- (UIAccessibilityTraits)accessibilityTraits {
  return [super accessibilityTraits] | UIAccessibilityTraitButton;
}

#pragma mark - Ink

- (UIColor *)inkColor {
  return _inkView.inkColor;
}

- (void)setInkColor:(UIColor *)inkColor {
  _inkView.inkColor = inkColor;
}

#pragma mark - Shadows

- (MDCShadowLayer *)shadowLayer {
  return (MDCShadowLayer *)self.layer;
}

- (void)moveButtonToHeightForState:(UIControlState)state {
  [CATransaction begin];
  [CATransaction setAnimationDuration:MDCButtonAnimationDuration];
  [self shadowLayer].elevation = [self elevationForState:state];
  [CATransaction commit];
}

#pragma mark - BackgroundColor

- (UIColor *)backgroundColorForState:(UIControlState)state {
  return _backgroundColors[@(state)];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
  _backgroundColors[@(state)] = backgroundColor;
}

#pragma mark - Elevations

- (CGFloat)elevationForState:(UIControlState)state {
  NSNumber *elevation = _userElevations[@(state)];

  if (elevation) {
    return [elevation floatValue];
  }
  if (state & UIControlStateSelected) {
    CGFloat elevationForNormal = [self elevationForState:UIControlStateNormal];
    // TODO(ajsecord): Why is this using the raised button values for all buttons?
    // This should just be a factor of 2, I believe.
    if (MDCButtonFloatIsExactlyZero(elevationForNormal)) {
      return MDCShadowElevationRaisedButtonPressed;
    } else {
      CGFloat pressedDeltaForRaisedButton = MDCShadowElevationRaisedButtonPressed -
                                            MDCShadowElevationRaisedButtonResting;
      return elevationForNormal + pressedDeltaForRaisedButton;
    }
  } else {
    return MDCShadowElevationNone;
  }
}

- (void)setElevation:(CGFloat)elevation forState:(UIControlState)state {
  _userElevations[@(state)] = @(elevation);
  [self shadowLayer].elevation = [self elevationForState:self.state];

  // The elevation of the normal state controls whether this button is flat or not, and flat buttons
  // have different background color requirements than raised buttons.
  if (state == UIControlStateNormal) {
    [self updateAlphaAndBackgroundColorAnimated:NO];
    [self updateTitleColor];
    [self updateDisabledTitleColor];
  }
}

- (void)resetElevationForState:(UIControlState)state {
  [_userElevations removeObjectForKey:@(state)];
  [self shadowLayer].elevation = [self elevationForState:self.state];
}

#pragma mark - Private methods

- (UIColor *)currentBackgroundColor {
  UIColor *color = _backgroundColors[@(self.state)];
  if (color) {
    return color;
  }
  return [self backgroundColorForState:UIControlStateNormal];
}

/**
 * The background color that a user would see for this button. If self.backgroundColor is not
 * transparent, then returns that. Otherwise, returns self.underlyingColor.
 * @note If self.underlyingColor is not set, then this method will return nil.
 */
- (UIColor *)effectiveBackgroundColor {
  return ![self isTransparentColor:self.currentBackgroundColor] ? self.currentBackgroundColor : self.underlyingColor;
}

/** Returns YES if the color is not transparent and is a "dark" color. */
- (BOOL)isDarkColor:(UIColor *)color {
  // TODO: have a components/private/ColorCalculations/MDCColorCalculations.h|m
  //  return ![self isTransparentColor:color] && [QTMColorGroup luminanceOfColor:color] < 0.5f;
  return ![self isTransparentColor:color];
}

/** Returns YES if the color is transparent (including a nil color). */
- (BOOL)isTransparentColor:(UIColor *)color {
  return !color || [color isEqual:[UIColor clearColor]] || CGColorGetAlpha(color.CGColor) == 0.0f;
}

- (void)touchDragEnter:(MDCButton *)button forEvent:(UIEvent *)event {
  [self handleBeginTouches:event.allTouches];
}

- (void)touchDragExit:(MDCButton *)button forEvent:(UIEvent *)event {
  CGPoint location = [self locationFromTouches:event.allTouches];
  [self evaporateInkToPoint:location];
}

- (void)handleBeginTouches:(NSSet *)touches {
  [_inkView spreadFromPoint:[self locationFromTouches:touches] completion:nil];
  if (_shouldRaiseOnTouch) {
    [self moveButtonToHeightForState:UIControlStateSelected];
  }
}

- (CGPoint)locationFromTouches:(NSSet *)touches {
  UITouch *touch = [touches anyObject];
  return [touch locationInView:self];
}

- (void)evaporateInkToPoint:(CGPoint)toPoint {
  [_inkView evaporateToPoint:toPoint completion:nil];
  if (_shouldRaiseOnTouch) {
    [self moveButtonToHeightForState:UIControlStateNormal];
  }
}

- (UIBezierPath *)boundingPath {
  return [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
}

- (CGFloat)cornerRadius {
  return 2.0f;
}

- (UIEdgeInsets)defaultContentEdgeInsets {
  return UIEdgeInsetsMake(8, 16, 8, 16);
}

- (BOOL)shouldHaveOpaqueBackground {
  BOOL isFlatButton = MDCButtonFloatIsExactlyZero([self elevationForState:UIControlStateNormal]);
  return !isFlatButton;
}

- (void)updateAlphaAndBackgroundColorAnimated:(BOOL)animated {
  void (^animations)() = ^{
    self.alpha = self.enabled ? 1.0f : _disabledAlpha;
    [self updateBackgroundColor];
  };

  if (animated) {
    [UIView animateWithDuration:MDCButtonAnimationDuration animations:animations];
  } else {
    animations();
  }
}

- (void)updateBackgroundColor {
  //  UIColor *color = nil;
  //  if ([self shouldHaveOpaqueBackground]) {
  //    if (self.enabled) {
  ////      color = self.enabledBackgroundColor;
  //    } else {
  //      color = [self isDarkColor:_underlyingColor] ? _disabledBackgroundColorLight
  //                                                  : _disabledBackgroundColorDark;
  //    }
  //  }
  self.backgroundColor = self.currentBackgroundColor;
}

- (void)updateDisabledTitleColor {
  // Disabled buttons have very low opacity, so we full-opacity text color here to make the text
  // readable. Also, even for non-flat buttons with opaque backgrounds, the correct background color
  // to examine is the underlying color, since disabled buttons are so transparent.
  BOOL darkBackground = [self isDarkColor:[self underlyingColor]];
  [self setTitleColor:darkBackground ? [UIColor whiteColor] : [UIColor blackColor]
             forState:UIControlStateDisabled];
}

- (void)updateTitleColor {
  if (_customTitleColor) {
    [self setTitleColor:_customTitleColor forState:UIControlStateNormal];
    return;
  }

  if (![self isTransparentColor:[self effectiveBackgroundColor]]) {
    //    QTMColorGroupTextOptions options = 0;
    //    if ([MDCTypography isLargeForContrastRatios:self.titleLabel.font]) {
    //      options = kQTMColorGroupTextLargeFont;
    //    }
    //    UIColor *color = [QTMColorGroup textColorOnColor:[self effectiveBackgroundColor]
    //                                           textAlpha:[MDCTypography buttonFontOpacity]
    //                                             options:options];
    //    [self setTitleColor:color forState:UIControlStateNormal];
  }
}

@end
