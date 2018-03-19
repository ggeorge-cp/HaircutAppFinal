//
//  Barbers.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/5/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class BarbersClass : NSObject, MKAnnotation {
    
    let ref: DatabaseReference?
    var name : String
    var city : String
    var latitude : Double
    var longitude : Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }

    var subtitle: String? {
        return city
    }

    init(name: String, city: String) {
        self.name = name
        self.city = city
        self.latitude = 0
        self.longitude = 0
        ref = nil
        
        super.init()
    }

    init(key : String, snapshot: DataSnapshot) {
        name = key
        
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        city = snapvalues["city"] as? String ?? "N/A"
        latitude = snapvalues["lat"] as? Double ?? 0.0
        longitude = snapvalues["lng"] as? Double ?? 0.0
        
        ref = snapshot.ref
        super.init()
    }
    
    init(snapshot: DataSnapshot) {
        let snapvalues = snapshot.value as! [String : AnyObject]
        
        name = snapvalues["name"] as? String ?? "N/A"
        city = snapvalues["city"] as? String ?? "N/A"
        latitude = snapvalues["lat"] as? Double ?? 0.0
        longitude = snapvalues["lng"] as? Double ?? 0.0
        
        ref = snapshot.ref
        
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "name" : name,
            "city" : city,
            "lat" : latitude,
            "lng" : longitude
        ]
    }
}

struct Barbers : Codable {
    
    let venues : [Barber]
    
    struct Barber : Codable {
        var name : String?
        var contact : Contact?
        var location : Location?
        var categories : [Categories]?
        
        struct Contact : Codable {
            var formattedPhone : String?
        }
        
        struct Location : Codable {
            var address : String?
            var lat : Double?
            var lng : Double?
            var postalCode : String?
            var city : String?
            var state : String?
            var country : String?
        }
        
        struct Categories : Codable {
            var name : String?
        }
    
        func toAnyObject() -> Any {
            let validName = name ?? ""
            let vaidContact = contact?.formattedPhone ?? ""
            let validAddress = location?.address ?? ""
            let validLat = location?.lat ?? 0.0
            let validLng = location?.lng ?? 0.0
            let validPostalCode = location?.postalCode ?? ""
            let validCity = location?.city ?? ""
            let validState = location?.state ?? ""
            let validCountry = location?.country ?? ""
            
            
            return [
                "name" : validName,
                "contact" :  vaidContact,
                "address" : validAddress,
                "lat" : validLat,
                "lng" : validLng,
                "postalCode" : validPostalCode,
                "city" : validCity,
                "state" : validState,
                "country" : validCountry
            ]
        }
    
    }
    
    
}
