//
//  RecordingViewModel.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit
import CoreLocation
import RealmSwift

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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocation),
            name: .updateLocation,
            object: nil
        )
    }
    
    @objc func updateLocation(_ notification: Notification) {
        
        guard let location = locationHelper?.newLocation else {
            return
        }
        
        // CLLocationから各種データを取得
        // 緯度経度
        let latitude: Double = location.coordinate.latitude
        let longitude: Double = location.coordinate.longitude
        
        // 標高
        let altitude: Double = location.altitude
        
        var ellipsoidalAltitude: Double = 0.0
        
        if #available(iOS 15, *) {
            ellipsoidalAltitude = location.ellipsoidalAltitude
        }
        
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
            "longitude": longitude,
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
        
        if let model = locationModel {
            // 変更通知を投げる
            NotificationCenter.default.post(name: .updateLocationModel, object: nil, userInfo: ["model": model])
        }
        
        // Realmに追加
        writeRealmData()
        
        // DEBUG: Realmの書き込みを確認
        let realm = try! Realm()
        let result = realm.objects(LocationObject.self)
        print("Realm Result = \(result)")
    }
    
    
    /// Realmデータベースにデータを追加
    func writeRealmData() {
        guard let model = locationModel else {
            return
        }
        
        let realm = try! Realm()
        let object = LocationObject()
        
        object.latitude = model.latitude
        object.longitude = model.longitude
        object.altitude = model.altitude
        object.ellipsoidalAltitude = model.ellipsoidalAltitude
        object.floor = model.floor
        object.horizontalAccuracy = model.horizontalAccuracy
        object.vericalAccuracy = model.vericalAccuracy
        object.timestamp = model.timestamp
        object.speed = model.speed
        object.speedAccuracy = model.speedAccuracy
        object.course = model.course
        object.courseAccuracy = model.courseAccuracy
        object.distanceFilter = model.distanceFilter
        object.desiredAccuracy = model.desiredAccuracy
        object.activityType = model.activityType
        
        try! realm.write {
            realm.add(LocationObject(value: object))
        }
    }
    
    /// Realmのデータを全消去します
    func allDeleteRealmData() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
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
