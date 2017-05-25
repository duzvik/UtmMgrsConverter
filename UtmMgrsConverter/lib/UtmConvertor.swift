/**
 * Convert between Universal Transverse Mercator coordinates and WGS 84 latitude/longitude points.
 *
 * Method based on Karney 2011 ‘Transverse Mercator with an accuracy of a few nanometers’,
 * building on Krüger 1912 ‘Konforme Abbildung des Erdellipsoids in der Ebene’.
 *
 * @module   utm
 * @requires latlon-ellipsoidal
 */

import Foundation

class UtmConvertor {
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
     *   var utmCoord = new Utm(31, 'N', 448251, 5411932);
     */
 /*  init(zone: Int, hemisphere: String, easting: Int, northing: Int, datum, convergence, scale) {
    if (!(this instanceof Utm)) { // allow instantiation without 'new'
    return new Utm(zone, hemisphere, easting, northing, datum, convergence, scale);
    }
    
    if (datum === undefined) datum = LatLon.datum.WGS84; // default if not supplied
    if (convergence === undefined) convergence = null;   // default if not supplied
    if (scale === undefined) scale = null;               // default if not supplied
    
    if (!(1<=zone && zone<=60)) throw new Error('Invalid UTM zone '+zone);
    if (!hemisphere.match(/[NS]/i)) throw new Error('Invalid UTM hemisphere '+hemisphere);
    // range-check easting/northing (with 40km overlap between zones) - is this worthwhile?
    //if (!(120e3<=easting && easting<=880e3)) throw new Error('Invalid UTM easting '+ easting);
    //if (!(0<=northing && northing<=10000e3)) throw new Error('Invalid UTM northing '+ northing);
    
    this.zone = Number(zone);
    this.hemisphere = hemisphere.toUpperCase();
    this.easting = Number(easting);
    this.northing = Number(northing);
    this.datum = datum;
    this.convergence = convergence===null ? null : Number(convergence);
    this.scale = scale===null ? null : Number(scale);
    }*/
}
