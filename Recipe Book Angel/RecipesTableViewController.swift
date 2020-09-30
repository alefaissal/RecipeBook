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
                self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
        
        let recipeObject = recipesArray[indexPath.row]
        
        cell.textLabel?.text = recipeObject.title

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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recipeObjectToDelete = recipesArray[indexPath.row]
            RecipesManager.shared.deleteRecipe(recipe: recipeObjectToDelete)
            recipesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    
    
    

}
