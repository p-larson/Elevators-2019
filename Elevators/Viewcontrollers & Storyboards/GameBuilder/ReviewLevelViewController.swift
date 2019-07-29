//
//  ReviewLevelViewController.swift
//  Elevators
//
//  Created by Peter Larson on 7/12/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import ElCore

public final class ReviewLevelViewController: FormViewController {
    
    public static let review_segue = "review"
    
    public var model: LevelModel!
    
    public var needsSave = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        form
        +++ Section("Level Properties")
            <<< TextRow("Name") {
                $0.title = "Name"
                $0.value = model.name
                
                let rule = RuleClosure<String>(closure: { (input) -> ValidationError? in
                    if let name = input {
                        return LevelsLoader.shared.containsLevel(named: name) ? ValidationError(msg: "Name Already Taken") : nil
                    } else {
                        return nil
                    }
                })
                
                $0.add(rule: rule)
                
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }.onChange({ (row) in
                if row.isValid {
                    self.model.name = row.value ?? self.model.name
                    self.needsSave = true
                }
            })
            <<< IntRow() {
                $0.title = "Number"
                $0.value = self.model.number
                $0.validationOptions = .validatesOnChange
                
                let rule = RuleClosure<Int>(closure: { (input) -> ValidationError? in
                    return Bool.random() ? ValidationError(msg: "Level Number already Taken! \(input!)") : nil
                })
                
                $0.add(rule: rule)
                
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }.onChange { (row) in
                if row.isValid {
                    self.model.number = row.value ?? self.model.number
                    self.needsSave = true
                }
            }
            <<< IntRow("firstfloor") {
                $0.title = "First Floor"
                $0.value = self.model.firstFloor
                $0.validationOptions = .validatesOnChange
                
                let rule = RuleClosure<Int>(closure: { (input) -> ValidationError? in
                    return self.model.floorWith(number: input!) == nil ? ValidationError(msg: "Floor \(input!) does not exist!") : nil
                })
                
                $0.add(rule: rule)
                
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }.onChange({ (row) in
                    if row.isValid {
                        self.model.firstFloor = row.value ?? self.model.firstFloor
                        self.needsSave = true
                    }
                })
            +++ Section("Stars")
            <<< DecimalRow() {
                $0.title = "Time (in seconds)"
                $0.placeholder = "∞"
                $0.value = self.model.time
                $0.validationOptions = .validatesOnChange
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
            }.onChange({ (row) in
                self.model.time = row.value
                self.needsSave = true
            })
            <<< IntRow() {
                $0.title = "Moves"
                $0.placeholder = "∞"
                $0.value = self.model.moves
                $0.validationOptions = .validatesOnChange
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
            }.onChange({ (row) in
                self.model.moves = row.value
                self.needsSave = true
            })
            <<< IntRow() {
                $0.title = "Gem Pickups"
                $0.placeholder = "#"
                $0.value = self.model.pickups
                $0.validationOptions = .validatesOnChange
                $0.add(rule: RuleGreaterOrEqualThan(min: 0))
            }.onChange({ (row) in
                self.model.pickups = row.value
                self.needsSave = true
            })
            +++ Section("Level Info")
            <<< LabelRow() {
                $0.title = "Floors"
                $0.value = String(self.model.floors.count)
            }
            <<< LabelRow() {
                $0.title = "Elevators"
                
                var x = 0
                
                self.model.floors.forEach({ (floor) in
                    x+=floor.baseElevators.count
                })
                
                $0.value = String(x)
            }
            <<< LabelRow() {
                $0.title = "Coins"
                $0.value = "_"
            }
            <<< LabelRow() {
                $0.title = "Disk Size"
                
                let format = ByteCountFormatter()
                format.allowedUnits = [.useGB, .useMB, .useKB]
                
                do {
                    guard let url = LevelsLoader.shared.levelURL(named: model.name) else {
                        return
                    }
                    let data = try Data(contentsOf: url)
                    
                    $0.value = format.string(fromByteCount: Int64(data.count))
                } catch {
                    return
                }
            }
            +++ Section("Signature")
            <<< TextRow() {
                $0.title = "Author"
                $0.placeholder = "?"
                $0.value = self.model.author
            }.onChange({ (row) in
                self.model.author = row.value
                self.needsSave = true
            })
            <<< TextRow() {
                $0.title = "Instagram"
                $0.placeholder = "optional"
                $0.value = self.model.instagram
            }.onChange({ (row) in
                self.model.instagram = row.value
                self.needsSave = true
            })
            <<< TextRow("lastSave") {
                $0.title = "Last Save"
                $0.placeholder = "?"
                $0.disabled = true
            }.cellUpdate({ (cell, row) in
                row.value = self.model.lastSaved?.timeAgoSinceDate()
            }).onCellSelection({ (cell, row) in
                row.updateCell()
            })
            +++ Section("Controls")
            <<< ButtonRow() {
                $0.title = "Test"
            }
            <<< ButtonRow() {
                $0.title = "Save"
            }.onCellSelection({ (cell, row) in
                let old = self.model.lastSaved
                self.model.lastSaved = Date()
                if LevelsLoader.shared.save(encodable: self.model, as: self.model.name, overwrites: true) {
                    self.needsSave = false
                    print("saved", self.model as Any)
                    self.form.allRows.forEach({ (row) in
                        row.reload()
                        row.updateCell()
                    })
                    
                } else {
                    self.model.lastSaved = old
                    print("could not save")
                }
            })
            <<< ButtonRow() {
                $0.title = "Close"
            }.onCellSelection({ (cell, row) in
                if self.needsSave {
                    let alert = UIAlertController(title: "Changes haven't been saved.", message: "Are you sure you want to close?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
                        alert in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
            +++ Section("Destructive Zone")
            <<< ButtonRow() {
                $0.title = "Delete"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .red
            }).onCellSelection({ (cell, row) in
                if (self.form.rowBy(tag: "safety") as? SwitchRow)?.value == true {
                    return // Safety is On
                }
                // Confirm
                let alert = UIAlertController(title: "Are you sure you want to delete this level?", message: "'\(self.model.name)' will be lost forever...\n(A long time)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                    alert in
                    
                    if LevelsLoader.shared.delete(named: self.model.name) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
            })
            <<< SwitchRow("safety") {
                $0.title = "Safety"
                $0.value = true
            }
    }
}
