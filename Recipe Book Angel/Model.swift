//
//  Model.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import Foundation
import RealmSwift



class Recipe: Object {
    @objc dynamic var creationDate = Date()
    @objc dynamic var title: String? = ""
    @objc dynamic var yield: String? = ""
    @objc dynamic var ingredients: String? = ""
    @objc dynamic var preparation: String? = ""
    //@objc dynamic var photo: ? = ""
    @objc dynamic var isFavorite: Bool = false
    
    let category = LinkingObjects(fromType: Category.self, property: "recipes")
}

class Category: Object {
    @objc dynamic var title = ""
    @objc dynamic var creationDate = Date()
    
    let recipes = List<Recipe>()
}

class ShoppingList: Object {
    @objc dynamic var title: String? = ""
    @objc dynamic var creationDate = Date()
    
}


