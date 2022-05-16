//
//  LocationManager.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var newLocation: CLLocation?
    
    override init() {
        super.init()
        
        // LocationManagerの定義
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        self.newLocation = CLLocation()
        
        // 各種設定値の設定
        self.settingLocationManager()
        
        // 権限設定
        locationManager!.requestWhenInUseAuthorization()
        
        // UserDefaultsの更新通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    func startLocationUpdate() {
        
        guard let manager = locationManager else {
            return
        }
        
        // 位置情報の取得を開始
        manager.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
        
        guard let manager = locationManager else {
            return
        }
        
        // 位置情報の取得を終了
        manager.stopUpdatingLocation()
        
    }
    
    // 位置情報が更新された場合の処理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 位置情報データがない場合は終了
        guard let newLocation = locations.last else {
            return
        }
        
        print("newLocation = \(newLocation)")
        
        self.newLocation = newLocation
        
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
            break
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        @unknown default:
            break
        }
    }
}

extension LocationHelper {
    
    /// UserDefaultsが更新されたときに実行
    /// - Parameter notification: Notification情報
    @objc func userDefaultsDidChange(_ notification: Notification) {
        self.settingLocationManager()
    }
    
    func settingLocationManager()  {
        guard let manager = locationManager else {
            return
        }
        
        // 距離フィルタの設定
        let distanceFilterValue = UserDefaults.standard.float(forKey: "distanceFilter")
        manager.distanceFilter = CLLocationDistance(distanceFilterValue)
        
        // 精度フィルタの設定
        let desiredAccuracyValue = UserDefaults.standard.float(forKey: "desiredAccuracy")
        manager.desiredAccuracy = CLLocationAccuracy(desiredAccuracyValue)
        
        // アクティビティタイプの設定
        let activityTypeValue = UserDefaults.standard.integer(forKey: "activityType")
        
        switch activityTypeValue {
        case 0:
            manager.activityType = .fitness
        case 1:
            manager.activityType = .automotiveNavigation
        case 2:
            manager.activityType = .otherNavigation
        case 3:
            manager.activityType = .airborne
        case 4:
            manager.activityType = .other
        default:
            manager.activityType = .other
        }
        
        // バックグラウンドの取得設定
        let isBackgroundLocationFetch = UserDefaults.standard.bool(forKey: "backgroundLocationFetch")
        manager.allowsBackgroundLocationUpdates = isBackgroundLocationFetch
        manager.showsBackgroundLocationIndicator = isBackgroundLocationFetch
        
        // 取得の自動一時停止の設定
        let isAutomaticallyPausesUpdate = UserDefaults.standard.bool(forKey: "automaticallyLocationUpdatePauses")
        manager.pausesLocationUpdatesAutomatically = isAutomaticallyPausesUpdate
    }
}
