//
//  AddShiftViewController.swift
//  WorkHoursApp
//
//  Created by Ethan McFarland on 2021-11-09.
//

import UIKit

class AddShiftViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var endTime: UIDatePicker!
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBAction func addShift(_ sender: Any) {
        let calendar = Calendar.current
        //Get date info
        let dayComp = calendar.dateComponents([.day], from: startDatePicker.date)
        let day = String(dayComp.day!)
        
        //Get shift times as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startTimes = dateFormatter.string(from: startTime.date).lowercased()
        let endTimes = dateFormatter.string(from: endTime.date).lowercased()
        let stringWorkTimes = startTimes + " - " + endTimes
        
        //Get Shift Length
        let shiftComp = calendar.dateComponents([.hour,.minute], from: startTime.date, to: endTime.date)
        let shiftLength: Float!
        
        //Make sure time diff is intervalled at 15
        if shiftComp.minute! % 15 != 0 {
            shiftLength = Float(shiftComp.hour!) + Float(shiftComp.minute! + 1)/60
        }else{
            shiftLength = Float(shiftComp.hour!) + Float(shiftComp.minute!)/60
        }
        
        //Update database
        let job = try! context.fetch(Job.fetchRequest())[0]
        let newShift = Shift(context: context)
        newShift.month = "Month"
        newShift.year = "2021"
        newShift.day = day
        newShift.time = stringWorkTimes
        newShift.length = shiftLength
        newShift.payed = false
        
        job.addToShifts(newShift)
        job.hoursWorked += shiftLength
        
        try! context.save()
        
        successAlert()
        
    }
    
    @IBAction func closeView(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addButton.isEnabled = false
        startDatePicker.maximumDate = Date()
        startDatePicker.minimumDate = getStartOfMonth()
        
        let date = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour], from: date)
        components.hour! += 3
        print(components.hour!)
        
        endTime.date = Calendar.current.date(from: components)!
        
        
    }
    func getStartOfMonth() -> Date{
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month], from: date)
        
        var startComponents = DateComponents()
        startComponents.year = components.year!
        startComponents.month = components.month!
        startComponents.day = 01
        
        let startDate = Calendar.current.date(from: startComponents)!
        return startDate
    }
    func successAlert(){
        let alert = UIAlertController(title: "", message:"", preferredStyle: .alert)
        let image = UIImageView(frame: CGRect(x: 40, y: 40, width: 90, height: 90))
        
        image.image = UIImage(named: "Success")
        alert.view.addSubview(image)
        
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: alert.view, attribute: .centerX, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: alert.view, attribute: .centerY, multiplier: 1, constant: 0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        alert.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    

}
