/**
 * Convert between Universal Transverse Mercator coordinates and WGS 84 latitude/longitude points.
 *
 * Method based on Karney 2011 ‘Transverse Mercator with an accuracy of a few nanometers’,
 * building on Krüger 1912 ‘Konforme Abbildung des Erdellipsoids in der Ebene’.
 *
 *  Converted by Denys Iuzvyk from http://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html  https://github.com/chrisveness/geodesy
 */

import Foundation

class Utm {
    var zone: Int
    var hemisphere: String
    var easting: Double
    var northing: Double
    var datum: DatumObject
    var convergence: Double?
    var scale: Double?
    
    /**
     * Creates a Utm coordinate object.
     *
     * @constructor
     * @param  {number} zone - UTM 6° longitudinal zone (1..60 covering 180°W..180°E).
     * @param  {string} hemisphere - N for northern hemisphere, S for southern hemisphere.
     * @param  {number} easting - Easting in metres from false easting (-500km from central meridian).
     * @param  {number} northing - Northing in metres from equator (N) or from false northing -10,000km (S).
     * @param  {LatLon.datum} [datum=WGS84] - Datum UTM coordinate is based on.
     * @param  {number} [convergence] - Meridian convergence (bearing of grid north clockwise from true
     *                  north), in degrees
     * @param  {number} [scale] - Grid scale factor
     * @throws {Error}  Invalid UTM coordinate
     *
     * @example
     *   let utmCoord = new Utm(31, "N", 448251, 5411932)
     */
    init(zone: Int, hemisphere: String, easting: Double, northing: Double, datum: DatumObject?, convergence: Double? = nil, scale: Double? = nil) throws {
        
        if !(1 <= zone && zone <= 60) {
            throw UtmMgrsError.fail("Invalid UTM zone \(zone)")
        }
        
        if !["N", "S", "n", "s"].contains(hemisphere) {
            throw UtmMgrsError.fail("Invalid UTM hemisphere \(hemisphere)")
        }
        
        // range-check easting/northing (with 40km overlap between zones) - is this worthwhile?
        //if (!(120e3<=easting && easting<=880e3)) throw new Error("Invalid UTM easting "+ easting)
        //if (!(0<=northing && northing<=10000e3)) throw new Error("Invalid UTM northing "+ northing)
        
        self.zone = zone
        self.hemisphere = hemisphere.uppercased()
        self.easting = easting
        self.northing = northing
        self.datum = datum == nil ?  LatLon.Datum.WGS84 : datum!
        self.convergence = convergence
        self.scale = scale
    }
    
    
    
    /**
     * Converts UTM zone/easting/northing coordinate to latitude/longitude
     *
     * @param   {Utm}    utmCoord - UTM coordinate to be converted to latitude/longitude.
     * @returns {LatLon} Latitude/longitude of supplied grid reference.
     *
     * @example
     *   var grid = new Utm(31, 'N', 448251.795, 5411932.678)
     *   var latlong = grid.toLatLonE() // latlong.toString(): 48°51′29.52″N, 002°17′40.20″E
     */
    func toLatLonE() -> LatLon {
        let z = self.zone
        let h = self.hemisphere
        var x = self.easting
        var y = self.northing
        
        
        //if z) || isNaN(x) || isNaN(y)) throw new Error('Invalid coordinate')
        
        let  falseEasting = 500e3
        let falseNorthing = 10000e3
        
        
        let a = self.datum.ellipsoid["a"]!
        let f = self.datum.ellipsoid["f"]!
        
        // WGS 84:  a = 6378137, b = 6356752.314245, f = 1/298.257223563
        
        let k0 = 0.9996 // UTM scale on the central meridian
        
        x = x - falseEasting               // make x ± relative to central meridian
        y = h == "S" ? y - falseNorthing : y // make y ± relative to equator
        
        // ---- from Karney 2011 Eq 15-22, 36:
        
        let e = sqrt(f*(2-f)) // eccentricity
        let n = f / (2 - f)        // 3rd flattening
        let n2 = n*n
        let n3 = n*n2
        let n4 = n*n3
        let n5 = n*n4
        let n6 = n*n5
        
        let A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6) // 2πA is the circumference of a meridian
        
        let η = x / (k0*A)
        let ξ = y / (k0*A)
        
        var β = [ 0, // note β is one-based array (6th order Krüger expressions)
            1/2*n - 2/3*n2 + 37/96*n3 -    1/360*n4 -   81/512*n5 +    96199/604800*n6,
            1/48*n2 +  1/15*n3 - 437/1440*n4 +   46/105*n5 - 1118711/3870720*n6,
            17/480*n3 -   37/840*n4 - 209/4480*n5 +      5569/90720*n6,
            4397/161280*n4 -   11/504*n5 -  830251/7257600*n6,
            4583/161280*n5 -  108847/3991680*n6,
            20648693/638668800*n6 ]
        
        var ξʹ = ξ
        for j in 1...6 {
            ξʹ -= β[j] * sin(2.0*Double(j)*ξ) * cosh(2.0*Double(j)*η)
        }
        
        var ηʹ = η
        for j in 1...6 {
            ηʹ -= β[j] * cos(2.0*Double(j)*ξ) * sinh(2.0*Double(j)*η)
        }
        
        let sinhηʹ = sinh(ηʹ)
        let sinξʹ = sin(ξʹ)
        let cosξʹ = cos(ξʹ)
        
        let τʹ = sinξʹ / sqrt(sinhηʹ*sinhηʹ + cosξʹ*cosξʹ)
        
        var τi = τʹ
        var δτi = 1.0// 1 > 1e-12
        repeat {
            let σi = sinh(e*atanh(e*τi/sqrt(1+τi*τi)))
            let τiʹ = τi * sqrt(1+σi*σi) - σi * sqrt(1+τi*τi)
            δτi = (τʹ - τiʹ)/sqrt(1+τiʹ*τiʹ)
                * (1 + (1-e*e)*τi*τi) / ((1-e*e)*sqrt(1+τi*τi))
            τi += δτi
        } while (abs(δτi) > 1e-12) // using IEEE 754 δτi -> 0 after 2-3 iterations
        // note relatively large convergence test as δτi toggles on ±1.12e-16 for eg 31 N 400000 5000000
        let τ = τi
        
        let φ = atan(τ)
        
        var λ = atan2(sinhηʹ, cosξʹ)
        
        // ---- convergence: Karney 2011 Eq 26, 27
        
        var p = 1.0
        for j in 1...6 {
            p -= 2*Double(j)*β[j] * cos(2*Double(j)*ξ) * cosh(2*Double(j)*η)
        }
        
        var q = 0.0
        for j in 1...6 {
            q += 2*Double(j)*β[j] * sin(2*Double(j)*ξ) * sinh(2*Double(j)*η)
        }
        
        let γʹ = atan(tan(ξʹ) * tanh(ηʹ))
        let γʺ = atan2(q, p)
        
        let γ = γʹ + γʺ
        
        // ---- scale: Karney 2011 Eq 28
        
        let sinφ = sin(φ)
        let kʹ = sqrt(1 - e*e*sinφ*sinφ) * sqrt(1 + τ*τ) * sqrt(sinhηʹ*sinhηʹ + cosξʹ*cosξʹ)
        let kʺ = A / a / sqrt(p*p + q*q)
        
        let k = k0 * kʹ * kʺ
        
        // ------------
        
        let λ0 = Double((z-1)*6 - 180 + 3).degreesToRadians // longitude of central meridian
        λ += λ0 // move λ from zonal to global coordinates
        
        // round to reasonable precision
        let lat =  φ.radiansToDegrees.roundTo(places: 11) // nm precision (1nm = 10^-11°)
        let lon = λ.radiansToDegrees.roundTo(places: 11) // (strictly lat rounding should be φ⋅cosφ!)
        let convergence = γ.radiansToDegrees.roundTo(places: 9)
        let scale = k.roundTo(places: 12)
        
        let latLong = LatLon(lat: lat, lon: lon, datum: self.datum)
        self.convergence = convergence
        self.scale = scale
        return latLong
    }
    
    
    /**
     * Parses string representation of UTM coordinate.
     *
     * A UTM coordinate comprises (space-separated)
     *  - zone
     *  - hemisphere
     *  - easting
     *  - northing.
     *
     * @param   {string} utmCoord - UTM coordinate (WGS 84).
     * @param   {Datum}  [datum=WGS84] - Datum coordinate is defined in (default WGS 84).
     * @returns {Utm}
     * @throws  {Error}  Invalid UTM coordinate.
     *
     * @example
     *   var utmCoord = Utm.parse('31 N 448251 5411932')
     *   // utmCoord: {zone: 31, hemisphere: 'N', easting: 448251, northing: 5411932 }
     */
    static func parse(utmCoord:  String, datum: DatumObject = LatLon.Datum.WGS84) throws -> Utm {
        // match separate elements (separated by whitespace)
        let coord = utmCoord.components(separatedBy: .whitespacesAndNewlines)
        if coord.isEmpty || coord.count != 4 {
            throw UtmMgrsError.fail("Invalid UTM coordinate. #1 \(utmCoord)")
        }
        
        guard let zone = Int(coord[0]),
            let hemisphere = String(coord[1]),
            let easting = Double(coord[2]),
            let northing = Double(coord[3]) else {
                throw UtmMgrsError.fail("Invalid UTM coordinate. #2 \(utmCoord)  \(coord.joined(separator: "->"))")
        }
        
        
        return try Utm(zone: zone, hemisphere: hemisphere, easting: easting, northing: northing, datum: datum)
    }
    
    
    /**
     * Returns a string representation of a UTM coordinate.
     *
     * To distinguish from MGRS grid zone designators, a space is left between the zone and the
     * hemisphere.
     *
     * Note that UTM coordinates get rounded, not truncated (unlike MGRS grid references).
     *
     * @param   {number} [digits=0] - Number of digits to appear after the decimal point (3 ≡ mm).
     * @returns {string} A string representation of the coordinate.
     *
     * @example
     *   var utm = Utm.parse('31 N 448251 5411932').toString(4)  // 31 N 448251.0000 5411932.0000
     */
    func toString(precision: Int = 0) -> String  {
        let z = self.zone < 10 ? "0\(self.zone)" : String(self.zone) // leading zero
        let h = self.hemisphere
        let e = self.easting
        let n = self.northing
        
        if !["N", "S"].contains(h) {
            return ""
        }
        return "\(z) \(h) \(String(format: "%.\(precision)f", e)) \(String(format: "%.\(precision)f", n))"
    }
    
}

extension LatLon {
    /**
     * Converts latitude/longitude to UTM coordinate.
     *
     * Implements Karney’s method, using Krüger series to order n^6, giving results accurate to 5nm for
     * distances up to 3900km from the central meridian.
     *
     * @returns {Utm}   UTM coordinate.
     * @throws  {Error} If point not valid, if point outside latitude range.
     *
     * @example
     *   let latlong = new LatLon(48.8582, 2.2945)
     *   let utmCoord = latlong.toUtm() // utmCoord.toString(): "31 N 448252 5411933"
     */
    func toUtm() throws -> Utm {
        if self.lat.isNaN || self.lon.isNaN {
            throw UtmMgrsError.fail("Invalid point")
        }
        
        
        if !(-80<=self.lat && self.lat<=84) {
            throw UtmMgrsError.fail("Outside UTM limits")
        }
        
        let falseEasting = 500e3
        let falseNorthing = 10000e3
        
        var zone = Int(floor((self.lon+180)/6) + 1) // longitudinal zone
        var λ0 = (Double(zone-1)*6 - 180 + 3).degreesToRadians // longitude of central meridian
        
        // ---- handle Norway/Svalbard exceptions
        // grid zones are 8° tall 0°N is offset 10 into latitude bands array
        let mgrsLatBands = "CDEFGHJKLMNPQRSTUVWXX" // X is repeated for 80-84°N
        let idx = Int(floor(self.lat/8+10))
        let latBand = Array(mgrsLatBands.characters)[idx] // charAt(floor(self.lat/8+10))
        // adjust zone & central meridian for Norway
        if (zone==31 && latBand=="V" && self.lon >= 3) {
            zone += 1
            λ0 += (6.0).degreesToRadians
        }
        // adjust zone & central meridian for Svalbard
        if (zone==32 && latBand=="X" && self.lon <  9) {
            zone -= 1
            λ0 -= (6.0).degreesToRadians
        }
        if (zone==32 && latBand=="X" && self.lon >= 9) {
            zone += 1
            λ0 += (6.0).degreesToRadians
        }
        if (zone==34 && latBand=="X" && self.lon < 21) {
            zone -= 1
            λ0 -= (6.0).degreesToRadians
        }
        if (zone==34 && latBand=="X" && self.lon >= 21) {
            zone += 1
            λ0 += (6.0).degreesToRadians
        }
        if (zone==36 && latBand=="X" && self.lon < 33) {
            zone -= 1
            λ0 -= (6.0).degreesToRadians
        }
        if (zone==36 && latBand=="X" && self.lon >= 33) {
            zone += 1
            λ0 += (6.0).degreesToRadians
        }
        
        let φ = self.lat.degreesToRadians     // latitude ± from equator
        let λ = self.lon.degreesToRadians - λ0 // longitude ± from central meridian
        
        let a = Double(self.datum.ellipsoid["a"]!)
        let f = Double(self.datum.ellipsoid["f"]!)
        
        // WGS 84: a = 6378137, b = 6356752.314245, f = 1/298.257223563
        
        let k0 = 0.9996 // UTM scale on the central meridian
        
        // ---- easting, northing: Karney 2011 Eq 7-14, 29, 35:
        
        let e = sqrt(f*(2-f)) // eccentricity
        let n = f / (2 - f)        // 3rd flattening
        let n2 = n*n, n3 = n*n2, n4 = n*n3, n5 = n*n4, n6 = n*n5 // TODO: compare Horner-form accuracy?
        
        let cosλ = cos(λ), sinλ = sin(λ), tanλ = tan(λ)
        
        let τ = tan(φ) // τ ≡ tanφ, τʹ ≡ tanφʹ prime (ʹ) indicates angles on the conformal sphere
        let σ = sinh(e*atanh(e*τ/sqrt(1+τ*τ)))
        
        let τʹ = τ*sqrt(1+σ*σ) - σ*sqrt(1+τ*τ)
        
        let ξʹ = atan2(τʹ, cosλ)
        let ηʹ = asinh(sinλ / sqrt(τʹ*τʹ + cosλ*cosλ))
        
        let A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6) // 2πA is the circumference of a meridian
        
        let α = [ 0, // note α is one-based array (6th order Krüger expressions)
            1/2*n - 2/3*n2 + 5/16*n3 +   41/180*n4 -     127/288*n5 +      7891/37800*n6,
            13/48*n2 -  3/5*n3 + 557/1440*n4 +     281/630*n5 - 1983433/1935360*n6,
            61/240*n3 -  103/140*n4 + 15061/26880*n5 +   167603/181440*n6,
            49561/161280*n4 -     179/168*n5 + 6601661/7257600*n6,
            34729/80640*n5 - 3418889/1995840*n6,
            212378941/319334400*n6 ]
        
        var ξ = ξʹ
        for j in 1...6 {
            ξ += α[j] * sin(2.0*Double(j)*ξʹ) * cosh(2*Double(j)*ηʹ)
        }
        
        var η = ηʹ
        for j in 1...6 {
            η += α[j] * cos(2.0*Double(j)*ξʹ) * sinh(2*Double(j)*ηʹ)
        }
        
        var x = k0 * A * η
        var y = k0 * A * ξ
        
        // ---- convergence: Karney 2011 Eq 23, 24
        
        var pʹ = 1.0
        for j in 1...6 {
            pʹ += 2.0*Double(j)*α[j] * cos(2.0*Double(j)*ξʹ) * cosh(2.0*Double(j)*ηʹ)
        }
        
        
        var qʹ = 0.0
        for j in 1...6 {
            qʹ += 2.0*Double(j)*α[j] * sin(2.0*Double(j)*ξʹ) * sinh(2.0*Double(j)*ηʹ)
        }
        
        let γʹ = atan(τʹ / sqrt(1+τʹ*τʹ)*tanλ)
        let γʺ = atan2(qʹ, pʹ)
        
        let γ = γʹ + γʺ
        
        // ---- scale: Karney 2011 Eq 25
        
        let sinφ = sin(φ)
        let kʹ = sqrt(1 - e*e*sinφ*sinφ) * sqrt(1 + τ*τ) / sqrt(τʹ*τʹ + cosλ*cosλ)
        let kʺ = A / a * sqrt(pʹ*pʹ + qʹ*qʹ)
        
        let k = k0 * kʹ * kʺ
        
        // ------------
        
        // shift x/y to false origins
        x = x + falseEasting             // make x relative to false easting
        if (y < 0) {
            y = y + falseNorthing // make y in southern hemisphere relative to false northing
        }
        // round to reasonable precision
        x =  x.roundTo(places: 6) // nm precision
        y = y.roundTo(places: 6) // nm precision

        let convergence = γ.radiansToDegrees.roundTo(places: 9)
        let scale = k.roundTo(places: 12)
        let h = self.lat>=0 ? "N" : "S" // hemisphere
        
        return try Utm(zone: zone, hemisphere: h, easting: x, northing: y, datum: self.datum, convergence: convergence, scale: scale)
    }
    
}
