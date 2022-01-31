//
//  ShiftTableViewCell.swift
//  WorkHoursApp
//
//  Created by Ethan McFarland on 2021-11-08.
//

import UIKit


protocol ShiftTableDelegate: AnyObject {
    func pressedPayButton(with shift: Shift)
}

class ShiftTableViewCell: UITableViewCell {
    static let identifier = "shiftCell"
    
    private var theShift: Shift!
    weak var delegate: ShiftTableDelegate?
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var theDate: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBAction func pressedPayButton(_ sender: Any) {
        delegate?.pressedPayButton(with: theShift)
        payButton.isEnabled = false
        payButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        theDate.textColor = .systemGray2
        time.textColor = .systemGray3
    }
    static func nib() -> UINib{
        return UINib(nibName: "ShiftTableViewCell", bundle: nil)
    }
    
    public func configure(shift: Shift, paid: Bool){
        self.theShift = shift
        
        if paid == true{
            payButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            theDate.textColor = UIColor.systemGray2
            time.textColor = UIColor.systemGray3
        }else{
            payButton.setImage(UIImage(systemName: "circle"), for: .normal)
            theDate.textColor = UIColor.black
            time.textColor = UIColor.darkGray
        }
        
        payButton.isEnabled = !paid
        theDate.text = "\(shift.month!) \(shift.day!), \(shift.year!)"
        time.text = shift.time
        amount.text = String(shift.length) + " hr"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
