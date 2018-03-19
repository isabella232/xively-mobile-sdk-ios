//
//  XILastWill.m
//  common-iOS
//
//  Created by gszajko on 26/10/15.
//  Copyright © 2015 Xively All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XILastWill.h"

@implementation XILastWill
-(instancetype) initWithChannel: (NSString*) channel message: (NSData*) message qos: (XIMessagingQoS) qos retain: (BOOL)retain {
    
    if ((self = [super init])) {
        assert(channel);
        assert(message);
        _channel = channel;
        _message = message;
        _qos = qos;
        _retained = retain;
    }
    
    return self;
}

-(BOOL) isEqualToLastWill: (XILastWill*) lastWill {
    
    return  [self.channel isEqualToString: lastWill.channel] &&
            [self.message isEqualToData: lastWill.message] &&
            self.qos == lastWill.qos &&
            self.retained == lastWill.retained;
}
@end