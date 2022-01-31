//
//  AlertManager.swift
//  WorkTrackerApp
//
//  Created by Ethan McFarland on 2022-01-30.
//

import Foundation
import UIKit

class Alert{
    private var alertView: UIAlertController!
    public var viewController: ViewController!
    
    //Add shift interactives
    let datePicker: UIDatePicker = UIDatePicker()
    let startPicker: UIDatePicker = UIDatePicker()
    let endPicker: UIDatePicker = UIDatePicker()
    let paidSwitch: UISwitch = UISwitch()
    
    //Add shift showed info
    let infoView = UIView()
    let timesLabel: UILabel = UILabel()
    let dateLabel: UILabel = UILabel()
    let paidLabel = UILabel()
    
    //Add shift picker label covers
    let startLabel = UILabel()
    let theDate = UILabel()
    let endLabel = UILabel()
    
    private var jobNameField: UITextField = {
        let padding = UIView(frame: CGRect(x:0,y: 0,width: 9,height: 30))
        
        var jobNameField = UITextField()
        jobNameField.frame = CGRect(x: 35, y: 65, width: 200, height: 30)
        jobNameField.leftView = padding
        jobNameField.leftViewMode = .always
        jobNameField.backgroundColor = .white
        jobNameField.layer.borderWidth = 1
        jobNameField.layer.borderColor = UIColor.systemGray5.cgColor
        jobNameField.layer.cornerRadius = 5
        jobNameField.text = ""
        
        return jobNameField
    }()
    
    func presentInfoAlert(with title: String, message: String){
        alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertView, animated: true, completion: nil)
    }
    
    func presentSuccessAlert(){
        alertView = UIAlertController(title: "", message:"", preferredStyle: .alert)
        let image = UIImageView(frame: CGRect(x: 40, y: 40, width: 90, height: 90))
        
        image.image = UIImage(named: "Success")
        alertView.view.addSubview(image)
        
        alertView.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: alertView.view, attribute: .centerX, multiplier: 1, constant: 0))
        alertView.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: alertView.view, attribute: .centerY, multiplier: 1, constant: 0))
        alertView.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        alertView.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64.0))
        
        viewController.present(alertView, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.alertView.dismiss(animated: true, completion: nil)
        }
    }
    
    func createJobAlert(){
        jobNameField.placeholder = "Job name"
        
        alertView = UIAlertController(title: "Create New Job", message: "\n\n\n", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Create", style: .default) { confirm in
            self.viewController.createNewJob(jobName: self.jobNameField.text!)
        }
        
        alertView.view.addSubview(jobNameField)
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        
        viewController.present(alertView, animated: true, completion: nil)
    }
    
    func editJobAlert(jobName: String){
        jobNameField.placeholder = "Updated name"
        
        alertView = UIAlertController(title: "Edit \(jobName)", message: "\n\n\n", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Update", style: .default) { confirm in
            self.viewController.editJob(jobName: self.jobNameField.text!, payRate: 15.00)
        }
        
        alertView.view.addSubview(jobNameField)
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        
        viewController.present(alertView, animated: true, completion: nil)
    }
    
    func deleteJobAlert(jobName: String){
        let message = "Are you sure you want to delete \"\(jobName)\""
        
        alertView = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { confirm in
            self.viewController.deleteJob()
        }
        
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        
        viewController.present(alertView, animated: true, completion: nil)
    }
    
    func addShiftSheet(selectedDate: DateComponents){
        alertView = UIAlertController(title: "Add Shift", message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        infoView.frame =  CGRect(x: alertView.view.frame.size.width / 2 - 30, y: 40, width: 185, height: 140)
        infoView.backgroundColor = .systemGray5
        infoView.layer.cornerRadius = 10
        
        let date = Date()
        let labelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        
        
        //Cover Labels
        startLabel.text = "Starts"
        startLabel.backgroundColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        startLabel.frame = CGRect(x: 30, y: 40, width: 100, height: 30)
        startLabel.layer.cornerRadius = 5
        startLabel.textColor = .white
        startLabel.layer.masksToBounds = true
        startLabel.textAlignment = .center

        theDate.text = "Date"
        theDate.backgroundColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        theDate.frame = CGRect(x: 30, y: 95, width: 100, height: 30)
        theDate.layer.cornerRadius = 5
        theDate.textColor = .white
        theDate.layer.masksToBounds = true
        theDate.textAlignment = .center

        endLabel.text = "Ends"
        endLabel.backgroundColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        endLabel.frame = CGRect(x: 30, y: 150, width: 100, height: 30)
        endLabel.layer.cornerRadius = 5
        endLabel.layer.masksToBounds = true
        endLabel.textColor = .white
        endLabel.textAlignment = .center
        
        //Date Pickers
        let calendarComp = Calendar.current.dateComponents([.day,.month], from: Date())
        var setComp = DateComponents()
        setComp.year = selectedDate.year
        setComp.month = selectedDate.month
        if calendarComp.month != setComp.month{
            setComp.day = 01
        }else{
            setComp.day = calendarComp.day
        }
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Calendar(identifier: .gregorian).date(from: setComp)!
        datePicker.datePickerMode = .date
        datePicker.frame = CGRect(x: 30, y: 95, width: 100, height: 30)
        datePicker.addTarget(self, action: #selector(updateShiftView), for: .valueChanged)

        startPicker.preferredDatePickerStyle = .compact
        startPicker.datePickerMode = .time
        startPicker.minuteInterval = 15
        startPicker.frame = CGRect(x: 30, y: 40, width: 100, height: 30)
        let componentsS = Calendar.current.dateComponents([.hour], from: date)
        startPicker.date = Calendar.current.date(from: componentsS)!
        startPicker.backgroundColor = .clear
        startPicker.addTarget(self, action: #selector(updateShiftView), for: .valueChanged)
        
        endPicker.preferredDatePickerStyle = .compact
        endPicker.datePickerMode = .time
        endPicker.minuteInterval = 15
        endPicker.frame = CGRect(x: 30, y: 150, width: 100, height: 30)
        var componentsE = Calendar.current.dateComponents([.hour], from: date)
        componentsE.hour! += 2
        endPicker.date = Calendar.current.date(from: componentsE)!
        endPicker.addTarget(self, action: #selector(updateShiftView), for: .valueChanged)
        
        //Showed Info View Content
        timesLabel.frame = CGRect(x: 20, y: 5, width: infoView.frame.size.width, height: 50)
        timesLabel.textColor = labelColor
        
        
        dateLabel.frame = CGRect(x: 20, y: 50, width: infoView.frame.size.width, height: 50)
        dateLabel.textColor = labelColor
        
        
        paidLabel.text = "Paid"
        paidLabel.frame = CGRect(x: 20, y: 90, width: 50, height: 50)
        paidLabel.textColor = labelColor
        
        paidSwitch.onTintColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        paidSwitch.frame = CGRect(x: paidLabel.frame.maxX , y: 100, width: 100, height: 50)
        
        //Populate shift info
        updateShiftView()
        
        //Add UI to alert
        infoView.addSubview(timesLabel)
        infoView.addSubview(dateLabel)
        infoView.addSubview(paidLabel)
        infoView.addSubview(paidSwitch)
    
        alertView.view.addSubview(startPicker)
        alertView.view.addSubview(datePicker)
        alertView.view.addSubview(endPicker)
        
        alertView.view.addSubview(startLabel)
        alertView.view.addSubview(theDate)
        alertView.view.addSubview(endLabel)
        
        alertView.view.addSubview(infoView)
        
        
        //Create alert actions
        let addAction = UIAlertAction(title: "Add", style: .default) { add in
            self.viewController.addShift(datePicker: self.datePicker,
                                         startPicker: self.startPicker,
                                         endPicker: self.endPicker,
                                         paidSwitch: self.paidSwitch)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertView.addAction(addAction)
        alertView.addAction(cancelAction)
        
        viewController.present(alertView, animated: true, completion: nil)
        
    }
}

//MARK: - Alert OBJC Functions
extension Alert{
    @objc func updateShiftView(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startTimes = dateFormatter.string(from: startPicker.date).lowercased()
        let endTimes = dateFormatter.string(from: endPicker.date).lowercased()
        timesLabel.text = "\(startTimes) - \(endTimes)"
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateTime = dateFormatter.string(from: datePicker.date)
        dateLabel.text = dateTime
        
    }
}
