//
//  HomeScreen.swift
//  HaircutApp
//
//  Created by CheckoutUser on 3/2/18.
//  Copyright © 2018 CheckoutUser. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation
import GeoFire
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class HomeScreen: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var annotations = [MKPointAnnotation]()
    var databaseRef : DatabaseReference?
    var barbers : Barbers?
    var geoFireBusiness : GeoFire?
    var geoFireUser : GeoFire?
    var regionQuery : GFRegionQuery?
    var currentLat : Double?
    var currentLong : Double?
    var barberData : String?
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var createSessionButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    var hamburgerMenuIsVisible = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileButton.isHidden = true
        createSessionButton.isHidden = true
        signOutButton.isHidden = true
        
        configureLocationManager()
        
        databaseRef = Database.database().reference()
        geoFireBusiness = GeoFire(firebaseRef: Database.database().reference().child("GeoFire").child("business"))
        geoFireUser = GeoFire(firebaseRef: Database.database().reference().child("GeoFire").child("user"))
        mapView.delegate = self
        
        //let roundedLat = Int(currentLat ?? 0)
        //let roundedLong = Int(currentLong ?? 0)
        
        barberData = "https://api.foursquare.com/v2/venues/search?client_id=ZKJ1MMDJU5SI5JL10UDBLDWLDSB0ZHCWXZFMRASNX1RBIB1A&client_secret=KCMAVC1ZZFSQS25TIUDE4KTGFPVEFZOXYB13PWC5X3UBCKIV&ll=35.2,-120.6&query=barber&v=20180301"
        
        print("!!!!!!!!!!!!!!!")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: URL(string: barberData!)!)
        
        let task: URLSessionDataTask = session.dataTask(with: request)
        { (receivedData, response, error) -> Void in
            
            if let data = receivedData {
                do {
                    let decoder = JSONDecoder()
                    let haircutVenueService = try decoder.decode(HaircutVenueService.self, from: data)
                    self.barbers = haircutVenueService.response
                    
                    for barber in (self.barbers?.venues)! {
                        print(barber.name!)
                        self.databaseRef?.child("response").child(barber.name!).setValue(barber.toAnyObject())
                    }
                    
                } catch {
                    print("Exception on Decode: \(error)")
                }
            }
        }
        task.resume()
        
        oneTimeInit()
    }
    
    // Hamburger button
    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        if !hamburgerMenuIsVisible {
            leadingC.constant = 200
            trailingC.constant = -200
            hamburgerMenuIsVisible = true
            profileButton.isHidden = false
            createSessionButton.isHidden = false
            signOutButton.isHidden = false
        }
        else {
            leadingC.constant = 0
            trailingC.constant = 0
            hamburgerMenuIsVisible = false
            profileButton.isHidden = true
            createSessionButton.isHidden = true
            signOutButton.isHidden = true
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            //print("Animation complete!!")
        }
    }
    
    @IBAction func signOutBtnTapped(_ sender: Any) {
        
        if FBSDKAccessToken.current() != nil {
            do {
                try Auth.auth().signOut()
                FBSDKLoginManager().logOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        else {
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
        performSegue(withIdentifier: "signedOutClicked", sender: self)
    }
    
    // Segues
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {}
    
    // One Time Init
    func oneTimeInit() {
        databaseRef?.child("response").queryOrdered(byChild: "response").observe(.value, with:
            { snapshot in
                
                var newBarbers = [BarbersClass]()

                for item in snapshot.children {
                    newBarbers.append(BarbersClass(snapshot: item as! DataSnapshot))
                }
                
                for next in newBarbers {
                    self.geoFireBusiness?.setLocation(CLLocation(latitude:next.latitude,longitude:next.longitude), forKey: next.name)
                }
        })
        
        databaseRef?.child("appointments").queryOrdered(byChild: "appointments").observe(.value, with:
            { snapshot in
                
                var newUsers = [Users]()
                
                for item in snapshot.children {
                    newUsers.append(Users(snapshot: item as! DataSnapshot))
                }
                
                for next in newUsers {
                    self.geoFireUser?.setLocation(CLLocation(latitude:next.lat,longitude:next.long), forKey: next.id)
                }
        })
    }
    
    // Map Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first{
            print(loc.coordinate.latitude)
            print(loc.coordinate.longitude)
            
            currentLat = loc.coordinate.latitude
            currentLong = loc.coordinate.longitude
            
            let center = CLLocationCoordinate2D(latitude: currentLat!, longitude: currentLong!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1.0
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        
        updateRegionQuery()
    }
    
    func updateRegionQuery() {
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        regionQuery = geoFireBusiness?.query(with: mapView.region)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in

            self.databaseRef?.child("response").queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
                
                let newBarber = BarbersClass(key:key, snapshot:snapshot)
                
                self.addBarber(newBarber)
            })
        })
        
        regionQuery = geoFireUser?.query(with: mapView.region)

        regionQuery?.observe(.keyEntered, with: { (key, location) in

            self.databaseRef?.child("appointments").queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
                
                let newUser = Users(key: key, snapshot: snapshot)

                self.addUser(newUser)

            })
        })
    }
    
    func addBarber(_ barber : BarbersClass) {
        DispatchQueue.main.async {
            self.mapView.addAnnotation(barber)
        }
    }
    
    func addUser(_ user : Users) {
        DispatchQueue.main.async {
            print("!!!!!!!!!!!!!!!!")
            print(user.id)
            self.mapView.addAnnotation(user)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is BarbersClass {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = .red
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            
            // Disclosure button
            let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
        }
        
        if annotation is Users {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = .blue
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            
            // Disclosure button
            let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
        }
        
        return nil
    }
    
    // Segues
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        if view.annotation is BarbersClass {
            performSegue(withIdentifier: "toBusinessInfo", sender: view.annotation?.title ?? "")
        }
        else {
            performSegue(withIdentifier: "toUserInfo", sender: view.annotation?.title ?? "")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBusinessInfo"{
            let destVC = segue.destination as! BusinessInfoScreen
            
            destVC.keyBarberName = sender as? String
        }
        
        if segue.identifier == "toUserInfo"{
            let destVC = segue.destination as! UserInfoScreen
            
            destVC.id = sender as? String
        }
    }
    
    
    
}
