import Foundation

struct DotinProfile {

    var name: String = ""
    var attributes = [DotinAttribute]()
	init(fromDictionary dictionary: [String:Any]) {
        self.attributes = [DotinAttribute]()
        if let attributesArray = dictionary["attributes"] as? [[String:Any]]{
            for dic in attributesArray{
                let value = DotinAttribute(fromDictionary: dic)
                self.attributes.append(value)
            }
        }
        self.name = dictionary["name"] as? String ?? ""
	}

}

struct DotinAttribute {

    var groups = [DotinGroups]()
    var label : String = ""
    var name : String = ""

    init(fromDictionary dictionary: [String:Any]) {
        self.groups = [DotinGroups]()
        if let groupsArray = dictionary["groups"] as? [[[String:Any]]] {
            for groupDic in groupsArray {
                for dic in groupDic {
                    let group = DotinGroups.init(fromDictionary: dic)
                    groups.append(group)
                }
            }
        }
        label = dictionary["label"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
    }

}

struct DotinGroups {
    var name: String
    var value: String

    init(fromDictionary dictionary: [String:Any]) {
        self.name = dictionary["name"] as? String ?? ""
        if let valueArr = dictionary["value"] as? [String],
            let valueText = valueArr.first {
            self.value = valueText
        } else {
            self.value = ""
        }
    }
}

