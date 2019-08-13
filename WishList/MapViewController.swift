
import UIKit
import MapKit
import CoreLocation


protocol MapViewControllerDelegate {
   func getAdress(_ adress: String?)
    
}


class MapViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var adressLable: UILabel!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var wish = Wish()
    let anatationIdentifire = "anatationIdentifire"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    var incomSegueID = ""
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    
    override func viewDidLoad() {
        adressLable.text = ""
        super.viewDidLoad()
        setupMapView()
        mapView.delegate = self
        checkLocationAutarization()
        checkLocationServices()

        
    }
    
    @IBAction func closeViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupMapView() {
        if incomSegueID == "showMap" {
            setupWishMark()
            mapPinImage.isHidden = true
            adressLable.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    private func setupWishMark() {
        guard let location = wish.location else {return}
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
               return
            }
          guard let placemarks = placemarks else {return}
          let placeMark = placemarks.first
          let annotation = MKPointAnnotation()
          annotation.title = self.wish.name
          annotation.subtitle = self.wish.cost
          
          guard let placemarkLocation  = placeMark?.location else {return}
          annotation.coordinate = placemarkLocation.coordinate
          self.mapView.showAnnotations([annotation], animated: true)
          self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutarization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAC(titel: "Location services are disable!", messege: "To enable it go setting")
            }
        }
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        mapViewControllerDelegate?.getAdress(adressLable.text)
        dismiss(animated: true, completion: nil)
    }
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    private func checkLocationAutarization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomSegueID == "getAdress" {
                showUserLocation()
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAC(titel: "You location is not avalible", messege: "Go to setting to fix it")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case is avalible")
        }
    }
    @IBAction func centerUserLocation() {
       showUserLocation()
    }
    
    private func showUserLocation() {
        if let location  = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longatude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longatude)
    }
    
    private func showAC (titel: String, messege: String) {
        let allert = UIAlertController(title: titel, message: messege, preferredStyle: .alert)
        let ac = UIAlertAction(title: "Ok", style: .default, handler: nil)
        allert.addAction(ac)
        present(allert, animated: true, completion: nil)
    }
}
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: anatationIdentifire) as? MKPinAnnotationView
        
        if anotationView == nil {
            anotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: anatationIdentifire)
            anotationView?.canShowCallout = true
            
        }
         if let wishImageData = wish.wishImageData {
        //создаем изображение длф пина
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        //сгладим углы
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        //плмещаеям изображение в пин
        imageView.image = UIImage(data: wishImageData)
        //устанавливаяем его с правой стороны
            anotationView?.rightCalloutAccessoryView = imageView
        
        }
        return anotationView
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { (placeMarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placeMarks = placeMarks else {return}
            
            let placeMArk = placeMarks.first
            let streetName = placeMArk?.thoroughfare
            let buildNumber = placeMArk?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.adressLable.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                        self.adressLable.text = "\(streetName!)"
                } else {
                        self.adressLable.text = ""
                }
                
            }
           
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutarization()
    }
}
