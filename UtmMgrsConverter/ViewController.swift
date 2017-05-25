//
//  ViewController.swift
//  UtmMgrsConverter
//
//  Created by Denys Iuzvyk on 5/24/17.
//  Copyright © 2017 duzvik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //UTM conversions
        do {
            let utm = try Utm.parse(utmCoord: "48 N 377298.745 1483034.794")
            let latlon = utm.toLatLonE()
            print(latlon.toString(format: "dms", dp: 4))
            
            let mgrs = try utm.toMgrs()
            print(mgrs.toString(precision: 10))
            print(try mgrs.toUtm().toLatLonE().toString(format: "dms", dp: 2))
        } catch let err as UtmMgrsError {
            print("FAILED!!! \(err.localizedDescription)")
        } catch {
            // Catch any other errors
            print("Err")
        }
    }
}
