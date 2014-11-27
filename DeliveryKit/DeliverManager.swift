//
//  DeliverKit.swift
//  Delivery
//
//  Created by Pierluigi Cifani on 26/11/14.
//
//

import Foundation
import Parse

let applicationID   = "bz4kuECGPnOeZ8MiLjQFv7xl5wQ28tdbU4Xg94Lg"
let clientKey       = "zJuf0GcECYs56GebvEMQNhDayBeIb9a6fJs1j7Z4"

let DeliveryClassName       = "Delivery"
let AddressKey              = "address"
let LatKey                  = "lat"
let LongKey                 = "long"

public class Delivery {
    
    public let address : String
    public let latitudeLongitude : CLLocationCoordinate2D
    
    public init (address : String, latitudeLongitude : CLLocationCoordinate2D) {
        self.address = address
        self.latitudeLongitude = latitudeLongitude
    }
}

public enum FetchDeliveryResult{
    case deliveries([Delivery])
    case error(NSError)
}

public typealias FetchProductsHandler = (FetchDeliveryResult) -> ()

public enum CreateDeliveryResult{
    case deliveryID(String)
    case error(NSError)
}

public typealias CreateDeliveryHandler = (CreateDeliveryResult) -> ()

public class DeliverManager {
    public init () {
        Parse.setApplicationId(applicationID, clientKey: clientKey)
    }
    
    public func fetchDeliveries(handler : FetchProductsHandler?) {
        let query = PFQuery(className: DeliveryClassName)
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let _handler = handler {
                if let _error = error {
                    _handler(FetchDeliveryResult.error(error))
                } else {
                    let deliveries = result.map({ (let fetchedObject) -> Delivery in
                        let pfObject = fetchedObject as PFObject
                        let address = pfObject.objectForKey(AddressKey) as String
                        let lat = pfObject.objectForKey(LatKey) as Double
                        let long = pfObject.objectForKey(LongKey) as Double
                        return Delivery(address: address, latitudeLongitude: CLLocationCoordinate2DMake(lat, long))
                    })
                    _handler(FetchDeliveryResult.deliveries(deliveries))
                }
            }
        }
    }
    
    public func createDelivery(delivery:Delivery, handler : CreateDeliveryHandler?) {
        
        let newDelivery = PFObject(className: DeliveryClassName)
        newDelivery.setObject(delivery.address, forKey: AddressKey)
        newDelivery.setObject(delivery.latitudeLongitude.latitude, forKey: LatKey)
        newDelivery.setObject(delivery.latitudeLongitude.longitude, forKey: LongKey)
        newDelivery.saveInBackgroundWithBlock { (success, error) -> Void in
            if let _handler = handler {
                if let _error = error {
                    _handler(CreateDeliveryResult.error(_error))
                } else {
                    _handler(CreateDeliveryResult.deliveryID(newDelivery.objectId))
                }
            }
        }
    }
}
