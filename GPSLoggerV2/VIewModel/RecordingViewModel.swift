//
//  RecordingViewModel.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit
import CoreLocation
import RealmSwift

class RecordingViewModel {
    
    // MARK: Properties
    
    // モデルの定義
    private var locationModel : LocationModel?
    
    // ロケーションの定義
    private var locationHelper: LocationHelper?
    
    // ロケーションの許可状態
    var authorization: CLAuthorizationStatus? {
        get {
            return locationHelper?.locationManager?.authorizationStatus
        }
    }
    
    // 保存ファイルのURL定義
    public var fileUrl: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let date = Date()
        let dateFormat = ISO8601DateFormatter()
        let dateString = dateFormat.string(from: date)
        return dir.appendingPathComponent("GPSLogging_\(dateString).csv")
    }
    
    // MARK: Location Properties
    
    // Locationの定義
    private var location : CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    
    // 緯度
    private var latitude: Double {
        location.coordinate.latitude
    }
    
    // 軽度
    private var longitude: Double {
        location.coordinate.longitude
    }
    
    // ジオロイド高
    private var altitude: Double {
        location.altitude
    }
    
    // 楕円体標高(iOS15未満は0と返す)
    private var ellipsoidalAltitude: Double {
        if #available(iOS 15, *) {
            return location.ellipsoidalAltitude
        } else {
            return 0.0
        }
    }
    
    // 階数
    private var floor: Int {
        guard let level = location.floor?.level else {
            return 0
        }
        
        return level
    }
    
    // 水平精度
    private var horizontalAccuracy: Double {
        location.horizontalAccuracy
    }
    
    // 垂直精度
    private var vericalAccuracy: Double {
        location.verticalAccuracy
    }
    
    // タイムスタンプ
    private var timestamp: String {
        
        let timestamp = location.timestamp
        
        // ISO8601形式に変更
        return ISO8601DateFormatter().string(from: timestamp)
    }
    
    // スピード
    private var speed: Double {
        let speed = location.speed
        
        if speed >= 0.0 {
            return speed * 3.6
        } else {
            return speed
        }
    }
    
    // スピードの精度
    private var speedAccuracy: Double {
        location.speedAccuracy
    }
    
    // 方位
    private var course: Double {
        location.course
    }
    
    // 方位の精度
    private var courseAccuracy: Double {
        location.courseAccuracy
    }
    
    // 距離フィルタ
    private var distanceFilter: Double {
        Double(UserDefaults.standard.float(forKey: "distanceFilter"))
    }
    
    // 精度フィルタ
    private var desiredAccuracy: Double {
        Double(UserDefaults.standard.float(forKey: "desiredAccuracy"))
    }
    
    // アクティビティタイプ
    private var activityType: Int {
        UserDefaults.standard.integer(forKey: "activityType")
    }
    
    // MARK: Initialize
    
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
}

// MARK: - Location Helper

extension RecordingViewModel {
    
    /// 位置情報の取得を開始します
    func startLocation() {
        guard let helper = locationHelper else {
            return
        }
        
        helper.startLocationUpdate()
    }
    
    /// 位置情報の取得を終了します
    func stopLocation() {
        guard let helper = locationHelper else {
            return
        }
        
        helper.stopLocationUpdate()
    }
    
    /// 位置情報がアップデートされたときの処理
    /// - Parameter notification: Notification情報
    @objc func updateLocation(_ notification: Notification) {
        
        guard let location = notification.userInfo?["newLocation"] as? CLLocation else {
            return
        }
        
        // ロケーションを定義
        self.location = location
        
        // attributesで定義して，モデルを初期化
        let attributes: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "altitude": altitude,
            "ellipsoidalAltitude": ellipsoidalAltitude,
            "floor": floor,
            "horizontalAccuracy": horizontalAccuracy,
            "vericalAccuracy": vericalAccuracy,
            "timestamp": timestamp,
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
}

// MARK: - Realm

extension RecordingViewModel {
    
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
    
    /// Realmに保存されたデータを全て取得します
    /// - Returns: LocationObjectの配列
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
}

// MARK: - File Output

extension RecordingViewModel {
    
    /// ロケーション情報をCSV出力します
    /// - Returns: ファイル作成ができたかどうかをBool値で返します
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
    
    /// csvファイルを作成します
    /// - Parameter logBody: csvのbody部分
    /// - Returns: ファイル作成ができたかどうかをBool値で返します
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
    
    /// 配列をCSVのテキストに変換します
    /// - Parameters:
    ///   - csvHeader: csvのHeader部分
    ///   - csvBody: csvのBody部分
    /// - Returns: CSVの文字列を返します
    func ArrayToCsvText(csvHeader: [String], csvBody: [[String]]) -> String {
        
        // テキストを初期化
        var text :String = ""
        
        // ヘッダーをテキスト化
        for (i, data) in csvHeader.enumerated() {
            text += data
            if i != csvHeader.count - 1 {
                text += ","
            }
        }
        
        // 改行を挿入
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
