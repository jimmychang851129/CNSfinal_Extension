//
//  FirstViewController.swift
//  CNS final
//
//  Created by 林品諺 on 2019/6/6.
//  Copyright © 2019 林品諺. All rights reserved.
//

import UIKit
import SQLite3

class FirstViewController: UIViewController {
    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
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
    
    var passwordData = [Data]()
    
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
    
    var db: OpaquePointer?
    
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
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var domainNameTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBAction func addPassword(_ sender: UIButton) {
        label.text=""
        
        //getting values from textfields
        let domainName = domainNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        //validating that values are not empty
        if(domainName?.isEmpty)!{
            label.text="Missing domain name."
            return
        }
        
        if(password?.isEmpty)!{
            label.text="Missing password."
            return
        }

        label.text = "Adding the password..."
        //creating a statement
        var stmt: OpaquePointer?
        
        var queryString : String
        
        //find if the domain name exists
        queryString = "SELECT * FROM Passwords WHERE domainName = ?"
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing SELECT: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 1, domainName, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding domain name for SELECT: \(errmsg)")
            return
        }
        
        // domain name exists, update password
        if sqlite3_step(stmt) == SQLITE_ROW {
            let id = sqlite3_column_int(stmt, 0)
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                print("error: find multiple domain name")
                return
            }
            
            queryString = "UPDATE Passwords SET password = ? WHERE id = ?"
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing UPDATE: \(errmsg)")
                return
            }
            if sqlite3_bind_text(stmt, 1, password, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding domain name for UPDATE: \(errmsg)")
                return
            }
            if sqlite3_bind_int(stmt, 2, id) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding ID for UPDATE: \(errmsg)")
                return
            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure UPDATE: \(errmsg)")
                return
            }
            
            label.text = "Password updated successfully!"
            readValues()
            return
        }
        
        //the insert query
        queryString = "INSERT INTO Passwords (domainName, password) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, domainName, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding domain name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, password, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding domain password: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting password: \(errmsg)")
            return
        }
        
        //emptying the textfields
        domainNameTextField.text=""
        passwordTextField.text=""
        
        label.text="Password is succesfully added!"
        
        readValues()
    }
    
    
    @IBAction func ClearPassword(_ sender: UIButton) {
        let queryString = "DELETE FROM Passwords"
        if sqlite3_exec(db, queryString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error deleting table: \(errmsg)")
        }
        label.text = "Clear success!"
        
        readValues()
    }
    
}

