//
//  PlistBaseViewerViewController.m
//  PlistBaseViewer
//
//  Created by Marc Liyanage on 12/6/11.
//

#import "PlistBaseViewerViewController.h"

@interface PlistBaseViewerViewController ()
@property (copy) NSString *plistText;
- (id)propertyListForData:(NSData *)data;
@end

@implementation PlistBaseViewerViewController

- (id)init
{
    return [self initWithNibName:@"PlistBaseViewer" bundle:[NSBundle bundleForClass:[self class]]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}


#pragma mark = Text view value bindings

@synthesize plistText;

- (NSFont *)textViewFont
{
	return [NSFont userFixedPitchFontOfSize:11];
}

#pragma mark - BaseViewerPlugin protocol

- (void)setData:(NSData *)data forCellInTable:(NSString *)tableName column:(NSString *)columnName withRowID:(long long)rowid
{
	id plist = [self propertyListForData:data];
	if (!plist) {
		self.plistText = NSLocalizedString(@"(Unable to decode as property list)", @"");
		return;
	}
	
	NSData *xmlPlistData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
	self.plistText = [[NSString alloc] initWithData:xmlPlistData encoding:NSUTF8StringEncoding];
}

- (CGFloat)priorityForData:(NSData *)data
{
	NSPropertyListFormat format = 0;
	BOOL didDecodePlist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:nil] != nil;
	didDecodePlist = didDecodePlist && (format == NSPropertyListXMLFormat_v1_0 || format == NSPropertyListBinaryFormat_v1_0);
	return didDecodePlist ? 1.0 : 0.0;
}

- (NSString *)displayName
{
	return NSLocalizedString(@"Property List", @"Menu item title");
}

- (NSData *)representedData
{
	return nil;
}

- (BSCellDataType)typeOfCurrentData
{
	return kBSDataTypeBlob;
}

- (BOOL)hasChanges
{
	return NO;
}


#pragma mark - Utilities

- (id)propertyListForData:(NSData *)data
{
	return [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:nil];
}


@end
