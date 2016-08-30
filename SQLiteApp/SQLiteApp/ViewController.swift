//
//  ViewController.swift
//  SQLiteApp
//
//  Created by class24 on 2016/8/30.
//  Copyright © 2016年 GUO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    struct Student {
        var id: Int32
        var name: String
        var chinese: Int32
        var math: Int32
        init(id: Int32, name: String, chinese: Int32, math: Int32) {
            self.id = id
            self.name = name
            self.chinese = chinese
            self.math = math
        }
    }
    
    
    // 畫面顯示物件
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numberTextField: UITextField!
    // 資料庫設定參數：資料庫物件、儲存空間、表格資料陣列
    var db: COpaquePointer = nil
    var records: COpaquePointer = nil
    var studentsArray: Array<Student> = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        
        // 取得專案中DB的路徑
        let path = NSBundle.mainBundle().pathForResource("StudentDB", ofType: "sqlite")
        // 開啟資料庫（路徑、位置）
        if sqlite3_open(path!, &db) != SQLITE_OK {
            // 顯示錯誤訊息
            self.showAlert("開啟資料庫失敗", message: "錯誤資訊：\(sqlite3_open(path!, &db))\n請重新確認您的資料庫")
            // 離開程式
            exit(1)
        } 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 顯示訊息窗
    func showAlert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "確定", style: .Default, handler: { (action1) in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 連結DB、取得DB欄位資料
    func catchData() {
        let id = sqlite3_column_int(records, 0)
        // 資料庫的 TEXT 為 C 語言處理：先儲存成 strName、再轉成 String 型態
        let strName = sqlite3_column_text(records, 1)
        let name = String.fromCString(UnsafePointer<CChar>(strName))
        let chinese = sqlite3_column_int(records, 2)
        let math = sqlite3_column_int(records, 3)
        
        let student = Student(id: id, name: name!, chinese: chinese, math: math)
        // 加入 tableView 顯示資料陣列
        self.studentsArray.append(student)
    }
    
    
    @IBAction func searchAction(sender: UIButton) {
        // 取得 輸入收尋編號
        let index: Int = Int(self.numberTextField.text!) ?? 0
        
        if index > 0 && index < 10 {
            // 清空儲存空間
            self.records = nil
            // SQL 語法
            let sql: NSString = "Select * From class101 Where s_id=" + self.numberTextField.text!
            if sqlite3_prepare_v2(db, sql.UTF8String, -1, &records, nil) != SQLITE_OK {
                self.showAlert("讀取資料庫資料失敗", message: "請確認您的資料庫內容")
                exit(1)
            } 
            // 清空tableView資料陣列
            self.studentsArray.removeAll()
            // 加入資料庫資料(只得到一筆資料)
            if sqlite3_step(records) == SQLITE_ROW {
                catchData()
            } else {
                self.showAlert("找不到編號\(self.numberTextField.text!)資料", message: "")
            }
            // 結束、關閉資料庫讀取
            sqlite3_finalize(records)
            // 重整 tableView
            self.tableView.reloadData()
            
            
        } else {
            self.showAlert("輸入查詢編號超出範圍", message: "請確認您的編號欄位")
        }
        
    }

    @IBAction func searchAllAction(sender: UIButton) {
        // 清空儲存空間
        self.records = nil
        // SQL 語法
        let sql: NSString = "Select * From class101"
        if sqlite3_prepare_v2(db, sql.UTF8String, -1, &records, nil) != SQLITE_OK {
            self.showAlert("讀取資料庫資料失敗", message: "請確認您的資料庫內容")
            exit(1)
        } 
        // 清空tableView資料陣列
        self.studentsArray.removeAll()
        // 加入資料庫資料
        while sqlite3_step(records) == SQLITE_ROW {
            catchData()
        }
        // 結束、關閉資料庫讀取
        sqlite3_finalize(records)
        // 重整 tableView
        self.tableView.reloadData()
               
    }

}
extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentsArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        cell.textLabel?.text = "姓名：\(self.studentsArray[indexPath.row].name)"
        cell.detailTextLabel?.text = "編號：\(self.studentsArray[indexPath.row].id)，國文：\(self.studentsArray[indexPath.row].chinese)，數學：\(self.studentsArray[indexPath.row].math)"
        return cell
    }
}
