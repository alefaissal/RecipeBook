//
//  RecipesManager.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//


import UIKit
import RealmSwift

class RecipesManager: NSObject {
    
    static let shared = RecipesManager()
    
    private override init() {
        super.init()
        
    }
    
    func createCategory(title: String){
        let realm = try! Realm()
        let category = Category()
        category.title = title
        category.creationDate = Date()
        try! realm.write {
            realm.add(category)
            
        }
        //addRecipes(category: category, realm: realm)
    }
    
    
    func addRecipeToCategory(category: Category, recipeTitle: String){
        let realm = try! Realm()
        let recipe = Recipe()
        recipe.id = recipe.incrementID()
        recipe.title = recipeTitle
        recipe.creationDate = Date()
        do {
            try realm.write {
                category.recipes.append(recipe)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func AddFullRecipeToCategory(category: Category, recipe: Recipe){
        let realm = try! Realm()
        recipe.creationDate = Date()
        do {
            try realm.write {
                category.recipes.append(recipe)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func addItemtoShoppingList(title: String) {
        let realm = try! Realm()
        let item = ShoppingList()
        item.title = title
        item.creationDate = Date()
        do {
            try realm.write {
                realm.add(item)
            }
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    //fixed
    func deleteCategory(category: Category){
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    //fixed
    func deleteRecipe (recipe: Recipe){
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(recipe)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    //fixed
    func deleteShopItem (item:ShoppingList){
        let realm = try! Realm()
        do {
            try realm.write{
                realm.delete(item)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    //fixed
    func getAllCategories() -> [Category]?{
        let realm = try! Realm()
        let data = realm.objects(Category.self)
        return data.map({$0})
    }
    
    //fixed
    func getAllRecipes() -> [Recipe]? {
        let realm = try! Realm()
        let data = realm.objects(Recipe.self)
        return data.map({$0})
    }
    
    
    //fixed
    func getAllRecipesByCategory(category: Category) -> [Recipe]? {
        let recipes = category.recipes
        return recipes.map({$0})
    }
    
    
    
    //fixed
    func getAllShoppingList() ->[ShoppingList]?{
        let realm = try! Realm()
        let items = realm.objects(ShoppingList.self)
        return items.map({$0})
    }
    
    func getAllShoppingListByChecked(isChecked: Bool) ->[ShoppingList]?{
        let realm = try! Realm()
        let items = realm.objects(ShoppingList.self)
        let results = items.filter("isChecked = \(isChecked) ")
        let recipes = Array(results)
        return recipes 
    }
    
    
    
    //fixed
    func updateRecipe(recipe: Recipe, yield:String, ingredients:String, preparation: String, equipments: String, image: String) {
        let realm = try! Realm()
        do {
            try realm.write{
                recipe.yield = yield
                recipe.ingredients = ingredients
                recipe.preparation = preparation
                recipe.equipments = equipments
                recipe.updateDate = Date()
                recipe.image = image
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    //testing
    func updateRecipeDate(recipe: Recipe, date: Date) {
        let realm = try! Realm()
        do {
            try realm.write{
                recipe.creationDate = date
                recipe.updateDate = Date()
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func updateRecipe(recipe: Recipe){
        let realm = try! Realm()
        do {
            try realm.write{
                let cat = getCategoryByTitle(title: recipe.category.first!.title)
                realm.delete(recipe)
                cat.recipes.append(recipe)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
//    fixed
    func updateFav(recipe: Recipe, favorite: Bool) {
        let realm = try! Realm()
        do {
            try realm.write{
                recipe.isFavorite = favorite
            }
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func updateShopListCheck(item: ShoppingList, checked: Bool) {
        let realm = try! Realm()
        do {
            try realm.write{
                item.isChecked = checked
            }
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    
    //fixed
    func getAllFav() -> [Recipe]? {
        let realm = try!Realm()
        let data = realm.objects(Recipe.self)
        let results = data.filter("isFavorite = true ")
        let recipes = Array(results)
        return recipes
        
    }
    
    //fixed
    //[c] is to ignore case senibility
    func searchAll(searchWord: String) -> [Recipe]? {
        let realm = try! Realm()
        let data = realm.objects(Recipe.self)
        let results = data.filter("title CONTAINS[c]'\(searchWord)' OR yield CONTAINS[c] '\(searchWord)' OR ingredients CONTAINS[c] '\(searchWord)' OR preparation CONTAINS[c] '\(searchWord)' OR equipments CONTAINS[c] '\(searchWord)'")
        let recipes = Array(results)
        return recipes
    }
    
    func getCategoryByTitle(title: String) -> Category {
        let realm = try! Realm()
        let data = realm.objects(Category.self)
        let results = data.filter("title CONTAINS[c]'\(title)'")
        let category = Array(results)
        return category.first!
    }
    
    func dateFormater( date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let newDate = String(formatter.string(from:date))
        return newDate
    }
    
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(named).png").path)
        }
        return nil
    }
}

