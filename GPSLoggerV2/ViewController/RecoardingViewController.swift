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
    
    @IBOutlet private weak var RecordingButton: UIButton!
    @IBOutlet private weak var ResetButton: UIButton!
    @IBOutlet private weak var SaveBotton: UIButton!
    
    var viewModel: RecordingViewModel?
    var isLocationUpdate: Bool = false

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
        self.RecordingButton.setTitle("位置取得", for: .normal)
        self.RecordingButton.tintColor = UIColor.systemBlue
        
        self.ResetButton.setTitle("リセット", for: .normal)
        self.ResetButton.tintColor = UIColor.systemRed
        
        self.SaveBotton.setTitle("保存", for: .normal)
        self.SaveBotton.tintColor = UIColor.systemBlue
        
        
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
                let alert = Alert.presentWarningAlert(
                    "位置情報の設定が無効になっています",
                    "設定画面から位置情報の取得を許可してください"
                )
                
                // アラートを表示
                present(alert, animated: true, completion: nil)
            case .restricted:
                // アラート設定
                let alert = Alert.presentWarningAlert(
                    "位置情報の設定が制限されています",
                    "ペアレンタルコントロールなどで位置情報の取得が制限されています"
                )
                
                // アラートを表示
                present(alert, animated: true, completion: nil)
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
        }
    }
    
    @IBAction func actionLocationUpdate(_ sender: Any) {
        
        guard let vm = viewModel else {
            return
        }
        
        if isLocationUpdate {
            vm.startLocation()
            isLocationUpdate = false
            
            // ボタンの設定
            self.RecordingButton.setTitle("取得停止", for: .normal)
            self.RecordingButton.tintColor = UIColor.systemRed
            
            self.ResetButton.setTitle("リセット", for: .disabled)
            self.ResetButton.tintColor = UIColor.systemGray
            
            self.SaveBotton.setTitle("保存", for: .disabled)
            self.SaveBotton.tintColor = UIColor.systemGray
            
        } else {
            vm.stopLocation()
            isLocationUpdate = true
            
            // ボタンの設定
            self.RecordingButton.setTitle("位置取得", for: .normal)
            self.RecordingButton.tintColor = UIColor.systemBlue
            
            self.ResetButton.setTitle("リセット", for: .normal)
            self.ResetButton.tintColor = UIColor.systemRed
            
            self.SaveBotton.setTitle("保存", for: .normal)
            self.SaveBotton.tintColor = UIColor.systemBlue
        }
    }

}
