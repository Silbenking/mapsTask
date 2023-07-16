//
//  ViewController.swift
//  MapsTask
//
//  Created by Сергей Сырбу on 12.07.2023.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation

class ViewController: UIViewController {

    var annotationArray = [MKPointAnnotation]() // чтобы добавить туда несколко точек
    let mapView = MKMapView()
    let annotationMK = MKPointAnnotation()
    
    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setTitle("GET ADRESS", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstant.fontSize)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor(red: 0/256, green: 0/256, blue: 0/256, alpha: 0.4)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = UIConstant.sizeButton/2
        return button
    }()
    let routeAdressButton: UIButton = {
        let button = UIButton()
        button.setTitle("ROUTE", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstant.fontSize)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.isHidden = true
        button.backgroundColor = UIColor(red: 0/256, green: 0/256, blue: 0/256, alpha: 0.4)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = UIConstant.sizeButton/2
        return button
    }()
    let deleteRouteButton: UIButton = {
        let button = UIButton()
        button.setTitle("DELETE", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstant.fontSize)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.isHidden = true
        button.backgroundColor = UIColor(red: 0/256, green: 0/256, blue: 0/256, alpha: 0.4)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = UIConstant.sizeButton/2
        return button
    }()
    
    enum UIConstant {
        static let sizeButton: CGFloat = 80
        static let buttinOffset: CGFloat = 35
        static let buttonBottomOffset: CGFloat = 65
        static let fontSize: CGFloat = 15

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func initialize(){
        addAdressButton.addTarget(self, action: #selector(addAdressTap), for: .touchUpInside)
        routeAdressButton.addTarget(self, action: #selector(routeAdressTap), for: .touchUpInside)
        deleteRouteButton.addTarget(self, action: #selector(deleteAdressTap), for: .touchUpInside)

        mapView.delegate = self
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        view.addSubview(addAdressButton)
        addAdressButton.snp.makeConstraints { make in
            make.size.equalTo(UIConstant.sizeButton)
            make.trailing.equalToSuperview().inset(UIConstant.buttinOffset)
            make.top.equalToSuperview().inset(UIConstant.buttonBottomOffset)
        }
        view.addSubview(routeAdressButton)
        routeAdressButton.snp.makeConstraints { make in
            make.size.equalTo(UIConstant.sizeButton)
            make.trailing.equalToSuperview().inset(UIConstant.buttinOffset)
            make.bottom.equalToSuperview().inset(UIConstant.buttonBottomOffset)
        }
        view.addSubview(deleteRouteButton)
        deleteRouteButton.snp.makeConstraints { make in
            make.size.equalTo(UIConstant.sizeButton)
            make.leading.equalToSuperview().inset(UIConstant.buttinOffset)
            make.bottom.equalToSuperview().inset(UIConstant.buttonBottomOffset)
        }
    
    }
        
    
    func getCoordinaterom(adress: String) {
        
        CLGeocoder().geocodeAddressString(adress) { [self] (placemark, error) in // пишем self здесь, чтобы не указыват его в функции
            
            if let error = error {
                alertError(name: "Ошибка", message: "Сервер не доступен, проверьте адрес")
                return
            }
            let annotation = MKPointAnnotation()
//                complition(placemark?.first?.location?.coordinate, error)
            guard let place = placemark?.first?.location else {return}
               annotation.coordinate = place.coordinate
            annotationArray.append(annotation)
            if annotationArray.count > 2 {
                routeAdressButton.isHidden = false
                deleteRouteButton.isHidden = false
            }
            self.mapView.showAnnotations([annotation], animated: true)

        }
    }
    private func createDirextionRequest(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D){ // создаем запрос для построения маршрута/ отвечает за построение маршрута между двух точек
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let endLocation = MKPlacemark(coordinate: endCoordinate)
//создаем запрос
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation) //источник откуда пойдем
        request.destination = MKMapItem(placemark: endLocation) // источник куда при=одим
        request.transportType = .walking //для какого трансопрта
        request.requestsAlternateRoutes = true // показывать ли альтернативыне маршруты
        let diraction = MKDirections(request: request) // напрвление
        diraction.calculate { response, error in // обрабатываем направление, где получаем ответ и отшибку
            if let error = error {
                print(error)
                return // выйти из метода
            }
            guard let response = response else {
                self.alertError(name:"Ошибка", message: "Маршрут не доступен")
                return// если ято то пошло не так
            }
            var minRoute = response.routes[0] // минимальный маршрут, если получаем один то его и берем
            for route in response.routes { // если маршрутов несколько
                minRoute = (route.distance < minRoute.distance) ? route:minRoute //если этот маршрут меньше minRoute.distance, тогда этот будет он, если нет , тогда будет minRoute.distance
            }
            self.mapView.addOverlay(minRoute.polyline) // линия маршрута
        }
    }
    
    @objc func addAdressTap(){
        alert { adress in
//            self.getCoordinaterom(adress: adress) { [self] coordinate, error in
//                guard let coordinate = coordinate, error == nil else {return}
//                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.getCoordinaterom(adress:adress)
            }
        }
    @objc func routeAdressTap(){
        for index in 0...annotationArray.count - 2 {
            createDirextionRequest(startCoordinate: annotationArray[index].coordinate, endCoordinate: annotationArray[index + 1].coordinate )
        }
        mapView.showAnnotations(annotationArray, animated: true) // отображаем маргрут для каждых двух значений
    }
    @objc func deleteAdressTap(){
        mapView.removeOverlays(mapView.overlays) // удалем все маршруты
        mapView.removeAnnotations(mapView.annotations) // удаляем все поинты
        annotationArray = [MKPointAnnotation]()
        routeAdressButton.isHidden = true
        deleteRouteButton.isHidden = true
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline) // получаем линию
        renderer.strokeColor = .blue
        return renderer
    }
}
