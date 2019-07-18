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

class RequestData {
    
}
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
