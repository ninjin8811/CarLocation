import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController{
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self

        setupLocationManager()

        //マップビューを画面に設定
        let gmsCamera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: gmsCamera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view = mapView

        //シドニーにマーカーを設置
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView

        renderMenuButton()
    }
    
    func renderMenuButton() {
        let menuButton = UIButton(type: .detailDisclosure)
        self.view.addSubview(menuButton)
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50).isActive = true
        menuButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80).isActive = true
    }
}

// MARK: - LocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func setupLocationManager() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            print("位置情報の取得を開始します")
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
        } else {
            print("位置情報取得の許可がありません")
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
        print("エラーError：\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        setupLocationManager()
    }
}

// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("長押しされました")
        print(coordinate)
        let marker = GMSMarker(position: coordinate)
        marker.title = "Hello World"
        marker.appearAnimation = .pop
        marker.snippet = "あああああああ"
        marker.map = mapView
    }
}
