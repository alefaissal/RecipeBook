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
        
        
//        let width = UIScreen.main.bounds.size.width
//        let height = UIScreen.main.bounds.size.height
//        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 100, width: width, height: height))
//        imageViewBackground.image = UIImage(named: "backGround")
//               
//        
//        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

        
        tableView.backgroundView = UIImageView(image: UIImage(named: "bellaBackGround"))
        
        
        
        loadData()
        //Table have the height of rows used
        tableView.tableFooterView = UIView()
        
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
        addAlert.addTextField {(textField:UITextField) in textField.placeholder = "Category title"; textField.autocapitalizationType = .sentences 
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

        //To see the background behind the cell
        cell.backgroundColor = .clear

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
    
    //To create and use the Edit and DELETE button in each cell of the table
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete"){(action, swipeButtonView, completetion) in
           
            let addAlert = UIAlertController(title: "Delete Category", message: "If you delete, all data in this category will be lost. \n Including all recipes inside this category", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            addAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ (action) in
            
                let categoryObjectToDelete = self.categoriesArray[indexPath.row]
            RecipesManager.shared.deleteCategory(category: categoryObjectToDelete)
            self.categoriesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completetion(true)
            }))
            
            self.present(addAlert, animated: true, completion: nil)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit"){(action, swipeButtonView, completetion) in

            let addAlert = UIAlertController(title: "Change Category Title", message: "Type new title to this category", preferredStyle: .alert)
            addAlert.addTextField {(textField:UITextField) in textField.placeholder = "Category title"; textField.autocapitalizationType = .sentences 
            }
            addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler:{ (action) in
            let categoryObjectToChange = self.categoriesArray[indexPath.row]
            if let title = addAlert.textFields?.first?.text {
                RecipesManager.shared.updateCategoryTitle(category: categoryObjectToChange, title: title)
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
