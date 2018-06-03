//
//  SignUpScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/1/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
///Users/checkoutuser/Desktop/HaircutApp/HaircutApp/Base.lproj/Main.storyboard

import UIKit
import Firebase
import FirebaseDatabase

class SignUpScreen: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var databaseRef : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.passwordField.isSecureTextEntry = true

        
        databaseRef = Database.database().reference().child("authUsers")
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        if self.nameField.text == "" || self.emailField.text == "" || self.passwordField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter a username, email, and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                if error == nil {
                    
                    Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                        if error == nil {
                            
                            var userInfo : [String : Any]
                            
                            userInfo = [
                                "fullName" : self.nameField.text!,
                                "phone" : "Not Available",
                                "specialties" : ""
                            ]
                            
                            self.databaseRef?.child(String(Auth.auth().currentUser!.uid)).setValue(userInfo)
                            
                            do {
                                try Auth.auth().signOut()
                            } catch let signOutError as NSError {
                                print ("Error signing out: %@", signOutError)
                            }
                            
                        }
                        else {
                            let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                }
                else {
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        return true
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
