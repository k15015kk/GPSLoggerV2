//
//  ActivityTypeTableViewController.swift
//  GPSLoggerV2
//
//  Created by 井上晴稀 on 2022/05/16.
//

import UIKit

class ActivityTypeTableViewController: UITableViewController {
    
    private var selectedRow: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let numActivity = UserDefaults.standard.integer(forKey: "activityType")
        self.selectedRow = numActivity
        
        if let selectedCell = tableView.cellForRow(at: IndexPath(row: numActivity, section: 0)) {
            selectedCell.accessoryType = .checkmark
        }
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
            return 5
        default :
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // すでに選択している場合は，何も発生しない
        if indexPath.row == selectedRow {
            return
        }
        
        // 選択中のセルを解除
        if let prevSelectedCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) {
            prevSelectedCell.accessoryType = .none
        }
        
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedCell.accessoryType = .checkmark
        }
        
        saveActivityType(activity: indexPath.row)
        selectedRow = indexPath.row
    }

}

extension ActivityTypeTableViewController {
    func saveActivityType(activity activityType: Int) {
        let defaults = UserDefaults.standard
        defaults.set(activityType, forKey: "activityType")
    }
}
