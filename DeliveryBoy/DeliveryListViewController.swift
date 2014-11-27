//
//  DeliveryListViewController.swift
//  Delivery
//
//  Created by Pierluigi Cifani on 26/11/14.
//
//

import DeliveryKit

let DeliveryListDataSourceCell = "DeliveryListDataSourceCell"

class DeliveryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CreateDeliveryProtocol {

    @IBOutlet weak var tableView: UITableView!
    var deliveries : [Delivery]?
    var manager : DeliverManager!
    
    lazy var activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.addSubview(activityIndicator)
        let xCenterConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self.tableView, attribute: .CenterX, multiplier: 1, constant: 0)
        self.tableView.addConstraint(xCenterConstraint)
        let yCenterConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self.tableView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.tableView.addConstraint(yCenterConstraint)
        return activityIndicator
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: DeliveryListDataSourceCell)
        self.tableView.tableFooterView = UIView()

        self.activityIndicator.startAnimating()
        self.manager = DeliverManager()

        self.fetch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CreateDelivery"){
            let destinationNavViewController = segue.destinationViewController as UINavigationController
            let deliveryCreatorController = destinationNavViewController.topViewController as CreateDeliveryViewController
            deliveryCreatorController.delegate = self
        } else if (segue.identifier == "DeliveryDetail"){
            let deliveryDetail = segue.destinationViewController as DeliveryDetailViewController
            deliveryDetail.delivery = sender as? Delivery
            deliveryDetail.manager = manager
        }
    }
    
    //MARK: Private
    func fetch () {
        self.manager.fetchDeliveries { (result) -> () in
            self.activityIndicator.stopAnimating()
            switch result {
            case .deliveries(let deliveries) :
                self.deliveries = deliveries
            case .error(let error) :
                println(error)
            }
            self.tableView.reloadData()
        }
    }
    
    //MARK: UITableViewDataSource
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.deliveries != nil) {
            return self.deliveries!.count
        }
        else {
            return 0
        }
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let delivery : Delivery = self.deliveries![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(DeliveryListDataSourceCell) as UITableViewCell
        var attributedText : NSMutableAttributedString = NSMutableAttributedString(string:delivery.address)
        if (delivery.isDelivered()) {
            attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributedText.length))
        }
        cell.textLabel?.attributedText = attributedText
        return cell
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
        let delivery : Delivery = self.deliveries![indexPath.row]
        self.performSegueWithIdentifier("DeliveryDetail", sender: delivery)
    }
    
    //MARK: CreateDeliveryProtocol
    func didCreateDelivery(delivery : Delivery) {
        self.manager.createDelivery(delivery, handler: { (result) -> () in
            switch result {
            case .deliveryID(let deliveryID) :
                self.fetch()
            case .error(let error) :
                println(error)
            }
        })
    }
}
