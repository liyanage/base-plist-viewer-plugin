//
//  PlistBaseViewerViewController.m
//  PlistBaseViewer
//
//  Created by Marc Liyanage on 12/6/11.
//

#import "PlistBaseViewerViewController.h"
#import <Python/Python.h>

@interface PlistBaseViewerViewController ()
@property (copy) NSString *plistText;
- (id)propertyListForData:(NSData *)data;
@end

@implementation PlistBaseViewerViewController

+ (void)initialize
{
	if ([self class] == [PlistBaseViewerViewController class]) {
		Py_Initialize();
		NSURL *scriptURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"keyedarchive" withExtension:@"py"];
		NSURL *resourcesURL = [scriptURL URLByDeletingLastPathComponent];
		
		PyObject *currentPath = PySys_GetObject("path");
		NSArray *pathItems = [self stringArrayForPyObject:currentPath];
		NSString *newPath = [NSString stringWithFormat:@"%@:%s", [pathItems componentsJoinedByString:@":"], [resourcesURL fileSystemRepresentation]];
		
		PySys_SetPath((char *)[newPath UTF8String]);
	}
}

- (id)init
{
    return [self initWithNibName:@"PlistBaseViewer" bundle:[NSBundle bundleForClass:[self class]]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)awakeFromNib
{
	// Disable wrapping, http://stackoverflow.com/questions/3174140/how-to-disable-word-wrap-of-nstextview/18245578#18245578
	NSSize layoutSize = [self.textView maxSize];
	layoutSize.width = layoutSize.height;
	[self.textView setMaxSize:layoutSize];
	[[self.textView textContainer] setWidthTracksTextView:NO];
	[[self.textView textContainer] setContainerSize:layoutSize];
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
	PyObject *mainModule = NULL, *globalsDictionary = NULL;
    mainModule = PyImport_AddModule("__main__");
    if (!mainModule) {
        return;
	}
    globalsDictionary = PyModule_GetDict(mainModule);
	PyObject *locals = PyDict_New();
	PyObject *dataValue = PyString_FromStringAndSize([data bytes], [data length]);
	if (!dataValue) {
		Py_CLEAR(locals);
		return;
	}
	PyDict_SetItemString(locals, "archive_data", dataValue);
	Py_CLEAR(dataValue);
	
	NSString *scriptString = @"import keyedarchive\narchive, output_error = keyedarchive.KeyedArchive.archive_from_bytes(archive_data)\noutput_dump = archive.dump_string()\n";

	PyObject *result = PyRun_String([scriptString UTF8String], Py_file_input, globalsDictionary, locals);
	if (!result) {
		if (PyErr_Occurred()) {
			PyErr_Print();
		}
		Py_CLEAR(locals);
		return;
	}
	Py_CLEAR(result);
	
	PyObject *output = PyDict_GetItemString(locals, "output_dump");
	if (!output) {
		Py_CLEAR(locals);
		return;
	}
	
	NSString *stringResult = [[self class] stringForPyObject:output];
	Py_CLEAR(locals);
	self.plistText = stringResult;
}


+ (NSString *)stringForPyObject:(PyObject *)object
{
	PyObject *strObject = PyObject_Str(object);
	if (!strObject) {
		return nil;
	}

	const char *objectString = NULL;
	Py_ssize_t objectStringLength = 0;
	NSString *resultString = nil;

	if (!PyObject_AsCharBuffer(strObject, &objectString, &objectStringLength)) {
		resultString = [[NSString alloc] initWithBytes:objectString length:objectStringLength encoding:NSUTF8StringEncoding];
	}
	
	Py_CLEAR(strObject);

	return resultString;
}


+ (NSArray *)stringArrayForPyObject:(PyObject *)object
{
	if (!PyList_Check(object)) {
		return nil;
	}
	
	NSMutableArray *result = [NSMutableArray array];
	Py_ssize_t size = PyList_Size(object);
	
	for (NSInteger i = 0; i < size; i++) {
		NSString *itemString = nil;
		PyObject *item = PyList_GetItem(object, i);
		itemString = [self stringForPyObject:item];
		if (itemString) {
			[result addObject:itemString];
		}
	}
	
	return result;
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
