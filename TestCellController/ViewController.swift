//
//  ViewController.swift
//  TestCellController
//
//  Created by James Tang on 19/9/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


class Observer : NSObject {

    typealias ChangeHandler = (String!, [NSObject : AnyObject]) -> ()

    weak var object : NSObject? {
        willSet {
            unobserve()
        }
        didSet {
            if let keyPaths = keyPaths {
                for keyPath in keyPaths {
                    self.object?.addObserver(self, forKeyPath:"\(keyPath)", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, context: nil)
                }
            }
        }
    }
    var keyPaths : [String]?
    var handler : ChangeHandler?

    func observe(object: NSObject, keyPaths theKeyPaths: [String]?, handler changeHandler:ChangeHandler?) {
        self.keyPaths = theKeyPaths
        self.handler = changeHandler
        self.object = object
    }

    func unobserve() {
        if let keyPaths = self.keyPaths {
            for keyPath in keyPaths {
                self.object?.removeObserver(self, forKeyPath: "\(keyPath)")
            }
        }
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {

        if let handler = self.handler {
            handler(keyPath, change)
        }

    }

    deinit {
        self.unobserve()
    }
}

class Binder : NSObject {
    weak var host : NSObject!
    var observer = Observer()
    var object : NSObject? {
        set {
            self.observer.object = object
        }
        get {
            return self.observer.object
        }
    }

    func bind(object: NSObject, keyPaths theKeyPaths: NSArray?) {

        var newKeyPaths = [String]()
        var map = [String:AnyObject]()

        if let theKeyPaths = theKeyPaths {
            for i in 0..<theKeyPaths.count {

                if let string = theKeyPaths[i] as? String {
                    newKeyPaths.append(string)
                    map[string] = string
                } else if let dict = theKeyPaths[i] as? [String:AnyObject] {
                    for (key, value) in dict {
                        newKeyPaths.append(key)
                        map[key] = value
                    }
                }
            }
        }

        self.observer.observe(object, keyPaths: newKeyPaths, handler: {
            fromKeyPath, change in

            let toKey : AnyObject? = map[fromKeyPath]
            let toKeyPath : String = toKey as String!

            if self.host.respondsToSelector(Selector(toKeyPath)) {
                self.host.setValue(object.valueForKeyPath(fromKeyPath), forKeyPath:toKeyPath)
            }
        })
    }

    init(_ host: NSObject) {
        super.init()
        self.host = host
    }
}


class Info : NSObject {
    dynamic var sex : String?
}

class TableItem : NSObject {
    dynamic var title : String?
    dynamic var subtitle : String?
    dynamic var info = Info()

    init(title: String) {
        self.title = title
    }
}



class ViewController: UITableViewController {


    lazy var items : NSMutableArray = {
        return NSMutableArray()
    }()
    var observer : Observer?
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        items.addObject(TableItem(title: "A"))
        items.addObject(TableItem(title: "B"))
        items.addObject(TableItem(title: "C"))
        items.addObject(TableItem(title: "D"))
        items.addObject(TableItem(title: "E"))
        items.addObject(TableItem(title: "A"))
        items.addObject(TableItem(title: "B"))
        items.addObject(TableItem(title: "C"))
        items.addObject(TableItem(title: "D"))
        items.addObject(TableItem(title: "E"))
        items.addObject(TableItem(title: "A"))
        items.addObject(TableItem(title: "B"))
        items.addObject(TableItem(title: "C"))
        items.addObject(TableItem(title: "D"))
        items.addObject(TableItem(title: "E"))
        items.addObject(TableItem(title: "A"))
        items.addObject(TableItem(title: "B"))
        items.addObject(TableItem(title: "C"))
        items.addObject(TableItem(title: "D"))
        items.addObject(TableItem(title: "E"))



        let item = self.items[0] as TableItem

        item.info.sex = "undefined"

        delay(1, {
            println("delay 1")

            item.title = "CC"
            item.subtitle = "something"
            item.info.sex = "M"
        })


        delay(3, {
            println("delay 3")
            item.title = "ZZ"
            item.subtitle = "nothing"
            item.info.sex = "F"
        })


        delay(5, {

            println("delay 5")

            self.tableView.beginUpdates()
            self.items.removeObjectAtIndex(0)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)

            self.items.insertObject(item, atIndex: 3)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.endUpdates()

        })


        delay(7, {
            println("delay 7")

            item.title = "AA"
            item.subtitle = "ccccc"

        })
        

//        delay(2, {
//            println("delay 2")
//
//            var array = self.mutableArrayValueForKey("items")
//            array.removeObjectAtIndex(0)
//            array.insertObject(10, atIndex: 2)
//        })


        /*
        items.addObject(1)
        items.addObject(2)
        items.addObject(3)
        items.addObject(4)
        items.addObject(5)

        self.observer = Observer(object: self, keyPaths: ["items"])


        delay(1, {
            println("delay 1")
            self.items.removeObjectAtIndex(0)
        })

        delay(2, {
            println("delay 2")

            var array = self.mutableArrayValueForKey("items")
            array.removeObjectAtIndex(0)
            array.insertObject(10, atIndex: 2)
        })
*/

//
//        self.mutableArrayValueForKey("items")
//

        /*
        var dict : NSMutableDictionary = NSMutableDictionary(dictionary: [
            "name":"James",
            "age":26,
            "skills":["ios":"great", "design":"good"],
            ], copyItems: true)

        self.observer = Observer(object: dict, keyPaths: ["name", "skills.ios"])

        NSMutableDictionary.keyPathsForValuesAffectingValueForKey(<#key: String!#>)

        delay(1, {
            println("delay 1")
            var skills = dict["skills"]?.mutableCopy() as NSMutableDictionary
            skills.setValue("cool", forKeyPath: "ios")
        })

        delay(2, {
            println("delay 2")
            self.observer = nil
        })

        delay(3, {
            println("delay 3")
            dict["name"] = "b"
        })
        */
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let item = self.items[indexPath.row] as TableItem

        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as ObservableTableViewCell

//        cell.observer.observe(item, keyPaths: ["info.sex"], handler: {
//            keyPath, change in
//            if keyPath == "title" {
//                cell.textLabel?.text = item.title
//            }
//            if keyPath == "info.sex" {
//                println("title (\(indexPath.row)):\(item.title) -> \(item.subtitle)")
//                cell.detailTextLabel?.text = item.info.sex ?? " "
//            }
//            return
//        })

        cell.binder.bind(item, keyPaths: ["title", ["info.sex": "subtitle"]])

        return cell
    }


}


class ObservableTableViewCell : UITableViewCell {
    var observer : Observer!

    @IBInspectable var title : String? {
        didSet {
            self.textLabel?.text = title
        }
    }
    @IBInspectable var subtitle : String? {
        didSet {
            self.detailTextLabel?.text = subtitle
        }
    }

    var binder : Binder!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observer = Observer()
        binder = Binder(self)
    }

    override func prepareForReuse() {
        observer.object = nil
        binder.object = nil
    }
}
