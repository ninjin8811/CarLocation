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

class AdminMapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()

        //マップビューを画面に設定
        let gmsCamera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: gmsCamera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
}


// MARK: - LocationManagerDelegate
extension AdminMapViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            print("位置情報の取得を開始します")
            locationManager.distanceFilter = 30
            locationManager.startUpdatingLocation()
        } else {
            print("位置情報取得の許可がありません")
            
            //--------------------------------
            //ここに位置情報取得を促すアラートを出す処理を書く
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
            
            //---------------------------------
            //ここに位置情報をアップロードする処理を書く
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("エラーError：\(error)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationManager()
    }
}

extension AdminMapViewController: GMSMapViewDelegate {
    
    //マップが長押しされたときにマーカーを設置
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        print(coordinate)
//        let marker = GMSMarker(position: coordinate)
//        marker.title = "Hello World"
//        marker.appearAnimation = .pop
//        marker.snippet = "あああああああ"
//        marker.map = mapView
        
        //---------------------------------
        //ここに長押しされたときにバス停追加のメニューを表示する処理を書く
    }
}
