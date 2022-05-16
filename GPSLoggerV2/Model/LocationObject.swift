//
//  LocationObject.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import RealmSwift

class LocationObject: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longtitute: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var ellipsoidalAltitude: Double = 0.0
    @objc dynamic var floor: Int = 0
    @objc dynamic var horizontalAccuracy: Double = 0.0
    @objc dynamic var vericalAccuracy: Double = 0.0
    @objc dynamic var timestamp: String = "1970-01-01T09:00:00+09:00"
    @objc dynamic var speed: Double = 0.0
    @objc dynamic var course: Double = 0.0
    @objc dynamic var distanceFilter: Double = 0.0
    @objc dynamic var desiredAccuracy: Double = 0.0
    @objc dynamic var activityType: Int = 4
}
