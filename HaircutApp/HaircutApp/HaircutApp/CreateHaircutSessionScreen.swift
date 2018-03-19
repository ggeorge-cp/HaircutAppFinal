//
//  CreateHaircutSessionScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/2/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import Firebase
import FirebaseDatabase

class CreateHaircutSessionScreen: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var startTimeTF: UITextField!
    @IBOutlet weak var endTimeTF: UITextField!
    let locationManager = CLLocationManager()
    var currentLat : Double?
    var currentLong : Double?
    
    var databaseRef : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference().child("appointments")

        self.startTimeTF.delegate = self
        self.endTimeTF.delegate = self
        
        startTimeTF.text = "00:00 AM"
        endTimeTF.text = "00:00 PM"
        
        configureLocationManager()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startTimeTF.resignFirstResponder()
        endTimeTF.resignFirstResponder()
        
        return true
    }
    
    // Segues
    @IBAction func backToHomeScreen(_ sender: UIButton) {
        
        var id : String?
        var fullName : String?
        
        if FBSDKAccessToken.current() != nil {
            id = String(FBSDKAccessToken.current().userID)
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, relationship_status"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let fbDetails = result as! NSDictionary
                    let nameAsString = fbDetails["name"]!
                    fullName = String(describing: nameAsString)
                    
                    var sessionTime : [String : Any]
                    
                    sessionTime = [
                        "startTime" : self.startTimeTF.text!,
                        "endTime" : self.endTimeTF.text!,
                        "lat" : self.currentLat ?? 0.0,
                        "long" : self.currentLong ?? 0.0,
                        "id" : id ?? "",
                        "name" : fullName ?? ""
                    ]
                    
                    self.databaseRef?.child(String(FBSDKAccessToken.current().userID)).setValue(sessionTime)
                }
            })
        }
        else{
            id = String(Auth.auth().currentUser!.uid)
            let ref = Database.database().reference().child("authUsers")
            
            ref.observeSingleEvent(of: .value, with: { snapshot in
                
                var sessionTime : [String : Any]
                let fullNameObject = UserInfo(key: id!, snapshot: snapshot)
                fullName = fullNameObject.fullName
                
                sessionTime = [
                    "startTime" : self.startTimeTF.text!,
                    "endTime" : self.endTimeTF.text!,
                    "lat" : self.currentLat ?? 0.0,
                    "long" : self.currentLong ?? 0.0,
                    "id" : id ?? "",
                    "name" : fullName ?? ""
                ]
                
                self.databaseRef?.child(String(Auth.auth().currentUser!.uid)).setValue(sessionTime)
            })
        }
        
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }

    // Locations
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1.0
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first{
            currentLat = loc.coordinate.latitude
            currentLong = loc.coordinate.longitude
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
