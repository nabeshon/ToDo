//
//  TodoViewController.swift
//  ToDo
//
//  Created by 渡邉昇 on 2022/09/10.
//

import UIKit
import RealmSwift

class TodoViewController: UIViewController{
    
    var todo: Todo?
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var dateSelector: UITextField!
    
    let realm = try! Realm()
    
    var datePicker = UIDatePicker()
    
    //既存のtodoを変更しているかどうか
    var isRewrite: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        messageTextField.borderStyle = .roundedRect
        
        //既存のtodoを変更しているなら前画面からデータを受け取って反映
        if isRewrite {
            titleTextField.text = todo?.title
            messageTextField.text = todo?.message
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年 M月d日"
            dateSelector.text = formatter.string(from: todo!.date)
        }
        
        //DatePicker用処理
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月d日"
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dateSelector.inputView = datePicker
        dateSelector.inputAccessoryView = toolbar
    }
    
    //「保存」が押されたときの処理
    @IBAction func save() {
        if isRewrite {
            //既存のならそれを更新
            let targetTodo = realm.objects(Todo.self).filter{ $0.title == self.todo?.title}.first
            try! realm.write{
                targetTodo?.title = titleTextField.text!
                targetTodo?.message = messageTextField.text!
                targetTodo?.date = datePicker.date
            }
        } else {
            //新規なら新規作成
            let newTodo = Todo()
            newTodo.title = titleTextField.text!
            newTodo.message = messageTextField.text!
            newTodo.date = datePicker.date
            newTodo.todoId = realm.objects(Todo.self).count
            try! realm.write {
                realm.add(newTodo)
            }
        }
        //前の画面に戻る
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //DatePickerで日付選択した時に実行される
    @objc func done() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月d日"
        dateSelector.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
