//
//  BusinessInfoScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/12/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class BusinessInfoScreen: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var databaseRef : DatabaseReference?
    var keyBarberName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference().child("response")
        
        databaseRef?.child(keyBarberName!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get value
            let value = snapshot.value as? NSDictionary
            
            let name = value?["name"] as? String ?? ""
            let address = value?["address"] as? String ?? ""
            let city = value?["city"] as? String ?? ""
            let state = value?["state"] as? String ?? ""
            let phone_number = value?["contact"] as? String ?? ""
            
            self.nameLabel.text = name
            
            if address != "" {
                self.addressLabel.text = address
            }
            else {
                self.addressLabel.text = "Not Available"
            }
            
            if city != "" {
                self.cityLabel.text = city
            }
            else {
                self.cityLabel.text = "Not Available"
            }
            
            if state != "" {
                self.stateLabel.text = state
            }
            else {
                self.stateLabel.text = "Not Available"
            }
            
            if phone_number != "" {
                self.phoneLabel.text = phone_number
            }
            else {
                self.phoneLabel.text = "Not Available"
            }
            
        }) { (error) in
            print(error.localizedDescription)
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
