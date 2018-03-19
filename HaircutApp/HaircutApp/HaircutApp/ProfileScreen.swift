//
//  ProfileScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/2/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class ProfileScreen: UIViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var specialtiesLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    var databaseRef : DatabaseReference?
    var id : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if FBSDKAccessToken.current() != nil {
            
            if id != nil {
                if FBSDKAccessToken.current().userID != id {
                    editBtn.isHidden = true
                    databaseRef = Database.database().reference().child("authUsers")
                    
                    databaseRef?.observeSingleEvent(of: .value, with: { snapshot in
                        
                        let user = UserInfo(key: self.id!, snapshot: snapshot)
                        self.fullNameLabel.text = user.fullName
                        self.specialtiesLabel.text = user.specialties
                        
                    })
                }
                else {
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, relationship_status"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil){
                            self.editBtn.isHidden = false
                            let fbDetails = result as! NSDictionary
                            let nameAsString = fbDetails["name"]!
                            self.fullNameLabel.text = String(describing: nameAsString)
                            self.databaseRef = Database.database().reference().child("authUsers")
                            self.specialtiesLabel.text = ""
                        }
                    })
                }
            }
            else{
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, relationship_status"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        self.editBtn.isHidden = false
                        let fbDetails = result as! NSDictionary
                        let nameAsString = fbDetails["name"]!
                        self.fullNameLabel.text = String(describing: nameAsString)
                        //let userID = String(describing: fbDetails["id"]! )
                        self.databaseRef = Database.database().reference().child("authUsers")
                        self.specialtiesLabel.text = ""
                        
//                        self.databaseRef?.observeSingleEvent(of: .childAdded, with: { (snapshot) in
//                            guard let data = snapshot.value as! [String:AnyObject]? else { return print("Snapshot error!")}
//                            if let user = data[userID] {
//                                let goodUser = UserInfo(key: userID, snapshot: snapshot)
//                                self.specialtiesLabel.text = goodUser.specialties
//                                print(user)
//
//                            }
//                            else {
//                                self.specialtiesLabel.text = ""
//                            }
//                        })
                    }
                })
            }
        }
        else {
            let userID = String(Auth.auth().currentUser!.uid)
            databaseRef = Database.database().reference().child("authUsers")
            
            if id != nil {
                if id != userID {
                    editBtn.isHidden = true
                    
                    databaseRef?.observeSingleEvent(of: .value, with: { snapshot in
                        
                        let user = UserInfo(key: self.id!, snapshot: snapshot)
                        self.fullNameLabel.text = user.fullName
                        self.specialtiesLabel.text = user.specialties
                    })
                }
                else {
                    databaseRef?.observeSingleEvent(of: .value, with: { snapshot in
                        
                        let user = UserInfo(key: userID, snapshot: snapshot)
                        self.fullNameLabel.text = user.fullName
                        self.specialtiesLabel.text = user.specialties
                    })
                }
            }
            else {
                databaseRef?.observeSingleEvent(of: .value, with: { snapshot in
                    
                    let user = UserInfo(key: userID, snapshot: snapshot)
                    self.fullNameLabel.text = user.fullName
                    self.specialtiesLabel.text = user.specialties
                })
            }
        }
    }

    @IBAction func toSettings(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    @IBAction func unwindToProfileScreen(segue:UIStoryboardSegue) {}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
