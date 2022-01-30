//
//  ViewController.swift
//  WorkHoursApp
//
//  Created by Ethan McFarland on 2021-11-07.
//

import UIKit

//MARK: - Variables
class ViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var count = 0
    
    //Pop ups
    let datePicker: UIDatePicker = UIDatePicker()
    let startPicker: UIDatePicker = UIDatePicker()
    let endPicker: UIDatePicker = UIDatePicker()
    let payedSwitch: UISwitch = UISwitch()
    
    let editField: UITextField = UITextField()
    
    let timesLabel: UILabel = UILabel()
    let dateLabel: UILabel = UILabel()
    
    var jobs: [Job]!
    var selectedJob: Job!
    var selectedDate: DateComponents = DateComponents()
    var selectedMonth: String!
    
    var newShift: Shift!
    var shifts: [Shift]!
    var shiftInfo: [Shift:[Any]] = [:] //ButEn,ButIm,dColor,tColor
    var monthlyHoursPaid: Float!
    var monthlyHoursWorked: Float!
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var jobButton: UIButton!
    @IBOutlet weak var decimal: UILabel!
    @IBOutlet weak var nextCover: UIView!
    @IBOutlet weak var prevCover: UIView!
    @IBOutlet weak var hoursWorked: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    //Shift View
    @IBOutlet weak var shiftView: UIView!
    @IBOutlet weak var shiftTable: UITableView!
    @IBOutlet weak var noShiftLabel: UILabel!
    
    //Progress View
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var fraction: UILabel!
}

//MARK: - UI Functions
extension ViewController{
    @IBAction func jobInfoButtton(_ sender: Any) {
        //let calendar = Calendar.current
        let dForm = DateFormatter()
        dForm.dateFormat = "MMM d, yyyy"
        
        let totalHours = selectedJob.hoursWorked
        var lowest = Date()
        var startDate = ""
        for shift in selectedJob.shifts!.allObjects as! [Shift]{
            let sDate = "\(shift.month!) \(shift.day!), \(shift.year!)"
            let date = dForm.date(from: sDate)!
            if date.compare(lowest) == .orderedAscending{
                startDate = sDate
                lowest = date
            }
        }
        let message = "First shift on \(startDate) and have worked \(totalHours) hours."
        let alert = UIAlertController(title: "\(selectedJob.name!) Info", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func prevMonth(_ sender: Any) {
        let calendar = Calendar(identifier: .gregorian)
        //Create currently selected datecomp as actual date
        let theSelectedDate = calendar.date(from: selectedDate)
        //Create a month component to add
        var increaseComp = DateComponents()
        increaseComp.month = -1
        //Add one month to selected date to get new date by one month
        let newDate = Calendar.current.date(byAdding: increaseComp,  to: theSelectedDate!)
        //Get components of new selected month
        updateDate(date: newDate!)
        updateView()
        shiftTable.reloadData()
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        let calendar = Calendar(identifier: .gregorian)
        //Create currently selected datecomp as actual date
        let theSelectedDate = calendar.date(from: selectedDate)
        //Create a month component to add
        var increaseComp = DateComponents()
        increaseComp.month = 1
        //Add one month to selected date to get new date by one month
        let newDate = Calendar.current.date(byAdding: increaseComp,  to: theSelectedDate!)
        updateDate(date: newDate!)
        updateView()
        shiftTable.reloadData()
    }
    
    @IBAction func addShift(_ sender: Any) {
        configureAddShiftPopUp()
    }
}

//MARK: - Visual/Alert SetUp
extension ViewController{
    func configureMenu(){
        let deleteJobAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { (action) in
            //Confirm delete job alert
            if self.jobs.count == 1{
                let alert = UIAlertController(title: "Error", message: "Cannot delete only job.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                let confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete " + self.selectedJob.name!, preferredStyle: .alert)
                let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) -> Void in
                        self.deleteJob()
                })
                let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: {(action) -> Void in })
                
                confirmAlert.addAction(cancelButton)
                confirmAlert.addAction(deleteButton)
               
                
                self.present(confirmAlert, animated: true, completion: nil)
            }
        }
        
        let editJobAction = UIAction(title: "Edit"){ (action) in
            self.editAlert(edit: true)
        }
        let addJobAction = UIAction(title: "New Job", image: UIImage(systemName: "plus")) { (action) in
            self.editAlert(edit: false)
        }
        let jobMenu = UIMenu(children: [editJobAction,addJobAction,deleteJobAction])
        editButton.menu = jobMenu
        editButton.showsMenuAsPrimaryAction = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add job if user's first time using app
        checkFirstTime()
        
        //Get curr date
        updateDate(date: Date())
        
        //Configure job options, get all jobs and get selected Job
        configureJobSwitch()
        selectedJob = jobs[0]
        
        //Update ui and get shift info for selected job and date
        updateView()
        
        //Configure Menus
        configureMenu()
        
        //Set up shift table
        shiftTable.register(ShiftTableViewCell.nib(), forCellReuseIdentifier: ShiftTableViewCell.identifier)
        shiftTable.delegate = self
        shiftTable.dataSource = self
        shiftTable.reloadData()
        
        setUpVisuals()
        
    }
    
    func setUpVisuals(){
        //Visuals
        nextCover.layer.cornerRadius = nextCover.frame.size.height/2
        nextCover.layer.borderColor = UIColor.white.cgColor
        nextCover.layer.borderWidth = 1
        
        prevCover.layer.cornerRadius = prevCover.frame.size.height/2
        prevCover.layer.borderColor = UIColor.white.cgColor
        prevCover.layer.borderWidth = 1
        
        progressView.layer.cornerRadius = 45
        progressView.layer.shadowColor = UIColor.blue.cgColor
        progressView.layer.shadowOpacity = 0.5
        progressView.layer.shadowOffset = .zero
        progressView.layer.shadowRadius = 10
        
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 2)
        
        shiftView.layer.cornerRadius = 40
        shiftView.layer.shadowColor = UIColor.gray.cgColor
        shiftView.layer.shadowOpacity = 0.2
        shiftView.layer.shadowOffset = .zero
        shiftView.layer.shadowRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shiftInfo.keys.count != 0{
            shiftTable.scrollToRow(at: IndexPath(row: shiftInfo.keys.count - 1,section: 0), at: .bottom, animated: false)
        }
    }
    
    func updateView(){
        getInfo()
        
        //let jobInfo = selectedJob!
        let workedHoursClean = String(format: "%.f", monthlyHoursWorked)
        let workedHours: String!
        let paidHours: String!
        //Check if decimal
        if monthlyHoursWorked.truncatingRemainder(dividingBy: 1) == 0 {
            workedHours = String(format: "%.f", monthlyHoursWorked)
            decimal.isHidden = true
        }else{
            workedHours = String(monthlyHoursWorked)
            decimal.isHidden = false
            decimal.text = String(monthlyHoursWorked.truncatingRemainder(dividingBy: 1)).trimmingCharacters(in: ["0"])
        }
        
        if (monthlyHoursPaid).truncatingRemainder(dividingBy: 1) == 0 {
            paidHours = String(format: "%.f", monthlyHoursPaid)
        }else{
            paidHours = String(monthlyHoursPaid)
        }
        
        let progress: Float
        let percent: Int
        if monthlyHoursWorked == 0 {
            percent = 0
            progress = 0
        }else if monthlyHoursPaid == 0{
            percent = 0
            progress = 0.005
        }else{
            progress = monthlyHoursPaid/monthlyHoursWorked
            percent = Int(progress * 100)
        }
        
        let theColor: UIColor!
        if percent > 60 {
            theColor = UIColor(red: 0, green: 0.8863, blue: 0.3373, alpha: 1)
            
        }else if percent >= 30{
            theColor = UIColor(red: 1, green: 0.7137, blue: 0, alpha: 1)
        }else{
            theColor = UIColor(red: 0.898, green: 0.0745, blue: 0, alpha: 1)
        }
        progressBar.progressTintColor = theColor
        
        hoursWorked.text = workedHoursClean
        
        fraction.text = paidHours + "/" + workedHours
        percentage.text = String(percent) + "%"
        progressBar.setProgress(progress, animated: false)
        
        yearLabel.text = String(selectedDate.year!)
        if shiftInfo.keys.count == 0{
            noShiftLabel.isHidden = false
        }else{
            noShiftLabel.isHidden = true
        }
    }
    
    func configureJobSwitch(newJob: Job? = nil){
        jobs = []
        let allJobs = try! context.fetch(Job.fetchRequest())
        for job in allJobs{
            jobs.append(job)
        }
        
        let selectJob = { (action: UIAction) in
            for job in self.jobs {
                if job.name! == action.title{
                    self.selectedJob = job
                }
            }
            self.updateView()
            self.shiftTable.reloadData()
        }
        var children: [UIAction] = []
        var action: UIAction!
        if newJob == nil{
            for i in 0...jobs.count-1{
                action = UIAction(title: jobs[i].name!, state: .on, handler: selectJob)
                children.append(action)
            }
        }else{
            for i in 0...jobs.count-1{
                if jobs[i] == newJob{
                    action = UIAction(title: jobs[i].name!, state: .on, handler: selectJob)
                }else{
                    action = UIAction(title: jobs[i].name!, state: .off, handler: selectJob)
                }
                children.append(action)
            }
        }
        jobButton.menu = UIMenu(children: children)
        
    }
    
    func configureAddShiftPopUp(){
        let alert = UIAlertController(title: "Add Shift", message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
    

        let infoView = UIView()
        infoView.frame =  CGRect(x: alert.view.frame.size.width / 2 - 30, y: 40, width: 185, height: 140)
        infoView.backgroundColor = .systemGray5
        infoView.layer.cornerRadius = 10
        
        let date = Date()
        let calendar = Calendar.current
        let labelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        
        
        //Edit Labels
        let startLabel = UILabel()
        startLabel.text = "Starts"
        startLabel.backgroundColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        startLabel.frame = CGRect(x: 30, y: 40, width: 100, height: 30)
        startLabel.layer.cornerRadius = 5
        startLabel.textColor = .white
        startLabel.layer.masksToBounds = true
        startLabel.textAlignment = .center

        
        let theDate = UILabel()
        theDate.text = "Date"
        theDate.backgroundColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        theDate.frame = CGRect(x: 30, y: 95, width: 100, height: 30)
        theDate.layer.cornerRadius = 5
        theDate.textColor = .white
        theDate.layer.masksToBounds = true
        theDate.textAlignment = .center

        
        let endLabel = UILabel()
        endLabel.text = "Ends"
        endLabel.backgroundColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        endLabel.frame = CGRect(x: 30, y: 150, width: 100, height: 30)
        endLabel.layer.cornerRadius = 5
        endLabel.layer.masksToBounds = true
        endLabel.textColor = .white
        endLabel.textAlignment = .center
        
        //Date Pickers
        let cal = Calendar.current.dateComponents([.day,.month], from: Date())
        var setComp = DateComponents()
        setComp.year = selectedDate.year
        setComp.month = selectedDate.month
        if cal.month != setComp.month{
            setComp.day = 01
        }else{
            setComp.day = cal.day
        }
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Calendar(identifier: .gregorian).date(from: setComp)!
        datePicker.datePickerMode = .date
        datePicker.frame = CGRect(x: 30, y: 95, width: 100, height: 30)
        datePicker.addTarget(self, action: #selector(updateInfoView), for: .valueChanged)

        startPicker.preferredDatePickerStyle = .compact
        startPicker.datePickerMode = .time
        startPicker.minuteInterval = 15
        startPicker.frame = CGRect(x: 30, y: 40, width: 100, height: 30)
        let componentsS = calendar.dateComponents([.hour], from: date)
        startPicker.date = Calendar.current.date(from: componentsS)!
        startPicker.backgroundColor = .clear
        startPicker.addTarget(self, action: #selector(updateInfoView), for: .valueChanged)
        
        endPicker.preferredDatePickerStyle = .compact
        endPicker.datePickerMode = .time
        endPicker.minuteInterval = 15
        endPicker.frame = CGRect(x: 30, y: 150, width: 100, height: 30)
        var componentsE = calendar.dateComponents([.hour], from: date)
        componentsE.hour! += 2
        endPicker.date = Calendar.current.date(from: componentsE)!
        endPicker.addTarget(self, action: #selector(updateInfoView), for: .valueChanged)
        
        //Info View
        timesLabel.frame = CGRect(x: 20, y: 5, width: infoView.frame.size.width, height: 50)
        timesLabel.textColor = labelColor
        
        
        dateLabel.frame = CGRect(x: 20, y: 50, width: infoView.frame.size.width, height: 50)
        dateLabel.textColor = labelColor
        
        let payedLabel = UILabel()
        payedLabel.text = "Paid"
        payedLabel.frame = CGRect(x: 20, y: 90, width: 50, height: 50)
        payedLabel.textColor = labelColor
        
        payedSwitch.onTintColor = UIColor(red: 0, green: 0.7647, blue: 1, alpha: 1)
        payedSwitch.frame = CGRect(x: payedLabel.frame.maxX , y: 100, width: 100, height: 50)
        
        //Create
        updateInfoView()
        
        
        infoView.addSubview(timesLabel)
        infoView.addSubview(dateLabel)
        infoView.addSubview(payedLabel)
        infoView.addSubview(payedSwitch)
    
        alert.view.addSubview(startPicker)
        alert.view.addSubview(datePicker)
        alert.view.addSubview(endPicker)
        
        alert.view.addSubview(startLabel)
        alert.view.addSubview(theDate)
        alert.view.addSubview(endLabel)
        
        alert.view.addSubview(infoView)
        
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in self.addShiftFunctionality()}))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        
        self.present(alert, animated: true)
    }
    
    @objc func updateInfoView(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startTimes = dateFormatter.string(from: startPicker.date).lowercased()
        let endTimes = dateFormatter.string(from: endPicker.date).lowercased()
        timesLabel.text = "\(startTimes) - \(endTimes)"
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateTime = dateFormatter.string(from: datePicker.date)
        dateLabel.text = dateTime
        
    }
    
    func editAlert(edit: Bool){
        let title: String!
        let confirmAction: UIAlertAction!
        editField.frame = CGRect(x: 35, y: 65, width: 200, height: 30)
        editField.backgroundColor = .white
        editField.layer.borderWidth = 1
        editField.layer.borderColor = UIColor.systemGray5.cgColor
        editField.layer.cornerRadius = 5
        editField.text = ""
        let paddingView = UIView(frame: CGRect(x:0,y: 0,width: 9, height: self.editField.frame.height))
        editField.leftView = paddingView
        editField.leftViewMode = .always
        
        if edit == true{
            editField.placeholder = "Updated name"
            title = "Edit \"\(selectedJob.name!)\""
            confirmAction = UIAlertAction(title: "Update", style: .default, handler: {action in
                self.selectedJob.name = self.editField.text!
                self.configureJobSwitch(newJob: self.selectedJob)
                try! self.context.save()
            })
        }else{
            editField.placeholder = "Job name"
            title = "Create New Job"
            confirmAction = UIAlertAction(title: "Create", style: .default, handler: {action in
                let newJob = Job(context: self.context)
                newJob.name = self.editField.text!
                newJob.hoursWorked = 0
                newJob.hoursPaid = 0
                newJob.shifts = []
                try! self.context.save()
                
                self.configureJobSwitch(newJob: newJob)
                self.selectedJob = newJob
                self.updateView()
                self.shiftTable.reloadData()
                
            })
        }
        
        let alert = UIAlertController(title: title, message: "\n\n\n", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.view.addSubview(editField)
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.present(alert,animated: true)
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

//MARK: - Main Functions
extension ViewController{
    func getInfo(){
        //Get shift info
        let jobInfo = selectedJob!
        var allShifts = (jobInfo.shifts!.allObjects as! [Shift])
        allShifts = allShifts.sorted(by: { Int($0.day!)! > Int($1.day!)! }).reversed()
        
        shiftInfo = [:]
        for shift in allShifts{
            if shift.month == selectedMonth && shift.year == String(selectedDate.year!){
                if shift.payed == true{
                    //ButEn,ButIm,dColor,tColor,
                    shiftInfo[shift] = [false,"checkmark.circle", UIColor.systemGray2, UIColor.systemGray3]
                }else{
                    shiftInfo[shift] = [true,"circle", UIColor.black,UIColor.darkGray]
                }
            }
        }
        
        monthlyHoursPaid = 0
        monthlyHoursWorked = 0
        for shift in Array(shiftInfo.keys){
            monthlyHoursWorked += shift.length
            if shift.payed == true{
                monthlyHoursPaid += shift.length
            }
        }
    }
    
    func deleteJob(){
        context.delete(selectedJob)
        try! context.save()
        configureJobSwitch()
        selectedJob = jobs[0]
        updateView()
        shiftTable.reloadData()
    }
    
    func updateDate(date: Date){
        let calendar = Calendar.current

        selectedDate.month = calendar.component(.month,from: date)
        selectedDate.year = calendar.component(.year,from: date)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        selectedMonth = monthFormatter.string(from: date)
        monthLabel.text = selectedMonth
    }
    
    func checkFirstTime(){
        var count = 0
        let allJobs = try! context.fetch(Job.fetchRequest())
        for _ in allJobs{
            count += 1
        }
        if count == 0{
            let newJob = Job(context: context)
            newJob.name = "Job #1"
            newJob.hoursWorked = 0
            newJob.hoursPaid = 0
            newJob.shifts = []
            try! context.save()
        }
    }
    
    func addShiftFunctionality(){
        let calendar = Calendar.current
        //Get date info
        let dayComp = calendar.dateComponents([.day], from: datePicker.date)
        let day = String(dayComp.day!)
        
        //Get shift times as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startTimes = dateFormatter.string(from: startPicker.date).lowercased()
        let endTimes = dateFormatter.string(from: endPicker.date).lowercased()
        let stringWorkTimes = startTimes + " - " + endTimes
        
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: datePicker.date)
        
        //Get Shift Length
        let shiftComp = calendar.dateComponents([.hour,.minute], from: startPicker.date, to: endPicker.date)
        
        var shiftLength: Float!
        
        //Make sure time diff is intervalled at 15
        if shiftComp.minute! % 15 != 0 {
            shiftLength = Float(shiftComp.hour!) + Float(shiftComp.minute! + 1)/60
        }else{
            shiftLength = Float(shiftComp.hour!) + Float(shiftComp.minute!)/60
        }
        if shiftLength < 0{
            shiftLength += 24
        }else if shiftLength > 24{
            shiftLength -= 24
        }
        //Get if shift is payed
        let shiftPaid = payedSwitch.isOn
        //Add shift to selected job in database
        let newShift = Shift(context: context)
        newShift.month = month
        newShift.year = String(selectedDate.year!)
        newShift.day = day
        newShift.time = stringWorkTimes
        newShift.length = abs(shiftLength)
        newShift.payed = shiftPaid
        if shiftPaid == true{
            selectedJob.hoursPaid += shiftLength
        }
        
        selectedJob.addToShifts(newShift)
        selectedJob.hoursWorked += shiftLength
        
        try! context.save()
        
        successAlert()
        updateView()
        shiftTable.reloadData()
    }
}

//MARK: - Table View Set Up
extension ViewController: UITableViewDelegate,UITableViewDataSource, ShiftTableDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftInfo.keys.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = shiftTable.dequeueReusableCell(withIdentifier: ShiftTableViewCell.identifier, for: indexPath) as! ShiftTableViewCell
        let eachShift = Array(shiftInfo.keys)[indexPath.row]
        let eachShiftInfo = Array(shiftInfo.values)[indexPath.row]
        cell.configure(shift: eachShift, shiftInfo: eachShiftInfo)
        cell.delegate = self
        return cell
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle  == .delete{
            shiftTable.beginUpdates()
            deleteShift(shift: Array(shiftInfo.keys)[indexPath.row], index: indexPath.row)
            updateView()
            shiftTable.deleteRows(at: [indexPath], with: .fade)
            shiftTable.endUpdates()
        }
    }
}

//MARK: - Table View Functions
extension ViewController{
    func deleteShift(shift: Shift, index: Int){
        selectedJob.hoursWorked -= shift.length
        if shift.payed == true{
            selectedJob.hoursPaid -= shift.length
        }
        context.delete(shift)
        try! context.save()
        shiftInfo.removeValue(forKey: shift)
    }
    
    func pressedPayButton(with shift: Shift) {
        shift.payed = true
        shift.job!.hoursPaid += shift.length
        shiftInfo[shift] = [false,"checkmark.circle", UIColor.systemGray2,UIColor.systemGray3]
        try! context.save()
        updateView()
    }
}

/*let j = try! context.fetch(Job.fetchRequest())[0]
j.hoursPaid = 2
j.hoursWorked = 2
try! context.save()*/
/*
try! context.save()
let newJob = Job(context: context)
newJob.name = "Skating Lab"
newJob.hoursWorked = 25.0
newJob.hoursPaid = 12.5
newJob.payRate = 15
newJob.shifts = []

let newS = Shift(context: context)
newS.length = 4.5
newS.payed = false
newS.year = "2021"
newS.month = "October"
newS.day = "15"
newS.time = "time"
newJob.addToShifts(newS)
try! context.save()*/
