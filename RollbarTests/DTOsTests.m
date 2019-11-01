//
//  DTOsTests.m
//  Rollbar
//
//  Created by Andrey Kornich on 2019-10-10.
//  Copyright © 2019 Rollbar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../Rollbar/DTOs/RollbarPayload.h"
#import "../Rollbar/DTOs/RollbarData.h"
#import "../Rollbar/DTOs/RollbarConfig.h"
#import "../Rollbar/DTOs/RollbarDestination.h"
#import "../Rollbar/DTOs/RollbarDeveloperOptions.h"
#import "../Rollbar/DTOs/RollbarProxy.h"
#import "../Rollbar/DTOs/RollbarScrubbingOptions.h"
#import "../Rollbar/DTOs/RollbarServer.h"
#import "../Rollbar/DTOs/RollbarPerson.h"
#import "../Rollbar/DTOs/RollbarModule.h"
#import "../Rollbar/DTOs/RollbarTelemetryOptions.h"
#import "../Rollbar/DTOs/RollbarLoggingOptions.h"
#import "../Rollbar/DTOs/CaptureIpType.h"
#import "../Rollbar/RollbarLevel.h"


@interface DTOsTests : XCTestCase

@end

@implementation DTOsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testBasicDTOInitializationWithJSONString {
    NSString *jsonString = @"{\"accessToken\":\"ACCESS_TOKEN\", \"data\":{\"environment\":\"ENV\"}}";
    NSString *jsonPayload = @"{\"accessToken\":\"ACCESS_TOKEN\"}";
    NSString *jsonData = @"{\"environment\":\"ENV\"}";

    RollbarPayload *payloadAtOnce = [[RollbarPayload alloc] initWithJSONString:jsonString];
    XCTAssertNotNil(payloadAtOnce,
                    @"Payload instance"
                    );
    XCTAssertTrue([payloadAtOnce.accessToken isEqualToString:@"ACCESS_TOKEN"],
                  @"Access token field [%@] of payload: %@.", payloadAtOnce.accessToken, [payloadAtOnce serializeToJSONString]
                  );
    XCTAssertNotNil(payloadAtOnce.data,
                    @"Data field of payload: %@.", [payloadAtOnce serializeToJSONString]
                    );
    XCTAssertTrue([payloadAtOnce.data.environment isEqualToString:@"ENV"],
                  @"Environment field [%@] of payload: %@.", payloadAtOnce.data.environment, [payloadAtOnce serializeToJSONString]
                  );

    RollbarPayload *payload = [[RollbarPayload alloc] initWithJSONString:jsonPayload];
    RollbarData *payloadData = [[RollbarData alloc] initWithJSONString:jsonData];
    payload.data = payloadData;
    XCTAssertTrue([[payloadAtOnce serializeToJSONString] isEqualToString:[payload serializeToJSONString]],
                  @"payloadAtOnce [%@] must match payload: [%@].",
                  [payloadAtOnce serializeToJSONString],
                  [payload serializeToJSONString]
                  );

    XCTAssertTrue(![payload hasSameDefinedPropertiesAs:payloadData],
                  @"RollbarPayload and RollbarData DTOs do not have same defined properties"
                  );
    XCTAssertTrue([payload hasSameDefinedPropertiesAs:payloadAtOnce],
                  @"Two RollbarPayload DTOs do not have same defined properties"
                  );
    
    XCTAssertTrue([payloadAtOnce isEqual:payload],
                  @"Two RollbarPayload DTOs are expected to be equal"
                  );

    payload.accessToken = @"SOME_OTHER_ONE";
    XCTAssertTrue(![payloadAtOnce isEqual:payload],
                  @"Two RollbarPayload DTOs are NOT expected to be equal"
                  );

    //id result = [payload getDefinedProperties];
}

- (void)testRollbarScrubbingOptionsDTO {
    RollbarScrubbingOptions *dto = [[RollbarScrubbingOptions alloc] initWithScrubFields:@[@"field1", @"field2"]];
    XCTAssertTrue(dto.enabled,
                  @"Enabled by default"
                  );
    XCTAssertTrue(dto.scrubFields.count == 2,
                  @"Has some scrub fields"
                  );
    XCTAssertTrue(dto.whitelistFields.count == 0,
                  @"Has NO whitelist fields"
                  );
    
    dto.whitelistFields = @[@"tf1", @"tf2", @"tf3"];
    XCTAssertTrue(dto.whitelistFields.count == 3,
                  @"Has some whitelist fields"
                  );
    
    dto.enabled = NO;
    XCTAssertTrue(!dto.enabled,
                  @"Expected to be disabled"
                  );
}

- (void)testRollbarServerDTO {
    RollbarServer *dto = [[RollbarServer alloc] initWithHost:@"HOST"
                                                        root:@"ROOT"
                                                      branch:@"BRANCH"
                                                 codeVersion:@"1.2.3"
                          ];
    XCTAssertTrue(NSOrderedSame == [dto.host compare:@"HOST"],
                  @"Proper host"
                  );
    XCTAssertTrue(NSOrderedSame == [dto.root compare:@"ROOT"],
                  @"Proper root"
                  );
    XCTAssertTrue(NSOrderedSame == [dto.branch compare:@"BRANCH"],
                  @"Proper branch"
                  );
    XCTAssertTrue(NSOrderedSame == [dto.codeVersion compare:@"1.2.3"],
                  @"Proper code version"
                  );

    dto.host = @"h1";
    XCTAssertTrue(NSOrderedSame == [dto.host compare:@"h1"],
                  @"Proper new host"
                  );
    dto.root = @"r1";
    XCTAssertTrue(NSOrderedSame == [dto.root compare:@"r1"],
                  @"Proper new root"
                  );
    dto.branch = @"b1";
    XCTAssertTrue(NSOrderedSame == [dto.branch compare:@"b1"],
                  @"Proper new branch"
                  );
    dto.codeVersion = @"3.2.5";
    XCTAssertTrue(NSOrderedSame == [dto.codeVersion compare:@"3.2.5"],
                  @"Proper new code version"
                  );
}

- (void)testRollbarPersonDTO {
    RollbarPerson *dto = [[RollbarPerson alloc] initWithID:@"ID"
                                                  username:@"USERNAME"
                                                     email:@"EMAIL"
                          ];
    XCTAssertTrue(NSOrderedSame == [dto.ID compare:@"ID"],
                  @"Proper ID"
                  );
    XCTAssertTrue(NSOrderedSame == [dto.username compare:@"USERNAME"],
                  @"Proper username"
                  );
    XCTAssertTrue(NSOrderedSame == [dto.email compare:@"EMAIL"],
                  @"Proper email"
                  );

    dto.ID = @"ID1";
    XCTAssertTrue(NSOrderedSame == [dto.ID compare:@"ID1"],
                  @"Proper ID"
                  );
    dto.username = @"USERNAME1";
    XCTAssertTrue(NSOrderedSame == [dto.username compare:@"USERNAME1"],
                  @"Proper username"
                  );
    dto.email = @"EMAIL1";
    XCTAssertTrue(NSOrderedSame == [dto.email compare:@"EMAIL1"],
                  @"Proper email"
                  );
    
    dto = [[RollbarPerson alloc] initWithID:@"ID007"];
    XCTAssertTrue(NSOrderedSame == [dto.ID compare:@"ID007"],
                  @"Proper ID"
                  );
    XCTAssertTrue([dto.username isEqualToString:@""],
                  @"Proper default username"
                  );
    XCTAssertTrue([dto.email isEqualToString:@""],
                  @"Proper default email"
                  );
}

- (void)testRollbarModuleDTO {
    RollbarModule *dto = [[RollbarModule alloc] initWithName:@"ModuleName"
                                                  version:@"v1.2.3"
                          ];
    XCTAssertTrue([dto.name isEqualToString:@"ModuleName"],
                  @"Proper name"
                  );
    XCTAssertTrue([dto.version isEqualToString:@"v1.2.3"],
                  @"Proper version"
                  );

    dto.name = @"MN1";
    XCTAssertTrue([dto.name isEqualToString:@"MN1"],
                  @"Proper name"
                  );
    dto.version = @"v3.2.1";
    XCTAssertTrue([dto.version isEqualToString:@"v3.2.1"],
                  @"Proper version"
                  );

    dto = [[RollbarModule alloc] initWithName:@"Module"];
    XCTAssertTrue([dto.name isEqualToString:@"Module"],
                  @"Proper name"
                  );
    XCTAssertTrue([dto.version isEqualToString:@""],
                  @"Proper version"
                  );
}

- (void)testRollbarTelemetryOptionsDTO {
    RollbarScrubbingOptions *scrubber =
    [[RollbarScrubbingOptions alloc] initWithEnabled:YES
                                         scrubFields:@[@"one", @"two"]
                                     whitelistFields:@[@"two", @"three", @"four"]
     ];
    RollbarTelemetryOptions *dto = [[RollbarTelemetryOptions alloc] initWithEnabled:YES
                                                                         captureLog:YES
                                                                captureConnectivity:YES
                                                                 viewInputsScrubber:scrubber
                                    ];
    XCTAssertTrue(dto.enabled,
                  @"Proper enabled"
                  );
    XCTAssertTrue(dto.captureLog,
                  @"Proper capture log"
                  );
    XCTAssertTrue(dto.captureConnectivity,
                  @"Proper capture connectivity"
                  );
    XCTAssertTrue(dto.viewInputsScrubber.enabled,
                  @"Proper view inputs scrubber enabled"
                  );
    XCTAssertTrue(dto.viewInputsScrubber.scrubFields.count == 2,
                  @"Proper view inputs scrubber scrub fields count"
                  );
    XCTAssertTrue(dto.viewInputsScrubber.whitelistFields.count == 3,
                  @"Proper view inputs scrubber white list fields count"
                  );
    
    dto = [[RollbarTelemetryOptions alloc] init];
    XCTAssertTrue(!dto.enabled,
                  @"Proper enabled"
                  );
    XCTAssertTrue(!dto.captureLog,
                  @"Proper capture log"
                  );
    XCTAssertTrue(!dto.captureConnectivity,
                  @"Proper capture connectivity"
                  );
    XCTAssertTrue(dto.viewInputsScrubber.enabled,
                  @"Proper view inputs scrubber enabled"
                  );
    XCTAssertTrue(dto.viewInputsScrubber.scrubFields.count == 0,
                  @"Proper view inputs scrubber scrub fields count"
                  );
    XCTAssertTrue(dto.viewInputsScrubber.whitelistFields.count == 0,
                  @"Proper view inputs scrubber white list fields count"
                  );

}

- (void)testRollbarLoggingOptionsDTO {
    RollbarLoggingOptions *dto = [[RollbarLoggingOptions alloc] initWithLogLevel:RollbarError
                                                                          crashLevel:RollbarInfo
                                                             maximumReportsPerMinute:45];
    dto.captureIp = CaptureIpAnonymize;
    dto.codeVersion = @"CODEVERSION";
    dto.framework = @"FRAMEWORK";
    dto.requestId = @"REQUESTID";
    
    XCTAssertTrue(dto.logLevel == RollbarError,
                  @"Proper log level"
                  );
    XCTAssertTrue(dto.crashLevel == RollbarInfo,
                  @"Proper crash level"
                  );
    XCTAssertTrue(dto.maximumReportsPerMinute == 45,
                  @"Proper max reports per minute"
                  );
    XCTAssertTrue(dto.captureIp == CaptureIpAnonymize,
                  @"Proper capture IP"
                  );
    XCTAssertTrue([dto.codeVersion isEqualToString:@"CODEVERSION"],
                  @"Proper code version"
                  );
    XCTAssertTrue([dto.framework isEqualToString:@"FRAMEWORK"],
                  @"Proper framework"
                  );
    XCTAssertTrue([dto.requestId isEqualToString:@"REQUESTID"],
                  @"Proper request ID"
                  );
    
    dto = [[RollbarLoggingOptions alloc] init];
    XCTAssertTrue(dto.logLevel == RollbarInfo,
                  @"Proper default log level"
                  );
    XCTAssertTrue(dto.crashLevel == RollbarError,
                  @"Proper default crash level"
                  );
    XCTAssertTrue(dto.maximumReportsPerMinute == 60,
                  @"Proper default max reports per minute"
                  );
    XCTAssertTrue(dto.captureIp == CaptureIpFull,
                  @"Proper default capture IP"
                  );
    XCTAssertTrue([dto.codeVersion isEqualToString:@""],
                  @"Proper default code version"
                  );
    XCTAssertTrue([dto.framework isEqualToString:@"macos"] || [dto.framework isEqualToString:@"ios"],
                  @"Proper default framework"
                  );
    XCTAssertTrue([dto.requestId isEqualToString:@""],
                  @"Proper request ID"
                  );
}


- (void)testRollbarConfigDTO {
    RollbarConfig *rc = [RollbarConfig new];
    //id destination = rc.destination;
    rc.destination.accessToken = @"ACCESSTOKEN";
    rc.destination.environment = @"ENVIRONMENT";
    rc.destination.endpoint = @"ENDPOINT";
    //rc.logLevel = RollbarDebug;
    
    [rc setPersonId:@"PERSONID" username:@"PERSONUSERNAME" email:@"PERSONEMAIL"];
    [rc setServerHost:@"SERVERHOST" root:@"SERVERROOT" branch:@"SERVERBRANCH" codeVersion:@"SERVERCODEVERSION"];
    [rc setNotifierName:@"NOTIFIERNAME" version:@"NOTIFIERVERSION"];
    
    RollbarConfig *rcClone = [[RollbarConfig alloc] initWithJSONString:[rc serializeToJSONString]];
    
//    id scrubList = rc.scrubFields;
//    id scrubListClone = rcClone.scrubFields;
    
    XCTAssertTrue([rc isEqual:rcClone],
                  @"Two DTOs are expected to be equal"
                  );
//    XCTAssertTrue([[rc serializeToJSONString] isEqualToString:[rcClone serializeToJSONString]],
//                  @"DTO [%@] must match DTO: [%@].",
//                  [rc serializeToJSONString],
//                  [rcClone serializeToJSONString]
//                  );

    rcClone.destination.accessToken = @"SOME_OTHER_ONE";
    XCTAssertTrue(![rc isEqual:rcClone],
                  @"Two DTOs are NOT expected to be equal"
                  );
//    XCTAssertTrue(![[rc serializeToJSONString] isEqualToString:[rcClone serializeToJSONString]],
//                  @"DTO [%@] must NOT match DTO: [%@].",
//                  [rc serializeToJSONString],
//                  [rcClone serializeToJSONString]
//                  );

    rcClone = [[RollbarConfig alloc] initWithJSONString:[rc serializeToJSONString]];
    rcClone.httpProxy.proxyUrl = @"SOME_OTHER_ONE";
    XCTAssertTrue(![rc isEqual:rcClone],
                  @"Two DTOs are NOT expected to be equal"
                  );
    XCTAssertTrue([rcClone isEqual:[[RollbarConfig alloc] initWithJSONString:[rcClone serializeToJSONString]]],
                  @"Two DTOs (clone and its clone) are expected to be equal"
                  );
}

@end