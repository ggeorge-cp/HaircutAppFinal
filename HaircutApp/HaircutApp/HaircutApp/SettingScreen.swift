//
//  SettingScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/12/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class SettingScreen: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var specialtiesTF: UITextField!
    
    var databaseRef : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference().child("authUsers")

        self.phoneNumTF.delegate = self
        self.specialtiesTF.delegate = self
        
        phoneNumTF.text = "(000) 000-0000"
    }

    @IBAction func saveBtnTapped(_ sender: Any) {
        if self.phoneNumTF.text == "" || self.specialtiesTF.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter a phone number and specialties.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            if FBSDKAccessToken.current() != nil {
                
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, relationship_status"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        let fbDetails = result as! NSDictionary
                        let nameAsString = fbDetails["name"]!
                        let fullName = String(describing: nameAsString)
                        
                        var userInfo : [String : Any]
                        
                        userInfo = [
                            "fullName": fullName,
                            "phone" : self.phoneNumTF.text!,
                            "specialties" : self.specialtiesTF.text!
                        ]
                        
                        self.databaseRef?.child(String(describing: fbDetails["id"]!)).setValue(userInfo)
                    }
                })
                
            }
            else {
                var userInfo : [String : Any]
                
                userInfo = [
                    "phone" : self.phoneNumTF.text!,
                    "specialties" : self.specialtiesTF.text!
                ]
                
                self.databaseRef?.child(String(Auth.auth().currentUser!.uid)).updateChildValues(userInfo)
            }
            
            performSegue(withIdentifier: "unwindToProfile", sender: self)
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
