//
//  UtmMgrsTests.swift
//  UtmMgrsConverter
//
//  Created by Denys Iuzvyk on 5/24/17.
//  Copyright © 2017 duzvik. All rights reserved.
//

import XCTest



class UtmMgrsTests: XCTestCase {
    func testUtmMgrs() {
        // http://geographiclib.sourceforge.net/cgi-bin/GeoConvert
        // http://www.rcn.montana.edu/resources/converter.aspx
        
        // latitude/longitude -> UTM
        /*("LL->UTM 0,0",*/
        XCTAssertTrue(try LatLon( lat: 0,  lon: 0).toUtm().toString(precision: 6).isEqual("31 N 166021.443081 0.000000"))
        /*LL->UTM 1,1",*/
        XCTAssertTrue(try LatLon( lat: 1,  lon: 1).toUtm().toString(precision: 6).isEqual("31 N 277438.263521 110597.972524"))
        /*LL->UTM -1,-1"*/
        XCTAssertTrue(try LatLon( lat:-1,  lon: -1).toUtm().toString(precision: 6).isEqual("30 S 722561.736479 9889402.027476"))
        /*LL->UTM eiffel tower"*/
        XCTAssertTrue(try LatLon( lat: 48.8583, lon:    2.2945).toUtm().toString(precision: 3).isEqual("31 N 448251.898 5411943.794"))
        /*LL->UTM sidney o/h"*/
        XCTAssertTrue(try LatLon( lat:-33.857, lon:   151.215 ).toUtm().toString(precision: 3).isEqual("56 S 334873.199 6252266.092"))
        /*LL->UTM white house"*/
        XCTAssertTrue(try LatLon( lat: 38.8977, lon:  -77.0365).toUtm().toString(precision: 3).isEqual("18 N 323394.296 4307395.634"))
        /*LL->UTM rio christ"*/
        XCTAssertTrue(try LatLon( lat:-22.9519, lon:  -43.2106).toUtm().toString(precision: 3).isEqual("23 S 683466.254 7460687.433"))
        /*LL->UTM bergen"*/
        XCTAssertTrue(try LatLon( lat: 60.39135, lon:   5.3249).toUtm().toString(precision: 3).isEqual("32 N 297508.410 6700645.296"))
        /*LL->UTM bergen convergence"*/
        XCTAssertTrue(try LatLon( lat: 60.39135, lon:   5.3249).toUtm().convergence!.isEqual(to: -3.196281440))
        /*LL->UTM bergen scale"*/
        XCTAssertTrue(try LatLon( lat: 60.39135, lon:   5.3249).toUtm().scale!.isEqual(    to: 1.000102473211))
        
        
        // UTM -> latitude/longitude
        /*UTM->LL 0,0",                */
        XCTAssertTrue(try Utm.parse(utmCoord: "31 N 166021.443081 0.000000").toLatLonE().toString().isEqual(LatLon( lat: 0, lon: 0).toString()))
        /*UTM->LL 1,1",                */
        XCTAssertTrue(try Utm.parse(utmCoord:"31 N 277438.263521 110597.972524").toLatLonE().toString().isEqual(LatLon( lat:  1, lon: 1).toString()))
        /*UTM->LL -1,-1",              */
        XCTAssertTrue(try Utm.parse(utmCoord: "30 S 722561.736479 9889402.027476").toLatLonE().toString().isEqual(LatLon( lat: -1, lon: -1).toString()))
        /*UTM->LL eiffel tower",       */
        XCTAssertTrue(try Utm.parse(utmCoord: "31 N 448251.898 5411943.794").toLatLonE().toString().isEqual(LatLon( lat:  48.8583, lon: 2.2945).toString()))
        /*UTM->LL sidney o/h",         */
        XCTAssertTrue(try Utm.parse(utmCoord: "56 S 334873.199 6252266.092").toLatLonE().toString().isEqual(LatLon( lat: -33.857, lon: 151.215 ).toString()))
        /*UTM->LL white house",        */
        XCTAssertTrue(try Utm.parse(utmCoord: "18 N 323394.296 4307395.634").toLatLonE().toString().isEqual(LatLon( lat:  38.8977, lon: -77.0365).toString()))
        /*UTM->LL rio christ",         */
        XCTAssertTrue(try Utm.parse(utmCoord: "23 S 683466.254 7460687.433").toLatLonE().toString().isEqual(LatLon( lat: -22.9519, lon: -43.2106).toString()))
        /*UTM->LL bergen",             */
        XCTAssertTrue(try Utm.parse(utmCoord: "32 N 297508.410 6700645.296").toLatLonE().toString().isEqual(LatLon( lat:  60.39135, lon:  5.3249).toString()))
        /*UTM->LL bergen convergence", */
        XCTAssertTrue(try Utm.parse(utmCoord: "32 N 297508.410 6700645.296").toLatLonE().toUtm().convergence!.isEqual(to: -3.196281443))
        /*UTM->LL bergen scale",       */
        XCTAssertTrue(try Utm.parse(utmCoord: "32 N 297508.410 6700645.296").toLatLonE().toUtm().scale!.isEqual(to: 1.000102473212))
        
        
        // UTM -> MGRS
        /*UTM->MGRS 0,0",              */
        XCTAssertTrue(try Utm.parse(utmCoord: "31 N 166021.443081 0.000000").toMgrs().toString().isEqual("31N AA 66021 00000"))
        /*UTM->MGRS 1,1",              */
        XCTAssertTrue(try Utm.parse(utmCoord: "31 N 277438.263521 110597.972524").toMgrs().toString().isEqual("31N BB 77438 10597"))
        /*UTM->MGRS -1,-1",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "30 S 722561.736479 9889402.027476").toMgrs().toString().isEqual("30M YD 22561 89402"))
        /*UTM->MGRS eiffel tower",     */
        XCTAssertTrue(try Utm.parse(utmCoord: "31 N 448251.898 5411943.794").toMgrs().toString().isEqual("31U DQ 48251 11943"))
        /*UTM->MGRS sidney o/h",       */
        XCTAssertTrue(try Utm.parse(utmCoord: "56 S 334873.199 6252266.092").toMgrs().toString().isEqual("56H LH 34873 52266"))
        /*UTM->MGRS white house",      */
        XCTAssertTrue(try Utm.parse(utmCoord: "18 N 323394.296 4307395.634").toMgrs().toString().isEqual("18S UJ 23394 07395"))
        /*UTM->MGRS rio christ",       */
        XCTAssertTrue(try Utm.parse(utmCoord: "23 S 683466.254 7460687.433").toMgrs().toString().isEqual("23K PQ 83466 60687"))
        /*UTM->MGRS bergen",           */
        XCTAssertTrue(try Utm.parse(utmCoord: "32 N 297508.410 6700645.296").toMgrs().toString().isEqual("32V KN 97508 00645"))
        
        
        // MGRS -> UTM
        /*MGRS->UTM 0,0",              */
        XCTAssertTrue(try Mgrs.parse(str: "31N AA 66021 00000").toUtm().toString().isEqual("31 N 166021 0"))
        /*MGRS->UTM 1,1",              */
        XCTAssertTrue(try Mgrs.parse(str: "31N BB 77438 10597").toUtm().toString().isEqual("31 N 277438 110597"))
        /*MGRS->UTM -1,-1",            */
        XCTAssertTrue(try Mgrs.parse(str: "30M YD 22561 89402").toUtm().toString().isEqual("30 S 722561 9889402"))
        /*MGRS->UTM eiffel tower",     */
        XCTAssertTrue(try Mgrs.parse(str: "31U DQ 48251 11943").toUtm().toString().isEqual("31 N 448251 5411943"))
        /*MGRS->UTM sidney o/h",       */
        XCTAssertTrue(try Mgrs.parse(str: "56H LH 34873 52266").toUtm().toString().isEqual("56 S 334873 6252266"))
        /*MGRS->UTM white house",      */
        XCTAssertTrue(try Mgrs.parse(str: "18S UJ 23394 07395").toUtm().toString().isEqual("18 N 323394 4307395"))
        /*MGRS->UTM rio christ",       */
        XCTAssertTrue(try Mgrs.parse(str: "23K PQ 83466 60687").toUtm().toString().isEqual("23 S 683466 7460687"))
        /*MGRS->UTM bergen",           */
        XCTAssertTrue(try Mgrs.parse(str: "32V KN 97508 00645").toUtm().toString().isEqual("32 N 297508 6700645"))
        // forgiving parsing of 100km squares spanning bands
        /*MGRS->UTM 01P ≡ UTM 01Q",    */
        XCTAssertTrue(try Mgrs.parse(str: "01P ET 00000 68935").toUtm().toString().isEqual("01 N 500000 1768935"))
        /*MGRS->UTM 01Q ≡ UTM 01P",    */
        XCTAssertTrue(try Mgrs.parse(str: "01Q ET 00000 68935").toUtm().toString().isEqual("01 N 500000 1768935"))
        // military style
        /*MGRS->UTM 0,0 military",     */
        XCTAssertTrue(try Mgrs.parse(str: "31NAA6602100000").toUtm().toString().isEqual("31 N 166021 0"))
        
        
        
        
        // https://www.ibm.com/developerworks/library/j-coordconvert/#listing7 (note UTM/MGRS confusion UTM is rounded, MGRS is truncated UPS not included)
        /*IBM #01 UTM->LL",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "31 N 166021 0").toLatLonE().toString(format: "d").isEqual("00.0000°N, 000.0000°W"))
        /*IBM #02 UTM->LL",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "30 N 808084 14385").toLatLonE().toString(format: "d").isEqual("00.1300°N, 000.2324°W"))
        /*IBM #03 UTM->LL",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "34 S 683473 4942631").toLatLonE().toString(format: "d").isEqual("45.6456°S, 023.3545°E"))
        /*IBM #04 UTM->LL",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "25 S 404859 8588690").toLatLonE().toString(format: "d").isEqual("12.7650°S, 033.8765°W"))
        /*IBM #09 UTM->LL",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "08 N 453580 2594272").toLatLonE().toString(format: "d").isEqual("23.4578°N, 135.4545°W"))
        /*IBM #10 UTM->LL",            */
        XCTAssertTrue(try Utm.parse(utmCoord: "57 N 450793 8586116").toLatLonE().toString(format: "d").isEqual("77.3450°N, 156.9876°E"))
        /*IBM #01 LL->UTM" */
        XCTAssertTrue(try LatLon(  lat: 0.0000,    lon: 0.0000).toUtm().toString().isEqual("31 N 166021 0"))
        /*IBM #01 LL->MGRS"*/
        XCTAssertTrue(try LatLon(  lat: 0.0000,    lon: 0.0000).toUtm().toMgrs().toString().isEqual("31N AA 66021 00000"))
        /*IBM #02 LL->UTM",*/
        XCTAssertTrue(try LatLon(  lat: 0.1300,   lon: -0.2324).toUtm().toString().isEqual("30 N 808084 14386"))
        /*IBM #02 LL->MGRS"*/
        XCTAssertTrue(try LatLon(  lat: 0.1300,   lon: -0.2324).toUtm().toMgrs().toString().isEqual("30N ZF 08084 14385"))
        /*IBM #03 LL->UTM",*/
        XCTAssertTrue(try LatLon(lat: -45.6456,   lon: 23.3545).toUtm().toString().isEqual("34 S 683474 4942631"))
        /*IBM #03 LL->MGRS"*/
        XCTAssertTrue(try LatLon(lat: -45.6456,   lon: 23.3545).toUtm().toMgrs().toString().isEqual("34G FQ 83473 42631"))
        /*IBM #04 LL->UTM",*/
        XCTAssertTrue(try LatLon(lat: -12.7650,  lon: -33.8765).toUtm().toString().isEqual("25 S 404859 8588691"))
        /*IBM #04 LL->MGRS"*/
        XCTAssertTrue(try LatLon(lat: -12.7650,  lon: -33.8765).toUtm().toMgrs().toString().isEqual("25L DF 04859 88691"))
        /*IBM #09 LL->UTM",*/
        XCTAssertTrue(try LatLon( lat: 23.4578, lon: -135.4545).toUtm().toString().isEqual("08 N 453580 2594273"))
        /*IBM #09 LL->MGRS"*/
        XCTAssertTrue(try LatLon( lat: 23.4578, lon: -135.4545).toUtm().toMgrs().toString().isEqual("08Q ML 53580 94272"))
        /*IBM #10 LL->UTM",*/
        XCTAssertTrue(try LatLon( lat: 77.3450,  lon: 156.9876).toUtm().toString().isEqual("57 N 450794 8586116"))
        /*IBM #10 LL->MGRS"*/
        XCTAssertTrue(try LatLon( lat: 77.3450,  lon: 156.9876).toUtm().toMgrs().toString().isEqual("57X VF 50793 86116"))
        
        // varying resolution
        /*MGRS 4-digit -> UTM"*/
        XCTAssertTrue(try Mgrs.parse(str: "12S TC 52 86").toUtm().toString().isEqual("12 N 252000 3786000"))
        /*MGRS 10-digit -> UTM"*/
        XCTAssertTrue(try Mgrs.parse(str: "12S TC 52000 86000").toUtm().toString().isEqual("12 N 252000 3786000"))
        /*MGRS 10-digit+decimals"*/
        XCTAssertTrue(try Mgrs.parse(str: "12S TC 52000.123 86000.123").toUtm().toString(precision: 3).isEqual("12 N 252000.123 3786000.123"))
        /*MGRS truncate"*/
        XCTAssertTrue(try Mgrs.parse(str: "12S TC 52999.999 86999.999").toString(precision: 6).isEqual("12S TC 529 869"))
        /*MGRS-UTM round"*/
        XCTAssertTrue(try Mgrs.parse(str: "12S TC 52999.999 86999.999").toUtm().toString().isEqual("12 N 253000 3787000"))
        
    }
}
