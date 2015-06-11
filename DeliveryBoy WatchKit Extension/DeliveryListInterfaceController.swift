//
//  InterfaceController.swift
//  DeliveryBoy WatchKit Extension
//
//  Created by Pierluigi Cifani on 27/11/14.
//
//

import WatchKit
import Foundation
import DeliveryKit

class DeliverySegueHolder {
    let manager : DeliverManager
    let delivery : Delivery
    
    init (manager : DeliverManager, delivery : Delivery) {
        self.manager = manager
        self.delivery = delivery
    }
}

class DeliveryTableRowController : NSObject {
    @IBOutlet weak var addressSample: WKInterfaceLabel!
}

class DeliveryListInterfaceController: WKInterfaceController {

    @IBOutlet weak var deliveryTable: WKInterfaceTable!
    let manager = DeliverManager()
    var deliveries : [Delivery]?

    //MARK: WKInterfaceController
    override func awakeWithContext(context: AnyObject?) {
        // Initialize variables here.
        super.awakeWithContext(context)
        
        manager.fetchDeliveries { (result) -> () in
            switch result {
            case .deliveries(let deliveries) :
                self.deliveries = deliveries
            case .error(let error) :
                println(error)
            }
            
            self.populateTable()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.populateTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        let delivery = self.deliveries![rowIndex]
        return DeliverySegueHolder(manager: manager, delivery: delivery)
    }
    
    //MARK: Private
    func populateTable() {
        if let _deliveries = self.deliveries {
            deliveryTable.setNumberOfRows(_deliveries.count, withRowType: "DeliveryTableRowController")
            for (index, element) in enumerate(_deliveries){
                let delivery = element as Delivery
                var attributedText : NSMutableAttributedString = NSMutableAttributedString(string:delivery.address)
                if (delivery.isDelivered()) {
                    attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributedText.length))
                }
                let row = deliveryTable.rowControllerAtIndex(index) as! DeliveryTableRowController
                row.addressSample.setAttributedText(attributedText)
            }
        }
    }
}

class DeliveryDetailInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var addressMapView: WKInterfaceMap!
    @IBOutlet weak var addressLabel: WKInterfaceLabel!
    @IBOutlet weak var deliveryTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var doneButton: WKInterfaceButton!
    var manager : DeliverManager!
    var delivery: Delivery!
    
    override func awakeWithContext(context: AnyObject?) {
        // Initialize variables here.
        super.awakeWithContext(context)
        if let _segueHolder = context as? DeliverySegueHolder {
            delivery = _segueHolder.delivery
            manager = _segueHolder.manager
        }
    }

    @IBAction func onDone() {
        manager.markDeliveryAsDone(delivery) {
            (success, error) -> Void in
            self.prepareForDelivery()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.prepareForDelivery()
    }
    
    func prepareForDelivery() {
        let deliveryAddressText : NSMutableAttributedString = NSMutableAttributedString(string:delivery.address)

        if delivery.isDelivered() {
            self.doneButton.setHidden(true)
            self.deliveryTimeLabel.setHidden(false)
            self.deliveryTimeLabel.setText("Delivered at \(delivery.deliveryDate!)")
            deliveryAddressText.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, deliveryAddressText.length))

        } else {
            self.doneButton.setHidden(false)
            self.deliveryTimeLabel.setHidden(true)
        }
        
        self.addressLabel.setAttributedText(deliveryAddressText)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let center = CLLocationCoordinate2D(latitude:delivery!.latitudeLongitude.latitude, longitude:delivery!.latitudeLongitude.longitude)
        let region = MKCoordinateRegionMake(center, span)
        self.addressMapView.setRegion(region)
        self.addressMapView.addAnnotation(delivery!.latitudeLongitude, withPinColor: .Red)
    }
}