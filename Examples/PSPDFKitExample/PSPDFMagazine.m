//
//  PSPDFMagazine.m
//  PSPDFKitExample
//
//  Created by Peter Steinberger on 7/22/11.
//  Copyright 2011 Peter Steinberger. All rights reserved.
//

#import "PSPDFMagazine.h"
#import "PSPDFMagazineFolder.h"
#import <QuartzCore/CATiledLayer.h>

@implementation PSPDFMagazine

@synthesize folder = folder_;
@synthesize downloading = downloading_;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

+ (PSPDFMagazine *)magazineWithPath:(NSString *)path; {
    NSURL *url = path ? [NSURL fileURLWithPath:path] : nil;
    PSPDFMagazine *magazine = [[(PSPDFMagazine *)[[self class] alloc] initWithUrl:url] autorelease];
    return magazine;
}

- (id)init {
    if ((self = [super init])) {
        // most magazines can enable this to speed up display (aspect ration doesn't need to be recalculated)
        //aspectRatioEqual_ = YES;
    }
    return self;
}

- (void)dealloc {
    folder_ = nil;
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Meta Data

- (UIImage *)coverImage {
    UIImage *coverImage = [[PSPDFCache sharedPSPDFCache] cachedImageForDocument:self page:0 size:PSPDFSizeThumbnail];
    return coverImage;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocument

- (void)drawAnnotations:(NSArray *)annotations inContext:(CGContextRef)context pageInfo:(PSPDFPageInfo *)pageInfo pageRect:(CGRect)pageRect; {
    // only render if annotation parser is available
    if ([annotations count]) {
        float yellowComponents[4] = { 1, 1, 0.1, 1 };
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextSetStrokeColorSpace(context, rgbColorSpace);
        CGColorRef yellow = CGColorCreate(rgbColorSpace, yellowComponents);
        CGContextSetStrokeColorWithColor(context, yellow);
        
        for (PSPDFLinkAnnotation *linkAnnotation in annotations) {
            
            // keynote is creating weird double links; ignore the small "shadow" link
            if (linkAnnotation.pdfRectangle.size.height <= 5) {
                continue;
            }
            
            CGPoint pt1 = [PSPDFTilingView convertPDFPointToViewPoint:linkAnnotation.pdfRectangle.origin rect:pageInfo.pageRect rotation:pageInfo.pageRotation pageRect:pageRect];
            CGPoint pt2 = CGPointMake(linkAnnotation.pdfRectangle.origin.x + linkAnnotation.pdfRectangle.size.width, 
                                      linkAnnotation.pdfRectangle.origin.y + linkAnnotation.pdfRectangle.size.height);
            pt2 = [PSPDFTilingView convertPDFPointToViewPoint:pt2 rect:pageInfo.pageRect rotation:pageInfo.pageRotation pageRect:pageRect];
            
            CGRect linkRectangle = CGRectMake(pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y);
                        
            // add round rect path
            CGFloat radius = 5.f;                         
            CGFloat minx = CGRectGetMinX(linkRectangle), midx = CGRectGetMidX(linkRectangle), maxx = CGRectGetMaxX(linkRectangle); 
            CGFloat miny = CGRectGetMinY(linkRectangle), midy = CGRectGetMidY(linkRectangle), maxy = CGRectGetMaxY(linkRectangle); 
            CGContextMoveToPoint(context, minx, midy); 
            CGContextAddArcToPoint(context, minx, miny, midx, miny, radius); 
            CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius); 
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius); 
            CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius); 
            CGContextClosePath(context); 
            
            CGContextStrokePath(context);
        }
        
        CGColorRelease(yellow);
        CGColorSpaceRelease(rgbColorSpace);
    }
}

@end