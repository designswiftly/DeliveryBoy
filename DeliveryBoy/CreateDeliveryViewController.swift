//
//  CreateDeliveryViewController.swift
//  Delivery
//
//  Created by Pierluigi Cifani on 26/11/14.
//
//

import CoreLocation
import DeliveryKit

public protocol CreateDeliveryProtocol : class {
    func didCreateDelivery(delivery : Delivery)
}

class CreateDeliveryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressMapView: DeliveryMapView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var dismissButton: UIBarButtonItem!

    weak var delegate : CreateDeliveryProtocol?
    var chosenDelivery : Delivery? {
        didSet {
            createButton.enabled = (chosenDelivery != nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chosenDelivery = nil
    }

    //MARK: IBActions
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCreate(sender: AnyObject) {
        self.delegate?.didCreateDelivery(self.chosenDelivery!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
    
        let address = textField.text

        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                let coordinate : CLLocationCoordinate2D = placemark.location.coordinate
                self.chosenDelivery = Delivery(address: address, latitudeLongitude: coordinate)
                self.addressMapView.prepareForDelivery(self.chosenDelivery!)
                return
            }
        })

        textField.resignFirstResponder()

        return false
    }
}
