import Foundation
extension Optional {
    func asStringOrEmpty() -> String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case _:
            return ""
        }
    }
    func aIntOrEmpty() -> Int {
        switch self {
        case .some(let value):
            print(value)
            return value as! Int
        case _:
            return 0
        }
    }
    func aDoubleOrEmpty() -> Double {
        switch self {
        case .some(let value):
            //print("aDoubleOrEmpty : \(value)")
            return Double(String(describing: value))!
        case _:
            return 0.0
        }
    }
    
    func asStringOrNilText() -> String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case _:
            return "(nil)"
        }
    }
}
