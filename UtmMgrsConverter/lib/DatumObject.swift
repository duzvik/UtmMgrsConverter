import Foundation

class DatumObject: NSObject {
    var ellipsoid: [String:Double]
    var transform: [Double]
    
    
    init(ellipsoid: [String:Double], transform: [Double]) {
        self.transform = transform
        self.ellipsoid = ellipsoid
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DatumObject else {
            return false
        }
        let lhs = self
        
        return (lhs.ellipsoid == rhs.ellipsoid && lhs.transform == rhs.transform)
    }
}
