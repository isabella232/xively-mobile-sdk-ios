//
//  XICOConnectionPoolDelegate.h
//  common-iOS
//
//  Created by gszajko on 22/07/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

@protocol XICOConnectionPooling;

@protocol XICOConnectionPoolDelegate <NSObject>
-(void) connectionPool: (id<XICOConnectionPooling>) connectionPool didCreateConnection: (id<XICOConnecting>) connection;
-(void) connectionPool: (id<XICOConnectionPooling>) connectionPool didFailToCreateConnection: (NSError*) error;
@end