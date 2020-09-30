//
//  RecipeViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-29.
//

import UIKit
import SwiftUI
import RealmSwift

class RecipeViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var yieldTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextView!
    @IBOutlet weak var preparationTextField: UITextView!
    
    @IBOutlet weak var favImage: UIButton!
    
    var categoryObject:Category! {
        didSet {
            self.configureView()
        }
    }
    
    var recipeObject:Recipe?
    
    var isFav = UserDefaults.standard.bool(forKey: "isFav")
    let realm = try! Realm()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
       
        print("Realm Address: \(realm.configuration.fileURL!)")
    }
    
    func configureView(){
        self.navigationItem.title = recipeObject?.title
        yieldTextField?.text = recipeObject?.yield != nil ? recipeObject?.yield : "Yield goes here"
        ingredientsTextField?.text = recipeObject?.ingredients != nil ? recipeObject?.ingredients : "Ingredients go here"
        preparationTextField?.text = recipeObject?.preparation != nil ? recipeObject?.preparation : "Preparation goes here"
        if let recipe = recipeObject {
            let fav = recipe.isFavorite
            isFav = fav
            let imageConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            if fav {
                let image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
                favImage!.setImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "heart", withConfiguration: imageConfig)
                favImage!.setImage(image, for: .normal)
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let recipe = recipeObject {
            
            let yield = yieldTextField.text
            let ingredients = ingredientsTextField.text
            let preparation = preparationTextField.text
            RecipesManager.shared.updateRecipe(recipe: recipe, yield: yield!, ingredients: ingredients!, preparation: preparation!)
        }
    }
    
    @IBAction func favButton(_ sender: UIButton) {
        isFav = !isFav
        if isFav {
            let imageConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            let image = UIImage(systemName: "heart.fill", withConfiguration: imageConfig)
            sender.setImage(image, for: .normal)
        } else {
            let imageConfig = UIImage.SymbolConfiguration(textStyle: .largeTitle)
            let image = UIImage(systemName: "heart", withConfiguration: imageConfig)
            sender.setImage(image, for: .normal)
        }
        print("Print from RecipeViewController action favButton: \(isFav)")
        if let recipe = recipeObject {
            let favorite = isFav
            RecipesManager.shared.updateFav(recipe: recipe, favorite: favorite)
        }
        
        UserDefaults.standard.set(isFav, forKey: "isFav")
        UserDefaults.standard.synchronize()
    }
    
    

}
