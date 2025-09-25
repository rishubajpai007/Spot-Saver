// LocationManager.swift
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    // A publisher that will emit the user's location when we find it.
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // We want a precise location
    }

    // This is the safe, public function for views to call to start the process.
    public func checkLocationAuthorization() {
        locationManagerDidChangeAuthorization(manager)
    }

    // This function is called internally or when permission is not yet determined.
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }

    // Delegate method: Called when the authorization status changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, start looking for the location.
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle cases where the user has denied permission.
            print("Location permission denied.")
        case .notDetermined:
            // The user hasn't been asked yet, so ask them.
            requestLocationPermission()
        @unknown default:
            break
        }
    }

    // Delegate method: Called when a new location is found.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Use the most recent location.
        guard let location = locations.last else { return }
        
        // Stop updating to save battery, as we only need the initial location.
        manager.stopUpdatingLocation()
        
        // Publish the found location for any listening views.
        self.currentLocation = location
    }

    // Delegate method: Called if there's an error finding the location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
