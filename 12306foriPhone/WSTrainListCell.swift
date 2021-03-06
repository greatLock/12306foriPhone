//
//  WSTrainListCell.swift
//  12306foriPhone
//
//  Created by WS on 2017/6/12.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

class WSTrainListCell: UITableViewCell {
    
    public var ticketInfo: WSQueryLeftNewDTO! {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var trainNameLabel: UILabel!
    @IBOutlet weak var addressStationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ticketsLeftLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    
    //detail
    @IBOutlet weak var fromStationName: UILabel!
    @IBOutlet weak var toStationName: UILabel!
    @IBOutlet weak var selectSeatButton: UIButton!
    @IBOutlet weak var selectPersonButton: UIButton!
    @IBOutlet weak var detailTrainName: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var addGrapTicketButton: UIButton!
    
    @IBOutlet weak var detailViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var detailViewLeading: NSLayoutConstraint!
    
    var seatAlert: WSTrainSeatAlert?
    var personAlert: WSTrainPersonAlert?
    
//MARK:- life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configSubviews()
    }

//MARK:- layout
    private func configSubviews() {
        buyButton.layer.cornerRadius = 15
        buyButton.layer.masksToBounds = true
        
        addGrapTicketButton.layer.cornerRadius = 5
        addGrapTicketButton.layer.masksToBounds = true
    }
    
    private func updateUI() {
        
        let hasSeat = isHaveSeat(ticketInfo)
        trainNameLabel.text = ticketInfo.TrainCode!
        timeLabel.text = "\(ticketInfo.start_time!) - \(ticketInfo.arrive_time!)"
        ticketsLeftLabel.text = hasSeat ? "有票": "无票"
        buyButton.setTitleColor(hasSeat ? UIColor(hexString: "333333") : UIColor(hexString: "AAAABC"), for: .normal)
        buyButton.setTitle(hasSeat ? "购买" : "预定", for: .normal)
        addressStationLabel.text = "\(ticketInfo.FromStationName!) - \(ticketInfo.ToStationName!)"
        detailTrainName.text = ticketInfo.TrainCode!
        addGrapTicketButton.setTitle(hasSeat ? "购买" : "预定", for: .normal)
        addGrapTicketButton.setTitleColor(hasSeat ? UIColor(hexString: "ffffff") : UIColor(hexString: "cccccc"), for: .normal)
        startTime.text = ticketInfo.start_time!
        fromStationName.text = ticketInfo.FromStationName!
        toStationName.text = ticketInfo.ToStationName!
        
        updateShadowColor()
        updateLayoutConstraint()
    }
    
    private func updateShadowColor() {
        
        mainView.layer.shadowColor = UIColor(hexString: "AAAAAA")?.cgColor
        mainView.layer.shadowRadius = 3
        mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        detailView.layer.shadowColor = UIColor(hexString: "AAAAAA")?.cgColor
        detailView.layer.shadowRadius = 3
        detailView.layer.shadowOffset = CGSize(width: 0, height: 0)
        detailView.layer.shadowOpacity = 0.5
        if ticketInfo.isShowDetail {
            detailView.isHidden = false
            mainView.layer.shadowOpacity = 0.5
        }else{
            detailView.isHidden = true
            mainView.layer.shadowOpacity = 0.1
        }
    }
    
    private func getDetailSnap() -> UIImage {
        
        addGrapTicketButton.isHidden = true
        let image = detailView.snapshotImage()
        addGrapTicketButton.isHidden = false
        return image!
    }
    
    private func setSeat(_ seatName: String) {
        selectSeatButton.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        selectSeatButton.setTitle(seatName, for: .normal)
    }
    
    private func setPerson(_ personName: String) {
        selectPersonButton.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        selectPersonButton.setTitle(personName, for: .normal)
    }
    
    private func updateLayoutConstraint() {
        detailViewTrailing.constant = detailViewTrailing.constant * WSConfig.SizeScale
        detailViewLeading.constant = detailViewLeading.constant * WSConfig.SizeScale
    }
    
    private func isHaveSeat(_ ticket: WSQueryLeftNewDTO) -> Bool {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(ticket.classForCoder, &count)
        for i in 0..<count {
            let property = properties![Int(i)]
            let key = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue)!
            if key.contains("Num") {
                let value = ticket.value(forKey: key as String) as! String
                
                if value != "" {
                    if value == "有" || (value != "无" && Int(value)! > 0){
                        ticketsLeftLabel.textColor = UIColor(hexString: "f7999e")
                        return true
                    }
                }
            }
        }
        ticketsLeftLabel.textColor = UIColor(hexString: "AAAABC")
        return false
    }
    
//MARK:- tapped response
    @IBAction func buyButtonDidTapped(_ sender: Any) {
        
    }
    
    @IBAction func selectSeatDidTapped(_ sender: Any) {
        
        WSTrainSeatAlert.showSeatAlert(WSConfig.getViewController(inView: self)!, ticketInfo.seatTypePairDic) { seatInfo in
        
            self.setSeat(seatInfo.seatName)
        }
    }
    
    @IBAction func selectPersonDidTapped(_ sender: Any) {
        if WSUserModule.passengers.count == 0 {
            WSLogin.isLogin = false
        }
        
        if !WSLogin.checkLogin() {return}
        
        WSTrainPersonAlert.showPersonAler(WSConfig.getViewController(inView: self)!, WSUserModule.passengers) { passenger in
            self.setPerson(passenger.passenger_name)
        }
    }
    
    @IBAction func addGrapTicketDidTapped(_ sender: Any) {
        
        let detailFrame = detailView.convert(detailView.bounds, to: WSConfig.keywindow)
        WSAddGrapTicketAnimation.startAddGrapAnimationInViewSnap(getDetailSnap(), detailFrame, {
            WSLMateBall.shared.addBubble()
        })
    }
}
