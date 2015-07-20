#import <Foundation/Foundation.h>

@interface User : NSObject

@property (readonly) UInt8 userid;
@property (copy, readonly) NSString *userName;
@property (copy,nonatomic) NSString *instrument;
@property (copy, readonly) NSString *IP;
@property (nonatomic) float volume;
@property (readonly) UIButton *userButton;

-(id)initWithUserName:(NSString *)userName ID:(UInt8)uid IP:(NSString *)IP Instrument:(NSString *)Instr;

@end
