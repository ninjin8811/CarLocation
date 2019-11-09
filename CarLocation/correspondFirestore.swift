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
    var documentIDarray = [String]()
    
    
    //RouteDataを保存する時に使う
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
    
    //位置情報をRouteDataの中に保存する時に使う
    func uploadLocation(_ index: Int, _ data: locationData, _ uid: String) {
        
        routes[index].latestLocation = data
        do {
            let mergeLocationData = try FirestoreEncoder().encode(routes[index])
            firestoreDB.collection("users").document(uid).collection("routes").document(documentIDarray[index]).setData(mergeLocationData, merge: true) { (error) in
                if let errorMessage = error {
                    print("Firestoreへの位置情報のマージに失敗しました：\(errorMessage)")
                } else {
                    print("位置情報をFirestoreへマージしました")
                }
            }
        } catch {
            print("エンコードに失敗しました：\(error)")
        }
    }
    
    //地点の追加時に使う
    func mergeSpotdata(_ index: Int, _ after: @escaping (Bool) -> Void) {
        var isStored = false
        guard let uid = Auth.auth().currentUser?.uid else {
            preconditionFailure("ユーザーIDの取得に失敗しました")
        }
        let sinceDate = Date().timeIntervalSince1970
        routes[index].updatedDate = sinceDate
        
        do {
            let mergeData = try FirestoreEncoder().encode(routes[index])
            firestoreDB.collection("users").document(uid).collection("routes").document(documentIDarray[index]).setData(mergeData, merge: true) { (error) in
                if let errorMessage = error {
                    print("Firestoreへのデータのマージに失敗しました：\(errorMessage)")
                } else {
                    isStored = true
                    print("データをFirestoreへ追加保存,削除しました")
                }
                after(isStored)
            }
        } catch {
            print("エンコードに失敗しました：\(error)")
        }
    }
    
    //データを全て取得する時に使う
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
                        self.documentIDarray.append(document.documentID)
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
