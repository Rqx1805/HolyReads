//
//  SaveItemModel.swift
//  iMenu
//
//  Created by Techugo on 17/10/18.
//  Copyright © 2018 Techugo. All rights reserved.
//

import Foundation

struct itemModel {
    
    let book_id: String!
    let user_id: String!
    let app_id: String!
    let chapter_name:  String!
    let note: String!
    var page_number: String!
    let rangy:  String!
    let content:  String!
    let type:  String!
   
    init(book_id:String, user_id:String , app_id:String, chapter_name:String!, note:String, page_number:String! ,rangy:String,content:String,type:String){
        
        self.book_id   =   book_id
        self.user_id  =   user_id
        self.app_id       =   app_id
        self.chapter_name  =   chapter_name
        
        self.note      =   note
        self.page_number =   page_number
        self.rangy     =   rangy
        self.content   =  content
        self.type =        type
    }
}
