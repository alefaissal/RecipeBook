//
//  CategTableViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import UIKit

class CategTableViewController: UITableViewController {
    
    var categoriesArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        loadData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData() {
        if let categories = RecipesManager.shared.getAllCategories() {
            categoriesArray = categories
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let addAlert = UIAlertController(title: "Add Category", message: "Enter the title of your new category", preferredStyle: .alert)
        addAlert.addTextField {(textField:UITextField) in textField.placeholder = "Category title"
        }
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler:{ (action) in
            if let title = addAlert.textFields?.first?.text {
                RecipesManager.shared.createCategory(title: title)
                self.loadData()
            }
            
        } ))
        
        self.present(addAlert, animated: true, completion: nil)
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoriesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath)

        let category = categoriesArray[indexPath.row]
        
        cell.textLabel?.text = category.title
        cell.detailTextLabel?.text = "Recipes: \(category.recipes.count)"

        return cell
    }

    
    // MARK: - Navigation
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showCatRecepies", sender: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let selectedCategoryIndexPath = self.tableView.indexPathForSelectedRow {
            let selectedCategory = categoriesArray[selectedCategoryIndexPath.row]
            let recipeTableVC = segue.destination as! RecipesTableViewController
            recipeTableVC.categoryObject = selectedCategory
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let addAlert = UIAlertController(title: "Delete Category", message: "If you delete, all data in this category will be lost. \n Including all recipes inside this category", preferredStyle: .alert)
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ (action) in
            if editingStyle == .delete {
                let categoryObjectToDelete = self.categoriesArray[indexPath.row]
                RecipesManager.shared.deleteCategory(category: categoryObjectToDelete)
                self.categoriesArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        } ))
        
        self.present(addAlert, animated: true, completion: nil)
        
    }
    

}
