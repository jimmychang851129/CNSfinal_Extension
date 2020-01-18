//
//  SecondViewController.swift
//  CNS final
//
//  Created by 林品諺 on 2019/6/6.
//  Copyright © 2019 林品諺. All rights reserved.
//

import UIKit
import SQLite3
import LocalAuthentication
import AVFoundation

class SendViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    var isAppearred: Bool = false
    
    var db: OpaquePointer?
    
    class Data_ {
        var id: Int
        var domainName: String?
        var password: String
        
        init(id: Int, domainName: String?, password: String){
            self.id = id
            self.domainName = domainName
            self.password = password
        }
    }
    
    func readValues(){
        //first empty the list of heroes
        passwordData.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM Passwords"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        print("id, domain, password")
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let domainName = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            
            //adding values to list
            passwordData.append(Data_(id: Int(id), domainName: domainName, password: password))
            
            print("\(id), \(domainName), \(password)")
        }
    }
    
    var passwordData = [Data_]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("PasswordDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Passwords (id INTEGER PRIMARY KEY AUTOINCREMENT, domainName TEXT, password TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
        
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isAppearred = true
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isAppearred = false
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if (self.isAppearred == false) {
            return
        }
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        var context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authentication"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                
                if success {
                    DispatchQueue.main.async {
                        //creating a statement
                        var stmt: OpaquePointer?
                        
                        var queryString : String
                        
                        let s = code.components(separatedBy: "||")
                        guard s.count == 2 else {
                            self.showAlertController("Wrong QR code.")
                            return
                        }

                        print("key: \(s[0])")
                        let decodedData = Data(base64Encoded: s[0])!
                        print("decodedData: \(decodedData)")
                        let key = [UInt8](decodedData)
                        let url = s[1]
                        //print("key: \(key)")
                        print("url: \(url)")
                        
                        //find if the domain name exists
                        queryString = "SELECT * FROM Passwords WHERE domainName = ?"
                        if sqlite3_prepare_v2(self.db, queryString, -1, &stmt, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                            print("error preparing SELECT: \(errmsg)")
                            return
                        }
                        if sqlite3_bind_text(stmt, 1, url, -1, self.SQLITE_TRANSIENT) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                            print("failure binding domain name for SELECT: \(errmsg)")
                            return
                        }
                        
                        // domain name exists, update password
                        if sqlite3_step(stmt) == SQLITE_ROW {
                            let password = String(cString: sqlite3_column_text(stmt, 2)).utf8.map{ UInt8($0) }
                            
                            if sqlite3_step(stmt) == SQLITE_ROW {
                                print("error: find multiple domain name")
                                return
                            }
                            
                            let register_id = UserDefaults.standard.string(forKey: "register_id")
                            
                            var encrypted = [UInt8] ()
                            for i in 0..<password.count {
                                encrypted.append(key[i] ^ password[i])
                                print("\(encrypted), \(key[i]), \(password[i])")
                            }
                            let data = NSData(bytes: encrypted, length: encrypted.count)
                            if key.count != 64 {
                                print("\(key.count)")
                                self.showAlertController("Wrong key length.")
                                //return
                            }
                            self.send_password(register_id: register_id!, password: data.base64EncodedString())
                            self.showAlertController("Password sent!")
                            return
                        }
                        else {
                            self.showAlertController("No corresbonding entry.")
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    return
                }
            }
        } else {
            self.showAlertController("QAQ")
            return
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func send_password(register_id: String, password: String){
        let api_key = "AAAAY4y4ym8:APA91bGvRhyuiKkkzdzK0CkeqgRHPSpBoo4ycu0Tv66qNiG3mQBFIaU62P9vuvCXjRHRhkNUNg2AW4QvgP8Lt6QfP1IR4AKo503csyYVvGqA-EepB4Bv18ymJSTcWzh4sRV0yZNm35by"
        let url = URL(string: "https://android.googleapis.com/gcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(api_key)", forHTTPHeaderField:"Authorization")
        request.httpMethod = "POST"
        
        request.httpBody = "registration_id=\(register_id)&data.username=qq&data.password=\(password)".data(using: .utf8)
        print("register_id=\(register_id), data= registration_id=\(register_id)&data.username=qq&data.password=\(password)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        
        task.resume()
    }
}
/*
class SecondViewController: UIViewController {
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    var auth: Bool?
    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    var db: OpaquePointer?
    
    class Data {
        var id: Int
        var domainName: String?
        var password: String
        
        init(id: Int, domainName: String?, password: String){
            self.id = id
            self.domainName = domainName
            self.password = password
        }
    }
    
    func readValues(){
        //first empty the list of heroes
        passwordData.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM Passwords"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        print("id, domain, password")
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let domainName = String(cString: sqlite3_column_text(stmt, 1))
            let password = String(cString: sqlite3_column_text(stmt, 2))
            
            //adding values to list
            passwordData.append(Data(id: Int(id), domainName: domainName, password: password))
            
            print("\(id), \(domainName), \(password)")
        }
    }
    
    var passwordData = [Data]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("PasswordDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Passwords (id INTEGER PRIMARY KEY AUTOINCREMENT, domainName TEXT, password TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
        
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    @IBOutlet weak var domainNameTextField: UITextField!
    @IBOutlet weak var passwordTextView: UITextView!
    @IBAction func findPassword(_ sender: UIButton) {
        //getting values from textfields
        let domainName = domainNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //validating that values are not empty
        if(domainName?.isEmpty)!{
            showAlertController("Missing domain name.")
            return
        }
        
        var context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authentication"
            self.auth = false
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                
                if success {
                    DispatchQueue.main.async {
                        //creating a statement
                        var stmt: OpaquePointer?
                        
                        var queryString : String
                        
                        //find if the domain name exists
                        queryString = "SELECT * FROM Passwords WHERE domainName = ?"
                        if sqlite3_prepare_v2(self.db, queryString, -1, &stmt, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                            print("error preparing SELECT: \(errmsg)")
                            return
                        }
                        if sqlite3_bind_text(stmt, 1, domainName, -1, self.SQLITE_TRANSIENT) != SQLITE_OK{
                            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                            print("failure binding domain name for SELECT: \(errmsg)")
                            return
                        }
                        
                        // domain name exists, update password
                        if sqlite3_step(stmt) == SQLITE_ROW {
                            let password = String(cString: sqlite3_column_text(stmt, 2))
                            
                            if sqlite3_step(stmt) == SQLITE_ROW {
                                print("error: find multiple domain name")
                                return
                            }
                            
                            let connectString = UserDefaults.standard.string(forKey: "connect string")
                            self.showAlertController("your password is:\n\(password), destination is: \(connectString)")
                            
                            return
                        }
                        else {
                            self.showAlertController("No corresbonding entry.")
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    return
                }
            }
        } else {
            self.showAlertController("QAQ")
            return
        }
    }
}

*/
