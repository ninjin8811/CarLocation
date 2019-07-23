//
//  CorrespondFirestore.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/18.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import CodableFirebase

class CorrespondData {
    
    let firestoreDB = Firestore.firestore()
    var routes = [RouteData]()
    
    func storeData(_ data: Any, _ after: @escaping (Bool) -> Void) {
        var isStored = false
        guard let uid = Auth.auth().currentUser?.uid else {
            preconditionFailure("ユーザーIDの取得に失敗しました")
        }
        guard var dictionaryData = data as? [String: Any] else {
            preconditionFailure("保存する路線データを辞書型に変換できませんでした")
        }
        let sinceDate = Date().timeIntervalSince1970
        dictionaryData["updatedDate"] = sinceDate
        firestoreDB.collection("users").document(uid).collection("routes").addDocument(data: dictionaryData) { (error) in
            if let errorMessege = error {
                print("FireStoreへのデータの保存に失敗しました：\(errorMessege)")
            } else {
                isStored = true
                print("データをFirestoreへ保存しました")
            }
            after(isStored)
        }
        
    }
    
    func fetchData(_ after: @escaping (Bool) -> Void) {
        var isFetched = false
        guard let uid = Auth.auth().currentUser?.uid else {
            preconditionFailure("ユーザーIDの取得に失敗しました")
        }
        firestoreDB.collection("users").document(uid).collection("routes").order(by: "updatedDate").getDocuments { (snapshots, error) in
            
            if let error = error {
                print("Firestoreからのデータの取得に失敗しました：\(error)")
            } else {
                print("Firestoreからデータを取得しました")
                self.routes.removeAll()
            
                guard let fetchedData = snapshots else {
                    preconditionFailure("snapshotsにデータが存在しませんでした")
                }
                for document in fetchedData.documents {
                    do {
                        let addRouteData = try FirestoreDecoder().decode(RouteData.self, from: document.data())
                        self.routes.append(addRouteData)
                        isFetched = true
                    } catch {
                        print("Firestoreから取得したドキュメントのデコードに失敗しました")
                    }
                }
                print(self.routes)
            }
            after(isFetched)
        }
    }
 }


//guard let uid = userID else {
//    preconditionFailure("ユーザーIDが渡されてませんでした！")
//}
//
//let profileDictionary: [String: Any] = ["gender": gender, "name": name, "age": age, "team": team, "region": region, "userID": uid, "imageURL": profileData.imageURL]
//
//db.collection("users").document(uid).setData(profileDictionary) { (error) in
//    if error != nil {
//        print("セーブできませんでした！")
//    } else {
//        print("セーブできました！")
//    }
//}


//var ref = db.collection("users") as Query
//
//for i in 0..<child.count {
//    let temp = ref.whereField(child[i], isEqualTo: equelValue[i])
//    ref = temp
//}
//ref.getDocuments { (snapshots, error) in
//    if error != nil {
//        print("ユーザーの検索に失敗しました！")
//    } else {
//        guard let snap = snapshots else {
//            preconditionFailure("データの取得に失敗しました！")
//        }
//        for document in snap.documents {
//            do {
//                let data = try FirestoreDecoder().decode(Profile.self, from: document.data())
//                self.list.append(data)
//            } catch {
//                print("取得したデータのデコードに失敗しました！")
//            }
//        }
//    }
//    self.goToPreviousView()
//}
