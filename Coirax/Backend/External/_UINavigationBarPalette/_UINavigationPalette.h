//
//  _UINavigationPalette.h
//  Watch The Throne
//
//  Created by Serena on 06/03/2023
//

#ifndef _UINavigationPalette_h
#define _UINavigationPalette_h
@import UIKit;

@protocol _UINavigationPalette

@property (retain, nonatomic) UIView *_backgroundView;
@property (nonatomic) BOOL _paletteOverridesPinningBar;
@property (readonly, nonatomic) UINavigationController *navController;
@property (readonly, nonatomic) NSUInteger boundaryEdge;
@property (nonatomic) BOOL pinned;
@property (nonatomic) BOOL pinningBarShadowWasHidden;
@property (nonatomic) BOOL pinningBarShadowIsHidden;
@property (nonatomic) BOOL paletteShadowIsHidden;
@property (nonatomic) BOOL visibleWhenPinningBarIsHidden;
@property (nonatomic) UIEdgeInsets preferredContentInsets;

-(BOOL)_paletteOverridesPinningBar;
-(BOOL)isAttached;
-(BOOL)isPinned;
-(BOOL)isVisibleWhenPinningBarIsHidden;
-(BOOL)paletteIsHidden;
-(BOOL)paletteShadowIsHidden;
-(BOOL)pinningBarShadowIsHidden;
-(BOOL)pinningBarShadowWasHidden;
-(NSUInteger)boundaryEdge;
-(id)_backgroundView;
-(id)navController;
-(struct UIEdgeInsets )preferredContentInsets;
-(void)_setBackgroundView:(id)arg0 ;
-(void)_setLeftConstraintConstant:(CGFloat)arg0 ;
-(void)_setPaletteOverridesPinningBar:(BOOL)arg0 ;
-(void)_setTopConstraintConstant:(CGFloat)arg0 ;
-(void)setFrame:(struct CGRect )arg0 isAnimating:(BOOL)arg1 ;
-(void)setPaletteShadowIsHidden:(BOOL)arg0 ;
-(void)setPinned:(BOOL)arg0 ;
-(void)setPinningBarShadowIsHidden:(BOOL)arg0 ;
-(void)setPinningBarShadowWasHidden:(BOOL)arg0 ;
-(void)setPreferredContentInsets:(struct UIEdgeInsets )arg0 ;
-(void)setVisibleWhenPinningBarIsHidden:(BOOL)arg0 ;

@end

#endif /* _UINavigationPalette_h */
