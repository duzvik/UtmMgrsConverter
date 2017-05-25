/**
 * Latitude/longitude points may be represented as decimal degrees, or subdivided into sexagesimal
 * minutes and seconds.
 *
 *  Converted by Denys Iuzvyk from http://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html  https://github.com/chrisveness/geodesy
 */


import Foundation

/**
 * Functions for parsing and representing degrees / minutes / seconds.
 * Latitude/longitude points may be represented as decimal degrees, or subdivided into sexagesimal
 * minutes and seconds.
 *
 */

class Dms {
    private init(){}
    /**
     * Parses string representing degrees/minutes/seconds into numeric degrees.
     *
     * This is very flexible on formats, allowing signed decimal degrees, or deg-min-sec optionally
     * suffixed by compass direction (NSEW). A variety of separators are accepted (eg 3° 37′ 09″W).
     * Seconds and minutes may be omitted.
     *
     * @param   {string|number} dmsStr - Degrees or deg/min/sec in variety of formats.
     * @returns {number} Degrees as decimal number.
     *
     * @example
     *     var lat = Dms.parseDMS('51° 28′ 40.12″ N');
     *     var lon = Dms.parseDMS('000° 00′ 05.31″ W');
     *     var p1 = new LatLon(lat, lon); // 51.4778°N, 000.0015°W
     */
    static func parseDMS(dmsStr: String) -> Double? {
        // check for signed decimal degrees without NSEW, if so return it directly
        //if (typeof dmsStr == 'number' && isFinite(dmsStr)) return Number(dmsStr);
        let dmsNumber = Double(dmsStr)
        
        if dmsNumber != nil {
            return dmsNumber!
        }
        
        // strip off any sign or compass dir'n & split out separate d/m/s
        var dms = dmsStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let firstChar = dms.characters.first, firstChar == "-" {
            dms.remove(at: dms.startIndex)
        }

        do {
            let regex = try NSRegularExpression(pattern: "[NSEW]$", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, dms.utf16.count)
            dms = regex.stringByReplacingMatches(in: dms, options: [], range: range, withTemplate: "")
        } catch {
            print("[Dms] ERROR1 regex parsing!")
            return nil
        }
        
        let dmsArray = split(str: dms, regex: "[^0-9.,]+").map{ Double($0) }.flatMap{$0}

        if dmsArray.isEmpty {
            print("[Dms] failed to convert to decimal degrees ")
            return nil
        }
        
        // and convert to decimal degrees...
        var deg: Double?
        
        switch dmsArray.count {
        case 3:  // interpret 3-part result as d/m/s
            deg = dmsArray[0]/1.0 + dmsArray[1]/60.0 + dmsArray[2]/3600.0
            break
        case 2:  // interpret 2-part result as d/m
            deg = dmsArray[0]/1.0 + dmsArray[1]/60.0
            break
        case 1:  // just d (possibly decimal) or non-separated dddmmss
            deg = dmsArray[0]
            // check for fixed-width unseparated format eg 0033709W
            //if (/[NS]/i.test(dmsStr)) deg = '0' + deg;  // - normalise N/S to 3-digit degrees
            //if (/[0-9]{7}/.test(deg)) deg = deg.slice(0,3)/1 + deg.slice(3,5)/60 + deg.slice(5)/3600;
            break
        default:
            print("[Dms] failed to convert to decimal degrees ")
            return nil
        }
        
        do {
            let testRegex = try NSRegularExpression(pattern: "^-|[WS]$", options: .caseInsensitive)
            let trimmedStr = dmsStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let matches = testRegex.matches(in: trimmedStr, options: [], range:NSMakeRange(0, trimmedStr.utf16.count ))
            if matches.count > 0 && deg != nil {
                deg = deg! * -1 // take '-', west and south as -ve
            }
        } catch {
            print("[Dms] ERROR2 regex parsing!")
            return nil
        }
        return deg
    }
    
    /**
     * Separator character to be used to separate degrees, minutes, seconds, and cardinal directions.
     *
     * Set to '\u202f' (narrow no-break space) for improved formatting.
     *
     * @example
     *   var p = new LatLon(51.2, 0.33);  // 51°12′00.0″N, 000°19′48.0″E
     *   Dms.separator = '\u202f';        // narrow no-break space
     *   var pʹ = new LatLon(51.2, 0.33); // 51° 12′ 00.0″ N, 000° 19′ 48.0″ E
     */
    static let separator = ""
    
    
    /**
    * Converts decimal degrees to deg/min/sec format
    *  - degree, prime, double-prime symbols are added, but sign is discarded, though no compass
    *    direction is added.
    *
    * @private
    * @param   {number} deg - Degrees to be formatted as specified.
    * @param   {string} [format=dms] - Return value as 'd', 'dm', 'dms' for deg, deg+min, deg+min+sec.
    * @param   {number} [dp=0|2|4] - Number of decimal places to use – default 0 for dms, 2 for dm, 4 for d.
    * @returns {string} Degrees formatted as deg/min/secs according to specified format.
    */
    static func toDMS(deg: Double, format: String? = "dms", dp: Int? = nil) -> String? {
        if deg.isNaN {
            return nil
        }
        
        var returnFormat = format ?? "dms"
        // for precision 0, set  3 the minimum width, including the dot character
        // for precision 2, set  6 the minimum width, including the dot character
        // for precision 4, set  8 the minimum width, including the dot character
        
        var degrees = deg
        var precisionFormat = ""
        var precision = 0
        //default values
            switch (returnFormat) {
            case "d", "deg":
                precision = dp ?? 4
                break
            case "dm", "deg+min":
                precision = dp ?? 2
                break
            case "dms", "deg+min+sec":
                precision = dp ?? 0
                break
            default:
                returnFormat = "dms"
                precision = 0  // be forgiving on invalid format
            }
        
        precisionFormat = "%.\(precision)f"
        degrees = abs(degrees)  // (unsigned result ready for appending compass dir'n)
        
        var dms = ""
        var d:Double = 0
        var m:Double = 0
        var s:Double = 0
        
        switch (returnFormat) {
        case "d", "deg":
            d = degrees
            var dStr =  String(format: precisionFormat, d)
            if d < 100{
                dStr = "0\(dStr)" // pad with leading zeros
            }
            if d < 10{
                dStr = "0\(dStr)"
            }
            dms = "\(dStr)°";
            break;
        case "dm","deg+min":
            
            d = floor(degrees)                       // get component deg
            m = ((degrees*60).truncatingRemainder(dividingBy: 60)).roundTo(places: precision)  // get component min & round/right-pad
            if (m == 60) { // check for rounding up
                m = 0
                d += 1
            }
            var dStr = String(format: "%g", d) //g = remove Trailing Zeros From Double
            dStr = "000\(dStr)"
            dStr = dStr.substring(from: dStr.index(dStr.endIndex, offsetBy: -3)) // left-pad with leading zeros
            
            var mStr = String(format: precisionFormat, m)
            if (m<10) {
                mStr = "0\(mStr)" // left-pad with leading zeros (note may include decimals)
            }
            dms = "\(dStr)°\(separator)\(mStr)′"
            break
        case "dms", "deg+min+sec":
            
            d = floor(degrees)                      // get component deg
            m = floor((degrees*3600)/60).truncatingRemainder(dividingBy: 60)        // get component min
            s = (degrees*3600).truncatingRemainder(dividingBy: 60).roundTo(places: precision)           // get component sec & round/right-pad
            if (s == 60) { // check for rounding up
                s = (0.0).roundTo(places: precision)
                m += 1;
            }
            
            if (m == 60) { // check for rounding up
                m = 0;
                d += 1;
            }
            var dStr = String(format: "%g", d)
            var mStr = String(format: "%g", m)
            var sStr = String(format: precisionFormat, s)
            
            dStr = "000\(dStr)"
            dStr = dStr.substring(from: dStr.index(dStr.endIndex, offsetBy: -3)) // left-pad with leading zeros
            
            mStr = "00\(mStr)"
            mStr = mStr.substring(from: mStr.index(mStr.endIndex, offsetBy: -2)) // left-pad with leading zeros

            if s < 10 {
                sStr = "0\(sStr)"                     // left-pad with leading zeros (note may include decimals)
            }
            dms = "\(dStr)°\(separator)\(mStr)′\(separator)\(sStr)″"
            break
        default: // invalid format spec!
            return nil
        }
        return dms
    }
    
    
    /**
     * Converts numeric degrees to deg/min/sec latitude (2-digit degrees, suffixed with N/S).
     *
     * @param   {number} deg - Degrees to be formatted as specified.
     * @param   {string} [format=dms] - Return value as 'd', 'dm', 'dms' for deg, deg+min, deg+min+sec.
     * @param   {number} [dp=0|2|4] - Number of decimal places to use – default 0 for dms, 2 for dm, 4 for d.
     * @returns {string} Degrees formatted as deg/min/secs according to specified format.
     */
    
    static func toLat(deg: Double, format: String? = "dms", dp: Int? = nil) -> String {
        guard var lat = Dms.toDMS(deg: deg, format: format, dp: dp) else {
            return "-"
        }
       
        lat.remove(at: lat.startIndex) // knock off initial '0' for lat!
        return "\(lat)\(separator)\((deg<0 ? "S" : "N"))"
    }
    
    /**
     * Convert numeric degrees to deg/min/sec longitude (3-digit degrees, suffixed with E/W)
     *
     * @param   {number} deg - Degrees to be formatted as specified.
     * @param   {string} [format=dms] - Return value as 'd', 'dm', 'dms' for deg, deg+min, deg+min+sec.
     * @param   {number} [dp=0|2|4] - Number of decimal places to use – default 0 for dms, 2 for dm, 4 for d.
     * @returns {string} Degrees formatted as deg/min/secs according to specified format.
     */
    static func toLon(deg: Double, format: String? = "dms", dp: Int? = nil) -> String {
        guard let lon = Dms.toDMS(deg: deg, format: format, dp: dp) else {
                return "-"
        }
        return "\(lon)\(separator)\((deg<0 ? "W" : "E"))"
    };
    
    static func split(str: String, regex pattern: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }
        
        //let nsString = str as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(in: str, options: [], range: NSRange.init(location: 0, length: str.utf16.count), withTemplate: stop)
        return modifiedString.components(separatedBy: stop)
    }

}
