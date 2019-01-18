//
//  ViewController.swift
//  SelfDrvnMobileTest
//
//  Created by Verma Mukesh on 18/01/19.
//  Copyright © 2019 Verma Mukesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var actView: UIActivityIndicatorView!
    @IBOutlet weak var tblBook: UITableView!
    var arrPlanets = [BookSwagger]() // Holds the BookSwagger NSManagedObjectModel
    
    
    // MARK: View lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fetchBookSwagger()
    }
    
    // MARK: Api Handling Method
    
    @objc func refreshData(_ id : Any) {
        
        fetchBookSwagger()
    }
    
    func fetchBookSwagger() {
        // first check for internet connection
        if Reachability.isConnectedToNetwork(){
            self.actView.startAnimating()
            print("Internet Connection Available!")
            let apiManager  = ApiManager()
            apiManager.makeGetRestApiRequest("https://www.booknomads.com/api/v0/isbn/9789000035526") { (bookModel , error ) -> (Void) in
                
                DispatchQueue.main.async {
                    
                    self.actView.stopAnimating()
                    
                    // first check for error if any
                    if let objError = error
                    {
                        switch objError {
                        case ApiErrors.dataNotFound:
                            print("Handle No Data found")
                        case ApiErrors.invalidResponse:
                            print("Handle invalid response")
                        case ApiErrors.unsuppotedURL:
                            print("Handle No Data found")
                        }
                    }
                    else
                    {
                       
                       
                        self.tblBook.reloadData()
                        
                    }
                }
            }
        }
        else{
            // Display Alert for no internet connection
            let alertController = UIAlertController(title: "Alert", message: "Internet Connection not available!", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                
            }
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            
            // Adding right bar button to refresh the content
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
            
        }
    }
    
    // MARK: UITableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlanets.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let BookSwagger = arrPlanets[indexPath.row]
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "planetCellId") as! UITableViewCell
//        cell.textLabel?.text = BookSwagger.
//        cell.detailTextLabel?.text = BookSwagger.planetterrain
        return cell;
    }
}

