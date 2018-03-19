//
//  XITimeSeriesStringChecker.m
//  common-iOS
//
//  Created by vfabian on 14/09/15.
//  Copyright (c) 2015 Xively All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSString+XISecureTopicName.h"

@interface XITimeSeriesStringChecker : XCTestCase

@end

@implementation XITimeSeriesStringChecker

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testXITimeSeriesStringChecker {
    NSString *originalString = @"dkjghdf:jhg?kjhg#kjhg[kjhg]kjhg@kjhg!kjhg$kjhg&kjhg'kjhg(jkhg)kjhg*kjhg+kjhg,jkgh;=skgdfh/gdflskhdf45363/45645=-0=-0=-0gkld/fhkdflghkj";
    NSString *secured = [originalString xiconvertTopicNameForUrl];
    
    XCTAssert([secured rangeOfString:@"/"].location != NSNotFound, @"/ left out");
    XCTAssert([secured rangeOfString:@":"].location == NSNotFound, @": left in");
    XCTAssert([secured rangeOfString:@"?"].location == NSNotFound, @"? left in");
    XCTAssert([secured rangeOfString:@"#"].location == NSNotFound, @"# left in");
    XCTAssert([secured rangeOfString:@"["].location == NSNotFound, @"[ left in");
    XCTAssert([secured rangeOfString:@"]"].location == NSNotFound, @"] left in");
    XCTAssert([secured rangeOfString:@"@"].location == NSNotFound, @"@ left in");
    XCTAssert([secured rangeOfString:@"!"].location == NSNotFound, @"! left in");
    XCTAssert([secured rangeOfString:@"$"].location == NSNotFound, @"$ left in");
    XCTAssert([secured rangeOfString:@"&"].location == NSNotFound, @"& left in");
    XCTAssert([secured rangeOfString:@"'"].location == NSNotFound, @"' left in");
    XCTAssert([secured rangeOfString:@"("].location == NSNotFound, @"( left in");
    XCTAssert([secured rangeOfString:@")"].location == NSNotFound, @") left in");
    XCTAssert([secured rangeOfString:@"+"].location == NSNotFound, @"+ left in");
    XCTAssert([secured rangeOfString:@","].location == NSNotFound, @", left in");
    XCTAssert([secured rangeOfString:@";"].location == NSNotFound, @"; left in");
    XCTAssert([secured rangeOfString:@"="].location == NSNotFound, @"= left in");
}



@end
