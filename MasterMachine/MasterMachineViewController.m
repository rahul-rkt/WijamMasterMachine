#import "MasterMachineViewController.h"
#import "Definition.h"

#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"

#import "MIDINote.h"
#import "NoteNumDict.h"
#import "AssignmentTable.h"
#import "VirtualInstrument.h"

#import "User.h"

@interface MasterMachineViewController () {
    CGRect RectA;
    CGRect RectB;
    CGRect RectC;
    CGRect RectD;
    CGRect RectE;
    CGRect RectF;
    
    UInt8 score[7];
    UInt8 scanCounter;
    
    CGFloat VolumeMax, VolumeMin;
    
}

/* View controller elements */
@property (strong, nonatomic) IBOutlet UIImageView *VolumeA;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeB;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeC;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeD;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeE;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeF;

@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderA;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderB;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderC;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderD;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderE;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderF;

@property (strong, nonatomic) IBOutlet UILabel *LoopName;
@property (strong, nonatomic) IBOutlet UILabel *OverallScore;
@property (strong, nonatomic) IBOutlet UILabel *RootScale;

@property (strong, nonatomic) UIPopoverController *LoopPopOver;
@property (strong, nonatomic) UIPopoverController *OverallScorePopOver;
@property (strong, nonatomic) UIPopoverController *InstrumentPopOver;
@property (strong, nonatomic) grooveTableViewController *LoopPicker;
@property (strong, nonatomic) PickViewController *OverallScorePicker;
@property (strong, nonatomic) PickViewController *InstrumentPicker;
@property (strong, nonatomic) NSMutableArray *ScoreArray;
@property (strong, nonatomic) NSMutableArray *InstrumentArray;
@property (strong, nonatomic) NSDictionary *InstrumentNameToChannelNum;

@property (strong, nonatomic) IBOutlet UIButton *ScoreA;
@property (strong, nonatomic) IBOutlet UIButton *ScoreB;
@property (strong, nonatomic) IBOutlet UIButton *ScoreC;
@property (strong, nonatomic) IBOutlet UIButton *ScoreD;
@property (strong, nonatomic) IBOutlet UIButton *ScoreE;
@property (strong, nonatomic) IBOutlet UIButton *ScoreF;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentA;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentB;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentC;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentD;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentE;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentF;
@property (strong, nonatomic) IBOutlet UILabel *UserA;
@property (strong, nonatomic) IBOutlet UILabel *UserB;
@property (strong, nonatomic) IBOutlet UILabel *UserC;
@property (strong, nonatomic) IBOutlet UILabel *UserD;
@property (strong, nonatomic) IBOutlet UILabel *UserE;
@property (strong, nonatomic) IBOutlet UILabel *UserF;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldA;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldB;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldC;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldD;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldE;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldF;

/* Jamming Controls */
@property (assign) UInt8 RootNum;
@property (copy) NSString *Root;
@property (copy) NSString *Scale;
@property (assign) BOOL isJamming;

/* Network Service Related Declaraion */
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (strong, nonatomic) MIDINetworkSession *Session;
@property (nonatomic, retain) NSTimer * rescanTimer;
@property (strong, nonatomic) NSMutableSet *IPSet;

/* Big Circle button Labels */
@property (strong, nonatomic) IBOutlet UILabel *Host;
@property (strong, nonatomic) IBOutlet UILabel *Jam;

/* Communication Infrastructure */
@property (strong, nonatomic) Communicator *CMU;
@property (readwrite) MIDINote *Assignment;
@property (readonly) NoteNumDict *Dict;
@property (readonly) AssignmentTable *AST;

/* Virtual Instrument */
@property (readonly) VirtualInstrument *VI;

/* Backing Manager + Loop Player */
@property (readwrite) NSURL *currentTrackURL;
@property (readonly) AVAudioPlayer *audioPlayer;
@property (readwrite) BOOL isLoopPlaying;

/* Users related */
@property (readwrite) NSMutableArray *userArray;
@property (readonly) NSArray *userLabelArray;
@property (readonly) NSArray *userFieldArray;
@property (readwrite) NSMutableArray *playerChannels;
- (void) blinkPlayerAtID:(NSNumber *)ID;

@end

@implementation MasterMachineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configureNetworkSessionAndServiceBrowser];
    [self infrastructureSetup];
    self.rescanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanPlayers) userInfo:nil repeats:YES];
    scanCounter = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [super viewDidAppear:NO];
    [self viewSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup routines

- (void)viewSetup {
    RectA = RectMake(_VolumeSliderA);
    RectB = RectMake(_VolumeSliderB);
    RectC = RectMake(_VolumeSliderC);
    RectD = RectMake(_VolumeSliderD);
    RectE = RectMake(_VolumeSliderE);
    RectF = RectMake(_VolumeSliderF);
    VolumeMin = RectA.origin.y;
    VolumeMax = RectA.origin.y + RectA.size.height;
    _RootNum = Root_C;
    _Root = @"C";
    _Scale = @"IONIAN";
    [self ChangeRootandScale];
    
    if (_LoopPicker == nil) {
        _LoopPicker = [[grooveTableViewController alloc] initWithStyle:UITableViewStylePlain];
        _LoopPicker.delegate = self;
        _LoopPopOver = [[UIPopoverController alloc] initWithContentViewController:_LoopPicker];
        _LoopPopOver.popoverContentSize = CGSizeMake(300, 200);
    }
    
    if (_OverallScorePicker == nil) {
        _OverallScorePicker = [[PickViewController alloc] initWithStyle:UITableViewStylePlain];
        _OverallScorePicker.delegate = self;
        _ScoreArray = [NSMutableArray arrayWithObjects:@"100", @"95", @"90", @"85", @"80", @"75", @"70", nil];
        [_OverallScorePicker passArray:_ScoreArray];
        _OverallScorePopOver = [[UIPopoverController alloc] initWithContentViewController:_OverallScorePicker];
        _OverallScorePopOver.popoverContentSize = CGSizeMake(100, 200);
        _ScoreA.titleLabel.textAlignment = NSTextAlignmentCenter;
        _ScoreB.titleLabel.textAlignment = NSTextAlignmentCenter;
        _ScoreC.titleLabel.textAlignment = NSTextAlignmentCenter;
        _ScoreD.titleLabel.textAlignment = NSTextAlignmentCenter;
        _ScoreE.titleLabel.textAlignment = NSTextAlignmentCenter;
        _ScoreF.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (_InstrumentPicker == nil) {
        _InstrumentPicker = [[PickViewController alloc] initWithStyle:UITableViewStylePlain];
        _InstrumentPicker.delegate = self;
        _InstrumentArray = [NSMutableArray arrayWithObjects:@"Trombone", @"SteelGuitar", @"Guitar", @"Ensemble", @"Piano", @"Vibraphone", nil];
        [_InstrumentPicker passArray:_InstrumentArray];
        _InstrumentPopOver = [[UIPopoverController alloc] initWithContentViewController:_InstrumentPicker];
        _InstrumentPopOver.popoverContentSize = CGSizeMake(200, 200);
        _InstrumentA.titleLabel.textAlignment = NSTextAlignmentCenter;
        _InstrumentB.titleLabel.textAlignment = NSTextAlignmentCenter;
        _InstrumentC.titleLabel.textAlignment = NSTextAlignmentCenter;
        _InstrumentD.titleLabel.textAlignment = NSTextAlignmentCenter;
        _InstrumentE.titleLabel.textAlignment = NSTextAlignmentCenter;
        _InstrumentF.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
}

- (void)infrastructureSetup {
    if (_CMU == nil) {
        _CMU = [[Communicator alloc] init];
        [_CMU setPlaybackDelegate:self];
    }
    IF_IOS_HAS_COREMIDI(
        if (_CMU.midi == nil) {
            _CMU.midi = [[PGMidi alloc] init];
        }
    )
    if (_VI == nil) {
        _VI = [[VirtualInstrument alloc] init];
        [_VI setInstrument:@"Trombone" withInstrumentID:Trombone]; //This is the groove instrument
        [_VI setInstrument:@"SteelGuitar" withInstrumentID:SteelGuitar];
        [_VI setInstrument:@"Guitar" withInstrumentID:Guitar];
        [_VI setInstrument:@"Ensemble" withInstrumentID:Ensemble];
        [_VI setInstrument:@"Piano" withInstrumentID:Piano];
        [_VI setInstrument:@"Vibraphone" withInstrumentID:Vibraphone];
        
        if (_InstrumentNameToChannelNum == nil) {
            _InstrumentNameToChannelNum = @{
                                            @"Trombone":@1,
                                            @"SteelGuitar":@2,
                                            @"Guitar":@3,
                                            @"Ensemble":@4,
                                            @"Piano":@5,
                                            @"Vibraphone":@6
                                            };
        }
    }
    if (_Dict == nil) {
        _Dict = [[NoteNumDict alloc] init];
    }
    if (_AST == nil) {
        _AST = [[AssignmentTable alloc] init];
    }
    if (_AST) {
        _Assignment = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                               SysEx:[_AST.MusicAssignment objectForKey:@"Ionian"] Root:Root_C];
    }
    
    // Users Setup
    if (_userFieldArray == nil) {
        _userArray = [[NSMutableArray alloc] init];
        _userLabelArray = [NSArray arrayWithObjects:_UserA, _UserB, _UserC, _UserD, _UserE, _UserF, nil];
        _userFieldArray = [NSArray arrayWithObjects:_UserFieldA, _UserFieldB, _UserFieldC,_UserFieldD, _UserFieldE, _UserFieldF, nil];
        _playerChannels = [[NSMutableArray alloc] init];
        for (UIButton *userField in _userFieldArray) {
            userField.alpha = 0.3;
            [_playerChannels addObject:[NSNumber numberWithUnsignedChar:0]];
        }
        for (UInt8 i = 0; i < 7; i++) {
            score[i] = 60;
        }
    }
    
    // Backing Manager Setup
    _isLoopPlaying = false;
    _isJamming = false;
}

#pragma mark - PlayBack routine
-(void) MIDIPlayback:(const MIDIPacket *)packet {
    NSLog(@"PlaybackDelegate Called");
    if (packet->length == 3) {
        NSLog(@"Playback Notes");
        UInt8 noteTypeAndChannel;
        UInt8 noteNum;
        UInt8 Velocity;
        UInt8 noteType, noteChannel;
        noteTypeAndChannel = (packet->length > 0) ? packet->data[0] : 0;
        noteNum = (packet->length > 1) ? packet->data[1] : 0;
        Velocity = (packet->length >2) ? packet->data[2] : 0;
        noteType = noteTypeAndChannel & 0xF0;
        noteChannel = noteTypeAndChannel & 0x0F;
        NSLog(@"noteNum: %d, noteType: %x, noteChannel: %x", noteNum, noteType, noteChannel);
        
        MIDINote *Note = [[MIDINote alloc] initWithNote:noteNum duration:1 channel:noteChannel velocity:Velocity SysEx:0 Root:noteType];
        if (noteChannel <= 6 && _VI) {
            [_VI playMIDI:Note];
        }
    } else if (packet->length == 4) {
        NSLog(@"Blink the user field");
        NSNumber *ID = [NSNumber numberWithChar:packet->data[2]];
        [self performSelectorInBackground:@selector(blinkPlayerAtID:) withObject:ID];
    }
}

- (void) blinkPlayerAtID:(NSNumber *)ID {
    UInt8 playerID = [ID unsignedCharValue];
    if (playerID < 6) {
        NSLog(@"Blink player ID %d", playerID);
        UIButton *UserField = [_userFieldArray objectAtIndex:playerID];
        [UIView animateWithDuration:0.1 animations:^{UserField.alpha = 1;}];
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionTransitionCurlUp animations:^{UserField.alpha = 0.3;} completion:NO];
    }
}

- (IBAction)loopPlay:(id)sender {
    _isLoopPlaying = !_isLoopPlaying;
    if (_isLoopPlaying && _currentTrackURL != nil) {
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_currentTrackURL error:nil];
        _audioPlayer.volume = 0.5;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

#pragma mark - Volume Slider
static CGRect RectMake (UIImageView *ImageView) {
    return CGRectMake(ImageView.frame.origin.x - 20, ImageView.frame.origin.y + 30, ImageView.frame.size.width + 40, ImageView.frame.size.height - 50);
}

static void Slide (CGRect Rect, CGPoint currentPoint, UIImageView *ImageView) {
    if (CGRectContainsPoint(Rect, currentPoint)) {
        DSLog(@"pointInside");
        [ImageView setCenter:CGPointMake(ImageView.center.x, currentPoint.y)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    Slide(RectA, currentPoint, _VolumeA);
    Slide(RectB, currentPoint, _VolumeB);
    Slide(RectC, currentPoint, _VolumeC);
    Slide(RectD, currentPoint, _VolumeD);
    Slide(RectE, currentPoint, _VolumeE);
    Slide(RectF, currentPoint, _VolumeF);
    
    [self volumeChanged];
}

- (void)volumeChanged {
    float Volume[6];
    CGFloat centerY;
    centerY = _VolumeA.center.y;
    Volume[0] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeB.center.y;
    Volume[1] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeC.center.y;
    Volume[2] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeD.center.y;
    Volume[3] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeE.center.y;
    Volume[4] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeF.center.y;
    Volume[5] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    
    if (_VI) {
        for (UInt8 i = 0; i < 6; i++) {
            UInt8 Channel = [[_playerChannels objectAtIndex:i] unsignedCharValue];
            NSLog(@"idx %d", i);
            NSLog(@"Volume %f", 3*Volume[i]);
            NSLog(@"Channel %d", Channel);
            [_VI setMixerInput: Channel gain:(AudioUnitParameterValue)3*Volume[i]];
        }
    }
    
    UInt8 userIdx = 0;
    for (User *user in _userArray) {
        if (userIdx > 5)
            break;
        user.volume = Volume[userIdx];
        userIdx++;
    }
}

#pragma mark - Root and Scale Change

- (IBAction)RootChange:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    switch (tag) {
        case 0:
            _RootNum = Root_C;
            _Root = @"C";
            break;
        case 1:
            _RootNum = Root_CC;
            _Root = @"C#";
            break;
        case 2:
            _RootNum = Root_D;
            _Root = @"D";
            break;
        case 3:
            _RootNum = Root_DD;
            _Root = @"D#";
            break;
        case 4:
            _RootNum = Root_E;
            _Root = @"E";
            break;
        case 5:
            _RootNum = Root_F;
            _Root = @"F";
            break;
        case 6:
            _RootNum = Root_FF;
            _Root = @"F#";
            break;
        case 7:
            _RootNum = Root_G;
            _Root = @"G";
            break;
        case 8:
            _RootNum = Root_GG;
            _Root = @"G#";
            break;
        case 9:
            _RootNum = Root_A;
            _Root = @"A";
            break;
        case 10:
            _RootNum = Root_AA;
            _Root = @"A#";
            break;
        case 11:
            _RootNum = Root_B;
            _Root = @"B";
            break;
        default:
            break;
    }
}

- (IBAction)ScaleChange:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    switch (tag) {
        case 0:
            _Scale = @"IONIAN";
            break;
        case 1:
            _Scale = @"DORIAN";
            break;
        case 2:
            _Scale = @"PHRYGIAN";
            break;
        case 3:
            _Scale = @"LYDIAN";
            break;
        case 4:
            _Scale = @"MIXOLYDIAN";
            break;
        case 5:
            _Scale = @"AEOLIAN";
            break;
        case 6:
            _Scale = @"LOCRIAN";
            break;
        case 7:
            _Scale = @"BLUES";
            break;
        case 8:
            _Scale = @"PENTATONIC";
            break;
        case 9:
            _Scale = @"HARMONIC";
            break;

        default:
            break;
    }
    [self ChangeRootandScale];
    
    // commit the change only when scale change
    [self applyRootScaleChange];
}

- (void)applyRootScaleChange {
    if (_isJamming) {
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_Scale]];
        [_Assignment setRoot:_RootNum];
        [_CMU sendMidiData:_Assignment];
    }
}

- (void) ChangeRootandScale {
    _RootScale.text = [NSString stringWithFormat:@"Root: %@, Scale: %@", _Root, _Scale];
}


- (IBAction)Jam:(id)sender {
    _isJamming = !_isJamming;
    if (_isJamming) {
        _Jam.textColor = [UIColor grayColor];
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_Scale]];
        [_Assignment setRoot:_RootNum];
        [_CMU sendMidiData:_Assignment];
    } else {
        _Jam.textColor = [UIColor whiteColor];
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:@"NONE"]];
        [_Assignment setRoot:0];
        [_CMU sendMidiData:_Assignment];
        _InstrumentA.titleLabel.text = @"Instrument";
        _InstrumentB.titleLabel.text = @"Instrument";
        _InstrumentC.titleLabel.text = @"Instrument";
        _InstrumentD.titleLabel.text = @"Instrument";
        _InstrumentE.titleLabel.text = @"Instrument";
        _InstrumentF.titleLabel.text = @"Instrument";
        _ScoreA.titleLabel.text = @"Score";
        _ScoreB.titleLabel.text = @"Score";
        _ScoreC.titleLabel.text = @"Score";
        _ScoreD.titleLabel.text = @"Score";
        _ScoreE.titleLabel.text = @"Score";
        _ScoreF.titleLabel.text = @"Score";
        _Root = @"C";
        _Scale = @"IONIAN";
        [self ChangeRootandScale];
    }
    
}

#pragma mark - Loop, Score, Instrument Selector

- (IBAction)loopSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
    CGPoint origin = Selector.frame.origin;
    CGSize size = Selector.frame.size;
    CGRect rect = CGRectMake(origin.x + size.width/2, origin.y + size.height/2, 1, 1);
    
    [_LoopPopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)scoreSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
    if (Selector.tag < _userArray.count || Selector.tag == 6) {
        [_OverallScorePicker passAccLabel:Selector.accessibilityLabel];
        [_OverallScorePicker passTag:Selector.tag];
        CGPoint origin = Selector.frame.origin;
        CGSize size = Selector.frame.size;
        CGRect rect = CGRectMake(origin.x + size.width/2, origin.y + size.height/2, 1, 1);
        [_OverallScorePopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (IBAction)instrumentSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
    if (Selector.tag < _userArray.count) {
        [_InstrumentPicker passAccLabel:Selector.accessibilityLabel];
        [_InstrumentPicker passTag:Selector.tag];
        CGPoint origin = Selector.frame.origin;
        CGSize size = Selector.frame.size;
        CGRect rect = CGRectMake(origin.x + size.width/2, origin.y + size.height/2, 1, 1);
        [_InstrumentPopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(void) selectedgroove:(NSURL*)grooveURL withName:(NSString *)fileName{
    NSLog(@"file URL = %@", grooveURL);
    _LoopName.text = fileName;
    _currentTrackURL = grooveURL;
    [_LoopPopOver dismissPopoverAnimated:YES];
}

- (void)selected:(NSString*)selectedName withAccLabel:(NSString *)AccLabel withTag:(UInt8)Tag {
    if ([AccLabel isEqual: @"Score"]) {
        switch (Tag) {
            // Player Score
            case 0:
                _ScoreA.titleLabel.text = selectedName;
                break;
            case 1:
                _ScoreB.titleLabel.text = selectedName;
                break;
            case 2:
                _ScoreC.titleLabel.text = selectedName;
                break;
            case 3:
                _ScoreD.titleLabel.text = selectedName;
                break;
            case 4:
                _ScoreE.titleLabel.text = selectedName;
                break;
            case 5:
                _ScoreF.titleLabel.text = selectedName;
                break;
            
            // Overall Score
            case 6:
                _OverallScore.text = selectedName;
                break;
                
            default:
                break;
        }
        score[Tag] = [selectedName integerValue];
        [_OverallScorePopOver dismissPopoverAnimated:YES];
    }
    if ([AccLabel isEqual:@"Instrument"]) {
        switch (Tag) {
            case 0:
                _InstrumentA.titleLabel.text = selectedName;
                break;
            case 1:
                _InstrumentB.titleLabel.text = selectedName;
                break;
            case 2:
                _InstrumentC.titleLabel.text = selectedName;
                break;
            case 3:
                _InstrumentD.titleLabel.text = selectedName;
                break;
            case 4:
                _InstrumentE.titleLabel.text = selectedName;
                break;
            case 5:
                _InstrumentF.titleLabel.text = selectedName;
                break;
                
            default:
                break;
        }
        
#pragma mark - player Mapping Broadcast
        // Broadcast the Arr(as SysEx) and the ID(as Root) to let each player know its unique ID and its instrument
        // This is how master can differentiate players
        if (_userArray.count > Tag) {
            User *player = [_userArray objectAtIndex:Tag];
            NSNumber *Channel = [_InstrumentNameToChannelNum objectForKey:selectedName];
            [player setInstrument:selectedName];
            [_Assignment setSysEx:[player.IP componentsSeparatedByString:@"."]];
            [_Assignment setRoot:[Channel unsignedCharValue]];
            [_Assignment setID:player.userid];
            [_CMU sendMidiData:_Assignment];
            [_playerChannels replaceObjectAtIndex:Tag withObject:Channel];
            [self volumeChanged];
        }
        [_InstrumentPopOver dismissPopoverAnimated:YES];
    }
}

#pragma mark - score and other feedback
- (IBAction)Score:(id)sender {
    if (_isJamming) {
        UInt8 idx = 0;
        for (User *player in _userArray) {
            [_Assignment setSysEx:[player.IP componentsSeparatedByString:@"."]];
            
            // Here the Root is the player's score and the ID is the overall score
            [_Assignment setRoot:score[idx]];
            [_Assignment setID:score[6]];
            [_CMU sendMidiData:_Assignment];
            idx++;
        }
    }
}

- (IBAction)Cue:(id)sender {
    if (_isJamming) {
        UIButton *cue = (UIButton *)sender;
        User *player;
        if ([cue.accessibilityLabel isEqualToString:@"userAFeedBack"] && _userArray.count > 0)
            player = [_userArray objectAtIndex:0];
        else if ([cue.accessibilityLabel isEqualToString:@"userBFeedBack"] && _userArray.count > 1)
            player = [_userArray objectAtIndex:1];
        else if ([cue.accessibilityLabel isEqualToString:@"userCFeedBack"] && _userArray.count > 2)
            player = [_userArray objectAtIndex:2];
        else if ([cue.accessibilityLabel isEqualToString:@"userDFeedBack"] && _userArray.count > 3)
            player = [_userArray objectAtIndex:3];
        else if ([cue.accessibilityLabel isEqualToString:@"userEFeedBack"] && _userArray.count > 4)
            player = [_userArray objectAtIndex:4];
        else if ([cue.accessibilityLabel isEqualToString:@"userFFeedBack"] && _userArray.count > 5)
            player = [_userArray objectAtIndex:5];
        else
            NSLog(@"Player doesn't exist Yet!");
        if (player) {
            [_Assignment setSysEx:[player.IP componentsSeparatedByString:@"."]];
            // Here plus 50 to let the player get that this is for the performance cue.
            [_Assignment setRoot:(50+cue.tag)];
            [_CMU sendMidiData:_Assignment];
        }
    }
}


#pragma mark - network configuration
/****** Thanks for CX's participation in this part ******/
- (void) configureNetworkSessionAndServiceBrowser {
    // configure network session
    _Session = [MIDINetworkSession defaultSession];
    _Session.enabled = false;
    _Session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
    
    // configure service browser
    self.services = [[NSMutableArray alloc] init];
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    // starting scanning for services (won't stop until stop() is called)
    [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
    
    // Variable for device scanning
    _IPSet = [[NSMutableSet alloc] init];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"didFindService.... %@", service.name);
    DSLog(@"service name: %@", service.name);
    DSLog(@"service hostName: %@", service.hostName);
    DSLog(@"service accessLabel: %@", service.accessibilityLabel);
    [self.services addObject:service];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService.... %@", service.name);
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    if (connection) {
        [_Session removeConnection:connection]; // remove connection automatically no matter what
    }
    [self.services removeObject:service];
}

- (IBAction)Host:(id)sender {
    _Session.enabled = !_Session.enabled;
    if (_Session.enabled) {
        _Host.textColor = [UIColor grayColor];
    } else {
        // reset everything
        _Host.textColor = [UIColor whiteColor];
        // Clear the user arrays and labels
        [_userArray removeAllObjects];
        [_IPSet removeAllObjects];
        
        for (UILabel *Label in _userLabelArray) {
            Label.textColor = [UIColor whiteColor];
        }
        _InstrumentA.titleLabel.text = @"Instrument";
        _InstrumentB.titleLabel.text = @"Instrument";
        _InstrumentC.titleLabel.text = @"Instrument";
        _InstrumentD.titleLabel.text = @"Instrument";
        _InstrumentE.titleLabel.text = @"Instrument";
        _InstrumentF.titleLabel.text = @"Instrument";
        _ScoreA.titleLabel.text = @"Score";
        _ScoreB.titleLabel.text = @"Score";
        _ScoreC.titleLabel.text = @"Score";
        _ScoreD.titleLabel.text = @"Score";
        _ScoreE.titleLabel.text = @"Score";
        _ScoreF.titleLabel.text = @"Score";
        _OverallScore.text = @"Overall Score";
        _Root = @"C";
        _Scale = @"IONIAN";
        [self ChangeRootandScale];
    }
}

// Keep scanning incomming players all the time, let them join whenever possible
- (void)scanPlayers {
    
    // If is already jamming now, send the broadcast the assignment again to let the new comer know
    // wait a while for the player's opening the communication channel
    if (_isJamming && scanCounter++ == 4) {
        scanCounter = 0;
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_Scale]];
        [_Assignment setRoot:_RootNum];
        [_CMU sendMidiData:_Assignment];
    }
    
    DSLog(@"scanPlayers...");
    if (_Session.enabled) {
        for (MIDINetworkConnection *conn in _Session.connections) {
            NSString *playerName = conn.host.name;
            NSLog(@"Player name: %@", playerName);
            
            NSString *IP = conn.host.address;
            if (IP != nil) {
                if ([_IPSet containsObject:IP]) {
                    continue;
                } else {
                    // new users comming
                    [_IPSet addObject:IP];
                    NSLog(@"Player IP: %@", IP);
                    UInt8 ID = _userArray.count;
                    User *user = [[User alloc] initWithUserName:playerName ID:ID IP:IP Instrument:@"unknown"];
                    [_userArray addObject:user];
                    UILabel *userLabel = [_userLabelArray objectAtIndex:ID];
                    userLabel.textColor = [UIColor grayColor];
                    
                    // no more than 6 players is allowed for the moment!!
                    if (ID == 5) {
                        break;
                    }
                }
            }
        }
    }
    
    for (int i = 0 ; i < _userArray.count; i++) {
        User *u = [_userArray objectAtIndex:i];
        NSLog(@"userArray player %d, is with IP %@", i, u.IP);
    }
}


@end
