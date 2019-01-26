//
//  BookTableViewCell.swift
//  SelfDrvnMobileTest
//
//  Created by Verma Mukesh on 18/01/19.
//  Copyright © 2019 Verma Mukesh. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    @IBOutlet weak var imgBookCover: UIImageView!
    var strBookISBN : String = ""
    var cellBookModel : BookItem? = nil
    @IBOutlet weak var actBookLoader: UIActivityIndicatorView!
    @IBOutlet weak var lblBookAuthorName: UILabel!
    @IBOutlet weak var lblBookCoverName: UILabel!
    @IBOutlet weak var lblBookName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func fetchBookDataOfCell() {
                // first check for internet connection
            self.actBookLoader.startAnimating()
            searchBook(isbn: strBookISBN)
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

//MARK:- APIs
extension BookTableViewCell {
    func searchBook(isbn: String) {
        
        BookISBNAPI.isbnISBNGet(ISBN: isbn) { (value, error) in
            
            self.actBookLoader.stopAnimating()
            
            if let bookModel = value {
                print(bookModel)
                
                self.cellBookModel = bookModel
                
                self.lblBookCoverName.text = bookModel.title
                self.lblBookName.text = bookModel.ISBN
                
                guard let strHasData = bookModel.coverThumb else
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
                
                guard let arrAuthor = bookModel.authors else
                {
                    return
                }
                
                if arrAuthor.count > 0
                {
                    let arrStrAuthors: [String] =  arrAuthor.map{ $0.name ?? ""
                    }
                    
                    self.lblBookAuthorName.text  = arrStrAuthors.joined(separator:", ")
                }
                
            } else {
                if let err = error {
                    print(err.localizedDescription ?? "")
                } else {
                    print("Unknown error occured")
                }
            }
            
            
        }
    }
}
