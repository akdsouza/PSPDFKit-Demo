//
//  PSPDFPDFPageView.h
//  PSPDFKit
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PSPDFKitGlobal.h"

@class PSPDFScrollView, PSPDFTilingView, PSPDFDocument, PSPDFViewController;

/// Compound view for a single pdf page. Will not be re-used for different pages.
/// You can add your own views on top of the UIView (e.g. custom annotations)
@interface PSPDFPageView : UIView 

/// configure page container with data.
- (void)displayDocument:(PSPDFDocument *)document page:(NSUInteger)page pageRect:(CGRect)pageRect scale:(CGFloat)scale pdfController:(PSPDFViewController *)pdfController;

/// destroys and removes CATiledLayer. Call prior deallocating.
/// Don't set removeFromView to YES if destroy is *not* on the main thread.
- (void)destroyPageAndRemoveFromView:(BOOL)removeFromView callDelegate:(BOOL)callDelegate;

/// set background image to custom image. used in PSPDFTiledLayer.
- (void)setBackgroundImage:(UIImage *)image animated:(BOOL)animated;

/// Access parent PSPDFScrollView if available. (zoom controller)
/// Note: this only lets you access the scrollView if it's in the view hiararchy.
/// If we use pageCurl mode, we have a global scrollView which can be accessed with pdfController.pagingScrollView
- (PSPDFScrollView *)scrollView;

/// Access pdfController
@property(nonatomic, ps_weak, readonly) PSPDFViewController *pdfController;

/// Page that is displayed. Readonly.
@property(nonatomic, assign, readonly) NSUInteger page;

/// Document that is displayed. Readonly.
@property(nonatomic, strong, readonly) PSPDFDocument *document;

/// Calculated scale. Readonly.
@property(nonatomic, assign, readonly) CGFloat pdfScale;

/// CATiledLayer subview. Not visible while rotation. Readonly.
@property(nonatomic, strong, readonly) PSPDFTilingView *pdfView;

/// UIImageView subview. Beneath the PSPDFTilingView. Readonly.
@property(nonatomic, strong, readonly) UIImageView *backgroundImageView;

/// If YES, there is no thumbnail flickering if they are available in mem/disk.
/// This looks nicer, but is a bit slower as we decompress in main thread.
/// Defaults to NO. (behavior in PSPPDFKit < 1.8.2 was YES)
@property(nonatomic, assign) BOOL loadThumbnailsOnMainThread;

/// Enables shadow for a single page. Only useful in combination with pageCurl.
@property(nonatomic, assign, getter=isShadowEnabled) BOOL shadowEnabled;

/// Set default shadowOpacity. Defaults to 0.7.
@property(nonatomic, assign) float shadowOpacity;

/// Subclass to change shadow behavior.
- (void)updateShadow;

/// Set block that is executed within updateShadow when isShadowEnabled = YES.
@property(nonatomic, copy) void(^updateShadowBlock)(PSPDFPageView *pageView);

@end
