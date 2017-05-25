/**
 * Library of geodesy functions for operations on an ellipsoidal earth model.
 *
 * Includes ellipsoid parameters and datums for different coordinate systems, and methods for
 * converting between them and to cartesian coordinates.
 *
 * q.v. Ordnance Survey ‘A guide to coordinate systems in Great Britain’ Section 6
 * www.ordnancesurvey.co.uk/docs/support/guide-coordinate-systems-great-britain.pdf.
 *
 *  Converted by Denys Iuzvyk from http://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html  https://github.com/chrisveness/geodesy
 */

import Foundation

class LatLon {
    
    var lat: Double
    var lon: Double
    var datum: DatumObject
    /**
     * Creates lat/lon (polar) point with latitude & longitude values, on a specified datum.
     *
     * @constructor
     * @param {number}       lat - Geodetic latitude in degrees.
     * @param {number}       lon - Longitude in degrees.
     * @param {LatLon.datum} [datum=WGS84] - Datum this point is defined within.
     *
     * @example
     *     var p1 = new LatLon(51.4778, -0.0016, LatLon.datum.WGS84)
     */
    init(lat: Double, lon: Double, datum: DatumObject? = nil) {
        self.lat = lat
        self.lon = lon
        
        
        self.datum = datum == nil ? Datum.WGS84 : datum!
    }
    /**
     * Ellipsoid parameters major axis (a), minor axis (b), and flattening (f) for each ellipsoid.
     */
    struct Ellipsoid {  //: [String : Dictionary<String, Double>] = [
        static let WGS84: [String : Double]         = [ "a": 6378137,     "b": 6356752.314245, "f":  1/298.257223563 ]
        static let Airy1830: [String : Double]      = [ "a": 6377563.396, "b": 6356256.909,    "f": 1/299.3249646   ]
        static let AiryModified: [String : Double]  = [ "a": 6377340.189, "b": 6356034.448,    "f": 1/299.3249646   ]
        static let Bessel1841: [String : Double]    = [ "a": 6377397.155, "b": 6356078.962818, "f": 1/299.1528128   ]
        static let Clarke1866: [String : Double]    = [ "a": 6378206.4,   "b": 6356583.8,      "f": 1/294.978698214 ]
        static let Clarke1880IGN: [String : Double] = [ "a": 6378249.2,   "b": 6356515.0,      "f": 1/293.466021294 ]
        static let GRS80: [String : Double]         = [ "a": 6378137,     "b": 6356752.314140, "f": 1/298.257222101 ]
        static let Intl1924: [String : Double]      = [ "a": 6378388,     "b": 6356911.946,    "f": 1/297           ] // aka Hayford
        static let WGS72: [String : Double]         = [ "a": 6378135,     "b": 6356750.5,      "f": 1/298.26        ]
    }
    
    
    /**
     * Datums with associated ellipsoid, and Helmert transform parameters to convert from WGS 84 into
     * given datum.
     *
     * Note that precision of various datums will vary, and WGS-84 (original) is not defined to be
     * accurate to better than ±1 metre. No transformation should be assumed to be accurate to better
     * than a meter for many datums somewhat less.
     */
    
    enum Datum  {
        // transforms: t in metres, s in ppm, r in arcseconds                    tx       ty        tz       s        rx       ry       rz
        static let Intl1924 = DatumObject(
            ellipsoid: LatLon.Ellipsoid.Intl1924,
            transform: [   89.5,    93.8,    123.1,    -1.2,     0.0,     0.0,     0.156  ]
        )
        static let ED50 = DatumObject(
            ellipsoid:  LatLon.Ellipsoid.Intl1924,
            transform:  [   89.5,    93.8,    123.1,    -1.2,     0.0,     0.0,     0.156  ]
        )
        static let Irl1975 = DatumObject(
            ellipsoid: LatLon.Ellipsoid.AiryModified,
            transform:  [ -482.530, 130.596, -564.557,  -8.150,  -1.042,  -0.214,  -0.631  ]
        )
        
        static let NAD27 = DatumObject(
            ellipsoid:  LatLon.Ellipsoid.Clarke1866,
            transform:  [    8,    -160,     -176,       0,       0,       0,       0      ]
        )
        
        static let NAD83 = DatumObject(
            ellipsoid : LatLon.Ellipsoid.GRS80,
            transform: [    1.004,  -1.910,   -0.515,  -0.0015,  0.0267,  0.00034, 0.011  ]
        )
        
        static let NTF = DatumObject(
            ellipsoid: LatLon.Ellipsoid.Clarke1880IGN,
            transform:  [  168,      60,     -320,       0,       0,       0,       0      ]
        )
        static let OSGB36 = DatumObject(
            ellipsoid: LatLon.Ellipsoid.Airy1830,
            transform: [ -446.448, 125.157, -542.060,  20.4894, -0.1502, -0.2470, -0.8421 ]
        )
        static let Potsdam = DatumObject(
            ellipsoid: LatLon.Ellipsoid.Bessel1841,
            transform: [ -582,    -105,     -414,      -8.3,     1.04,    0.35,   -3.08   ]
        )
        static let TokyoJapan = DatumObject(
            ellipsoid: LatLon.Ellipsoid.Bessel1841,
            transform:  [  148,    -507,     -685,       0,       0,       0,       0      ]
        )
        
        static let WGS72 = DatumObject(
            ellipsoid: LatLon.Ellipsoid.WGS72,
            transform:  [    0,       0,     -4.5,      -0.22,    0,       0,       0.554  ]
        )
        static let WGS84 = DatumObject(
            ellipsoid: LatLon.Ellipsoid.WGS84,
            transform: [    0.0,     0.0,      0.0,     0.0,     0.0,     0.0,     0.0    ]
        )
    }
    
    
    
    
    /* sources:
     * - ED50:          www.gov.uk/guidance/oil-and-gas-petroleum-operations-notices#pon-4
     * - Irl1975:       www.osi.ie/wp-content/uploads/2015/05/transformations_booklet.pdf
     *   ... note: many sources have opposite sign to rotations - to be checked!
     * - NAD27:         en.wikipedia.org/wiki/Helmert_transformation
     * - NAD83: (2009) www.uvm.edu/giv/resources/WGS84_NAD83.pdf
     *   ... note: functionally ≡ WGS84 - if you *really* need to convert WGS84<->NAD83, you need more knowledge than this!
     * - NTF:           Nouvelle Triangulation Francaise geodesie.ign.fr/contenu/fichiers/Changement_systeme_geodesique.pdf
     * - OSGB36:        www.ordnancesurvey.co.uk/docs/support/guide-coordinate-systems-great-britain.pdf
     * - Potsdam:       kartoweb.itc.nl/geometrics/Coordinate%20transformations/coordtrans.html
     * - TokyoJapan:    www.geocachingtoolbox.com?page=datumEllipsoidDetails
     * - WGS72:         www.icao.int/safety/pbn/documentation/eurocontrol/eurocontrol wgs 84 implementation manual.pdf
     *
     * more transform parameters are available from earth-info.nga.mil/GandG/coordsys/datums/NATO_DT.pdf,
     * www.fieldenmaps.info/cconv/web/cconv_params.js
     */
    
    
    
    /**
     * Converts ‘this’ lat/lon coordinate to new coordinate system.
     *
     * @param   {LatLon.datum} toDatum - Datum this coordinate is to be converted to.
     * @returns {LatLon} This point converted to new datum.
     *
     * @example
     *     var pWGS84 = new LatLon(51.4778, -0.0016, LatLon.datum.WGS84)
     *     var pOSGB = pWGS84.convertDatum(LatLon.datum.OSGB36) // 51.4773°N, 000.0000°E
     */
    func convertDatum(toDatum: DatumObject) -> LatLon {
        var oldLatLon = self
        var transform: [Double]?
        
        if oldLatLon.datum.isEqual(LatLon.Datum.WGS84) {
            // converting from WGS 84
            transform = toDatum.transform
        }
        if toDatum.isEqual(LatLon.Datum.WGS84) {
            // converting to WGS 84 use inverse transform (don't overwrite original!)
            transform = []
            for p in 0 ..< 7 {
                transform![p] =  -oldLatLon.datum.transform[p]
            }
        }
        
        if (transform == nil) {
            // neither this.datum nor toDatum are WGS84: convert this to WGS84 first
            oldLatLon = self.convertDatum(toDatum: LatLon.Datum.WGS84)
            transform = toDatum.transform
        }
        
        let oldCartesian = oldLatLon.toCartesian()                // convert polar to cartesian...
        let newCartesian = oldCartesian.applyTransform(t: transform!) // ...apply transform...
        let newLatLon = newCartesian.toLatLonE(datum: toDatum)           // ...and convert cartesian to polar
        
        return newLatLon
    }
    
    /**
     * Converts ‘this’ point from (geodetic) latitude/longitude coordinates to (geocentric) cartesian
     * (x/y/z) coordinates.
     *
     * @returns {Vector3d} Vector pointing to lat/lon point, with x, y, z in metres from earth centre.
     */
    func toCartesian() -> Vector3d {
        let φ = self.lat.degreesToRadians
        let λ = self.lon.degreesToRadians
        
        let h = 0.0 // height above ellipsoid - not currently used
        let a = self.datum.ellipsoid["a"]!
        let f = self.datum.ellipsoid["f"]!
        
        let sinφ = sin(φ)
        let cosφ = cos(φ)
        let sinλ = sin(λ)
        let cosλ = cos(λ)
        
        let eSq = 2.0*f - f*f                      // 1st eccentricity squared ≡ (a²-b²)/a²
        let ν = a / sqrt(1.0 - eSq*sinφ*sinφ) // radius of curvature in prime vertical
        
        let x = (ν+h) * cosφ * cosλ
        let y = (ν+h) * cosφ * sinλ
        let z = (ν*(1-eSq)+h) * sinφ
        
        let point = Vector3d(x: x, y: y, z: z)
        return point
    }
    
    
    /**
     * Returns a string representation of ‘this’ point, formatted as degrees, degrees+minutes, or
     * degrees+minutes+seconds.
     *
     * @param   {string} [format=dms] - Format point as 'd', 'dm', 'dms'.
     * @param   {number} [dp=0|2|4] - Number of decimal places to use - default 0 for dms, 2 for dm, 4 for d.
     * @returns {string} Comma-separated latitude/longitude.
     */
    func toString(format: String? = nil, dp: Int? = nil) -> String {
        return Dms.toLat(deg: self.lat, format: format, dp: dp) + ", " + Dms.toLon(deg: self.lon, format: format, dp: dp)
    }

}

extension Vector3d {
    /**
     * Converts ‘this’ (geocentric) cartesian (x/y/z) point to (ellipsoidal geodetic) latitude/longitude
     * coordinates on specified datum.
     *
     * Uses Bowring’s (1985) formulation for μm precision in concise form.
     *
     * @param {LatLon.datum.transform} datum - Datum to use when converting point.
     */
    func toLatLonE(datum: DatumObject) -> LatLon {
        let x = self.x
        let y = self.y
        let z = self.z
        
        let a = datum.ellipsoid["a"]!
        let b = datum.ellipsoid["b"]!
        let f = datum.ellipsoid["f"]!
        
        let e2 = 2*f - f*f   // 1st eccentricity squared ≡ (a²-b²)/a²
        let ε2 = e2 / (1-e2) // 2nd eccentricity squared ≡ (a²-b²)/b²
        let p = sqrt(x*x + y*y) // distance from minor axis
        let R = sqrt(p*p + z*z) // polar radius
        
        // parametric latitude (Bowring eqn 17, replacing tanβ = z·a / p·b)
        let tanβ = (b*z)/(a*p) * (1+ε2*b/R)
        let sinβ = tanβ / sqrt(1+tanβ*tanβ)
        let cosβ = sinβ / tanβ
        
        // geodetic latitude (Bowring eqn 18: tanφ = z+ε²bsin³β / p−e²cos³β)
        let φ = cosβ.isNaN ? 0 : atan2(z + ε2*b*sinβ*sinβ*sinβ, p - e2*a*cosβ*cosβ*cosβ)
        
        // longitude
        let λ = atan2(y, x)
        
        // height above ellipsoid (Bowring eqn 7) [not currently used]
        let sinφ = sin(φ)
        let cosφ = cos(φ)
        let ν = a/sqrt(1-e2*sinφ*sinφ) // length of the normal terminated by the minor axis
        let h = p*cosφ + z*sinφ - (a*a/ν)
        
        let point = LatLon(lat: φ.radiansToDegrees, lon: λ.radiansToDegrees, datum: datum)
        return point
    }
    
    
    /**
     * Applies Helmert transform to ‘this’ point using transform parameters t.
     *
     * @private
     * @param   {number[]} t - Transform to apply to this point.
     * @returns {Vector3} Transformed point.
     */
    func applyTransform(t: [Double]) -> Vector3d  {
        // this point
        let x1 = self.x
        let y1 = self.y
        let z1 = self.z
        
        // transform parameters
        let tx = t[0]                    // x-shift
        let ty = t[1]                    // y-shift
        let tz = t[2]                    // z-shift
        let s1 = t[3]/1e6 + 1            // scale: normalise parts-per-million to (s+1)
        let rx = (t[4]/3600).degreesToRadians // x-rotation: normalise arcseconds to radians
        let ry = (t[5]/3600).degreesToRadians // y-rotation: normalise arcseconds to radians
        let rz = (t[6]/3600).degreesToRadians // z-rotation: normalise arcseconds to radians
        
        // apply transform
        let x2 = tx + x1*s1 - y1*rz + z1*ry
        let y2 = ty + x1*rz + y1*s1 - z1*rx
        let z2 = tz - x1*ry + y1*rx + z1*s1
        
        return Vector3d(x: x2, y: y2, z: z2)
    }
    
    
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        let result = (self * divisor).rounded() / divisor
        return result
    }

    var cleanValue: String {
        return self.truncatingRemainder(dividingBy:  1) == 0 ? String(format: "%.0f", self) : String(self)
    }

}
