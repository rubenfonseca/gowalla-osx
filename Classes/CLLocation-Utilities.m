//
//  CLLocation+Aditions.m
//  Gowalla
//
//  Created by Ruben Fonseca on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CLLocation-Utilities.h"


@implementation CLLocation (Aditions)
- (NSDictionary *)betterCoordinates {
	NSMutableDictionary *res = [NSMutableDictionary dictionaryWithCapacity:2];
	[res setObject:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
	[res setObject:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];
	return res;
}
@end
