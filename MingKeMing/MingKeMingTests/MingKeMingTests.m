//
//  MingKeMingTests.m
//  MingKeMingTests
//
//  Created by Albert Moky on 2018/12/19.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <MingKeMing/MingKeMing.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMImmortals.h"

@interface MingKeMingTests : XCTestCase

@end

@implementation MingKeMingTests

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

- (void)testHash {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    NSData *hash;
    NSString *res;
    NSString *exp;
    
    
    // sha256（moky）= cb98b739dd699aa44bb6ebba128d20f2d1e10bb3b4aa5ff4e79295b47e9ed76d
    exp = @"cb98b739dd699aa44bb6ebba128d20f2d1e10bb3b4aa5ff4e79295b47e9ed76d";
    hash = [data sha256];
    res = [hash hexEncode];
    NSLog(@"sha256(%@) = %@", string, res);
    NSAssert([res isEqual:exp], @"sha256 error: %@ != %@", res, exp);
    
    
    // ripemd160(moky) = 44bd174123aee452c6ec23a6ab7153fa30fa3b91
    exp = @"44bd174123aee452c6ec23a6ab7153fa30fa3b91";
    hash = [data ripemd160];
    res = [hash hexEncode];
    NSLog(@"ripemd160(%@) = %@", string, res);
    NSAssert([res isEqual:exp], @"ripemd160 error: %@ != %@", res, exp);
    
}

- (void)testSymmetric {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    MKMSymmetricKey *key;
    
    NSData *CT;
    NSData *dec;
    
    NSString *keyInfo = @"{\"algorithm\": \"AES\", \"data\": \"C2+xGizLL1G1+z9QLPYNdp/bPP/seDvNw45SXPAvQqk=\", \"iv\": \"SxPwi6u4+ZLXLdAFJezvSQ==\"}";
    
    // 1
    key = [[MKMSymmetricKey alloc] initWithJSONString:keyInfo];
    CT = [key encrypt:data];
    dec = [key decrypt:CT];
    NSLog(@"key: %@", key);
    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    NSAssert([dec isEqual:data], @"en/decrypt error");
    
    string = @"XX5qfromb3R078VVK7LwVA==";
    CT = [string base64Decode];
    dec = [key decrypt:CT];
    NSLog(@"%@ -> %@", string, [dec UTF8String]);
    dec = [key decrypt:CT];
    NSLog(@"%@ -> %@", string, [dec UTF8String]);

    
//    // 2
//    key = [[MKMSymmetricKey alloc] init];
//    NSLog(@"key: %@", key);
//    CT = [key encrypt:data];
//    NSLog(@"key: %@", key);
//    dec = [key decrypt:CT];
//    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
//    NSAssert([dec isEqual:data], @"en/decrypt error");
    
}

- (void)testAsymmetric {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
    MKMPublicKey *PK = SK.publicKey;
    NSLog(@"private key: %@", SK);
    NSLog(@"public key: %@", PK);
    
    NSData *CT = [PK encrypt:data];
    NSData *dec = [SK decrypt:CT];
    NSLog(@"%@ -> %@ -> %@", string, [CT base64Encode], [dec UTF8String]);
    NSAssert([dec isEqual:data], @"en/decrypt error");
    
    NSData *sig = [SK sign:data];
    NSLog(@"sign(%@) = %@", [data UTF8String], [sig base64Encode]);
    
    if ([PK verify:data withSignature:sig]) {
        NSLog(@"==== CORRECT!");
    } else {
        NSAssert(false, @"signature error");
    }
    
}

- (void)testMeta {
    
    NSString *name = @"moky";
    MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
    MKMPublicKey *PK = SK.publicKey;
    
    MKMMeta *meta = [[MKMMeta alloc] initWithSeed:name
                                       privateKey:SK
                                        publicKey:PK];
    
    MKMID *ID = [meta buildIDWithNetworkID:MKMNetwork_Main];
    
    NSLog(@"meta: %@", meta);
    NSLog(@"ID: %@", ID);
    
    NSAssert([meta matchID:ID], @"error");
    
}

- (void)testAccount {
    
    MKMImmortals *immortals = [[MKMImmortals alloc] init];
    MKMFacebook().userDelegate = immortals;
    
    MKMID *ID = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    MKMUser *user = MKMUserWithID(ID);
    
    NSLog(@"user: %@", user);
    NSLog(@"SK: %@", user.privateKey);
    NSAssert([user.publicKey isMatch:user.privateKey], @"error");
    
    NSString *string;
    NSData *data;
    string = @"WH/wAcu+HfpaLq+vRblNnYufkyjTm4FgYyzW3wBDeRtXs1TeDmRxKVu7"
    "nQI/sdIALGLXrY+O5mlRfhU8f8TuIBilZUlX/eIUpL4uSDYKVLaRG9pO"
    "crCHKevjUpId9x/8KBEiMIL5LB0Vo7sKrvrqosCnIgNfHbXMKvMzwcqZ"
    "EU8=";
    data = [string base64Decode];
    data = [user.privateKey decrypt:data];
    string = [data UTF8String];
    NSLog(@"RSA decrypt: %@", string);
    
    MKMSymmetricKey *pw;
    pw = [[MKMSymmetricKey alloc] initWithJSONString:string];
    
    string = @"9cjCKG99ULCCxbL2mkc/MgF1saeRqJaCc+S12+HCqmsuF7TWK61EwTQWZSKskUeF";
    data = [string base64Decode];
    data = [pw decrypt:data];
    string = [data UTF8String];
    NSLog(@"AES decrypt: %@", string);
    
}

@end
