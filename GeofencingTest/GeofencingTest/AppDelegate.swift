//
//  AppDelegate.swift
//  GeofencingTest
//
//  Created by Angus Yi on 2020/11/12.
//

import UIKit
import CoreLocation
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    
    var notificationCenter: UNUserNotificationCenter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
//        let geofenceRegion: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(35.70206910, 139.77532690), radius: 100, identifier: "dlinkHQ")
        let geofenceRegion: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(25.066181, 121.582854), radius: 100, identifier: "dlinkHQ")
//        let geofenceRegion: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(37.332331, -122.031219), radius: 100, identifier: "dlinkHQ")
        locationManager.startMonitoring(for: geofenceRegion)
        
        notificationCenter = UNUserNotificationCenter.current()
        notificationCenter?.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter?.requestAuthorization(options: options, completionHandler: { (granted, error) in
            if !granted {
                print("notification permission not granted")
            }
        })
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func geofenceNotification(region: CLRegion, enter: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Geofence"
        content.body = enter ? "enter: \(region.identifier)" : "exit: \(region.identifier)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: region.identifier,
                                            content: content,
                                            trigger: trigger)
        notificationCenter?.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("cannot add notification with identifier: \(region.identifier)")
            }
        })
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("enter: \(region.identifier)")
        geofenceNotification(region: region, enter: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exit: \(region.identifier)")
        geofenceNotification(region: region, enter: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            print("\(String(describing: index)): \(currentLocation)")
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.identifier)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
}


