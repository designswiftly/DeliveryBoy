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
let DeliveredAtKey          = "delivered_at"

public class Delivery {
    
    public let address : String
    public let latitudeLongitude : CLLocationCoordinate2D
    public var deliveryDate : NSDate?
    public var deliveryID : String?
    public func isDelivered () -> Bool{
        return (self.deliveryDate != nil)
    }

    public init (address : String, latitudeLongitude : CLLocationCoordinate2D) {
        self.address = address
        self.latitudeLongitude = latitudeLongitude
    }
}

public enum FetchDeliveryResult{
    case deliveries([Delivery])
    case error(NSError)
}

public enum CreateDeliveryResult{
    case deliveryID(String)
    case error(NSError)
}

public typealias FetchProductsHandler = (FetchDeliveryResult) -> ()
public typealias CreateDeliveryHandler = (CreateDeliveryResult) -> ()
public typealias UpdateDeliveryResultBlock = (Bool, NSError!) -> Void

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
                        let pfObject = fetchedObject as! PFObject
                        let address = pfObject.objectForKey(AddressKey) as! String
                        let lat = pfObject.objectForKey(LatKey) as! Double
                        let long = pfObject.objectForKey(LongKey) as! Double
                        let deliveryDate = pfObject.objectForKey(DeliveredAtKey) as? NSDate

                        let deliveryObject = Delivery(address: address, latitudeLongitude: CLLocationCoordinate2DMake(lat, long))
                        deliveryObject.deliveryID = pfObject.objectId
                        deliveryObject.deliveryDate = deliveryDate
                        
                        return deliveryObject
                    })
                    _handler(FetchDeliveryResult.deliveries(deliveries))
                }
            }
        }
    }
    
    public func markDeliveryAsDone(delivery:Delivery, handler : UpdateDeliveryResultBlock?){
        let deliveryDate = NSDate()
        let updatedDelivery = PFObject(withoutDataWithClassName: DeliveryClassName, objectId: delivery.deliveryID!)
        updatedDelivery[DeliveredAtKey] = deliveryDate
        updatedDelivery.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                delivery.deliveryDate = deliveryDate
            }
            
            if let _handler = handler {
                _handler(success, error)
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
                    delivery.deliveryID = newDelivery.objectId
                    _handler(CreateDeliveryResult.deliveryID(newDelivery.objectId))
                }
            }
        }
    }
}
