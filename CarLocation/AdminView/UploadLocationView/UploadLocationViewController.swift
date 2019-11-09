//
//  UploadLocationViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/08/03.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase

class UploadLocationViewController: UIViewController {
    
    var uncorrespondFirestore: CorrespondData?
    var selectedIndex = 0
    var locationManager = CLLocationManager()
    var mapView: GMSMapView!
    var gmsCamera: GMSCameraPosition!
    var zoomLevel: Float = 15.0
    
    var opUserID: String?
    var latitude: Double = 0
    var longitude: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = uncorrespondFirestore?.routes[selectedIndex].routeName ?? "現在地をアップロード"

//マップビューを画面に設定
        gmsCamera = GMSCameraPosition.camera(withLatitude: 35, longitude: 135, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: gmsCamera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        opUserID = Auth.auth().currentUser?.uid
        locationManager.delegate = self
        setupLocationManager()
        addStoredMarker()
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

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent == true {
            print("位置情報の更新を停止します")
            locationManager.stopUpdatingLocation()
        }
    }
}

//MARK: - LocationManagerDelegate
extension UploadLocationViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
            print("位置情報の取得を開始します:アップロード画面")
        } else {
            print("位置情報取得の許可がありません")
            
            let locationAlert = UIAlertController(title: "位置情報が取得できません", message: "設定→プライバシー→位置情報の許可でこのアプリを許可してください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            locationAlert.addAction(okAction)
            self.present(locationAlert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("位置情報を取得しました：アップロード画面")
        guard let location = locations.last else {
            preconditionFailure("配列から位置情報を取得できませんでした")
        }
        if location.horizontalAccuracy > 0 {
            let gmsCamera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: zoomLevel)
            mapView.animate(to: gmsCamera)
            
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            print(location.coordinate)
            updateLocation()
        } else {
            print("位置情報のデータが微妙です")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得エラー：\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationManager()
    }
    
    //位置情報が更新されたらFirebaseにアップロード
    func updateLocation() {
        guard let userID = opUserID else {
            preconditionFailure("ユーザーIDが取得できていませんでした")
        }
        let location = locationData()
        location.latitude = latitude
        location.longitude = longitude
        
        guard let correspondFirestore = uncorrespondFirestore else {
            preconditionFailure("通信クラスを取得できませんでした")
        }
        correspondFirestore.uploadLocation(selectedIndex, location, userID)
    }
    
    
}

//MARK: - GMAMapViewDelegate
extension UploadLocationViewController: GMSMapViewDelegate {
    
}
