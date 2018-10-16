//
//  HomeViewController.swift
//  SafeCrossing
//
//  
//

import UIKit
import Firebase
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Showing user location
    @IBOutlet weak var roadLabel: UILabel!
    @IBOutlet weak var suburbLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var direction1Label: UILabel!
    @IBOutlet weak var direction2Label: UILabel!
    @IBOutlet weak var distance1Label: UILabel!
    
    @IBOutlet weak var speed1Label: UILabel!
    @IBOutlet weak var distance2Label: UILabel!
    @IBOutlet weak var speed2Label: UILabel!
    @IBOutlet weak var safeImageView: UIImageView!
    
    // MARK: Firebase login & signup
    var storageRef = Storage.storage()
    let rootRef = Database.database().reference()
    let user = Auth.auth().currentUser!.uid
    var userRefHandle: DatabaseHandle?
    
    // MARK: Getting user location
    let manager = CLLocationManager()
    //let geocoder = CLGeocoder()
    var locality = ""
    var administrativeArea = ""
    var country = ""
    //var location = CLLocation().self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for getting user location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    @IBAction func logoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get the latest location")
        guard let currentLocation = locations.first else { return }
        var latitude = currentLocation.coordinate.latitude
        var longitude = currentLocation.coordinate.longitude
        
        let userRef = rootRef.child("Users/\(user)")
        let geoRef = userRef.childByAutoId()
        geoRef.child("latitude").setValue(latitude)
        geoRef.child("longitude").setValue(longitude)
        
        print("lat: \(latitude), long: \(longitude)")
        //manager.stopUpdatingLocation()
        //self.location = currentLocation
        convertLatLongToAddress(latitude: latitude, longitude: longitude)
    }
    
    // https://stackoverflow.com/questions/51905877/converting-cllocationcoordinate2d-to-street-address-with-swift
    func convertLatLongToAddress(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        //let geocoder = CLGeocoder()
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            
            //let placemark = placemarks! as [CLPlacemark]
            if ((placemarks?.count)!) > 0 {
                let pm = placemarks![0] as CLPlacemark
                if let locationName = pm.location {
                    print(locationName)
                }
                // Street address
                if let street = pm.thoroughfare {
                    print(street)
                    self.roadLabel.text = street
                }
                // City
                if let city = pm.locality {
                    print(city)
                    self.suburbLabel.text = city
                }
                
                // State
                if let state = pm.administrativeArea {
                    print(state)
                    self.stateLabel.text = state
                }
            }
        })
        
    }
    
    //    func userLocationString() -> String {
    //        let userLocationString = "\(locality), \(administrativeArea), \(country)"
    //        print("\(userLocationString)")
    //        return userLocationString
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
