//
//  DistanceFilterSettingController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit

class DistanceFilterTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // MARK: UI
    
    @IBOutlet private weak var distanceFilterTextField: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // テキストフィールドのデリゲートを設定
        distanceFilterTextField.delegate = self
        
        // UserDefaultが保存されている場合は，それを表示する
        let distanceFilter = UserDefaults.standard.float(forKey: "distanceFilter")
        distanceFilterTextField.text = String(distanceFilter)
        
        // UITapGestureRecognizerを定義
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapped(_:)))
        
        // タップジェスチャーのデリゲートを設定
        tapGesture.delegate = self
        
        // タップジェスチャーを設定
        self.view.addGestureRecognizer(tapGesture)
        
    }
}

// MARK: - UITableViewController

extension DistanceFilterTableViewController{
    
    /// TableView内のセクション数を返します
    /// - Parameter tableView: TableViewのオブジェクト
    /// - Returns: セクション数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// セクションごとのRow数を返します
    /// - Parameters:
    ///   - tableView: TableViewのオブジェクト
    ///   - section: セクション情報（数値）
    /// - Returns: セクションごとのRow数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /// セクションごとのRowを返す
        switch section {
        case 0:
            return 1
        default :
            return 0
        }
    }

}

// MARK: - TextFieldDelegate

extension DistanceFilterTableViewController {
    
    /// キーボード内のエンターが呼ばれたときの処理
    /// - Parameter textField: テキストフィールドの情報
    /// - Returns: 終了値
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        self.distanceFilterTextField.endEditing(true)
        return true
    }
    
    /// キーボードが閉じる直前の処理
    /// - Parameter textField: テキストフィールドの情報
    /// - Returns: 終了値
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        // 入力値が小数かどうかチェック
        if checkFloatDistanceFilter(distance: textField.text) {

            // 入力値が小数の場合，値をUserDefaultに保存
            saveDistanceFilter(distance: textField.text)
        }
        
        return true
    }
    
}

// MARK: - UITapGestureRecognizer

extension DistanceFilterTableViewController {
    
    /// 画面内をタップしたときの処理
    /// - Parameter sender: UITapGestureRecognizerのSender
    @objc func tapped(_ sender: UITapGestureRecognizer){
        
        if sender.state == .ended {
            self.view.endEditing(true)
        }
    }
}

// MARK: - Others

extension DistanceFilterTableViewController {
    
    /// 距離が適切な小数値か判定する関数です
    /// - Parameter distanceFilter: 設定した距離値
    /// - Returns: 適切な距離値かどうかBoolで返します
    func checkFloatDistanceFilter(distance distanceFilter: String?) -> Bool {
        
        guard let distanceFilter = distanceFilter else {
            return false
        }
        
        // 距離が小数値かどうか判定
        if let distance = Float(distanceFilter){
            
            // 距離が0未満の場合はアラートを出す
            if distance < 0 {
                
                // 警告アラートを出す
                presentWarningAlert("入力値不正", "0以上の小数を入力してください")
                return false
                
            }
            
            return true
            
        } else {
            
            // 警告アラートを出す
            presentWarningAlert("入力値不正", "小数を入力してください")
            return false
        }
        
    }
    
    /// 距離をUserDefaultに設定します
    /// - Parameter distanceFilter: 最小取得距離
    func saveDistanceFilter(distance distanceFilter: String?) {
        
        guard let distanceFilter = distanceFilter else {
            return
        }
        
        if let distanceFilterValue = Float(distanceFilter) {
            
            UserDefaults.standard.set(distanceFilterValue, forKey: "distanceFilter")
            distanceFilterTextField.text = String(distanceFilterValue)
        }
        
    }
}
