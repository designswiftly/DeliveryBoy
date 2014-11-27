//
//  DeliveryMapView.swift
//  Delivery
//
//  Created by Pierluigi Cifani on 27/11/14.
//
//

import MapKit
import DeliveryKit

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class DeliveryMapView: MKMapView {
    
    func prepareForDelivery(delivery : Delivery) {
        self.setCenterCoordinate(delivery.latitudeLongitude, animated: true)
        self.addAnnotation(MapPin(coordinate: delivery.latitudeLongitude, title: delivery.address, subtitle: ""))
    }
}
