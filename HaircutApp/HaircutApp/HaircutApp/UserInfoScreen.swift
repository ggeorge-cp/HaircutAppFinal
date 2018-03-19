//
//  UserInfoScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/17/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserInfoScreen: UIViewController {
    
    var databaseRef : DatabaseReference?
    var id : String?

    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var barberNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference().child("authUsers")
        
        databaseRef?.child(id!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get value
            let value = snapshot.value as? NSDictionary
            
            let name = value?["fullName"] as? String ?? "Not Available"
            let number = value?["phone"] as? String ?? "Not Available"
            
            self.barberNameLabel.text = name
            self.phoneNumLabel.text = number
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func viewProfileBtnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "userInfoToProfile", sender: id ?? "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInfoToProfile"{
            let destVC = segue.destination as! ProfileScreen
            
            destVC.id = sender as? String
        }    }
 

}
