//
//  AdminEditRouteTableViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/17.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit

class AdminEditRouteTableViewController: UITableViewController {
    
    let editMenuList = ["時刻表の確認・追加", "地点の編集・追加"]
    var correspondFirestore: CorrespondData?
    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = correspondFirestore?.routes[selectedIndex].routeName ?? "ルートの編集"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAdminMapView" {
            guard let destinationVC = segue.destination as? AdminMapViewController else {
                preconditionFailure("遷移先のViewControllerを取得できませんでした")
            }
            destinationVC.correspondFirestore = correspondFirestore
            destinationVC.selectedIndex = selectedIndex
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editMenuList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeEditMenuCell", for: indexPath)
        cell.textLabel?.text = editMenuList[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "goToAdminTimetableView", sender: self)
            break
        
        case 1:
            performSegue(withIdentifier: "goToAdminMapView", sender: self)
            break
            
        default:
            break
        }
    }
}
