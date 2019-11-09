//
//  LocationRouteTableViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/08/03.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit
import CodableFirebase
import Firebase
import FirebaseFirestore

class LocationRouteTableViewController: UITableViewController {
    
    let correspondFirestore = CorrespondData()
    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Firestoreと通信してデータを取得
        correspondFirestore.fetchData { (isFetched) in
            if isFetched {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? UploadLocationViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.uncorrespondFirestore = correspondFirestore
        destinationVC.selectedIndex = selectedIndex
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return correspondFirestore.routes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "uploadRouteCell", for: indexPath)
        
        cell.textLabel?.text = correspondFirestore.routes[indexPath.row].routeName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "goToUploadLocation", sender: self)
    }

}
