//
//  Users.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/15/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class Users : NSObject, MKAnnotation {
    
    let ref: DatabaseReference?
    var id : String
    var name : String
    var startTime : String
    var endTime : String
    var lat : Double
    var long : Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    var title: String? {
        return id
    }
    
    var subtitle: String? {
        return startTime + " to " + endTime
    }
    
    init(id: String, name: String, startTime: String, endTime: String) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.lat = 0
        self.long = 0
        ref = nil
        
        super.init()
    }
    
    init(key : String, snapshot: DataSnapshot) {
        id = key
        
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        
        name = snapvalues["name"] as? String ?? "N/A"
        startTime = snapvalues["startTime"] as? String ?? "N/A"
        endTime = snapvalues["endTime"] as? String ?? "N/A"
        lat = snapvalues["lat"] as? Double ?? 0.0
        long = snapvalues["long"] as? Double ?? 0.0
        
        ref = snapshot.ref
        super.init()
    }
    
    init(snapshot: DataSnapshot) {
        let snapvalues = snapshot.value as! [String : AnyObject]
        
        id = snapvalues["id"] as? String ?? "N/A"
        name = snapvalues["name"] as? String ?? "N/A"
        startTime = snapvalues["startTime"] as? String ?? "N/A"
        endTime = snapvalues["endTime"] as? String ?? "N/A"
        lat = snapvalues["lat"] as? Double ?? 0.0
        long = snapvalues["long"] as? Double ?? 0.0
        
        ref = snapshot.ref
        
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "id" : id,
            "name" : name,
            "startTime" : startTime,
            "endTime" : endTime,
            "lat" : lat,
            "long" : long
        ]
    }
}
