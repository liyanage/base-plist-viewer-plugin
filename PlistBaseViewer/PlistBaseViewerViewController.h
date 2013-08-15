//
//  PlistBaseViewerViewController.h
//  PlistBaseViewer
//
//  Created by Marc Liyanage on 12/6/11.
//

#import <Cocoa/Cocoa.h>
#import "BaseViewerPluginProtocols.h"

@interface PlistBaseViewerViewController : NSViewController <BaseViewerPlugin>

@property (strong) IBOutlet NSTextView *textView;

@end
