//
//  UserInfo.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/17/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import Foundation

import Foundation
import FirebaseDatabase
import MapKit

class UserInfo : NSObject {
    
    let ref: DatabaseReference?
    var id : String
    var fullName : String
    var phone : String
    var specialties : String
    
    init(id: String, fullName: String, phone: String, specialties: String) {
        self.id = id
        self.fullName = fullName
        self.phone = phone
        self.specialties = specialties
        ref = nil
        
        super.init()
    }
    
    init(key : String, snapshot: DataSnapshot) {
        id = key
        
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        
        fullName = snapvalues["fullName"] as? String ?? "N/A"
        phone = snapvalues["phone"] as? String ?? "N/A"
        specialties = snapvalues["specialties"] as? String ?? "N/A"
        
        ref = snapshot.ref
        super.init()
    }
    
    init(snapshot: DataSnapshot) {
        let snapvalues = snapshot.value as! [String : AnyObject]
        
        id = snapvalues["id"] as? String ?? "N/A"
        fullName = snapvalues["fullName"] as? String ?? "N/A"
        phone = snapvalues["phone"] as? String ?? "N/A"
        specialties = snapvalues["specialties"] as? String ?? "N/A"
        
        ref = snapshot.ref
        
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "id" : id,
            "fullName" : fullName,
            "phone" : phone,
            "specialties" : specialties
        ]
    }
}
