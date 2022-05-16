//
//  RecoardingViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit
import CoreLocation

class RecordingViewController: UIViewController {
    
    var viewModel: RecordingViewModel?
    var isLocationUpdate: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = RecordingViewModel()
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
    
    @IBAction func actionLocationUpdate(_ sender: Any) {
        
        guard let vm = viewModel else {
            return
        }
        
        if isLocationUpdate {
            vm.startLocation()
            isLocationUpdate = false
        } else {
            vm.stopLocation()
            isLocationUpdate = true
        }
    }

}
