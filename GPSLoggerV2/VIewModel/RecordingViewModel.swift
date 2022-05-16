//
//  RecordingViewModel.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit
import CoreLocation

enum ViewModelState {
    case shouldUpdate
    case didUpdate
}

class RecordingViewModel {
    private var locationModel : LocationModel?
    private var locationHelper: LocationHelper?
    
    var authorization: CLAuthorizationStatus? {
        get {
            return locationHelper?.locationManager?.authorizationStatus
        }
    }
    
    init() {
        locationModel = LocationModel()
        locationHelper = LocationHelper()
    }
    
    func updateLocationData(location: CLLocation) {
        // CLLocationから各種データを取得
        // 緯度経度
        let latitude: Double = location.coordinate.latitude
        let longitude: Double = location.coordinate.longitude
        
        // 標高
        let altitude: Double = location.altitude
        let ellipsoidalAltitude: Double = location.ellipsoidalAltitude
        
        // フロア
        var floor:Int = 0
        
        if let level = location.floor?.level {
            floor = level
        }
        
        // 位置情報精度
        let horizontalAccuracy: Double = location.horizontalAccuracy
        let vericalAccuracy: Double = location.verticalAccuracy
        
        // タイムスタンプ
        let timestamp = location.timestamp
        let dateFormat = ISO8601DateFormatter()
        let timestampString = dateFormat.string(from: timestamp)
        
        // スピード
        let speed: Double = location.speed
        let speedAccuracy: Double = location.speedAccuracy
        
        // 方位
        let course: Double = location.course
        let courseAccuracy: Double = location.courseAccuracy
        
        // 位置情報取得の設定値
        let distanceFilter: Double =  Double(UserDefaults.standard.float(forKey: "distanceFilter"))
        let desiredAccuracy: Double = Double(UserDefaults.standard.float(forKey: "desiredAccuracy"))
        let activityType: Int = UserDefaults.standard.integer(forKey: "activityType")
        
        // attributesで定義して，モデルを初期化
        let attributes: [String: Any] = [
            "latitude": latitude,
            "longtitude": longitude,
            "altitude": altitude,
            "ellipsoidalAltitude": ellipsoidalAltitude,
            "floor": floor,
            "horizontalAccuracy": horizontalAccuracy,
            "vericalAccuracy": vericalAccuracy,
            "timestamp": timestampString,
            "speed": speed,
            "speedAccuracy": speedAccuracy,
            "course": course,
            "courseAccuracy": courseAccuracy,
            "distanceFilter": distanceFilter,
            "desiredAccuracy": desiredAccuracy,
            "activityType": activityType
        ]
        
        locationModel = LocationModel(attributes: attributes)
    }
}

extension RecordingViewModel {
    func startLocation() {
        guard let helper = locationHelper else {
            return
        }
        
        helper.startLocationUpdate()
    }
    
    func stopLocation() {
        guard let helper = locationHelper else {
            return
        }
        
        helper.stopLocationUpdate()
    }
}
