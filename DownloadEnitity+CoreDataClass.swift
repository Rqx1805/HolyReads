 
//  DownloadEnitity+CoreDataClass.swift
//  Holy Reads
//
//  Created by mac-14 on 27/12/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//
//

import UIKit
import Foundation
import CoreData

@objc(DownloadEnitity)
public class DownloadEnitity: NSManagedObject {
    
    static let shared = DownloadEnitity()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var getDict = NSMutableArray ()
    var arrDetails = [[DownloadEnitity]]()
    
    //MARK:- Save Data
    func saveData(dict: [String:Any]) {
        var strBookid = Int64()
        if let bookId =  dict["book_id"] as? Int64 {
            strBookid = bookId
        } else {
            print("No id found for saving data in core data")
            return
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
        request.predicate = NSPredicate(format: "id = %d", strBookid )
        request.returnsObjectsAsFaults = false
        do {
            let fetchReq = try! context!.fetch(request)
            if fetchReq.count != 0{
                 self.UpdateData(id: strBookid, userdict: dict)
             } else  {
                let userEntity = NSEntityDescription.insertNewObject(forEntityName: "DownloadEnitity", into: context!) as! DownloadEnitity
                userEntity.id = dict["book_id"] as! Int64
                userEntity.book_name = dict["book_title"] as? String
                userEntity.descript = dict["descript"] as? String
                userEntity.chapter_name =  dict["chapter_name"] as? [String]
                userEntity.book_image = dict["book_image"] as? Data
                userEntity.author_name = dict["author"] as? String
                userEntity.audioUrl = dict["book_name"] as? Data
                userEntity.contains_Audio = dict["contains_Audio"] as? Bool ?? false
                userEntity.contains_Video = dict["contains_Video"] as? Bool ?? false
                userEntity.contains_Book = dict["contains_Book"] as? Bool ?? false
                userEntity.arr_Audio = dict["arr_Audio"] as? [String]
                userEntity.arr_highlight = dict["arr_highlight"] as? Data
                
                  do{
                    try! context?.save()
                    print("Data Saved")
                }
            }
        }
    }
    
    
    //MARK:- Update Data
      func UpdateData(id: Int64, userdict : [String:Any]) {
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
          // let request:NSFetchRequest<UserDetails> = UserDetails.fetchRequest()
          request.predicate = NSPredicate(format: "id = %ld", id)
          do{
//            @NSManaged public var audioUrl: Data?
//            @NSManaged public var author_name: String?
//            @NSManaged public var book_id: String?
//            @NSManaged public var book_image: Data?
//            @NSManaged public var book_name: String?
//            @NSManaged public var id: Int64
              let test = try! context?.fetch(request)
              if test?.count != 0{
                let objupdate = test![0] as! NSManagedObject
                //objupdate.setValue("roman", forKey: "country")
                if let id = userdict["book_id"] as? Int64{
                    objupdate.setValue(id, forKey: "id")
                }
                if let bookName = userdict["book_title"] as? String {
                    objupdate.setValue(bookName, forKey: "book_name")
                }
                if let  bookImage = userdict["book_image"] as? Data {
                    objupdate.setValue(bookImage, forKey: "book_image")
                }
                if let  videoUrl = userdict["video_url"] as? Data {
                    objupdate.setValue(videoUrl, forKey: "video_url")
                }
                if let  authorName = userdict["author"] as? String {
                    objupdate.setValue(authorName, forKey: "author_name")
                }
                if let containAudio = userdict["contains_Audio"] as? Bool {
                    objupdate.setValue(containAudio, forKey: "contains_Audio")
                }
                if let containsVideo = userdict["contains_Video"] as? Bool {
                    objupdate.setValue(containsVideo, forKey: "contains_Video")
                }
                if let arrAudio = userdict["arr_Audio"] as? [String] {
                    objupdate.setValue(arrAudio, forKey: "arr_Audio")
                }
                if let arr_highlight = userdict["arr_highlight"] as? Data {
                    objupdate.setValue(arr_highlight, forKey: "arr_highlight")
                }
                if let containsBook = userdict["contains_Book"] as? Bool {
                    objupdate.setValue(containsBook, forKey: "contains_Book")
                }
                   do{
                      try! context?.save()
                      print("Update Data saved.")
                  }
              }
              else{
                  return
              }
          }
      }
    
    func fetchData() -> [DownloadEnitity] {
            var allUsersDetails  = [DownloadEnitity]()
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
           do {
               allUsersDetails = try! context?.fetch(fetchRequest) as! [DownloadEnitity]
               for location in allUsersDetails {
                   print(location)
               }
           }
           return allUsersDetails
       }
    
    func fetchDataForId(BookId: Int64) -> DownloadEnitity {
        var dictUsersDetails  = DownloadEnitity()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
            fetchRequest.predicate = NSPredicate(format: "id = %d", BookId )
            fetchRequest.returnsObjectsAsFaults = false
  
        do {
            let result = try context!.fetch(fetchRequest) as Any
            if let dict = result as? [DownloadEnitity] {
                dictUsersDetails =  dict[0] as! DownloadEnitity
                 print("It's is")
                //dictUsersDetails =  dict
            } else {
                print("It's not")
            }
            print(dictUsersDetails)
        }  catch {
            print("Failed")
        }
        return dictUsersDetails
//            dictUsersDetails =  try! context?.fetch(fetchRequest) as! [DownloadEnitity]
//            return dictUsersDetails
    }
    
    
    //MARK:- Delete Data For ID
      func DeleteData(id: Int64) {
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
          // let request:NSFetchRequest<UserDetails> = UserDetails.fetchRequest()
          request.predicate = NSPredicate(format: "id = %ld", id)
          do{
              let test = try! context?.fetch(request)
              if test?.count != 0{
                  let objupdate = test![0] as! NSManagedObject
                   do{
                      try! context?.delete(objupdate)
                      print("Data Deleted Data saved.")
                  }
              }
              else{
                  return
              }
          }
      }
 
    
    func deleteAllData() {
     let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
     request.returnsObjectsAsFaults = false
     do {
        let results = (try  context?.fetch(request))!
         for object in results {
             guard let objectData = object as? NSManagedObject else {continue}
             context?.delete(objectData)
         }
     } catch let error {
         print("Detele all data in \(entity) error :", error)
     }
 }
    
    func DeleteIDData(arrDelete :[Int64]) {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
              // let request:NSFetchRequest<UserDetails> = UserDetails.fetchRequest()
             for id in arrDelete {
              request.predicate = NSPredicate(format: "id = %ld", id)
              do{
                  let test = try! context?.fetch(request)
                 let objupdate = test![0] as! NSManagedObject
                       do{
                          try! context?.delete(objupdate)
                          print("Data Deleted Data saved.")
                      }
               } catch let error {
                  print("Detele all data in \(entity) error :", error)
              }
          }
     }

}
