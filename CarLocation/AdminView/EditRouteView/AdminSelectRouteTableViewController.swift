//
//  AdminSelectRouteTableViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/13.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit

class AdminSelectRouteTableViewController: UITableViewController {
    
    var routeList = [RouteData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //1つだけサンプルとしてルートを作っておく
        let route = RouteData()
        route.routeName = "サンプル"
        routeList.append(route)
        tableView.reloadData()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeListCell", for: indexPath)
        
        cell.textLabel?.text = routeList[indexPath.row].routeName
        
        return cell
    }

}
