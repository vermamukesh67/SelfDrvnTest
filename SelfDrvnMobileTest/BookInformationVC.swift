//
//  BookInformationVC.swift
//  SelfDrvnMobileTest
//
//  Created by Verma Mukesh on 18/01/19.
//  Copyright © 2019 Verma Mukesh. All rights reserved.
//

import UIKit

class BookInformationVC: UITableViewController {
    @IBOutlet weak var lblBookDesc: UILabel!
    
    @IBOutlet weak var lblSubjects: UILabel!
    @IBOutlet weak var imgBookCover: UIImageView!
    var bookModel : BookItem? = nil
    @IBOutlet weak var actBookLoader: UIActivityIndicatorView!
    @IBOutlet weak var lblBookAuthorName: UILabel!
    @IBOutlet weak var lblBookCoverName: UILabel!
    @IBOutlet weak var lblBookName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = UIView.init()
        
        if let bookisbn = bookModel?.ISBN
        {
            self.lblBookName.text = bookisbn
        }
        
        if let booktitle = bookModel?.title
        {
            self.lblBookCoverName.text = booktitle
        }
        
        guard let strHasData = bookModel?.coverThumb else
        {
            return
        }
        
        let arr = strHasData.components(separatedBy: ",")
        
        if arr.count > 0
        {
            if let imageData = Data(base64Encoded: arr[arr.count-1])
            {
                let image = UIImage(data: imageData)
                self.imgBookCover.image = image
                
            }
        }
        
        guard let arrAuthor = bookModel?.authors else
        {
            return
        }
        
        if arrAuthor.count > 0
        {
            let arrStrAuthors: [String] =  arrAuthor.map{ $0.name ?? ""
            }
            
            self.lblBookAuthorName.text  =  arrStrAuthors.joined(separator:", ")
        }
        
        if let des = bookModel?._description {
            
            self.lblBookDesc.text = "Description : \n\n" + des
        }
        
        
        guard let arrSubjects = bookModel?.subjects else
        {
            return
        }
        
        if arrSubjects.count > 0
        {
            self.lblSubjects.text  = "Subjects : \n\n" + arrSubjects.joined(separator:", ")
        }

    }
    
}
