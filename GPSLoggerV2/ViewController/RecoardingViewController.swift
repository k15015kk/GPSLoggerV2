//
//  RecoardingViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit
import CoreLocation

class RecordingViewController: UIViewController {
    
    @IBOutlet weak private var recordingButton: UIButton!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var resetButton: UIButton!
    
    var viewModel: RecordingViewModel?
    var isLocationUpdate: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewModelを定義
        viewModel = RecordingViewModel()
        
        // 今あるRealmのデータは全消去
        viewModel!.allDeleteRealmData()
        
        recordingButton.setTitle("取得開始", for: .normal)
        saveButton.setTitle("保存", for: .normal)
        resetButton.setTitle("リセット", for: .normal)
        
        recordingButton.tintColor = .green
        saveButton.tintColor = .blue
        resetButton.tintColor = .red
        
        
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
        print("モデルの値が変更になりました")
        print(notification.userInfo?["model"])
    }
    
    @IBAction func actionLocationUpdate(_ sender: Any) {
        
        guard let vm = viewModel else {
            return
        }
        
        if isLocationUpdate {
            vm.startLocation()
            isLocationUpdate = false
            
            recordingButton.setTitle("取得停止", for: .normal)
            saveButton.setTitle("保存", for: .disabled)
            resetButton.setTitle("リセット", for: .disabled)
            
            recordingButton.tintColor = .red
            saveButton.tintColor = .gray
            resetButton.tintColor = .gray
        } else {
            vm.stopLocation()
            isLocationUpdate = true
            
            recordingButton.setTitle("取得開始", for: .normal)
            saveButton.setTitle("保存", for: .normal)
            resetButton.setTitle("リセット", for: .normal)
            
            recordingButton.tintColor = .green
            saveButton.tintColor = .blue
            resetButton.tintColor = .red
        }
    }

}
