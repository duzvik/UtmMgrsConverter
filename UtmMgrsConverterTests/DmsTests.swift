//
//  DmsTests.swift
//  UtmMgrsConverter
//
//  Created by Denys Iuzvyk on 5/24/17.
//  Copyright © 2017 duzvik. All rights reserved.
//

import XCTest

class DmsTests: XCTestCase {
    func testZero() {
        XCTAssertTrue(Dms.parseDMS(dmsStr: "0.0°") == 0.0, "parse 0.0°")
        XCTAssertTrue(Dms.toDMS(deg: 0, format: "d") == "000.0000°", "output 000.0000°")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "0°") == 0, "parse 0°")
        XCTAssertTrue(Dms.toDMS(deg: 0, format: "d", dp: 0) == "000°", "output 000°")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "000 00 00 ") == 0, "parse 000 00 00 ")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "000°00′00″") == 0, "parse 000°00′00″")
        XCTAssertTrue(Dms.toDMS(deg: 0) == "000°00′00″", "output 000°00′00″")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "000°00′00.0″") == 0, "parse 000°00′00.0″")
        XCTAssertTrue(Dms.toDMS(deg: 0, format: "dms", dp: 2) == "000°00′00.00″", "output 000°00′00.00″")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "0") == 0, "parse num 0")
        XCTAssertTrue(Dms.toDMS(deg: 0, format: "dms", dp: 2) == "000°00′00.00″", "output str 0")
    }
    
    func testVariations() {
        let variations = [
            "45.76260",
            "45.76260 ",
            "45.76260°",
            "45°45.756′",
            "45° 45.756′",
            "45 45.756",
            "45°45′45.36″",
            "45º45'45.36\"",
            "45°45’45.36”",
            "45 45 45.36 ",
            "45° 45′ 45.36″",
            "45º 45' 45.36\"",
            "45° 45’ 45.36”",
            ]
        
        for  v in variations {
            XCTAssertTrue(Dms.parseDMS(dmsStr: v)!.isEqual(to: 45.76260), "parse dms variations \(v)")
            XCTAssertTrue(Dms.parseDMS(dmsStr: "-\(v)")!.isEqual(to: -45.76260), "parse dms variations -\(v)")
            XCTAssertTrue(Dms.parseDMS(dmsStr: "\(v)N")!.isEqual(to: 45.76260), "parse dms variations \(v)N")
            XCTAssertTrue(Dms.parseDMS(dmsStr: "\(v)S")!.isEqual(to: -45.76260), "parse dms variations \(v)S")
            XCTAssertTrue(Dms.parseDMS(dmsStr: "\(v)E")!.isEqual(to: 45.76260), "parse dms variations \(v)W")
            XCTAssertTrue(Dms.parseDMS(dmsStr: "\(v)W")!.isEqual(to: -45.76260), "parse dms variations \(v)W")
            
        }
        
        XCTAssertTrue(Dms.parseDMS(dmsStr: " 45°45′45.36″ ")!.isEqual(to: 45.76260), "parse dms variations ws before+after")
    }
    
    func testOutOfRange(){
        XCTAssertTrue(Dms.parseDMS(dmsStr: "185")!.isEqual(to: 185), "parse 185")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "365")!.isEqual(to: 365), "parse 365")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "-185")!.isEqual(to: -185), "parse -185")
        XCTAssertTrue(Dms.parseDMS(dmsStr: "-365")!.isEqual(to: -365), "parse -365")
    }
    
    func testOutputVariations() {
        XCTAssertTrue(Dms.toDMS(deg: 45.76260)!.isEqual("045°45′45″"), "output dms ")
        XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"d")!.isEqual("045.7626°"), "output dms  d")
        XCTAssertTrue(Dms.toDMS(deg: 45.76260, format: "dm")!.isEqual("045°45.76′"), "output dms dm")
        XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"dms")!.isEqual("045°45′45″"), "output dms dms")
        XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"d", dp: 6)!.isEqual("045.762600°"), "output dms d")
        XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"dm", dp: 4)!.isEqual("045°45.7560′"), "output dms dm")
        XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"dms", dp: 2)!.isEqual("045°45′45.36″"), "output dms dms")
        XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"xxx")!.isEqual("045°45′45″"), "output dms xxx")
        //XCTAssertTrue(Dms.toDMS(deg:45.76260, format:"xxx", dp: 6)!.isEqual("045.762600°"), "output dms xxx")
    }
    
    func testMisc() {
        let minus = Dms.toLat(deg: Double.nan, format: "dms")
        
        XCTAssertTrue(Dms.toLat(deg: 51.2, format: "dms").isEqual("51°12′00″N"), "toLat num")
        XCTAssertTrue(Dms.toLat(deg: 51.2, format: "dms").isEqual("51°12′00″N"), "toLat str")
        XCTAssertTrue(minus.isEqual("-"), "toLat xxx")
        XCTAssertTrue(Dms.toLon(deg: 0.33, format: "dms").isEqual("000°19′48″E"), "toLon num")
        XCTAssertTrue(Dms.toDMS(deg: 51.19999999999999, format: "d")!.isEqual("051.2000°"), "toDMS rnd-up")
        XCTAssertTrue(Dms.toDMS(deg: 51.19999999999999, format: "dm")!.isEqual("051°12.00′"), "toDMS rnd-up")
        XCTAssertTrue(Dms.toDMS(deg: 51.19999999999999, format: "dms")!.isEqual("051°12′00″"), "num")
        //XCTAssertTrue(Dms.toBrng(1)!.isEqual("001°00′00″"), "toBrng")
    }
    
    func testParseFailures(){
        XCTAssertNil(Dms.parseDMS(dmsStr: "0 0 0 0"))
        XCTAssertNil(Dms.parseDMS(dmsStr: "xxx"))
        XCTAssertNil(Dms.parseDMS(dmsStr: ""))
    }
    
    func testConvertFailures() {
        XCTAssertTrue(Dms.toDMS(deg: 1/0) == "inf°an′nan″")
    }
}
