#import <UIKit/UIKit.h>

#import "DirectoryWatcher.h"

@protocol SelectedGrooveDelegate <NSObject>
@required

-(void) selectedgroove:(NSURL*)grooveURL withName:(NSString *)fileName;

@end

@interface grooveTableViewController : UITableViewController <DirectoryWatcherDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id <SelectedGrooveDelegate> delegate;

@end
