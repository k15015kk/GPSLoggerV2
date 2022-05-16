//
//  LocationModel.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

struct LocationModel {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let ellipsoidalAltitude: Double
    let floor: Int
    let horizontalAccuracy: Double
    let vericalAccuracy: Double
    let timestamp: String
    let speed: Double
    let speedAccuracy: Double
    let course: Double
    let courseAccuracy: Double
    let distanceFilter: Double
    let desiredAccuracy: Double
    let activityType: Int
    
    init() {
        latitude = 0.0
        longitude = 0.0
        altitude = 0.0
        ellipsoidalAltitude = 0.0
        floor = 0
        horizontalAccuracy = 0.0
        vericalAccuracy = 0.0
        timestamp = "1970-01-01T09:00:00+09:00"
        speed = 0.0
        speedAccuracy = 0.0
        course = 0.0
        courseAccuracy = 0.0
        distanceFilter = 0.0
        desiredAccuracy = 0.0
        activityType = 4
    }
    
    init(attributes: [String: Any]) {
        self.latitude = attributes["latitude"] as! Double
        self.longitude = attributes["longitude"] as! Double
        self.altitude = attributes["altitude"] as! Double
        self.ellipsoidalAltitude = attributes["ellipsoidalAltitude"] as! Double
        self.floor = attributes["floor"] as! Int
        self.horizontalAccuracy = attributes["horizontalAccuracy"] as! Double
        self.vericalAccuracy = attributes["vericalAccuracy"] as! Double
        self.timestamp = attributes["timestamp"] as! String
        self.speed = attributes["speed"] as! Double
        self.speedAccuracy = attributes["speedAccuracy"] as! Double
        self.course = attributes["course"] as! Double
        self.courseAccuracy = attributes["courseAccuracy"] as! Double
        self.distanceFilter = attributes["distanceFilter"] as! Double
        self.desiredAccuracy = attributes["desiredAccuracy"] as! Double
        self.activityType = attributes["activityType"] as! Int
    }
}
