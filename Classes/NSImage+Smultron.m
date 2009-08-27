/*
Smultron version 3.5.1, 2009-01-26
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/smultron

Copyright 2004-2009 Peter Borg

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "NSImage+Smultron.h"
#import "SMLStandardHeader.h"
#import "SMLVariousPerformer.h"

@implementation NSImage (NSImageSmultron)

+ (NSArray *)iconsForPath:(NSString *)path
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *iconsArray;
	if ([[SMLDefaults valueForKey:@"UseQuickLookIcon"] boolValue] == YES) {
		iconsArray = [NSImage quickLookIconForPath:path];
		if (iconsArray != nil && [iconsArray count] > 0) {
			[pool drain];
			return iconsArray;
		}
	}
	NSImage *temporaryIcon = [[NSWorkspace sharedWorkspace] iconForFile:path];

	NSBitmapImageRep *imageRep = [[temporaryIcon representations] objectAtIndex:0];

	NSSize iconSize = NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
	NSImage *icon = [[NSImage alloc] initWithSize:iconSize];

	[icon addRepresentation:imageRep];
	
	[icon setSize:NSMakeSize(ICON_MAX_SIZE, ICON_MAX_SIZE)]; // This makes sure that unsavedIcon will not get "fuzzy"
	
	NSImage *unsavedIcon = [[NSImage alloc] initWithSize:iconSize];
	
	CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:imageRep];
	[unsavedIcon addRepresentation:[NSCIImageRep imageRepWithCIImage:[NSImage unsavedFilterForCIImage:ciImage]]];
	[unsavedIcon setSize:NSMakeSize(ICON_MAX_SIZE, ICON_MAX_SIZE)];
	[unsavedIcon setScalesWhenResized:YES];
	iconsArray = [NSArray arrayWithObjects:icon, unsavedIcon, nil];
	[pool drain];
	
	return iconsArray;
}


+ (NSArray *)quickLookIconForPath:(NSString *)path
{
	// Thanks to Matt Gemmel (http://mattgemmell.com/) for the basics of this code
	
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],(NSString *)kQLThumbnailOptionIconModeKey, nil];
    CGImageRef imageRef = QLThumbnailImageCreate(kCFAllocatorDefault, (CFURLRef)[NSURL fileURLWithPath:path], CGSizeMake(ICON_MAX_SIZE, ICON_MAX_SIZE), (CFDictionaryRef)options);
	NSMakeCollectable(imageRef);
    
	if (imageRef != NULL) {
		NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
		
		if (bitmapImageRep != nil) {

			NSSize iconSize = NSMakeSize([bitmapImageRep pixelsWide], [bitmapImageRep pixelsHigh]);
			NSImage *icon = [[NSImage alloc] initWithSize:iconSize];
			
			[icon addRepresentation:bitmapImageRep];
			NSImage *unsavedIcon = [[NSImage alloc] initWithSize:iconSize];
			CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmapImageRep];
			[unsavedIcon addRepresentation:[NSCIImageRep imageRepWithCIImage:[NSImage unsavedFilterForCIImage:ciImage]]];
			
			[icon setScalesWhenResized:YES];
			[unsavedIcon setScalesWhenResized:YES];
			
			return [NSArray arrayWithObjects:icon, unsavedIcon, nil];
		}
	}
	
    return nil;
}


+ (CIImage *)unsavedFilterForCIImage:(CIImage *)ciImage
{
	CIFilter *filter1 = [CIFilter filterWithName:@"CIColorControls"]; 
	[filter1 setDefaults]; 
	[filter1 setValue:ciImage forKey:@"inputImage"];  
	[filter1 setValue:[NSNumber numberWithFloat:-0.1] forKey:@"inputBrightness"];
	
	CIFilter *filter2 = [CIFilter filterWithName:@"CISepiaTone"]; 
	[filter2 setDefaults]; 
	[filter2 setValue:[filter1 valueForKey:@"outputImage"] forKey:@"inputImage"];  
	[filter2 setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
	
	return [filter2 valueForKey:@"outputImage"];
}


@end
