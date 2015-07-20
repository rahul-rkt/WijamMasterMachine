#import "MIDINote.h"
@interface MIDINote ()

@end

@implementation MIDINote

-(id)initWithNote:(UInt8)note duration:(UInt8)duration channel:(UInt8)channel
         velocity:(UInt8)velocity SysEx:(NSArray *)SysEx Root:(UInt8)Root ID:(UInt8)ID{
    self = [super init];
    if (self) {
        _note = note;
        _duration = duration;
        _channel = channel;
        _velocity = velocity;
        _SysEx = SysEx;
        _Root = Root;
        _ID = ID;
        return self;
    }
    return nil;
}

-(id)initWithNote:(UInt8)note duration:(UInt8)duration channel:(UInt8)channel
         velocity:(UInt8)velocity SysEx:(NSArray *)SysEx Root:(UInt8)Root{
    self = [super init];
    if (self) {
        _note = note;
        _duration = duration;
        _channel = channel;
        _velocity = velocity;
        _SysEx = SysEx;
        _Root = Root;
        return self;
    }
    return nil;
}

@end
