//
//  RecipeViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-29.
//

import UIKit
import SwiftUI
import RealmSwift
import Vision

//Add two classes for images purposes
class RecipeViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var yieldTextField: UITextField!
    @IBOutlet weak var ingredientsTextField: UITextView!
    @IBOutlet weak var preparationTextField: UITextView!
    @IBOutlet weak var equipmentsTextField: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var creationDateTextField: UITextField!
    @IBOutlet weak var addPhotoOutlet: UIButton!
    
    @IBOutlet weak var favImage: UIButton!
    
    //Added for dropdown menu for categories
    var pickerViewForCat = UIPickerView()
    
    //Added for image picker
    var pickerForPhoto:UIImagePickerController!
    
    var categoryObject:Category! {
        didSet {
            self.configureView()
        }
    }
    
    var recipeObject:Recipe?
    
    var isFav = UserDefaults.standard.bool(forKey: "isFav")
    let realm = try! Realm()
    
    var imageName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // created a picker for this text field
        pickerViewForCat.delegate = self
        pickerViewForCat.dataSource = self
        categoryTextField.inputView = pickerViewForCat
        
        //created a picker to get images from library
        pickerForPhoto = UIImagePickerController()
        pickerForPhoto.sourceType = .photoLibrary
        pickerForPhoto.delegate = self
        
        self.configureView()
        print("Realm Address: \(realm.configuration.fileURL!)")
        
    }
   
    //Test doesn't work so far
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let addAlert = UIAlertController(title: "Information Chaged", message: "Do you want to save before go back, you will lose all info changed if not saved", preferredStyle: .alert)
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler:{ (action) in
                                            self.saveData()}))
        
        if let recipe = recipeObject{
            if (recipe.category.first?.title != categoryTextField.text) ||
                (recipe.ingredients != ingredientsTextField.text) ||
                (recipe.yield != yieldTextField.text) ||
                (recipe.preparation != preparationTextField.text) ||
                (recipe.equipments != equipmentsTextField.text){
                print("view will disapear")
                
                self.present(addAlert, animated: true, completion: nil)
                
            }
        }
    }

    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let categories = RecipesManager.shared.getAllCategories()
        return categories!.count
    }
    
    //picker for Category Text field - pass the options for the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categories = RecipesManager.shared.getAllCategories()
        return categories![row].title
    }
    
    //picker for category text field - when selected, what should do
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categories = RecipesManager.shared.getAllCategories()
        categoryTextField.text = categories![row].title
        categoryTextField.resignFirstResponder()
    }
    
    func configureView(){
        self.navigationItem.title = recipeObject?.title
        categoryTextField?.text = recipeObject?.category.first?.title
        let createdDate = RecipesManager.shared.dateFormater(date: recipeObject?.creationDate ?? Date())
        creationDateTextField?.text = createdDate
        yieldTextField?.text = recipeObject?.yield != nil ? recipeObject?.yield : "Yield goes here"
        ingredientsTextField?.text = recipeObject?.ingredients != nil ? recipeObject?.ingredients : "Ingredients go here"
        preparationTextField?.text = recipeObject?.preparation != nil ? recipeObject?.preparation : "Preparation goes here"
        equipmentsTextField?.text = recipeObject?.equipments != nil ? recipeObject?.equipments : "Equipments go here"
        imageView?.image = recipeObject?.image != nil || recipeObject?.image != "" ? getSavedImage(named: "\(recipeObject?.image).png"): UIImage(systemName: "photo")
        
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
    
    func saveData(){
        if let recipe = recipeObject {
            if categoryTextField.text != recipe.category.first?.title {
                let recipeTitle = recipe.title!
                let recipeYield = recipe.yield!
                let recipeCreationDate = recipe.creationDate
                let recipeIngred = recipe.ingredients!
                let recipePrep = recipe.preparation!
                let recipEquip = recipe.equipments!
                let recipeFav = recipe.isFavorite
                let recipeImage = recipe.image == imageName ? recipe.image : imageName
                RecipesManager.shared.deleteRecipe(recipe: recipe)
                
                let newCatTitle = categoryTextField.text
                let categoryToBeAdded = RecipesManager.shared.getCategoryByTitle(title: newCatTitle!)
                let newRecipe = Recipe()
                newRecipe.title = recipeTitle
                newRecipe.yield = recipeYield
                newRecipe.ingredients = recipeIngred
                newRecipe.preparation = recipePrep
                newRecipe.isFavorite = recipeFav
                newRecipe.equipments = recipEquip
                newRecipe.image = recipeImage
                
                RecipesManager.shared.AddFullRecipeToCategory(category: categoryToBeAdded, recipe: newRecipe)

                RecipesManager.shared.updateRecipeDate(recipe: newRecipe, date: recipeCreationDate)
               
            } else {
                let yield = yieldTextField.text
                let ingredients = ingredientsTextField.text
                let preparation = preparationTextField.text
                let equipment = equipmentsTextField.text
                let image = recipe.image == imageName ? recipe.image : imageName
                
                RecipesManager.shared.updateRecipe(recipe: recipe, yield: yield!, ingredients: ingredients!, preparation: preparation!, equipments: equipment!, image: image ?? "")
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveData()
        //Go back when save button is pressed
        self.navigationController?.popViewController(animated: true)
        
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
    
  
    
    @IBAction func changeImgButton(_ sender: Any) {
        pickerForPhoto.modalPresentationStyle = .overFullScreen
        self.modalPresentationStyle = .pageSheet
        present(pickerForPhoto, animated: true)
        
        
    }
    
    //to present image from photo library into the ViewController
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = img
        if let recipe = recipeObject {
            imageName = "\(recipe.title)\(recipe.ingredients)\(recipe.preparation)"
        }
        savePhoto(image: imageView.image!)
    }
 
    //To save image in document Directory
    func savePhoto(image: UIImage){
        let data = image.jpegData(compressionQuality: 0.75) ?? image.pngData()
        let directory = try? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) as [URL]
        do {
            if let recipe = recipeObject{
                try data!.write(to: directory![0].appendingPathComponent("\(recipe.image)).png"))
            }
            
        } catch {
            print(error.localizedDescription)
            
        }
        
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    
}
