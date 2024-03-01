//
//  _UINavigationBarPalette.h
//  Marseille
//
//  Created by Serena on 06/01/2023
//
	

#ifndef _UINavigationBarPalette_h
#define _UINavigationBarPalette_h
#include "_UInavigationPalette.h"

@interface _UINavigationBarPalette : UIView <_UINavigationPalette>

@property (retain, nonatomic) UIView *_backgroundView;
@property (nonatomic) NSUInteger _contentViewMarginType; // ivar: __contentViewMarginType
@property (nonatomic) BOOL _displaysWhenSearchActive; // ivar: __displaysWhenSearchActive
@property (nonatomic) NSInteger _layoutPriority; // ivar: __layoutPriority
@property (nonatomic) BOOL _paletteOverridesPinningBar;
@property (readonly, nonatomic) NSUInteger boundaryEdge;
@property (readonly, nonatomic) UIView *contentView; // ivar: _contentView
@property (readonly, copy) NSString *debugDescription;
@property (readonly, copy) NSString *description;
@property (nonatomic) BOOL didSetMinimumHeight; // ivar: _didSetMinimumHeight
@property (readonly) NSUInteger hash;
@property (nonatomic) CGFloat minimumHeight; // ivar: _minimumHeight
@property (readonly, nonatomic) UINavigationController *navController;
@property (weak, nonatomic) UINavigationItem *owningNavigationItem; // ivar: _owningNavigationItem
@property (nonatomic) BOOL paletteShadowIsHidden;
@property (nonatomic) BOOL pinned; // ivar: _pinned
@property (nonatomic) BOOL pinningBarShadowIsHidden;
@property (nonatomic) BOOL pinningBarShadowWasHidden;
@property (nonatomic) UIEdgeInsets preferredContentInsets;
@property (nonatomic) CGFloat preferredHeight; // ivar: _preferredHeight
@property (readonly) Class superclass;
@property (retain, nonatomic) UIView *temporaryBackgroundView; // ivar: _temporaryBackgroundView
@property (nonatomic) BOOL transitioning; // ivar: _transitioning
@property (nonatomic) BOOL visibleWhenPinningBarIsHidden;

+(id)defaultContentViewWithFrame:(struct CGRect)arg0 ;
-(BOOL)_displaysWhenSearchActive;
-(BOOL)_paletteOverridesPinningBar;
-(BOOL)_shouldUpdateBackground;
-(BOOL)didSetMinimumHeight;
-(BOOL)isAttached;
-(BOOL)paletteIsHidden;
-(BOOL)paletteShadowIsHidden;
-(BOOL)pinningBarShadowIsHidden;
-(BOOL)pinningBarShadowWasHidden;
-(BOOL)transitioning;
-(id)_attachedPinningTopBar;
-(instancetype _Nonnull)initWithContentView:(UIView *)arg0 ;
-(void)_configureConstraintsForBackground:(id)arg0 ;
-(void)_configurePaletteConstraintsForBoundary;
-(void)_disableConstraints;
-(void)_enableConstraints;
-(void)_resetConstraintConstants:(CGFloat)arg0 ;
-(void)_resetHeightConstraintConstant;
-(void)_setAttached:(BOOL)arg0 didComplete:(BOOL)arg1 ;
-(void)_setBackgroundView:(id)arg0 ;
-(void)_setContentViewMarginType:(NSUInteger)arg0 ;
-(void)_setDisplaysWhenSearchActive:(BOOL)arg0 ;
-(void)_setLayoutPriority:(NSInteger)arg0 ;
-(void)_setLeftConstraintConstant:(CGFloat)arg0 ;
-(void)_setPaletteOverridesPinningBar:(BOOL)arg0 ;
-(void)_setSize:(struct CGSize )arg0 ;
-(void)_setTopConstraintConstant:(CGFloat)arg0 ;
-(void)_setupBackgroundViewIfNecessary;
-(void)_updateBackgroundConstraintsIfNecessary;
-(void)_updateBackgroundView;
-(void)addSubview:(id)arg0 ;
-(void)layoutSubviews;
-(void)resetBackgroundConstraints;
-(void)setFrame:(struct CGRect )arg0 isAnimating:(BOOL)arg1 ;

@end

@interface UINavigationItem ()
@property (retain, nonatomic, setter=_setBottomPalette:) _UINavigationBarPalette *_bottomPalette;
-(void)_setBottomPaletteNeedsUpdate:(id)arg0;
@end

@interface UIView ()
-(instancetype _Nonnull) initWithSize: (CGSize)arg1;
@end

#endif /* _UINavigationBarPalette_h */
