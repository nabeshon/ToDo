//
//  Todo.swift
//  ToDo
//
//  Created by 渡邉昇 on 2022/09/10.
//

import UIKit
import RealmSwift

class Todo: Object {
    
    @objc dynamic var todoId: Int = 0 //お気に入りの並べ方用のid保存
    @objc dynamic var title: String! //todo保存
    @objc dynamic var message: String! //詳細保存
    @objc dynamic var date: Date = Date(timeIntervalSince1970: 0) //期限保存
    
}
