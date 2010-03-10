//
//  CLLocation+Aditions.h
//  Gowalla
//
//  Created by Ruben Fonseca on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CLLocation.h>

@interface CLLocation (Utilities)
	- (NSDictionary *) betterCoordinates;
@end
