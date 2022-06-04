//
//  DesiredAccuracyTableViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit

class DesiredAccuracyTableViewController: UITableViewController {
    
    // MARK: UI
    
    @IBOutlet private weak var desiredAccuracyTextField: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desiredAccuracyTextField.delegate = self
        
        // UserDefaultが保存されている場合，それを表示する
        let desiredAccuracy = UserDefaults.standard.float(forKey: "desiredAccuracy")
        desiredAccuracyTextField.text = String(desiredAccuracy)
        
        // UITapGestureRecognizerを定義
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapped(_:)))
        
        // デリゲートをセット
        tapGesture.delegate = self
        
        // タップジェスチャーを設定
        self.view.addGestureRecognizer(tapGesture)
        
    }
}

// MARK: - UITableViewController

extension DesiredAccuracyTableViewController {
    
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

extension DesiredAccuracyTableViewController: UITextFieldDelegate {
    
    /// キーボード内のエンターが呼ばれたときの処理
    /// - Parameter textField: テキストフィールドの情報
    /// - Returns: 終了値
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボードを閉じる
        self.desiredAccuracyTextField.endEditing(true)
        return true
    }
    
    /// キーボードが閉じる直前の処理
    /// - Parameter textField: テキストフィールドの情報
    /// - Returns: 終了値
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        // 入力値が小数かどうかチェック
        if checkFloatDesiredAccuracy(accuracy: textField.text) {

            // 入力値が小数の場合，値をUserDefaultに保存
            saveDesiredAccuracy(accuracy: textField.text)
        }
        
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DesiredAccuracyTableViewController: UIGestureRecognizerDelegate {
    
    /// 画面内をタップしたときの処理
    /// - Parameter sender: sender
    @objc func tapped(_ sender: UITapGestureRecognizer){
        
        if sender.state == .ended {
            self.view.endEditing(true)
        }
    }
}

// MARK: - Ohters

extension DesiredAccuracyTableViewController {
    
    /// 精度値が適切な値かどうかを判定する関数です
    /// - Parameter desiredAccuracy: 入力した精度値
    /// - Returns: 精度が適切な値かBool値で返します
    func checkFloatDesiredAccuracy(accuracy desiredAccuracy: String?) -> Bool {
        
        guard let desiredAccuracy = desiredAccuracy else {
            return false
        }
        
        // 精度が小数値かどうか判定
        if let accuracy = Float(desiredAccuracy){
            
            // 精度が０未満であればアラートを出す
            if accuracy < 0 {
                
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
    
    /// 精度値を設定します
    /// - Parameter desiredAccuracy: 設定する精度値
    func saveDesiredAccuracy(accuracy desiredAccuracy: String?) {
        
        guard let desiredAccuracy = desiredAccuracy else {
            return
        }
        
        if let desiredAccuracyValue = Float(desiredAccuracy) {
            
            UserDefaults.standard.set(desiredAccuracyValue, forKey: "desiredAccuracy")
            desiredAccuracyTextField.text = String(desiredAccuracyValue)
        }
        
    }
}
