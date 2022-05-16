//
//  LocationModel.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

struct LocationModel {
    let latitude: Double
    let longtitute: Double
    let altitude: Double
    let ellipsoidalAltitude: Double
    let floor: Int
    let horizontalAccuracy: Double
    let vericalAccuracy: Double
    let timestamp: String
    let speed: Double
    let course: Double
    let distanceFilter: Double
    let desiredAccuracy: Double
    let activityType: Int
    
    init() {
        latitude = 0.0
        longtitute = 0.0
        altitude = 0.0
        ellipsoidalAltitude = 0.0
        floor = 0
        horizontalAccuracy = 0.0
        vericalAccuracy = 0.0
        timestamp = "1970-01-01T09:00:00+09:00"
        speed = 0.0
        course = 0.0
        distanceFilter = 0.0
        desiredAccuracy = 0.0
        activityType = 4
    }
}
