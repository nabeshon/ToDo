//
//  ViewController.swift
//  ToDo
//
//  Created by 渡邉昇 on 2022/09/10.
//

import UIKit
import RealmSwift

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var sortButton: UIBarItem!
    
    let realm = try! Realm()
    
    var todoes: [Todo?] = []
    
    var todo: Todo?
    
    //既存のtodoを編集するのかどうか
    var isRewrite: Bool = false
    
    //期限順で並び替えるかどうか
    var isDateSort: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //TODOをRealmから取得
        todoes = Array(realm.objects(Todo.self))
        
        //編集ボタンなどを追加
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_ :)))
        navigationItem.rightBarButtonItems = [editButtonItem, addBarButtonItem]
    }
    
    //画面が表示されるたびにtableViewのデータを全更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    //新規作成ボタンを押されたときの処理
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        todo = nil
        isRewrite = false
        performSegueToTodo()
    }
    
    //並び替えモード切替のボタンが押されたときの処理
    @IBAction func sort() {
        if !isDateSort {
            sortButton.title = "お気に入り"
        } else {
            sortButton.title = "期限順"
        }
        isDateSort = !isDateSort
        reloadData()
    }
    
    //Realmからデータを一度取得してからtableViewに反映させる
    func reloadData() {
        if isDateSort {
            todoes = Array(realm.objects(Todo.self).sorted(byKeyPath: "date", ascending: true))
        } else {
            todoes = Array(realm.objects(Todo.self).sorted(byKeyPath: "todoId", ascending: true))
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoes.count
    }
    
    //todoのタイトルを一覧に
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = todoes[indexPath.row]?.title
        return cell
    }
    
    //既存のtodoが選択されたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todo = todoes[indexPath.row]
        isRewrite = true
        performSegueToTodo()
    }
    
    //編集モードになったら
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    //ユーザーがtodoを削除したとき
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write{
                //realmから削除
                realm.delete(todoes[indexPath.row]!)
            }
            //todoesからも削除
            todoes.remove(at: indexPath.row)
            //並び方を設定する
            try! realm.write{
                if todoes.count > 0 {
                    for i in 0...todoes.count - 1 {
                        todoes[i]?.todoId = i
                    }
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        reloadData()
    }
    
    //ユーザーが好きなように並び替えられる
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        //todoesで変更
        let selectedtodo = todoes[fromIndexPath.row]
        todoes.remove(at: fromIndexPath.row)
        todoes.insert(selectedtodo, at: to.row)
        //並び方を設定する
        try! realm.write{
            for i in 0...todoes.count - 1 {
                todoes[i]?.todoId = i
            }
        }
        reloadData()
    }
    
    //画面遷移用
    func performSegueToTodo() {
        performSegue(withIdentifier: "toTodoView", sender: nil)
    }
    
    //todoが既存か新規か、既存ならどのtodoかを次の画面に送信する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTodoView" {
            let todoViewController = segue.destination as! TodoViewController
            todoViewController.todo = self.todo
            todoViewController.isRewrite = self.isRewrite
        }
    }

}

