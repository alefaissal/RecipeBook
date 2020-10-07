//
//  Model.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import Foundation
import RealmSwift



class Recipe: Object {
    @objc dynamic var id = Int()
    @objc dynamic var creationDate = Date()
    @objc dynamic var updateDate = Date()
    @objc dynamic var title: String? = ""
    @objc dynamic var yield: String? = ""
    @objc dynamic var ingredients: String? = ""
    @objc dynamic var preparation: String? = ""
    @objc dynamic var equipments: String? = ""
    @objc dynamic var image: String? = ""
    @objc dynamic var isFavorite: Bool = false
    
    var category = LinkingObjects(fromType: Category.self, property: "recipes")
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int{
        let realm = try! Realm()
        if let retNext = realm.objects(Recipe.self).sorted(byKeyPath: "id").last?.id {
            return retNext + 1
        }else{
            return 1
        }
    }

}


class Category: Object {
    @objc dynamic var title = ""
    @objc dynamic var creationDate = Date()
    
    let recipes = List<Recipe>()
}

class ShoppingList: Object {
    @objc dynamic var title: String? = ""
    @objc dynamic var creationDate = Date()
    @objc dynamic var isChecked: Bool = false
    
}


