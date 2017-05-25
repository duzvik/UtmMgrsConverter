/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Vector handling functions                                          (c) Chris Veness 2011-2016  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/geodesy/docs/module-vector3d.html                               */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

/**
 * Library of 3-d vector manipulation routines.
 *
 * In a geodesy context, these vectors may be used to represent:
 *  - n-vector representing a normal to point on Earth's surface
 *  - earth-centered, earth fixed vector (≡ Gade’s ‘p-vector’)
 *  - great circle normal to vector (on spherical earth model)
 *  - motion vector on Earth's surface
 *  - etc
 *
 * Functions return vectors as return results, so that operations can be chained.
 * @example var v = v1.cross(v2).dot(v3) // ≡ v1×v2⋅v3
 *
 *  Converted by Denys Iuzvyk from http://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html  https://github.com/chrisveness/geodesy
 */

import Foundation
class Vector3d {
    var x: Double
    var y: Double
    var z: Double
    
    /**
     * Creates a 3-d vector.
     *
     * The vector may be normalised, or use x/y/z values for eg height relative to the sphere or
     * ellipsoid, distance from earth centre, etc.
     *
     * @constructor
     * @param {number} x - X component of vector.
     * @param {number} y - Y component of vector.
     * @param {number} z - Z component of vector.
     */
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     * Adds supplied vector to ‘this’ vector.
     *
     * @param   {Vector3d} v - Vector to be added to this vector.
     * @returns {Vector3d} Vector representing sum of this and v.
     */
    func plus(v: Vector3d) -> Vector3d {
        return  Vector3d(x: self.x + v.x, y: self.y + v.y, z: self.z + v.z)
    }
    
    /**
     * Subtracts supplied vector from ‘this’ vector.
     *
     * @param   {Vector3d} v - Vector to be subtracted from this vector.
     * @returns {Vector3d} Vector representing difference between this and v.
     */
    func minus(v: Vector3d) -> Vector3d {
        return Vector3d(x: self.x - v.x, y: self.y - v.y, z: self.z - v.z)
    }
    
    
    /**
     * Multiplies ‘this’ vector by a scalar value.
     *
     * @param   {number}   x - Factor to multiply this vector by.
     * @returns {Vector3d} Vector scaled by x.
     */
    func times(x: Double) -> Vector3d{
        return Vector3d(x: self.x * x, y: self.y * x, z: self.z * x)
    }
    
    
    /**
     * Divides ‘this’ vector by a scalar value.
     *
     * @param   {number}   x - Factor to divide this vector by.
     * @returns {Vector3d} Vector divided by x.
     */
    func dividedBy(x: Double) -> Vector3d{
        return Vector3d(x: self.x / x, y: self.y / x, z: self.z / x)
    }
    
    
    /**
     * Multiplies ‘this’ vector by the supplied vector using dot (scalar) product.
     *
     * @param   {Vector3d} v - Vector to be dotted with this vector.
     * @returns {number} Dot product of ‘this’ and v.
     */
    func dot(v: Vector3d) -> Double {
        return self.x*v.x + self.y*v.y + self.z*v.z
    }
    
    
    /**
     * Multiplies ‘this’ vector by the supplied vector using cross (vector) product.
     *
     * @param   {Vector3d} v - Vector to be crossed with this vector.
     * @returns {Vector3d} Cross product of ‘this’ and v.
     */
    func cross(v: Vector3d) -> Vector3d {
        let x = self.y*v.z - self.z*v.y
        let y = self.z*v.x - self.x*v.z
        let z = self.x*v.y - self.y*v.x
        
        return Vector3d(x: x, y: y, z: z)
    }
    
    
    /**
     * Negates a vector to point in the opposite direction
     *
     * @returns {Vector3d} Negated vector.
     */
    func negate() -> Vector3d {
        return  Vector3d(x: -self.x, y: -self.y, z: -self.z)
    }
    
    
    /**
     * Length (magnitude or norm) of ‘this’ vector
     *
     * @returns {number} Magnitude of this vector.
     */
    func length() -> Double {
        return Double(self.x*self.x + self.y*self.y + self.z*self.z).squareRoot()
    }
    
    
    /**
     * Normalizes a vector to its unit vector
     * – if the vector is already unit or is zero magnitude, this is a no-op.
     *
     * @returns {Vector3d} Normalised version of this vector.
     */
    func unit() -> Vector3d {
        let norm = self.length()
        if (norm == 1) {
            return self
        }
        if (norm == 0) {
            return self
        }
        
        let x = self.x/norm
        let y = self.y/norm
        let z = self.z/norm
        
        return Vector3d(x: x, y: y, z: z)
    }
    
    
    
    /**
     * Calculates the angle between ‘this’ vector and supplied vector.
     *
     * @param   {Vector3d} v
     * @param   {Vector3d} [n] - Plane normal: if supplied, angle is -π..+π, signed +ve if this->v is
     *     clockwise looking along n, -ve in opposite direction (if not supplied, angle is always 0..π).
     * @returns {number} Angle (in radians) between this vector and supplied vector.
     */
    func angleTo(v: Vector3d, n: Vector3d) -> Double{
        //var sign = n==undefined ? 1 : Math.sign(this.cross(v).dot(n))
        let sign = self.cross(v: v).dot(v: n) < 0 ? -1.0 : 1.0
        let sinθ = self.cross(v: v).length() * sign
        let cosθ = self.dot(v: v)
        return atan2(sinθ, Double(cosθ))
    }
    
    
    /**
     * Rotates ‘this’ point around an axis by a specified angle.
     *
     * @param   {Vector3d} axis - The axis being rotated around.
     * @param   {number}   theta - The angle of rotation (in radians).
     * @returns {Vector3d} The rotated point.
     */
    func rotateAround(axis: Vector3d, theta: Double) -> Vector3d {
        
        // en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
        // en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Quaternion-derived_rotation_matrix
        let p1 = self.unit()
        let p = [ p1.x, p1.y, p1.z ] // the point being rotated
        let a = axis.unit()          // the axis being rotated around
        let s = sin(theta)
        let c = cos(theta)
        
        // quaternion-derived rotation matrix
        let q: [[Double]] = [
            [a.x*a.x*Double(1.0-c) + c, a.x*a.y*Double(1.0-c) - a.z*s, a.x*a.z*Double(1.0-c) + a.y*s ],
            [ a.y*a.x*Double(1.0-c) + a.z*s, a.y*a.y*Double(1.0-c) + c,     a.y*a.z*Double(1.0-c) - a.x*s ],
            [ a.z*a.x*Double(1.0-c) - a.y*s, a.z*a.y*Double(1.0-c) + a.x*s, a.z*a.z*Double(1.0-c) + c     ],
        ]
        
        // multiply q × p
        var qp = [ 0.0, 0.0, 0.0 ]
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                qp[i] += q[i][j] * p[j]
            }
        }
        
        let p2 = Vector3d(x: qp[0], y: qp[1], z: qp[2])
        return p2
        // qv en.wikipedia.org/wiki/Rodrigues'_rotation_formula...
    }
    
    /**
     * String representation of vector.
     *
     * @param   {number} [precision=3] - Number of decimal places to be used.
     * @returns {string} Vector represented as [x,y,z].
     */
    func toString(precision: Int = 3) -> String {
        let format = "%.\(precision)f"
        return "[\(String(format: format, self.x)), \(String(format: format, self.y)), \(String(format: format, self.z))]"
    }
}
