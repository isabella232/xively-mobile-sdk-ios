//
//  XICOFiniteStateMachine.h
//  common-iOS
//
//  Created by gszajko on 30/06/15.
//  Copyright (c) 2015 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XICOFiniteStateMachine : NSObject
@property (nonatomic, readonly) NSInteger state;
-(instancetype) initWithInitialState: (NSInteger) initialState;
-(void) addTransitionWithState: (NSInteger) state event: (NSInteger) event object: (id) object selector: (SEL) selector;
-(void) doEvent: (NSInteger) event;
-(void) doEvent: (NSInteger) event withObject: (id) object;
@end
