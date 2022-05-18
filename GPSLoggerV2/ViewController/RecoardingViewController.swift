//
//  RecoardingViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit
import CoreLocation
import MapKit

class RecordingViewController: UIViewController {
    
    @IBOutlet private weak var SpeedView: UIView!
    @IBOutlet private weak var AltitudeView: UIView!
    
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var altitudeLabel: UILabel!
    
    @IBOutlet private weak var MapView: MKMapView!
    
    @IBOutlet private weak var RecordingButton: UIButton!
    @IBOutlet private weak var ResetButton: UIButton!
    @IBOutlet private weak var SaveBotton: UIButton!
    
    var viewModel: RecordingViewModel?
    var isLocationUpdate: Bool = false
    
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
        self.RecordingButton.setTitle("取得開始", for: .normal)
        self.RecordingButton.tintColor = UIColor.systemBlue
        self.RecordingButton.isEnabled = true
        
        self.ResetButton.setTitle("リセット", for: .normal)
        self.ResetButton.tintColor = UIColor.systemRed
        self.ResetButton.isEnabled = true
        
        self.SaveBotton.setTitle("保存", for: .normal)
        self.SaveBotton.tintColor = UIColor.systemBlue
        self.SaveBotton.isEnabled = true
        
        // MapViewのdelegateを設定
        MapView.delegate = self
        
        // MapKitの現在地表示を行う
        MapView.userTrackingMode = MKUserTrackingMode.follow
        
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
                    "位置情報の設定が無効になっています",
                    "設定画面から位置情報の取得を許可してください"
                )
                
            case .restricted:
                // アラート設定
                presentWarningAlert(
                    "位置情報の設定が制限されています",
                    "ペアレンタルコントロールなどで位置情報の取得が制限されています"
                )
                
            default:
                break
            }
        }
        
    }
    
    @objc func updateLocationModel(notification: Notification) {
        print("位置情報が更新されました")
        
        if let userInfo =  notification.userInfo?["model"]{
            
            let model = userInfo as! LocationModel
            
            print("speed = \(model.speed)")
            
            speedLabel.text = String(Int(model.speed)) + "km/h"
            altitudeLabel.text = String(Int(model.altitude)) + "m"
            
            // 再度，現在地表示を行う
            MapView.userTrackingMode = MKUserTrackingMode.follow
            
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
            self.RecordingButton.setTitle("取得停止", for: .normal)
            self.RecordingButton.tintColor = UIColor.systemRed
            
            self.ResetButton.tintColor = UIColor.systemGray
            self.ResetButton.isEnabled = false
            
            self.SaveBotton.tintColor = UIColor.systemGray
            self.SaveBotton.isEnabled = false
            
        } else {
            vm.stopLocation()
            isLocationUpdate = false
            
            // ボタンの設定
            self.RecordingButton.setTitle("取得開始", for: .normal)
            self.RecordingButton.tintColor = UIColor.systemBlue
            
            self.ResetButton.tintColor = UIColor.systemRed
            self.ResetButton.isEnabled = true
            
            self.SaveBotton.tintColor = UIColor.systemBlue
            self.SaveBotton.isEnabled = true
        }
    }

    
    @IBAction private func actionLocationLogReset(_ sender: Any) {
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            guard let viewModel = self.viewModel else {
                self.presentWarningAlert("リセットエラー", "位置情報ログがリセットできませんでした．")
                return
            }

            // データを全削除
            viewModel.allDeleteRealmData()
            
            // MapKitからレイヤーを消す
            self.MapView.removeAnnotations(self.MapView.annotations)
            self.MapView.removeOverlays(self.MapView.overlays)
        }
        
        presentChoicesAlert("位置情報ログリセット", "位置情報のログをリセットしますか？", [okAction])
    }
    
    @IBAction private func actionSave(_ sender: Any) {
        guard let viewModel = viewModel else {
            self.presentWarningAlert("保存エラー", "csvファイルが保存できませんでした")
            return
        }

        if viewModel.outputCsv() {
            self.presentWarningAlert("CSV保存", "csvファイルを保存しました")
        } else {
            self.presentWarningAlert("保存エラー", "csvファイルが保存できませんでした")
        }
    }
}

extension RecordingViewController: MKMapViewDelegate {
    
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
