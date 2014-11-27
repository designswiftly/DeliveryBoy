//
//  DeliveryDetailViewController.swift
//  Delivery
//
//  Created by Pierluigi Cifani on 27/11/14.
//
//

import DeliveryKit

class DeliveryDetailViewController: UIViewController {
    var delivery : Delivery!
    var manager : DeliverManager!

    @IBOutlet weak var addressMapView: DeliveryMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressMapView.prepareForDelivery(self.delivery!)
    }
    
    @IBAction func onDone(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Mark this delivery as Done?", message:nil , preferredStyle: .ActionSheet)
        let markDoneAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            alertController .dismissViewControllerAnimated(true, completion: nil)
            self.markDeliveryAsDone()
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default) { (action) -> Void in
            alertController .dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(markDoneAction)
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Private
    func markDeliveryAsDone(){
        manager.markDeliveryAsDone(delivery, handler: { (success, error) -> Void in
            
        })
    }
}
