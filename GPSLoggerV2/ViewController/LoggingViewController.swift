//
//  RecoardingViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit
import CoreLocation
import MapKit

class LoggingViewController: UIViewController {
    
    @IBOutlet private weak var SpeedView: UIView!
    @IBOutlet private weak var AltitudeView: UIView!
    
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var altitudeLabel: UILabel!
    
    @IBOutlet private weak var MapView: MKMapView!
    
    @IBOutlet private weak var LoggingButton: UIButton!
    @IBOutlet private weak var ResetButton: UIButton!
    @IBOutlet private weak var SaveBotton: UIButton!
    
    var viewModel: RecordingViewModel?
    var isLocationUpdate: Bool = false
    let userTrackingButtonSize: CGFloat = 32
    
    var prevLocation: CLLocationCoordinate2D? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewModelを定義
        viewModel = RecordingViewModel()
        
        // 今あるRealmのデータは全消去
        viewModel!.allDeleteRealmData()
        
        // Viewを角丸にする
        self.SpeedView.layer.cornerRadius = 4
        self.AltitudeView.layer.cornerRadius = 4
        
        // Labelを初期化
        self.speedLabel.text = "0km/h"
        self.altitudeLabel.text = "0m"
        
        // ボタンの設定
        changedButtonWhenStopLogging()
        
        // MapViewのdelegateを設定
        MapView.delegate = self
        
        // MapKitの現在地表示を行う
        MapView.userTrackingMode = MKUserTrackingMode.follow
        
        let userTrackingButton = MKUserTrackingButton(mapView: MapView)
        userTrackingButton.layer.backgroundColor = UIColor(white: 1, alpha: 1).cgColor
        userTrackingButton.layer.cornerRadius = 4
        userTrackingButton.frame = CGRect(
            x: 16,
            y: AltitudeView.frame.maxY + 8,
            width: userTrackingButtonSize,
            height: userTrackingButtonSize
        )
        self.view.addSubview(userTrackingButton)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocationModel),
            name: .updateLocationModel,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // 位置情報が許可されていない場合，その旨のアラートを出す
        if let authorization = viewModel?.authorization {
            switch authorization {
            case .denied:
                // アラート設定
                presentWarningAlert(
                    "alert_title_invalid_location_setting".localized,
                    "alert_message_invalid_location_setting".localized
                )
                
            case .restricted:
                // アラート設定
                presentWarningAlert(
                    "alert_title_restricted_location_setting".localized,
                    "alert_message_restricted_location_setting".localized
                )
                
            default:
                break
            }
        }
        
    }
    
    @objc func updateLocationModel(notification: Notification) {
        
        if let userInfo =  notification.userInfo?["model"]{
            
            // モデルを定義
            let model = userInfo as! LocationModel
            
            // 画面ラベルを変更
            speedLabel.text = String(Int(model.speed)) + "km/h"
            altitudeLabel.text = String(Int(model.altitude)) + "m"
            
            // 位置を定義
            let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
            
            //　ピンを追加
            let annotation = MKPointAnnotation()
            annotation.title = model.timestamp
            annotation.coordinate = coordinates
            MapView.addAnnotation(annotation)
            
            // 誤差半径の描画
//            let circle = MKCircle(center: coordinates, radius: CLLocationDistance(model.horizontalAccuracy))
//            MapView.addOverlay(circle)
            
            // 直線の描画
            if let prevLocation = prevLocation {
                let coordinatesList = [prevLocation, coordinates]
                let polyLine = MKPolyline(coordinates: coordinatesList, count: coordinatesList.count)
                MapView.addOverlay(polyLine)
            }
            
            // 以前の位置情報をprevに保存
            prevLocation = coordinates
        }
        
    }
    
    @IBAction private func actionLocationUpdate(_ sender: Any) {
        
        guard let vm = viewModel else {
            return
        }
        
        if !isLocationUpdate {
            vm.startLocation()
            isLocationUpdate = true
            
            // ボタンの設定
            changedButtonWhenStartLogging()
            
        } else {
            vm.stopLocation()
            isLocationUpdate = false
            
            // ボタンの設定
            changedButtonWhenStopLogging()
        }
    }

    
    @IBAction private func actionLocationLogReset(_ sender: Any) {
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            guard let viewModel = self.viewModel else {
                self.presentWarningAlert("alert_title_reset_error".localized, "alert_message_reset_error".localized)
                return
            }

            // データを全削除
            viewModel.allDeleteRealmData()
            
            // MapKitからレイヤーを消す
            self.MapView.removeAnnotations(self.MapView.annotations)
            self.MapView.removeOverlays(self.MapView.overlays)
        }
        
        presentChoicesAlert("alert_title_reset_confirm".localized, "alert_message_reset_confirm".localized, [okAction])
    }
    
    @IBAction private func actionSave(_ sender: Any) {
        guard let viewModel = viewModel else {
            self.presentWarningAlert("alert_title_save_error".localized, "alert_message_save_error".localized)
            return
        }

        if viewModel.outputCsv() {
            self.presentWarningAlert("alert_title_save_success".localized, "alert_message_save_success".localized)
        } else {
            self.presentWarningAlert("alert_title_save_error".localized, "alert_message_save_error".localized)
        }
    }
}

extension LoggingViewController {
    private func changedButtonWhenStartLogging() {
        self.LoggingButton.setTitle("button_title_logging_stop".localized, for: .normal)
        self.LoggingButton.tintColor = UIColor.systemRed
        self.LoggingButton.isEnabled = true
        
        self.ResetButton.setTitle("button_title_reset".localized, for: .normal)
        self.ResetButton.tintColor = UIColor.systemGray
        self.ResetButton.isEnabled = false
        
        self.SaveBotton.setTitle("button_title_save".localized, for: .normal)
        self.SaveBotton.tintColor = UIColor.systemGray
        self.SaveBotton.isEnabled = false
    }
    
    private func changedButtonWhenStopLogging() {
        self.LoggingButton.setTitle("button_title_logging_stop".localized, for: .normal)
        self.LoggingButton.tintColor = UIColor.systemBlue
        self.LoggingButton.isEnabled = true
        
        self.ResetButton.setTitle("button_title_reset".localized, for: .normal)
        self.ResetButton.tintColor = UIColor.systemRed
        self.ResetButton.isEnabled = true
        
        self.SaveBotton.setTitle("button_title_save".localized, for: .normal)
        self.SaveBotton.tintColor = UIColor.systemBlue
        self.SaveBotton.isEnabled = true
    }
}

extension LoggingViewController: MKMapViewDelegate {
    
    // ラインの色を定義
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRender = MKPolylineRenderer(polyline: polyline)
            
            polylineRender.strokeColor = UIColor.systemRed
            polylineRender.lineWidth = 3.0
            return polylineRender
        }
        
        if let circle = overlay as? MKCircle {
            let circleRender = MKCircleRenderer(circle: circle)
            
            circleRender.fillColor = UIColor.systemRed
            circleRender.alpha = 0.4
            return circleRender
        }
        
        return MKOverlayRenderer()
    }
}
