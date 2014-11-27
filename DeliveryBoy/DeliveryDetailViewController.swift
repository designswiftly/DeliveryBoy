//
//  DeliveryDetailViewController.swift
//  Delivery
//
//  Created by Pierluigi Cifani on 27/11/14.
//
//

import DeliveryKit

class DeliveryDetailViewController: UIViewController {
    var delivery : Delivery?
    @IBOutlet weak var addressMapView: DeliveryMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressMapView.prepareForDelivery(self.delivery!)
    }
}
