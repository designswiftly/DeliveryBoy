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

class DeliveryTableRowController : NSObject {
    @IBOutlet weak var addressSample: WKInterfaceLabel!
}

class DeliveryListInterfaceController: WKInterfaceController {

    @IBOutlet weak var deliveryTable: WKInterfaceTable!
    let manager = DeliverManager()
    var deliveries : [Delivery]?

    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
        
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
        NSLog("%@ will activate", self)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }

    func populateTable() {
        deliveryTable.setNumberOfRows(self.deliveries!.count, withRowType: "DeliveryTableRowController")
        for (index, element) in enumerate(self.deliveries!){
            let delivery = element as Delivery
            var attributedText : NSMutableAttributedString = NSMutableAttributedString(string:delivery.address)
            if (delivery.delivered) {
                attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributedText.length))
            }
            let row = deliveryTable.rowControllerAtIndex(index) as DeliveryTableRowController
            row.addressSample.setAttributedText(attributedText)
        }
    }
}

