#import "AssignmentTable.h"

// Given a scale name and a key, returns an eight-notes assignment
@implementation AssignmentTable

NSArray *Ionian;
NSArray *Dorian;
NSArray *Phrygian;
NSArray *Lydian;
NSArray *Mixolydian;
NSArray *Aeolian;
NSArray *Locrian;
NSArray *Pentatonic;
NSArray *Blues;
NSArray *Harmonic;
NSArray *None;

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    //FIXME: whether should I use up to 6 or 5? Whether should I let users change octaves in simple mode?
    Ionian = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"E5", @"F5", @"G5", @"A5", @"B5", @"C6", nil];
    Dorian = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"D#5", @"F5", @"G5", @"A5", @"A#5", @"C6", nil];
    Phrygian = [[NSArray alloc] initWithObjects:@"C5", @"C#5", @"D#5", @"F5", @"G5", @"G#5", @"A#5", @"C6", nil];
    Lydian = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"E5", @"F#5", @"G5", @"A5", @"B5", @"C6", nil];
    Mixolydian = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"E5", @"F5", @"G5", @"A5", @"A#5", @"C6", nil];
    Aeolian = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"D#5", @"F5", @"G5", @"G#5", @"A#5", @"C6", nil];
    Locrian = [[NSArray alloc] initWithObjects:@"C5", @"C#5", @"D#5", @"F5", @"F#5", @"G#5", @"A#5", @"C6", nil];
    Pentatonic = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"E5", @"G5", @"A5", @"C6", @"D6", @"E6", nil];
    Blues = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"D#5", @"E5", @"G5", @"G#5", @"A5", @"C6", nil];
    Harmonic = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"D#5", @"F5", @"G5", @"G#5", @"B5", @"C6", nil];
    None = [[NSArray alloc] initWithObjects:@"C0", nil];
    
    _MusicAssignment = @{
                         @"IONIAN": Ionian,
                         @"DORIAN":Dorian,
                         @"PHRYGIAN":Phrygian,
                         @"LYDIAN":Lydian,
                         @"MIXOLYDIAN":Mixolydian,
                         @"AEOLIAN":Aeolian,
                         @"LOCRIAN":Locrian,
                         @"PENTATONIC":Pentatonic,
                         @"BLUES":Blues,
                         @"HARMONIC":Harmonic,
                         @"NONE":None,
              };
    return self;
}

@end
