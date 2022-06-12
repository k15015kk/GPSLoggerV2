//
//  LocationManager.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import CoreLocation

class LocationHelper: NSObject {
    
    // MARK: Properties
    
    // ロケーションマネジャー
    var locationManager: CLLocationManager?
    
    // 精度フィルタ
    private var distanceFilter: Float {
        UserDefaults.standard.float(forKey: "distanceFilter")
    }
    
    // 精度フィルタ
    private var desiredAccuracy: Float {
        UserDefaults.standard.float(forKey: "desiredAccuracy")
    }
    
    // アクティビティタイプ
    private var activityType: Int {
        UserDefaults.standard.integer(forKey: "activityType")
    }
    
    // バックグラウンド取得
    private var isBackgroundLocationFetch: Bool {
        UserDefaults.standard.bool(forKey: "backgroundLocationFetch")
    }
    
    // 取得の自動一時停止の設定
    private var isAutomaticallyPausesUpdate: Bool {
        UserDefaults.standard.bool(forKey: "automaticallyLocationUpdatePauses")
    }
    
    override init() {
        super.init()
        
        // LocationManagerの定義
        locationManager = CLLocationManager()
        
        // LocationManagerのデリゲート設定
        locationManager!.delegate = self
        
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
}

// MARK: - CLLocationManagerDelegate

extension LocationHelper: CLLocationManagerDelegate  {
    
    // 位置情報が更新された場合の処理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 位置情報データがない場合は終了
        guard let newLocation = locations.last else {
            return
        }
        
        print("newLocation = \(newLocation)")
        
        // 変更通知を投げる
        NotificationCenter.default.post(name: .updateLocation, object: nil, userInfo: ["newLocation": newLocation])
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

// MARK: - Location Functions

extension LocationHelper {
    
    /// 位置情報の取得を開始
    func startLocationUpdate() {
        
        guard let manager = locationManager else {
            return
        }
        
        // 位置情報の取得を開始
        manager.startUpdatingLocation()
    }
    
    /// 位置情報の取得を終了
    func stopLocationUpdate() {
        
        guard let manager = locationManager else {
            return
        }
        
        // 位置情報の取得を終了
        manager.stopUpdatingLocation()
        
    }
    
    /// UserDefaultsが更新されたときに実行
    /// - Parameter notification: Notification情報
    @objc func userDefaultsDidChange(_ notification: Notification) {
        self.settingLocationManager()
    }
    
    /// ロケーションマネジャーの設定を行う処理
    func settingLocationManager()  {
        guard let manager = locationManager else {
            return
        }
        
        // 距離フィルタの設定
        manager.distanceFilter = CLLocationDistance(distanceFilter)
        
        // 精度フィルタの設定
        manager.desiredAccuracy = CLLocationAccuracy(desiredAccuracy)
        
        // アクティビティタイプの設定
        switch activityType {
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
        manager.allowsBackgroundLocationUpdates = isBackgroundLocationFetch
        manager.showsBackgroundLocationIndicator = isBackgroundLocationFetch
        
        // 取得の自動一時停止の設定
        manager.pausesLocationUpdatesAutomatically = isAutomaticallyPausesUpdate
    }
}
