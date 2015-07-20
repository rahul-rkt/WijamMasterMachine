#import <UIKit/UIKit.h>

@protocol PickerDelegate <NSObject>
@required
-(void) selected:(NSString*)selectedName withAccLabel:(NSString *)AccLabel withTag:(UInt8)Tag;
@end

@interface PickViewController : UITableViewController

@property (nonatomic) UInt8 Tag;
@property (nonatomic) NSString *AccLabel;
@property (nonatomic, retain) NSMutableArray *Array;
@property (nonatomic, weak) id <PickerDelegate> delegate;

-(void)passArray:(NSMutableArray *) NamesArray;
-(void)passTag: (UInt8)Tag;
-(void)passAccLabel: (NSString *)AccLabel;


@end
