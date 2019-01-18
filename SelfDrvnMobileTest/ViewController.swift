//
//  ViewController.swift
//  SelfDrvnMobileTest
//
//  Created by Verma Mukesh on 18/01/19.
//  Copyright © 2019 Verma Mukesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var diccReference : [String : String] = [String : String]()
    
    // MARK: Properties
    @IBOutlet weak var actView: UIActivityIndicatorView!
    @IBOutlet weak var tblBook: UITableView!
    var arrPlanets = ["9789025750022","9789045116136","9789000035526","9789000036851"] // Holds the BookSwagger ISBN numbers
    
    
    // MARK: View lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
   
}

// MARK: UITableView DataSource Methods
extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlanets.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strBookSwaggerISBN = arrPlanets[indexPath.row]
        
        let cell:BookTableViewCell = tableView.dequeueReusableCell(withIdentifier: "bookInfoCell") as! BookTableViewCell
        
        cell.strBookISBN = strBookSwaggerISBN
        if self.diccReference["index"] == "\(indexPath.row)" {
            
        }
        else
        {
            cell.fetchBookDataOfCell()
            self.diccReference["index"] = "\(indexPath.row)"
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell : BookTableViewCell =  tableView.cellForRow(at: indexPath) as! BookTableViewCell
        
        let objInfoScr = self.storyboard?.instantiateViewController(withIdentifier: "BookInformationVC") as! BookInformationVC
        
        objInfoScr.bookModel = cell.cellBookModel
        
        self.navigationController?.pushViewController(objInfoScr, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

