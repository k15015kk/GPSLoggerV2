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
    
    public var fileUrl: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let date = Date()
        let dateFormat = ISO8601DateFormatter()
        let dateString = dateFormat.string(from: date)
        return dir.appendingPathComponent("GPSLogging_\(dateString).csv")
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
        var speed: Double = 0.0
        
        if location.speed >= 0.0 {
            speed = location.speed * 3.6
        }
        
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
        let result = fetchAllData()
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
    
    func fetchAllData() -> [LocationObject] {
        let realm = try! Realm()
        
        let objects = realm.objects(LocationObject.self)
        return Array(objects)
    }
    
    /// Realmのデータを全消去します
    func allDeleteRealmData() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    // Realmのデータをcsvテキスト化します
    func outputCsv() -> Bool {
        let data = fetchAllData()
        let body = data.map({[
            String($0.latitude),
            String($0.longitude),
            String($0.altitude),
            String($0.ellipsoidalAltitude),
            String($0.floor),
            String($0.horizontalAccuracy),
            String($0.vericalAccuracy),
            String($0.speed),
            String($0.speedAccuracy),
            String($0.course),
            String($0.courseAccuracy),
            $0.timestamp,
            String($0.distanceFilter),
            String($0.desiredAccuracy),
            String($0.activityType)
        ]})
        
        return createFile(logBody: body)
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
    
    func createFile(logBody: [[String]]) -> Bool {
        let logHeader = [
            "latitude",
            "longitude",
            "altitude",
            "ellipsoidalAltitude",
            "floor",
            "horizontalAccuracy",
            "vericalAccuracy",
            "speed",
            "speedAccuracy",
            "course",
            "courseAccuracy",
            "timestamp",
            "distanceFilter",
            "desiredAccuracy",
            "activityType"
        ]
        
        let outputText :String = ArrayToCsvText(csvHeader: logHeader, csvBody: logBody)
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            // ファイルを書き込む
            do {
                try outputText.write(to: fileUrl, atomically: false, encoding: .utf8)
                print("書き込み保存成功")
                return true
            } catch {
                print("書き込み保存失敗")
                return false
            }
        } else {
            if FileManager.default.createFile(atPath: fileUrl.path, contents: outputText.data(using: .utf8), attributes: nil) {
                print("書き込み新規成功")
                return true
            } else {
                print("書き込み新規失敗")
                return false
            }
        }
    }
    
    func ArrayToCsvText(csvHeader: [String], csvBody: [[String]]) -> String {
            var text :String = ""
            
            // ヘッダーをテキスト化
            for (i, data) in csvHeader.enumerated() {
                text += data
                if i != csvHeader.count - 1 {
                    text += ","
                }
            }
            
            text += "\n"
            
            // 本文をテキスト化
            for csvArray in csvBody {
                for (i,data) in csvArray.enumerated() {
                    text += data
                    if i != csvArray.count - 1 {
                        text += ","
                    }
                }
                
                text += "\n"
            }
            
            return text
        }
}
