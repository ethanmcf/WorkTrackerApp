//
//  ViewController.swift
//  WorkHoursApp
//
//  Created by Ethan McFarland on 2021-11-07.
//

import UIKit

//MARK: - Variables
class ViewController: UIViewController {
    static let shared = ViewController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var count = 0
    
    let alert = Alert()
    
    var jobs: [Job]!
    var selectedJob: Job!
    var selectedDate: DateComponents = DateComponents()
    var selectedMonth: String!
    
    var newShift: Shift!
    var shiftInfo: [Int:[Any]] = [:] // [shiftOrderNum: [shift, Bool(buttonEnabled), ButtonImageName, dateLabelColor, timeLabelColor]
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
    @IBAction func didTapInfo(_ sender: Any) {
        //let calendar = Calendar.current
        let dForm = DateFormatter()
        dForm.dateFormat = "MMM d, yyyy"
        
        //Get first shift worked
        let totalHours = selectedJob.hoursWorked
        var lowestDate = Date()
        var startDate = ""
        for shift in selectedJob.shifts!.allObjects as! [Shift]{
            let stringDate = "\(shift.month!) \(shift.day!), \(shift.year!)"
            let date = dForm.date(from: stringDate)!
            if date.compare(lowestDate) == .orderedAscending{
                startDate = stringDate
                lowestDate = date
            }
        }
        
        var message = "First shift on \(startDate) and have worked \(totalHours) hours."
        if startDate == ""{
            message = "No information collected yet."
        }
        
        alert.presentInfoAlert(with: "\(selectedJob.name!) Info", message: message)
    }
    
    @IBAction func didTapPrevious(_ sender: Any) {
        updateSelectedDate(increadBy: -1)
        updateView()
        shiftTable.reloadData()
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        updateSelectedDate(increadBy: 1)
        updateView()
        shiftTable.reloadData()
    }
    
    @IBAction func didTapAddShift(_ sender: Any) {
        alert.addShiftSheet(selectedDate: selectedDate)
    }
}

//MARK: - Visual Functions
extension ViewController{
    func configureOptionMenu(){
        let deleteJobAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { (action) in
            
            //Check if user only has one job
            if self.jobs.count == 1{
                self.alert.presentInfoAlert(with: "Error", message: "Cannot delete only job.")
                return
            }
            //Double check user wants to delete job
            self.alert.deleteJobAlert(jobName: self.selectedJob.name!)
        }
        
        let editJobAction = UIAction(title: "Edit"){ (action) in
            self.alert.editJobAlert(jobName: self.selectedJob.name!)
        }
        
        let addJobAction = UIAction(title: "New Job", image: UIImage(systemName: "plus")) { (action) in
            self.alert.createJobAlert()
        }
        
        let jobMenu = UIMenu(children: [editJobAction,addJobAction,deleteJobAction])
        
        editButton.menu = jobMenu
        editButton.showsMenuAsPrimaryAction = true
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
}

//MARK: - Main Functions
extension ViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up alert instance
        alert.viewController = self
        
        //Add job if user's first time using app
        checkFirstTime()
        
        //Get/Set curr date
        selectedDate.month = Calendar.current.component(.month,from: Date())
        selectedDate.year = Calendar.current.component(.year,from: Date())
        updateSelectedDate(increadBy: 0)
        
        //Configure job options, get all jobs and get selected Job
        configureJobSwitch()
        selectedJob = jobs[0]
        
        //Update ui and get shift info for selected job and date
        updateView()
        
        configureOptionMenu()
        
        //Set up shift table
        shiftTable.register(ShiftTableViewCell.nib(), forCellReuseIdentifier: ShiftTableViewCell.identifier)
        shiftTable.delegate = self
        shiftTable.dataSource = self
        shiftTable.reloadData()
        
        setUpVisuals()
        
    }
    
    func getInfo(){
        //Gets all shifts from selected job in decending order
        var allShifts = (selectedJob!.shifts!.allObjects as! [Shift])
        allShifts = allShifts.sorted(by: { Int($0.day!)! > Int($1.day!)! }).reversed()
        
        //Resest values to perform calculations/gathering of data
        monthlyHoursPaid = 0
        monthlyHoursWorked = 0
        shiftInfo = [:]
        
        if allShifts.count != 0{
            //Get shifts for selected month and year/order them
            for i in 0...allShifts.count-1{
                let shift = allShifts[i]
                if shift.month == selectedMonth && shift.year == String(selectedDate.year!){
                    if shift.payed == true{
                        //ButEn,ButIm,dColor,tColor,
                        shiftInfo[i] = [shift, false,"checkmark.circle", UIColor.systemGray2, UIColor.systemGray3]
                    }else{
                        shiftInfo[i] = [shift, true,"circle", UIColor.black,UIColor.darkGray]
                    }
                }
            }
            
            //Update hours and amount owed
            for i in 0...shiftInfo.values.count-1{
                let shift = shiftInfo[i]![0] as! Shift
                monthlyHoursWorked += shift.length
                if shift.payed == true{
                    monthlyHoursPaid += shift.length
                }
            }
        }
    }
    
    func updateSelectedDate(increadBy amount: Int){
        let calendar = Calendar(identifier: .gregorian)
        //Create currently selected datecomp as actual date
        let theSelectedDate = calendar.date(from: selectedDate)
        //Create a month component to add
        var increaseComp = DateComponents()
        increaseComp.month = amount
        //Add one month to selected date to get new date by one month
        let newDate = Calendar.current.date(byAdding: increaseComp,  to: theSelectedDate!)!
        
        selectedDate.month = Calendar.current.component(.month,from: newDate)
        selectedDate.year = Calendar.current.component(.year,from: newDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        selectedMonth = monthFormatter.string(from: newDate)
        monthLabel.text = selectedMonth
    }
    
    func checkFirstTime(){
        if try! context.fetch(Job.fetchRequest()).count == 0{
            let newJob = Job(context: context)
            newJob.name = "Job #1"
            newJob.hoursWorked = 0
            newJob.hoursPaid = 0
            newJob.shifts = []
            newJob.payRate = 15.00
            try! context.save()
        }
    }
    
    func addShift(datePicker: UIDatePicker, startPicker: UIDatePicker, endPicker: UIDatePicker, paidSwitch: UISwitch){
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
        let shiftPaid = paidSwitch.isOn
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
        
        alert.presentSuccessAlert()
        updateView()
        shiftTable.reloadData()
    }
    
    func configureJobSwitch(newJob: Job? = nil){
        jobs = try! context.fetch(Job.fetchRequest())
        
        //Switch job
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
        
        //Create job switch menu
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
    
    func createNewJob(jobName: String){
        let newJob = Job(context: context)
        newJob.name = jobName
        newJob.hoursWorked = 0
        newJob.hoursPaid = 0
        newJob.payRate = 15.00
        newJob.shifts = []
        try! context.save()
        
        configureJobSwitch(newJob: newJob)
        selectedJob = newJob
        updateView()
        shiftTable.reloadData()
    }
    
    func deleteJob(){
        context.delete(selectedJob)
        try! context.save()
        configureJobSwitch()
        selectedJob = jobs[0]
        updateView()
        shiftTable.reloadData()
    }
    
    func editJob(jobName: String, payRate: Float){
        selectedJob.name = jobName
        selectedJob.payRate = payRate
        try! self.context.save()
        
        self.configureJobSwitch(newJob: self.selectedJob)
        
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
        
        
        let eachShift = shiftInfo[indexPath.row]![0] as! Shift
        var eachShiftInfo = shiftInfo[indexPath.row]!
        eachShiftInfo.remove(at: 0)
        
        let cell = shiftTable.dequeueReusableCell(withIdentifier: ShiftTableViewCell.identifier, for: indexPath) as! ShiftTableViewCell
        cell.configure(shift: eachShift, shiftInfo: eachShiftInfo)
        cell.delegate = self
        return cell
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle  == .delete{
            shiftTable.beginUpdates()
            deleteShift(shift: shiftInfo[indexPath.row]![0] as! Shift, index: indexPath.row)
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
        shiftInfo[index] = nil
    }
    
    func pressedPayButton(with shift: Shift) {
        shift.payed = true
        shift.job!.hoursPaid += shift.length
        try! context.save()
        updateView()
    }
}
