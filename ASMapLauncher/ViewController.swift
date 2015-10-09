//
//  ViewController.swift
//  ASMapLauncher
//
//  Created by Abdullah Selek on 06/06/15.
//  Copyright (c) 2015 Abdullah Selek. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIActionSheetDelegate, CLLocationManagerDelegate {
    
    // map launcher
    private var mapLauncher: ASMapLauncher!
    private var mapApps: NSMutableArray!
    
    // location manager
    private var locationManager: CLLocationManager = CLLocationManager()
    // current coordinate
    private var currenctCoordinate: CLLocationCoordinate2D!
    
    // ui compononents
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        mapLauncher = ASMapLauncher()
        
        // get current location
        getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showNavigationSheet() {
        self.mapApps = mapLauncher.getMapApps()
        let actionSheet = UIActionSheet(title: "Choose your app for navigation", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        for mapApp in self.mapApps {
            actionSheet.addButtonWithTitle(mapApp as? String)
        }
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = mapApps.count
        actionSheet.showInView(self.view)
    }

    // MARK: ActionSheet Delegates
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == actionSheet.numberOfButtons - 1 {
            return
        }
        
        let mapApp: String! = self.mapApps[buttonIndex] as! String
        let destination: CLLocation! = CLLocation(latitude: 41.0053215, longitude: 29.0121795)
        
        let fromMapPoint: ASMapPoint! = ASMapPoint(location: CLLocation(latitude: currenctCoordinate.latitude, longitude: currenctCoordinate.longitude), name: "", address: "")
        let toMapPoint: ASMapPoint! = ASMapPoint(location: CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude), name: "", address: "")
        
        mapLauncher.launchMapApp(ASMapApp(rawValue: mapApp)!, fromDirections: fromMapPoint, toDirection: toMapPoint)
    }
    
    // MARK: Location Manager methods
    
    func getLocation() {
        enableIndicator(true)
      
        /**
        * - parameter for desiredAccuracy
        *   kCLLocationAccuracyBestForNavigation
        *   kCLLocationAccuracyBest
        *   kCLLocationAccuracyNearestTenMeters
        *   kCLLocationAccuracyHundredMeters
        *   kCLLocationAccuracyKilometer
        *   kCLLocationAccuracyThreeKilometers
        **/
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        
        startUpdatingLocation()
    }
    
    // MARK: Location Manager delegates
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            switch status {
            case CLAuthorizationStatus.Restricted, CLAuthorizationStatus.Denied, CLAuthorizationStatus.NotDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case CLAuthorizationStatus.AuthorizedAlways, CLAuthorizationStatus.AuthorizedWhenInUse:
                startUpdatingLocation()
                break
            }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coordinate = locationObj.coordinate
        self.currenctCoordinate = coordinate
        
        locationManager.stopUpdatingLocation()
        self.enableIndicator(false)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()

    }
    
    func startUpdatingLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
                locationManager.startUpdatingLocation()
            }
        }
    }

    // MARK: Button Action
    
    @IBAction func navigationBtnTapped(sender: AnyObject) {
        /*** show all available mapping actions ***/
        showNavigationSheet()
        
        /*** navigation for only selected map app type
        var isInstalled = mapLauncher.isMapAppInstalled(ASMapApp.ASMapAppGoogleMaps)
        if isInstalled {
            var destination: CLLocation! = CLLocation(latitude: 41.0053215, longitude: 29.0121795)
            var fromMapPoint: ASMapPoint! = ASMapPoint(location: CLLocation(latitude: currenctCoordinate.latitude, longitude: currenctCoordinate.longitude), name: "", address: "")
            var toMapPoint: ASMapPoint! = ASMapPoint(location: CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude), name: "", address: "")
            mapLauncher.launchMapApp(ASMapApp.ASMapAppGoogleMaps, fromDirections: fromMapPoint, toDirection: toMapPoint)
        }
        ***/
    }
    
    // MARK: Activity Indicator
    
    func enableIndicator(enable: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if enable {
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                
                self.navigationBtn.hidden = false
            }
        })
    }
}

