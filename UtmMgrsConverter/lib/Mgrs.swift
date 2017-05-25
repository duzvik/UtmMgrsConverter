/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/*  MGRS / UTM Conversion Functions                                   (c) Chris Veness 2014-2016  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-utm-mgrs.html                                           */
/* www.movable-type.co.uk/scripts/geodesy/docs/module-mgrs.html                                   */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
//  Converted by Denys Iuzvyk from http://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html  https://github.com/chrisveness/geodesy


import Foundation

class  Mgrs {
    /**
     * Convert between Universal Transverse Mercator (UTM) coordinates and Military Grid Reference
     * System (MGRS/NATO) grid references.
     *
     * @module   mgrs
     * @requires utm
     * @requires latlon-ellipsoidal
     */
    
    /* qv www.fgdc.gov/standards/projects/FGDC-standards-projects/usng/fgdc_std_011_2001_usng.pdf p10 */
    
    
    /*
     * Latitude bands C..X 8° each, covering 80°S to 84°N
     */
    static let latBands = "CDEFGHJKLMNPQRSTUVWXX" // X is repeated for 80-84°N
    
    
    /*
     * 100km grid square column (‘e’) letters repeat every third zone
     */
    static let e100kLetters = [ "ABCDEFGH", "JKLMNPQR", "STUVWXYZ" ]
    
    
    /*
     * 100km grid square row (‘n’) letters repeat every other zone
     */
    static let n100kLetters = ["ABCDEFGHJKLMNPQRSTUV", "FGHJKLMNPQRSTUVABCDE"]
    
    
    var zone: Int
    var band: String
    var e100k: String
    var n100k: String
    var easting: Double
    var northing: Double
    var datum: DatumObject
    
    
    
    /**
     * Creates an Mgrs grid reference object.
     *
     * @constructor
     * @param  {number} zone - 6° longitudinal zone (1..60 covering 180°W..180°E).
     * @param  {string} band - 8° latitudinal band (C..X covering 80°S..84°N).
     * @param  {string} e100k - First letter (E) of 100km grid square.
     * @param  {string} n100k - Second letter (N) of 100km grid square.
     * @param  {number} easting - Easting in metres within 100km grid square.
     * @param  {number} northing - Northing in metres within 100km grid square.
     * @param  {LatLon.datum} [datum=WGS84] - Datum UTM coordinate is based on.
     * @throws {Error}  Invalid MGRS grid reference.
     *
     * @example
     *   var mgrsRef = new Mgrs(31, 'U', 'D', 'Q', 48251, 11932) // 31U DQ 48251 11932
     */
    init(zone: Int, band: String, e100k: String, n100k: String, easting: Double, northing: Double, datum: DatumObject = LatLon.Datum.WGS84) throws {
        if (!(1<=zone && zone<=60)) {
            throw UtmMgrsError.fail("Invalid MGRS grid reference (zone \(zone))")
        }
        if (band.characters.isEmpty) {
            throw UtmMgrsError.fail("Invalid MGRS grid reference (band \(band))")
        }
        
        if (Mgrs.latBands.range(of: band) == nil) {
            throw UtmMgrsError.fail("Invalid MGRS grid reference (band  \(band))")
        }
        if (e100k.characters.isEmpty) {
            throw UtmMgrsError.fail("Invalid MGRS grid reference (e100k \(e100k))")
        }
        if (n100k.characters.isEmpty) {
            throw UtmMgrsError.fail("Invalid MGRS grid reference (n100k  \(n100k))")
        }
        
        self.zone = zone
        self.band = band
        self.e100k = e100k
        self.n100k = n100k
        self.easting = easting
        self.northing = northing
        self.datum = datum
    }
    
    /**
     * Converts MGRS grid reference to UTM coordinate.
     *
     * @returns {Utm}
     *
     * @example
     *   var utmCoord = Mgrs.parse('31U DQ 448251 11932').toUtm() // 31 N 448251 5411932
     */
    func toUtm() throws -> Utm {
        let hemisphere = band >= "N" ? "N" : "S"
        // get easting specified by e100k
        let eastingArray = Mgrs.e100kLetters[(zone-1)%3].characters
        guard let eastingIndex = eastingArray.index(of: Character(e100k)) else {
            throw UtmMgrsError.fail("Failder find E index of \(e100k)")
        }
        let col = eastingArray.distance(from: eastingArray.startIndex, to: eastingIndex) + 1 // index+1 since A (index 0) -> 1*100e3, B (index 1) -> 2*100e3, etc.
        let e100kNum = Double(col) * 100e3 // e100k in metres
        
        // get northing specified by n100k
        let northingArray = Mgrs.n100kLetters[(zone-1)%2].characters
        guard let northingIndex = northingArray.index(of: Character(n100k)) else {
            throw UtmMgrsError.fail("Failder find N index of \(n100k)")
        }
        
        let row = northingArray.distance(from: northingArray.startIndex, to: northingIndex)
        let n100kNum = Double(row) * 100e3 // n100k in metres
        
        // get latitude of (bottom of) band
        let latBandArr =  Mgrs.latBands.characters
        guard let llIndex = latBandArr.index(of: Character(band)) else {
            throw UtmMgrsError.fail("Failder find latBand index of \(band)")
        }
        let latBand = (latBandArr.distance(from: latBandArr.startIndex, to: llIndex) - 10)  * 8
        
        // northing of bottom of band, extended to include entirety of bottommost 100km square
        // (100km square boundaries are aligned with 100km UTM northing intervals)
        let utm = try LatLon(lat: Double(latBand), lon: 0).toUtm()
        let n = Double(utm.northing) / 100e3
        let nBand = floor(n)*100e3
        // 100km grid square row letters repeat every 2,000km north add enough 2,000km blocks to get
        // into required band
        var n2M = 0.0 // northing of 2,000km block
        while (n2M + n100kNum + Double(northing) < nBand) {
            n2M += 2000e3
        }
        
        return try Utm(zone: zone, hemisphere: hemisphere, easting: (e100kNum+easting), northing: (n2M+n100kNum+northing), datum: self.datum)
    }
    
    
    /**
     * Parses string representation of MGRS grid reference.
     *
     * An MGRS grid reference comprises (space-separated)
     *  - grid zone designator (GZD)
     *  - 100km grid square letter-pair
     *  - easting
     *  - northing.
     *
     * @param   {string} mgrsGridRef - String representation of MGRS grid reference.
     * @returns {Mgrs}   Mgrs grid reference object.
     * @throws  {Error}  Invalid MGRS grid reference.
     *
     * @example
     *   var mgrsRef = Mgrs.parse('31U DQ 48251 11932')
     *   var mgrsRef = Mgrs.parse('31UDQ4825111932')
     *   //  mgrsRef: { zone:31, band:'U', e100k:'D', n100k:'Q', easting:48251, northing:11932 }
     */
    static func parse(str: String) throws -> Mgrs {
        var mgrsGridRef = str.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !mgrsGridRef.contains(" "){
            var startRange = mgrsGridRef.index(mgrsGridRef.startIndex, offsetBy: 5)
            var endRange = mgrsGridRef.endIndex
            var en = mgrsGridRef.substring(with: startRange..<endRange) // get easting/northing following zone/band/100ksq
            let e = String(en.characters.prefix(en.utf16.count/2))  //get easting
            let n = String(en.characters.suffix(en.utf16.count/2))  //get northing
            let part1 = String(mgrsGridRef.characters.prefix(3))
            startRange = mgrsGridRef.index(mgrsGridRef.startIndex, offsetBy: 3)
            endRange = mgrsGridRef.index(mgrsGridRef.startIndex, offsetBy: 5)
            let part2 = mgrsGridRef.substring(with: startRange..<endRange)  // play
            mgrsGridRef = "\(part1) \(part2) \(e) \(n)"
        }
        
        // match separate elements (separated by whitespace)
        let components = mgrsGridRef.components(separatedBy: .whitespaces)
        if (components.isEmpty || components.count != 4) {
            throw UtmMgrsError.fail("Invalid MGRS grid reference \(mgrsGridRef)")
        }
        
        // split gzd into zone/band
        let gzd = components[0]
        
        guard let zone = Int(String(gzd.characters.prefix(2)))   else { //get first 2 gigits
            throw UtmMgrsError.fail("Invalid MGRS grid reference \(mgrsGridRef) failed parse zone")
        }
        
        var startRange = gzd.index(gzd.startIndex, offsetBy: 2)
        var endRange = gzd.index(gzd.startIndex, offsetBy: 3)
        let band = gzd.substring(with: startRange..<endRange)  // get bvand

        // split 100km letter-pair into e/n
        var en100k = components[1]
        let e100k =  String(en100k.characters.prefix(1)) //slice(0, 1)

        startRange = en100k.index(en100k.startIndex, offsetBy: 1)
        endRange = en100k.index(en100k.startIndex, offsetBy: 2)
        let n100k = en100k.substring(with: startRange..<endRange) //slice(1, 2)

        var eStr = components[2]
        var nStr = components[3]

        // standardise to 10-digit refs - ie metres) (but only if < 10-digit refs, to allow decimals)
        if eStr.utf16.count < 5  {
            eStr = "\(eStr)00000"
            startRange = eStr.startIndex
            endRange = eStr.index(eStr.startIndex, offsetBy: 5)
            eStr = eStr.substring(with: startRange..<endRange) //slice(0, 5)
        }

        if nStr.utf16.count < 5  {
            nStr = "\(nStr)00000"
            startRange = nStr.startIndex
            endRange = nStr.index(nStr.startIndex, offsetBy: 5)
            nStr = nStr.substring(with: startRange..<endRange) //slice(0, 5)
        }

        guard let e = Double(eStr),
            let n = Double(nStr) else {
                throw UtmMgrsError.fail("Invalid MGRS grid reference \(mgrsGridRef) failed parse e n")
        }
        return try Mgrs(zone: zone, band: band, e100k: e100k, n100k: n100k, easting: e, northing: n)
    }
    
    /**
     * Returns a string representation of an MGRS grid reference.
     *
     * To distinguish from civilian UTM coordinate representations, no space is included within the
     * zone/band grid zone designator.
     *
     * Components are separated by spaces: for a military-style unseparated string, use
     * Mgrs.toString().replace(/ /g, '')
     *
     * Note that MGRS grid references get truncated, not rounded (unlike UTM coordinates).
     *
     * @param   {number} [digits=10] - Precision of returned grid reference (eg 4 = km, 10 = m).
     * @returns {string} This grid reference in standard format.
     * @throws  {Error}  Invalid precision.
     *
     * @example
     *   var mgrsStr = new Mgrs(31, 'U', 'D', 'Q', 48251, 11932).toString() // '31U DQ 48251 11932'
     */
    
    func toString(precision: Int = 10) -> String {
        if ![2,4,6,8,10].contains(precision) {
            return("[Mgrs] Invalid precision \(precision) ")
        }
        
        let zone = String(format: "%02d", self.zone) // ensure leading zero
        let band = self.band
        
        let e100k = self.e100k
        let n100k = self.n100k
        
        // truncate to required precision
        
        let eRounded = floor(self.easting/pow(10.0, Double(5-precision/2)))
        let nRounded = floor(self.northing/pow(10.0, Double(5-precision/2)))
        
        // ensure leading zeros
        var easting = "00000\(String(format: "%g", eRounded))"
        easting = easting.substring(from: easting.index(easting.endIndex, offsetBy: -precision/2))
        
        var northing = "00000\(String(format: "%g", nRounded))"
        northing = northing.substring(from: northing.index(northing.endIndex, offsetBy: -precision/2))
        
        return "\(zone)\(band) \(e100k)\(n100k) \(easting) \(northing)"
    }
}

extension Utm {
    /**
     * Converts UTM coordinate to MGRS reference.
     *
     * @returns {Mgrs}
     * @throws  {Error} Invalid UTM coordinate.
     *
     * @example
     *   var utmCoord = new Utm(31, 'N', 448251, 5411932)
     *   var mgrsRef = utmCoord.toMgrs() // 31U DQ 48251 11932
     */
    func toMgrs() throws -> Mgrs {
        // MGRS zone is same as UTM zone
        let zone = self.zone
        
        // convert UTM to lat/long to get latitude to determine band
        let latlong = self.toLatLonE()
        // grid zones are 8° tall, 0°N is 10th band
        let idx = Int(floor(latlong.lat/8+10))
        let band = String(Array(Mgrs.latBands.characters)[idx]) // latitude band
        
        // columns in zone 1 are A-H, zone 2 J-R, zone 3 S-Z, then repeating every 3rd zone
        let col = floor(Double(self.easting) / 100e3)
        let e100k = String(Array(Mgrs.e100kLetters[(zone-1)%3].characters)[Int(col-1)]) // col-1 since 1*100e3 -> A (index 0), 2*100e3 -> B (index 1), etc.
        
        // rows in even zones are A-V, in odd zones are F-E
        let row = floor(Double(self.northing) / 100e3).truncatingRemainder(dividingBy: 20)
        let n100k = String(Array(Mgrs.n100kLetters[(zone-1)%2].characters)[Int(row)])
        
        // truncate easting/northing to within 100km grid square
        let easting = self.easting.truncatingRemainder(dividingBy: 100e3).roundTo(places: 6)
        let northing = self.northing.truncatingRemainder(dividingBy: 100e3).roundTo(places: 6)
        
        // round easting, northing to nm precision
        return try Mgrs(zone: zone, band: band, e100k: e100k, n100k: n100k, easting: easting, northing: northing)
    }
}
