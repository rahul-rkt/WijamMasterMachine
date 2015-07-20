#import <UIKit/UIKit.h>
#import "PickViewController.h"
#import "grooveTableViewController.h"
#import "Communicator.h"

@interface MasterMachineViewController : UIViewController <PickerDelegate, NSNetServiceBrowserDelegate, MIDIPlaybackHandle, SelectedGrooveDelegate>

@end
