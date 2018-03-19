//
//  XICOFiniteStateMachine.m
//  common-iOS
//
//  Created by gszajko on 30/06/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import "XICOFiniteStateMachine.h"

@interface Transition : NSObject
@property (weak, nonatomic) id object;
@property (assign, nonatomic) SEL selector;
-(instancetype) initWithObject: (id) object select: (SEL) selector;
@end

@implementation Transition
-(instancetype) initWithObject: (id) object select: (SEL) selector {
    if ((self = [super init])) {
        _object = object;
        _selector = selector;
    }
    return self;
}
@end

@interface XICOFiniteStateMachine () {
    NSInteger _state;
}
@property (strong, nonatomic) NSMutableDictionary* transitions;
@end

@implementation XICOFiniteStateMachine
@synthesize state = _state;

-(instancetype) initWithInitialState: (NSInteger) initialState {
    if ((self = [super init])) {
        _state = initialState;
        _transitions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) addTransitionWithState: (NSInteger) state event: (NSInteger) event object: (id) object selector: (SEL) selector {
    
    NSMutableDictionary* events = [_transitions objectForKey: @(state)];
    if (events == nil) {
        
        events = [[NSMutableDictionary alloc] init];
        _transitions[@(state)] = events;
    }
    
    events[@(event)] = [[Transition alloc] initWithObject: object select: selector];
}

-(void) doEvent: (NSInteger) event {
    
    [self doEvent: event withObject: nil];
}

-(void) doEvent: (NSInteger) event withObject: (id) object {
    
    NSMutableDictionary* events = _transitions[@(_state)];
    if (events == nil) {
        return;
    }
    
    Transition* transition = events[@(event)];
    if (transition == nil) {
        return;
    }
    
    SEL selector = transition.selector;
    if (![transition.object respondsToSelector: selector]) {
        return;
    }
    
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: [[transition.object class] instanceMethodSignatureForSelector: selector]];
    [invocation setSelector: selector];
    [invocation setTarget: transition.object];
    [invocation setArgument: &object atIndex: 2];
    [invocation invoke];
    
    NSInteger returnValue = _state;
    [invocation getReturnValue: &returnValue];
    _state = returnValue;
}
@end
