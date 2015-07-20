#import "grooveTableViewController.h"

@interface grooveTableViewController ()

@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@property (nonatomic, strong) NSMutableArray *documentURLs;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@end

@implementation grooveTableViewController
//@synthesize grooveArray;

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {        
        // Custom initialization
        self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
        
        self.documentURLs = [NSMutableArray array];
        
        // scan for existing documents
        [self directoryDidChange:self.docWatcher];

    }
    return self;
}

- (void)viewDidLoad

{
    [super viewDidLoad];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
   // Return the number of rows in the section.
    
    return self.documentURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSURL *fileURL;
    //fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[indexPath.row] ofType:nil]];
    fileURL = [self.documentURLs objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = [[[fileURL path] lastPathComponent] stringByDeletingPathExtension];
    cell.textLabel.font = [UIFont fontWithName:@"Noteworthy-Bold" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor =[UIColor clearColor];
    cell.backgroundColor = [UIColor blackColor];
    
    NSString *fileURLString = [self.docInteractionController.URL path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error:nil];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize
                                                           countStyle:NSByteCountFormatterCountStyleFile];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", fileSizeStr, self.docInteractionController.UTI];
    
    [tableView setSeparatorColor:[UIColor whiteColor]];
    tableView.backgroundColor = [UIColor blackColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the URL
    NSURL *grooveURL;
    grooveURL = [self.documentURLs objectAtIndex:indexPath.row];
    NSString *FileName = [[[grooveURL path] lastPathComponent] stringByDeletingPathExtension];
    
    //Notify the delegate if it exists.
    if (_delegate != nil) {
        [_delegate selectedgroove:grooveURL withName:FileName];
    }
}

#pragma mark - File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	[self.documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
	{
        //NSLog(@"'%@'", [curFileName pathExtension]);
        if ([[curFileName pathExtension] isEqualToString:@"mp3"]) {
            NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
            
            if (!(isDirectory ))
            {
                [self.documentURLs addObject:fileURL];
            }
        }
	}
	
	[self.tableView reloadData];
}


@end
