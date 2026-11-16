//
//  DownloadEnitity+CoreDataProperties.swift
//  Holy Reads
//
//  Created by mac-14 on 31/12/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//
//

import Foundation
import CoreData


extension DownloadEnitity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadEnitity> {
        return NSFetchRequest<DownloadEnitity>(entityName: "DownloadEnitity")
    }

    @NSManaged public var arr_Audio: [String]?
    @NSManaged public var audioUrl: Data?
    @NSManaged public var author_name: String?
    @NSManaged public var descript: String?
    @NSManaged public var chapter_name: [String]?
    @NSManaged public var book_image: Data?
    @NSManaged public var book_name: String?
    @NSManaged public var contains_Audio: Bool
    @NSManaged public var contains_Video: Bool
    @NSManaged public var id: Int64
    @NSManaged public var contains_Book: Bool
    @NSManaged public var arr_highlight: Data?
    

}
