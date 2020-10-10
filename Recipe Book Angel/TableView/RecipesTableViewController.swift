//
//  RecipesTableViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import UIKit

class RecipesTableViewController: UITableViewController {
    
    var categoryObject:Category? {
        didSet {
            self.configureView()
        }
    }
    
    var recipesArray = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func configureView() {
        self.navigationItem.title = categoryObject?.title
        loadData()
    }
    
    func loadData() {
        if let category = categoryObject {
            if let recipes = RecipesManager.shared.getAllRecipesByCategory(category: category) {
                recipesArray = recipes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //TODO this function should move to another page where all info about the new recipe can be created
    @IBAction func addRecipe(_ sender: Any) {
        
        let addAlert = UIAlertController(title: "Add Recipe", message: "Enter the title of your new recipe", preferredStyle: .alert)
        addAlert.addTextField {(textField:UITextField) in textField.placeholder = "Recipe title"
        }
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler:{ (action) in
            if let category = self.categoryObject {
                if let title = addAlert.textFields?.first?.text {
                    RecipesManager.shared.addRecipeToCategory(category: category, recipeTitle: title)
                    self.loadData()
                }
            }
            
            
        } ))
        
        self.present(addAlert, animated: true, completion: nil)
        
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeViewCell
        
        let recipeObject = recipesArray[indexPath.row]
        
        let updated = RecipesManager.shared.dateFormater(date: recipeObject.updateDate)
        
        cell.recipeTitleLabel.text = recipeObject.title
        cell.recipeSubTitleLabel.text = "Yield: \(recipeObject.yield!), updated: \(updated)"
        cell.recipeImageView.image = recipeObject.image != nil && recipeObject.image != "" ? RecipesManager.shared.getSavedImage(named: "\(recipeObject.image ?? "")"): UIImage(systemName: "photo")
        

        return cell
    }

    
    // MARK: - Navigation
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        performSegue(withIdentifier: "showRecipe", sender: nil)
    }
     
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let recipeVC = segue.destination as! RecipeViewController
        
        recipeVC.categoryObject = categoryObject
        recipeVC.navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        //Here is to display, depending on the identifier of the segue
        if segue.identifier == "showRecipe" {
            if let selectedNoteIndexPath = self.tableView.indexPathForSelectedRow {
                let recipeObject = recipesArray[selectedNoteIndexPath.row]
                recipeVC.recipeObject = recipeObject
            }
        }
        
    }
    
    //To create and use the Edit and DELETE button in each cell of the table
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete"){(action, swipeButtonView, completetion) in
            
            let addAlert = UIAlertController(title: "Delete Recipe", message: "If you delete, all data in this recipe will be lost.", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            addAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ (action) in
                
                let recipeObjectToDelete = self.recipesArray[indexPath.row]
                RecipesManager.shared.deleteRecipe(recipe: recipeObjectToDelete)
                self.recipesArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } ))
            
            self.present(addAlert, animated: true, completion: nil)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit"){(action, swipeButtonView, completetion) in

            let addAlert = UIAlertController(title: "Change Recipe Title", message: "Type new title to this recipe", preferredStyle: .alert)
            addAlert.addTextField {(textField:UITextField) in textField.placeholder = "Recipe title"
            }
            addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler:{ (action) in
            let recipeToChange = self.recipesArray[indexPath.row]
            if let title = addAlert.textFields?.first?.text {
                RecipesManager.shared.updateRecipeTitle(recipe: recipeToChange, title: title)
                self.loadData()
            }
            completetion(true)
            }))
            
            self.present(addAlert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        edit.backgroundColor = UIColor.blue
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    
    
}
