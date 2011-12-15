//
//  BaseViewerPluginProtocols.h
//  Base
//
//  Created by Ben Barnett on 03/07/2010.
//  Copyright 2010 Menial. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	@enum		Cell data type
	@abstract	Describes how data within a cell should be handled
	@constant	kBSDataTypeText		Textual or numeric data (text treated as UTF8)
	@constant	kBSDataTypeBlob		Any binary data
	@discussion	Internally, all cell contents are handled as NSData for convenience. However,
	viewer plugins need to be able to tell the app what how their data shoud be treated when
	stored in the database. Binary data will be inserted as a BLOB exactly as provided. 
	Textual data (including numeric data) will be inserted as TEXT/INTEGER/REAL etc.
*/
enum {
	kBSDataTypeText = 0,
	kBSDataTypeBlob = 1,
	kBSDataTypeCount = 2
};
typedef NSInteger BSCellDataType;



/*!
    @protocol	BaseViewerPlugin
    @abstract	The base methods required for a viewer plugin
    @discussion	The principal class of viewer plugins must conform to this protocol. All
	methods are required.
*/
@protocol BaseViewerPlugin <NSObject>
@required


/*!
	@method		displayName
	@abstract	A short name for this viewer to display in a menu
	@discussion	A name for this viewer, suitable for display in an NSMenuItem. 
	Examples could include: "Text", "Image", "Property List" etc
 */
- (NSString *)displayName;


/*!
	@method		view
	@abstract	The view for displaying the current cell data
	@discussion	This view will be inserted into the view hierarchy when the plugin
	is selected. It should be suitable for display at a range of sizes.
 */
- (NSView *)view;


/*!
	@method		setData:forCellInTable:column:withRowID:
	@abstract	Provides a viewer plugin with information about the currently viewed cell
	@param		data		An NSData ofbject of the cells current contents
	@param		tableName	The name of the table in which the cell exists
	@param		columnName	The name of the column in which the cell exists
	@param		rowid		A 64-bit integer of the ROWID for this cell
	@discussion	Each time a cell is to be viewed, the plugin will have this method called.
	Any state or display will need to be updated to reflect the new cell being viewed.
*/
- (void)setData:(NSData *)data forCellInTable:(NSString *)tableName column:(NSString *)columnName withRowID:(long long)rowid;


/*!
	@method		representedData
	@abstract	Returns the current data for the displayed cell
	@discussion	This method returns the cell data, including any changes made. The
	returned value will be inserted into the database (if different to the original).
	This method will only be called if hasChanges returns YES.
 */
- (NSData *)representedData;


/*!
	 @method	typeOfCurrentData
	 @abstract	Describes how the current data should be handled
	 @seealso	BSCellDataType
 */
- (BSCellDataType)typeOfCurrentData;


/*!
	@method		priorityForData:
	@abstract	Indicates whether a viewer recognises a given data object
	@param		data	The data object to inspect
	@return		On a scale of zero to one, how much the plugin wants this data
	@discussion	Several different viewers may be able to display the same data
	object (eg. An image can be shown as an image, hex data or a textual
	representation). A plugin can attempt to stake a greater claim to display
	of an object by returning a higher value here.
*/
- (CGFloat)priorityForData:(NSData *)data;


/*!
	@method		hasChanges
	@abstract	Indicates whether a viewer has had its data modified
	@return		YES if there the data has been changed, NO otherwise
	@discussion	A viewer will only be asked for its represented data if it returns
	YES from this method.
 */
- (BOOL)hasChanges;

@end

