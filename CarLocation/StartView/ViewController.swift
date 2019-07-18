import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import FontAwesome_swift

class ViewController: UIViewController{
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let sidemenuViewController = SideMenuViewController()
    var isShownSideMenu: Bool {
        return sidemenuViewController.parent == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self

        setupLocationManager()

        //マップビューを画面に設定
        let gmsCamera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: gmsCamera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)

        renderMenuButton()
        
        sidemenuViewController.delegate = self
        sidemenuViewController.startPanGestureRecognizing()
    }
    
    //メニューボタンの作成
    func renderMenuButton() {
        let menuButton = UIButton(type: .custom)
        self.view.addSubview(menuButton)
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        menuButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        menuButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.setTitleColor(.gray, for: .highlighted)
        menuButton.setTitle(String.fontAwesomeIcon(name: .bars), for: .normal)
        
        menuButton.addTarget(self, action: #selector(menuButtonPressed(_:)), for: .touchUpInside)
    }

    private func showSidemenu(contentAvailability: Bool = true, animated: Bool) {
        
        if isShownSideMenu {
            return
        }
        
        addChild(sidemenuViewController)
        sidemenuViewController.view.autoresizingMask = .flexibleHeight
        sidemenuViewController.view.frame = view.bounds
        view.insertSubview(sidemenuViewController.view, aboveSubview: self.view)
        sidemenuViewController.didMove(toParent: self)
        if contentAvailability {
            sidemenuViewController.showContentView(animated: animated)
        }
        
        
    }
    
    private func hideSidemenu(animated: Bool) {
        if !isShownSideMenu {
            return
        }
        
        sidemenuViewController.hideContentView(animated: animated) { (_) in
            self.sidemenuViewController.willMove(toParent: nil)
            self.sidemenuViewController.removeFromParent()
            self.sidemenuViewController.view.removeFromSuperview()
        }
    }
    
    @objc func menuButtonPressed(_ sender: UIButton) {
        print("ボタンがタップされました")
        showSidemenu(animated: true)
    }
}

// MARK: - LocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func setupLocationManager() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            print("位置情報の取得を開始します")
            locationManager.distanceFilter = 10
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
    
    //マップが長押しされたときにマーカーを設置
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

extension ViewController: SidemenuViewControllerDelegate {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> UIViewController {
        return self
    }
    
    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> Bool {
        return true
    }
    
    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool) {
        showSidemenu(contentAvailability: contentAvailability, animated: animated)
    }
    
    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SideMenuViewController, animated: Bool) {
        hideSidemenu(animated: animated)
    }
    
    func sidemenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath) {
        hideSidemenu(animated: true)
        
        switch indexPath.row {
        case 3:
            performSegue(withIdentifier: "goToLoginView", sender: self)
            print(indexPath.row)
            break
            
        default:
            print(indexPath.row)
            break
        }
    }
}
