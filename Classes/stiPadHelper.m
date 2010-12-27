//
//  stiPadHelper.m
//  SapusTongue-iOS
//
//  Created by Ricardo Quesada on 11/18/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//

#import <Availability.h>
#import "stiPadHelper.h"


NSString* stConverToiPadOniPad(NSString* filename)
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		NSString *extension = [filename pathExtension];
		NSString *pathWithExt = [filename stringByDeletingPathExtension];
		
		return [NSString stringWithFormat:@"%@-ipad.%@", pathWithExt, extension];
	}
	else
		return filename;

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	return filename;
#endif
}