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
    @IBOutlet weak var scrollView: UIScrollView!
    
    
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
    var newRecipe: Recipe?
    
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
        
        //Listen for keyboard events
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//
        hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        print("Realm Address: \(realm.configuration.fileURL!)")

    }
    
    
    //Method to remove Observer for keyboard
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveData()
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
        if let recipe = recipeObject {
        self.navigationItem.title = recipeObject?.title
        categoryTextField?.text = recipeObject?.category.first?.title
        let createdDate = RecipesManager.shared.dateFormater(date: recipeObject?.creationDate ?? Date())
        creationDateTextField?.text = createdDate
        yieldTextField?.text = recipeObject?.yield != nil ? recipeObject?.yield : "Yield goes here"
        ingredientsTextField?.text = recipeObject?.ingredients != nil ? recipeObject?.ingredients : "Ingredients go here"
        preparationTextField?.text = recipeObject?.preparation != nil ? recipeObject?.preparation : "Preparation goes here"
        equipmentsTextField?.text = recipeObject?.equipments != nil ? recipeObject?.equipments : "Equipments go here"
            if let image = recipeObject?.image {
                imageView?.image = recipeObject?.image != nil && recipeObject?.image != "" ? RecipesManager.shared.getSavedImage(named: "\(image)"): UIImage(systemName: "photo")
            }
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
                
                //Copy all info from previous recipe
                let recipeCreationDate = recipe.creationDate
                let recipeTitle = recipe.title!
                let recipeYield = recipe.yield!
                let recipeIngred = recipe.ingredients!
                let recipePrep = recipe.preparation!
                let recipEquip = recipe.equipments!
                let recipeFav = recipe.isFavorite
                let recipeImage = recipe.image!
                
                //Delete recipe
                RecipesManager.shared.deleteRecipe(recipe: recipe)
                
                //Get category title to add recipe
                let newCatTitle = categoryTextField.text
                let categoryToBeAdded = RecipesManager.shared.getCategoryByTitle(title: newCatTitle!)
                
                //Create new Recipe object
                let newRecipe = Recipe()
                newRecipe.title = recipeTitle
                newRecipe.yield = recipeYield
                newRecipe.ingredients = recipeIngred
                newRecipe.preparation = recipePrep
                newRecipe.isFavorite = recipeFav
                newRecipe.equipments = recipEquip
                newRecipe.image = recipeImage
                
                //Add recipe to category
                RecipesManager.shared.AddFullRecipeToNewCategory(category: categoryToBeAdded, recipe: newRecipe)
                
                //restore old creation date to this recipe
                RecipesManager.shared.updateRecipeDate(recipe: newRecipe, date: recipeCreationDate)
              
            } else  if yieldTextField.text != recipe.yield || ingredientsTextField.text != recipe.ingredients
                        || preparationTextField.text != recipe.preparation || equipmentsTextField.text != recipe.equipments {
                let yield = yieldTextField.text
                let ingredients = ingredientsTextField.text
                let preparation = preparationTextField.text
                let equipment = equipmentsTextField.text
                
                RecipesManager.shared.updateRecipe(recipe: recipe, yield: yield!, ingredients: ingredients!, preparation: preparation!, equipments: equipment!)
            }
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
            RecipesManager.shared.updateImage(recipe: recipe, image: "\(recipe.id)")
        }
        savePhoto(image: imageView.image!)
    }
 
    //To save image in document Directory
    func savePhoto(image: UIImage){
        let data = image.jpegData(compressionQuality: 0.75) ?? image.pngData()
        let directory =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) as [URL]
        do {
           if let recipe = recipeObject {
            try data!.write(to: directory[0].appendingPathComponent("\(recipe.id).png"))
            }
            
        } catch {
            print(error.localizedDescription)
            
        }
        
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(named).png").path)
        }
        return nil
    }
    
    //Methods to make keyboard push text up when showing
    func hideKeyboard() {
//        ingredientsTextField.resignFirstResponder()
//        preparationTextField.resignFirstResponder()
//        equipmentsTextField.resignFirstResponder()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
//    @objc func keyboardWillChange(notification: Notification){
//        print("Keyboard will show: \(notification.name.rawValue)")
//        var yValue:CGFloat = 0;
//        if ingredientsTextField.isFirstResponder {
//            yValue = -7
//            print("got it 1")
//        }
//        if preparationTextField.isFirstResponder {
//            yValue = -118
//            print("got it 2")
//        }
//        if equipmentsTextField.isFirstResponder {
//            yValue = -230
//            print("got it 3")
//        }
//        view.frame.origin.y = yValue
//
//
//    }
//
    @objc func dismissKeyboard(){
        view.endEditing(true)
//        view.frame.origin.y = 0
    }
    
    //Func to scroll screen when keyboard shows up
    @objc func keyboardWillShow(notification:NSNotification) {
        if ingredientsTextField.isFirstResponder {
            scrollView.contentOffset = CGPoint(x: 0, y: 30)
        }
        if preparationTextField.isFirstResponder {
            scrollView.contentOffset = CGPoint(x: 0, y: 140)
        }
        if equipmentsTextField.isFirstResponder {
            scrollView.contentOffset = CGPoint(x: 0, y: 250)
        }
        
        
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height - 50
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    
    
}
