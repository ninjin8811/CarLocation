//
//  AdminMapViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/13.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SVProgressHUD

class AdminMapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var mapView: GMSMapView!
    var gmsCamera: GMSCameraPosition!
    var zoomLevel: Float = 15.0
    var uncorrespondFirestore: CorrespondData?
    var selectedIndex = 0
    let popupmenuViewController = PopupMenuViewController()
    var isShownPopupMenu: Bool {
        return popupmenuViewController.parent == self
    }
    var latitude: Double = 0
    var longitude: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

//マップビューを画面に設定
        gmsCamera = GMSCameraPosition.camera(withLatitude: 35, longitude: 135, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: gmsCamera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        self.navigationItem.title = uncorrespondFirestore?.routes[selectedIndex].routeName ?? "地点の追加・削除"
        
        popupmenuViewController.delegate = self
        addStoredMarker()
    }
    
//MARK: - 削除処理
    @IBAction func deleteButtonPressed(_ sender: Any) {
        print("削除ボタンがタップされました")
        let deleteAlert = UIAlertController(title: "マーカーを削除", message: "選択されたマーカーを削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "削除", style: .destructive) { (Action) in
            self.deleteMarker()
        }
        let cancelActin = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelActin)
        deleteAlert.addAction(okAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteMarker() {
        guard let correspondFirestore = uncorrespondFirestore else {
            preconditionFailure("通信クラスを取得できませんでした")
        }
        
        let selectedSpot = spotData()
        selectedSpot.latitude = latitude
        selectedSpot.longitude = longitude
        
        
        if let deleteIndex = correspondFirestore.routes[selectedIndex].spotList.firstIndex(of: selectedSpot) {
            SVProgressHUD.show()
            
            correspondFirestore.routes[selectedIndex].spotList.remove(at: deleteIndex)
            correspondFirestore.mergeSpotdata(selectedIndex) { (isStored) in
                SVProgressHUD.dismiss()
                self.hidePopupmenu(animated: true)
                self.mapView.selectedMarker?.map = nil
                print("保存されていたマーカーを削除しました")
            }
        } else {
            mapView.selectedMarker?.map = nil
            print("マーカーを削除しました")
        }
    }
    
//MARK: - ポップアップメニューについて
    func showPopupmenu(animated: Bool) {
        if isShownPopupMenu {
            return
        }
        
        addChild(popupmenuViewController)
        popupmenuViewController.view.autoresizingMask = .flexibleWidth
        popupmenuViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: popupmenuViewController.contentMaxHeight + popupmenuViewController.contentPositionY)
        view.addSubview(popupmenuViewController.view)
        popupmenuViewController.didMove(toParent: self)
        popupmenuViewController.showContentView(animated: animated)
    }
    
    func hidePopupmenu(animated: Bool) {
        if !isShownPopupMenu {
            return
        }
        
        popupmenuViewController.hideContentView(animated: animated) { (_) in
            self.popupmenuViewController.willMove(toParent: nil)
            self.popupmenuViewController.removeFromParent()
            self.popupmenuViewController.view.removeFromSuperview()
        }
    }
    
//全スポットにマーカーを設置
    func addStoredMarker() {
        guard let spotData = uncorrespondFirestore?.routes[selectedIndex].spotList else {
            preconditionFailure("バス停リストを取得できませんでした")
        }
        for spot in spotData {
            let coordinationData = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
            let stationMarker = GMSMarker(position: coordinationData)
            stationMarker.title = spot.spotName
            stationMarker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1))
            stationMarker.map = mapView
        }
    }
}


// MARK: - LocationManagerDelegate
extension AdminMapViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            print("位置情報の取得を開始します")
            locationManager.distanceFilter = 30
            locationManager.startUpdatingLocation()
        } else {
            print("位置情報取得の許可がありません")
            
            //--------------------------------
            //ここに位置情報取得を促すアラートを出す処理を書く
            let locationAlert = UIAlertController(title: "位置情報が取得できません", message: "設定→プライバシー→位置情報の許可でこのアプリを許可してください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            locationAlert.addAction(okAction)
            self.present(locationAlert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("位置情報を取得しました")
        guard let location = locations.last else {
            preconditionFailure("配列から位置情報を取得できませんでした")
        }
        if location.horizontalAccuracy > 0 {
            let gmsCamera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: zoomLevel)
            mapView.animate(to: gmsCamera)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得エラー：\(error)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationManager()
    }
}

//MARK: - GMSMapViewDelegate
extension AdminMapViewController: GMSMapViewDelegate {
    
//マップが長押しされたときにマーカーを設置してポップアップメニューを表示
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {

        let marker = GMSMarker(position: coordinate)
        marker.title = "名前"
        marker.appearAnimation = .pop
        marker.map = mapView
        mapView.selectedMarker = marker
        
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        gmsCamera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoomLevel)
        
        showPopupmenu(animated: true)
        popupmenuViewController.textfield.text = ""
        //長押しされた時にカメラを中心にする
    }
    
//マーカーがタップされた時にポップアップメニューを表示
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        latitude = marker.position.latitude
        longitude = marker.position.longitude
        
        gmsCamera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)

        showPopupmenu(animated: true)
        popupmenuViewController.textfield.text = marker.title ?? "タイトルなし"
        
        return false
    }
    
//マーカー以外の場所がタップされた時にマーカーの選択を解除する
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hidePopupmenu(animated: true)
    }
}

//MARK: - PopupMenuViewDelegate
extension AdminMapViewController: PopupMenuViewControllerDelegate {
    func parentViewControllerForPopuoMenuViewController(_ popupmenuViewController: PopupMenuViewController) -> UIViewController {
        return self
    }
    
    func shouldPresentForPopupmenuViewController(_ popupmenuViewController: PopupMenuViewController) -> Bool {
        return true
    }
    
    func popupmenuViewControllerDidRequestShowing(_ popupmenuViewController: PopupMenuViewController, animated: Bool) {
        showPopupmenu(animated: true)
    }
    
    func popupmenuViewControllerDidRequestHiding(_ popupmenuViewController: PopupMenuViewController, animated: Bool) {
        hidePopupmenu(animated: animated)
    }
    
//ポップアップメニューの保存ボタンが押された時にスポットデータを保存する
    func storeBusstationName(_ popupmenuViewController: PopupMenuViewController, stationName: String) {
        print("保存ボタンがタップされました\(stationName)")
        
        if stationName != "" {
            let spot = spotData()
            spot.spotName = stationName
            spot.latitude = latitude
            spot.longitude = longitude
            
            guard let correspondFirestore = uncorrespondFirestore else {
                preconditionFailure("通信クラスを取得できませんでした")
            }
            correspondFirestore.routes[selectedIndex].spotList.append(spot)
            SVProgressHUD.show()
            correspondFirestore.mergeSpotdata(selectedIndex) { (isStored) in
                SVProgressHUD.dismiss()
                
                if let marker = self.mapView.selectedMarker {
                    marker.title = stationName
                    marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1))
                } else {
                    print("選択されたマーカーを取得できませんでした")
                }
                self.hidePopupmenu(animated: true)
            }
            
        } else {
            let alert = UIAlertController(title: "バス停名を入力してください", message: "入力欄が空白です", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }
    }
}



