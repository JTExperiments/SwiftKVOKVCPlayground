// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var dict : NSMutableDictionary = [
    "name":"James",
    "age":26,
]


class Observer : NSObject {

    var dict : NSMutableDictionary?

    init(dictionary: NSMutableDictionary) {
        super.init()
        self.dict = dictionary
        self.addObserver(self, forKeyPath:"dict.name" , options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {

        println("change \(change)")
    }
}

extension NSString {

    func toColor() -> UIColor {
        let scanner = NSScanner(string: self)
        var rgbValue : UInt32 = 0
        scanner.scanLocation = 0
        scanner.scanHexInt(&rgbValue)

        let red = CGFloat(((rgbValue & 0xFF0000) >> 16) / 255)
        let green = CGFloat(((rgbValue & 0xFF00) >> 8) / 255)
        let blue = CGFloat((rgbValue & 0xFF) / 255)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

}

class InfoValueTransformer : NSValueTransformer {

    typealias TransformationHandler = (AnyObject? -> AnyObject?)
    lazy var info : NSMutableDictionary = {
        return NSMutableDictionary()
    }()

    var transformationHandler : TransformationHandler?

    override func transformedValue(value: AnyObject?) -> AnyObject? {
        var transformed : AnyObject?
        if let transformationHandler = self.transformationHandler {
            transformed = transformationHandler(value)
        }
        return transformed
    }

    init(forName name: String) {
        super.init()
        NSValueTransformer.setValueTransformer(self, forName: name)
    }
}

extension NSDate {
    func shortDate() -> String? {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle

        return dateFormatter.stringFromDate(self)
    }

    func format(format: String) -> String? {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
}

extension NSArray {

    func _formatForKeyPath(keyPath:String) -> NSArray {

        let components = NSMutableArray(array: keyPath.componentsSeparatedByString("."))

        let first = components.firstObject! as String

        components.removeObjectAtIndex(0)
        let second = components.componentsJoinedByString(".")


        var array = NSMutableArray()
        for date in self {
            if let date = date as? NSDate {
                array.addObject(date.format(first)!)
            }
        }
        return array.valueForKeyPath("self.\(second)") as NSArray
    }

    func _uppercaseForKeyPath(keyPath:String) -> NSArray {
        let path = "\(keyPath)"
        let array = self.valueForKeyPath(path) as NSArray
        return array.valueForKeyPath("self.uppercaseString") as NSArray
    }
}

let array : NSArray = [["color":"ffffff"], ["color":"000000"]]

array.valueForKeyPath("color.toColor")


let dates : NSArray = [["date":NSDate()], ["date":NSDate()]]

dates.valueForKeyPath("date.@format.yyyy/mm/dd HH:MMM:ss.uppercaseString.lowercaseString")


