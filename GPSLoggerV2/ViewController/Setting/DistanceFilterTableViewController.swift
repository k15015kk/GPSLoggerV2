//
//  DistanceFilterSettingController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/15.
//

import UIKit

class DistanceFilterTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var distanceFilterTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceFilterTextField.delegate = self
        
        // UserDefaultが保存されている場合，それを表示する
        let distanceFilter = UserDefaults.standard.float(forKey: "distanceFilter")
        distanceFilterTextField.text = String(distanceFilter)
        
        // UITapGestureRecognizerを定義
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapped(_:)))
        
        // デリゲートをセット
        tapGesture.delegate = self
        
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    // MARK: TableViewのデータソース
    
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
    
    // MARK: TextFieldDelegate
    
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
    
    // MARK: UITapGestureRecognizer
    
    /// 画面内をタップしたときの処理
    /// - Parameter sender: sender
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            self.view.endEditing(true)
        }
    }
}

extension DistanceFilterTableViewController {
    func checkFloatDistanceFilter(distance distanceFilter: String?) -> Bool {
        
        guard let distanceFilter = distanceFilter else {
            return false
        }
        
        if let distance = Float(distanceFilter){
            
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
    
    func presentWarningAlert(_ title: String, _ message: String) {
        // アラートを定義
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKを押した際の処理を追加
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        // アラートにOKボタンを追加
        alert.addAction(ok)
        
        // アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    func saveDistanceFilter(distance distanceFilter: String?) {
        
        guard let distanceFilter = distanceFilter else {
            return
        }
        
        let defaults = UserDefaults.standard
        
        if let distanceFilterValue = Float(distanceFilter) {
            defaults.set(distanceFilterValue, forKey: "distanceFilter")
            distanceFilterTextField.text = String(distanceFilterValue)
        }
        
    }
}
