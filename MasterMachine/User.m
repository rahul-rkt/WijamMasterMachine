#import "User.h"

@implementation User

-(id)initWithUserName:(NSString *)userName ID:(UInt8)uid IP:(NSString *)IP Instrument:(NSString *)Instr {
    self = [super init];
    if (self) {
        _userName = userName;
        _userid = uid;
        _IP = IP;
        _instrument = Instr;
    }
    return self;
}
    




@end
