//
//  MWKTitleTests.m
//  MediaWikiKit
//
//  Created by Brion on 10/7/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MWKTestCase.h"

#define HC_SHORTHAND 1
#import <OCHamcrest/OCHamcrest.h>

@interface MWKTitleTests : MWKTestCase

@end

@implementation MWKTitleTests {
    MWKSite* site;
}

- (void)setUp {
    [super setUp];
    site = [[MWKSite alloc] initWithDomain:@"wikipedia.org" language:@"en"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimple {
    MWKTitle* title = [MWKTitle titleWithString:@"Simple" site:site];

    XCTAssertEqualObjects(title.prefixedDBKey, @"Simple", @"DB key form is full");
    XCTAssertEqualObjects(title.prefixedText, @"Simple", @"Text form is full");
    XCTAssertEqualObjects(title.prefixedURL, @"Simple", @"URL form is full");
    XCTAssertNil(title.fragment, @"Fragment is nil");
    XCTAssertEqualObjects(title.escapedFragment, @"", @"Fragment for URL is empty string");
}

- (void)testUnderscoresAndSpaces {
    NSArray* inputs = @[[MWKTitle titleWithString:@"Fancy title with spaces" site:site],
                        [MWKTitle titleWithString:@"Fancy_title with_spaces" site:site]
    ];
    for (MWKTitle* title in inputs) {
        XCTAssertEqualObjects(title.prefixedDBKey, @"Fancy_title_with_spaces", @"DB key form has underscores");
        XCTAssertEqualObjects(title.prefixedText, @"Fancy title with spaces", @"Text form has spaces");
        XCTAssertEqualObjects(title.prefixedURL, @"Fancy_title_with_spaces", @"URL form has underscores");
        XCTAssertNil(title.fragment, @"Fragment is nil");
        XCTAssertEqualObjects(title.escapedFragment, @"", @"Fragment for URL is empty string");
    }
}

- (void)testUnicode {
    MWKTitle* title = [MWKTitle titleWithString:@"Éclair" site:site];
    XCTAssertEqualObjects(title.prefixedDBKey, @"Éclair", @"DB key form has unicode");
    XCTAssertEqualObjects(title.prefixedText, @"Éclair", @"Text form has unicode");
    XCTAssertEqualObjects(title.prefixedURL, @"%C3%89clair", @"URL form has percent encoding");
    XCTAssertNil(title.fragment, @"Fragment is nil");
    XCTAssertEqualObjects(title.escapedFragment, @"", @"Fragment for URL is empty string");
}

- (void)testFragment {
    MWKTitle* title = [MWKTitle titleWithString:@"foo#bar" site:site];
    assertThat(title.site, is(site));
    assertThat(title.text, is(@"foo"));
    assertThat(title.fragment, is(@"bar"));
}

- (void)testPercentEscaped {
    MWKTitle* title = [MWKTitle titleWithString:@"foo%20baz#bar" site:site];
    assertThat(title.site, is(site));
    assertThat(title.text, is(@"foo baz"));
    assertThat(title.fragment, is(@"bar"));
}

- (void)testEquals {
    MWKTitle* title  = [site titleWithString:@"Foobie foo"];
    MWKTitle* title2 = [site titleWithString:@"Foobie foo"];
    XCTAssertEqualObjects(title, title2);

    MWKTitle* title3 = [site titleWithString:@"Foobie_foo"];
    XCTAssertEqualObjects(title, title3);

    MWKTitle* title4 = [site titleWithString:@"Foobie_Foo"];
    XCTAssertNotEqualObjects(title, title4);

    MWKSite* site2   = [[MWKSite alloc] initWithDomain:@"wikipedia.org" language:@"fr"];
    MWKTitle* title5 = [site2 titleWithString:@"Foobie foo"];
    XCTAssertNotEqualObjects(title, title5);
}

@end
