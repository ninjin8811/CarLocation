//
//  AdminSelectRouteTableViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/13.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit
import CodableFirebase
import Firebase
import FirebaseFirestore

class AdminSelectRouteTableViewController: UITableViewController {
    
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

    @IBAction func addButtonPressed(_ sender: Any) {
        let addRouteAlert = UIAlertController(title: "ルートの追加", message: "路線名を追加してください", preferredStyle: .alert)
        addRouteAlert.addTextField(configurationHandler: nil)
        let okAction = UIAlertAction(title: "追加", style: .default) { (action) in
            print("追加ボタンが押されました")
            
            let routeItem = RouteData()
            
            guard let textfields = addRouteAlert.textFields else {
                preconditionFailure("テキストフィールドの取得に失敗しました")
            }
            guard !textfields.isEmpty else {
                return
            }
            guard let addText = textfields.last?.text else {
                preconditionFailure("追加する路線名の取得に失敗しました")
            }
            if addText != "" {
                routeItem.routeName = addText
            } else {
                return
            }
            do {
                let encodedRouteData = try FirestoreEncoder().encode(routeItem)
                self.correspondFirestore.storeData(encodedRouteData, { (isStored) in
                    if isStored {
                        self.correspondFirestore.fetchData({ (isFetched) in
                            if isFetched {
                                self.tableView.reloadData()
                            }
                        })
                    }
                })
            } catch {
                print("エンコードに失敗しました：\(error)")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        addRouteAlert.addAction(okAction)
        addRouteAlert.addAction(cancelAction)
        
        self.present(addRouteAlert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? AdminEditRouteTableViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.correspondFirestore = correspondFirestore
        destinationVC.selectedIndex = selectedIndex
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return correspondFirestore.routes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeListCell", for: indexPath)
        
        cell.textLabel?.text = correspondFirestore.routes[indexPath.row].routeName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "goToEditRouteView", sender: self)
    }

}
