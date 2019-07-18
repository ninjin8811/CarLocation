//
//  AdminMenuTableViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/13.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit

class AdminMenuTableViewController: UITableViewController {
    
    let adminMenuList = ["ルートを追加・編集", "ログアウト"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adminMenuList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminMenuCell", for: indexPath)
        
        cell.textLabel?.text = adminMenuList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "goToRouteListView", sender: self)
            break
            
        case 1:
            dismiss(animated: true, completion: nil)
            break
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}
