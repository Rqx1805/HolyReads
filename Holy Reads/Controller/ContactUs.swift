//
//  ContactUs.swift
//  Holy Reads
//
//  Created by mac-14 on 31/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class ContactUs: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtMeassage: UITextField!
    @IBOutlet weak var mapviewnew: GMSMapView!
    var locationManager = CLLocationManager()
    var str_lat:String!
    var str_long:String!
    var driverMarker = GMSMarker()
    var centerMapCoordinate:CLLocationCoordinate2D!
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapviewnew.delegate = self
       // mapviewnew?.isMyLocationEnabled = true
       // determineMyCurrentLocation()

        // Do any additional setup after loading the view.
    }
    
    func determineMyCurrentLocation() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation:CLLocation = locations[0] as CLLocation
            
            
            
            // self.map.setRegion(region, animated: true)
            
            print("user latitude = \(userLocation.coordinate.latitude)")
            print("user longitude = \(userLocation.coordinate.longitude)")
            
            print("\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
            
            str_lat = ((String(userLocation.coordinate.latitude)))
            str_long = ((String(userLocation.coordinate.longitude)))
            
            let morelat = Double(self.str_lat)!
            let morelong = Double(self.str_long)
           // convertLatLongToAddress(latitude: morelat, longitude: morelong!)

            
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) {
                (placemarks, error) -> Void in
            }
            let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 14.0)
            self.mapviewnew?.animate(to: camera)
            
            if userLocation.coordinate.latitude>0  {
                manager.stopUpdatingLocation()
            }
            
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            print("Error \(error)")
        }
        
    // Camera change Position this methods will call every time
       func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
           
           let latitude = mapView.camera.target.latitude
           let longitude = mapView.camera.target.longitude
           centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
           self.placeMarkerOnCenter(centerMapCoordinate: centerMapCoordinate)

       }
       
    func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
        if driverMarker == nil {
            driverMarker = GMSMarker()
        }
        driverMarker.position = centerMapCoordinate
        driverMarker.icon = UIImage(named: "notify")
        var strlat = String()
        strlat = String(centerMapCoordinate.latitude)
        var strlong = String()
        strlong = String(centerMapCoordinate.longitude)
        let morelat = Double(strlat)
        let morelong = Double(strlong)
        
        driverMarker.map = mapviewnew
    }
    
    
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSend_DidiSelect(_ sender: UIButton) {
        self.view.endEditing(true)
        if ValidationClass().ValidateContactUsForm(self) {
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
            parameterDictionary.setValue(DataManager.getVal(txtSubject.text!) as! String, forKey: "subject")
            parameterDictionary.setValue(DataManager.getVal(txtMeassage.text!) as! String, forKey: "message")
            print(parameterDictionary)
            
            let methodName = "contact_us"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    self.navigationController?.popViewController(animated: true)
                    self.topViewController()?.view.makeToast(message: message)

                } else {
                    self.view.makeToast(message: message)
                }
                self.clearHud()
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
