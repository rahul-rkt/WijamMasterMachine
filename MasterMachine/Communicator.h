#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@class PGMidi;
@class MIDINote;


@protocol MIDIPlaybackHandle <NSObject>

- (void) MIDIPlayback: (const MIDIPacket *)packet;

@end

@protocol MIDIAssignmentHandle <NSObject>

- (void) MIDIAssignment: (const MIDIPacket *)packet;

@end

@interface Communicator : NSObject

@property (nonatomic,strong) PGMidi *midi;
@property (nonatomic,strong) id<MIDIPlaybackHandle> PlaybackDelegate;
@property (nonatomic,strong) id<MIDIAssignmentHandle> AssignmentDelegate;

- (void) sendMidiData:(MIDINote*)midinote;

@end

