//
//  GetAdress.swift
//  MapsTask
//
//  Created by Сергей Сырбу on 14.07.2023.
//

import UIKit
import CoreLocation
import MapKit

extension UIViewController {
    func alert(complihion: @escaping(String)->Void){
        let alert = UIAlertController(title: "Введите адрес", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { ok in
            let tfText = alert.textFields?.first
            guard let text = tfText?.text else {return}
        complihion(text)
        
        }
        alert.addTextField { tf in
            tf.placeholder = "Адрес"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    func alertError(name:String, message: String){
        let alert = UIAlertController(title: name, message: message, preferredStyle: .alert)
        let canxelAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(canxelAction)
        present(alert, animated: true)
    }
}
