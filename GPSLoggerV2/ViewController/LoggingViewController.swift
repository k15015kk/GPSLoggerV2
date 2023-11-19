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
    
    // MARK: UI
    
    // View
    
    @IBOutlet private weak var SpeedView: UIView!
    @IBOutlet private weak var AltitudeView: UIView!
    @IBOutlet private weak var MapView: MKMapView!
    
    // Label
    
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var altitudeLabel: UILabel!
    
    // Button
    
    @IBOutlet private weak var LoggingButton: UIButton!
    @IBOutlet private weak var ResetButton: UIButton!
    @IBOutlet private weak var SaveBotton: UIButton!
    
    // MARK: ViewModel
    
    var viewModel: RecordingViewModel?
    
    // MARK: Properties
    
    var isLocationUpdate: Bool = false
    let userTrackingButtonSize: CGFloat = 32
    var prevLocation: CLLocationCoordinate2D? = nil

    // MARK: Lifecycle
    
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
        
        /// ボタンの初期設定
        /// アプリ起動時はロギング終了時の制御変更を実行
        changedButtonWhenStopLogging()
        
        // MapViewのdelegateを設定
        MapView.delegate = self
        
        // MapKitの現在地表示を行う
        MapView.userTrackingMode = MKUserTrackingMode.follow
        
        // NotificationCenterのObserver定義
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocationModel),
            name: .updateLocationModel,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        // ユーザー追跡ボタンの定義
        let userTrackingButton = MKUserTrackingButton(mapView: MapView)
        
        /// そのままユーザー追跡ボタンを設置すると
        /// 背景が無色透明になってしまうため
        /// ユーザー追跡ボタンに白色の背景を定義します
        userTrackingButton.layer.backgroundColor = UIColor(white: 1, alpha: 1).cgColor
        userTrackingButton.layer.cornerRadius = 4
        
        userTrackingButton.frame = CGRect(
            x: self.view.frame.width - userTrackingButtonSize - 16,
            y: self.view.safeAreaInsets.top + 8,
            width: userTrackingButtonSize,
            height: userTrackingButtonSize
        )
        
        // ユーザー追跡ボタンをViewに設置
        self.view.addSubview(userTrackingButton)
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
    
    // MARK: Actions
    
    /// 位置取得・取得終了ボタンを押したときの処理
    /// - Parameter sender: Sender情報
    @IBAction private func actionLocationUpdate(_ sender: UIButton) {
        
        guard let vm = viewModel else {
            return
        }
        
        // ロギング中かどうか制御します
        if isLocationUpdate {
            
            vm.stopLocation()
            isLocationUpdate = false
            
            // ボタンの設定
            changedButtonWhenStopLogging()
            
        } else {
            
            vm.startLocation()
            isLocationUpdate = true
            
            // ボタンの設定
            changedButtonWhenStartLogging()
        }
    }
    
    /// リセットボタンを押したときの処理
    /// - Parameter sender: Sender情報
    @IBAction private func actionLocationLogReset(_ sender: UIButton) {
        
        // アラートのOKを押した際の処理を定義
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
        
        // リセットして良いかアラートを出す
        presentChoicesAlert("alert_title_reset_confirm".localized, "alert_message_reset_confirm".localized, [okAction])
    }
    
    /// 保存ボタンを押したときの処理
    /// - Parameter sender: Sender情報
    @IBAction private func actionSave(_ sender: Any) {
        
        guard let viewModel = viewModel else {
            self.presentWarningAlert("alert_title_save_error".localized, "alert_message_save_error".localized)
            return
        }

        // CSVの保存が正常に終わった場合
        if viewModel.outputCsv() {
            
            // CSVの保存ができたアラートを出す
            self.presentWarningAlert("alert_title_save_success".localized, "alert_message_save_success".localized)
            
        } else {
            
            // CSVの保存ができなかったアラートをだす
            self.presentWarningAlert("alert_title_save_error".localized, "alert_message_save_error".localized)
        }
    }
}

// MARK: - MKMapViewDelegate

extension LoggingViewController: MKMapViewDelegate {
    
    // 地図上に表示する線・ポリゴンのスタイル設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // ポリライン（線分データ）のスタイル
        if let polyline = overlay as? MKPolyline {
            let polylineRender = MKPolylineRenderer(polyline: polyline)
            
            polylineRender.strokeColor = UIColor.systemRed
            polylineRender.lineWidth = 3.0
            return polylineRender
        }
        
        // 円のスタイル
        if let circle = overlay as? MKCircle {
            let circleRender = MKCircleRenderer(circle: circle)
            
            circleRender.fillColor = UIColor.systemRed
            circleRender.alpha = 0.4
            return circleRender
        }
        
        return MKOverlayRenderer()
    }
}

// MARK: - NotificationObserver

extension LoggingViewController {
    
    /// 位置情報がアップデートされた通知を受信したときの処理
    /// - Parameter notification: <#notification description#>
    @objc func updateLocationModel(notification: Notification) {
        
        // modelのデータを取得
        if let userInfo =  notification.userInfo?["model"]{
            
            // モデルを定義
            let model = userInfo as! LocationModel
            
            // 画面ラベルを変更
            speedLabel.text = String(Int(model.speed)) + "km/h"
            altitudeLabel.text = String(Int(model.altitude)) + "m"
            
            // 位置を定義
            let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
            
            //　ピンを追加
//            let annotation = MKPointAnnotation()
//            annotation.title = model.timestamp
//            annotation.coordinate = coordinates
//            MapView.addAnnotation(annotation)
            
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
}

// MARK: - Other

extension LoggingViewController {
    
    /// ロギングを開始したときのボタン制御変更
    private func changedButtonWhenStartLogging() {
        
        // ロギングボタン 「取得開始」→「取得終了」
        self.LoggingButton.setTitle("button_title_logging_stop".localized, for: .normal)
        self.LoggingButton.tintColor = UIColor.systemRed
        self.LoggingButton.isEnabled = true
        
        // リセットボタン 無効化
        self.ResetButton.setTitle("button_title_reset".localized, for: .normal)
        self.ResetButton.tintColor = UIColor.systemGray
        self.ResetButton.isEnabled = false
        
        // 保存ボタン 無効化
        self.SaveBotton.setTitle("button_title_save".localized, for: .normal)
        self.SaveBotton.tintColor = UIColor.systemGray
        self.SaveBotton.isEnabled = false
    }
    
    
    /// ロギングを終了したときのボタン制御変更
    private func changedButtonWhenStopLogging() {
        
        // ロギングボタン　「取得終了」→「取得開始」
        self.LoggingButton.setTitle("button_title_logging_start".localized, for: .normal)
        self.LoggingButton.tintColor = UIColor.systemBlue
        self.LoggingButton.isEnabled = true
        
        // リセットボタン 有効化
        self.ResetButton.setTitle("button_title_reset".localized, for: .normal)
        self.ResetButton.tintColor = UIColor.systemRed
        self.ResetButton.isEnabled = true
        
        // 保存ボタン 有効化
        self.SaveBotton.setTitle("button_title_save".localized, for: .normal)
        self.SaveBotton.tintColor = UIColor.systemBlue
        self.SaveBotton.isEnabled = true
    }
}
