//
//  SearchTableViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var recipesArray =  [Recipe]()
    var filteredTableData =  [Recipe]()
    var resultSearchController = UISearchController()
    var isSearchBarEmpty: Bool {
      return resultSearchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return resultSearchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            //the code below makes the elements in search clickable
            controller.obscuresBackgroundDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()

        // Reload the table
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        if let recipes = RecipesManager.shared.getAllRecipes() {
            recipesArray = recipes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            filteredTableData = recipesArray
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  isFiltering {
            return filteredTableData.count
        }
        return recipesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        var recipe: Recipe?
        if isFiltering{
            recipe =  filteredTableData[indexPath.row]
        }else {
            recipe = recipesArray[indexPath.row]
        }
        
        let date = RecipesManager.shared.dateFormater(date: recipe!.creationDate)
        let updated = RecipesManager.shared.dateFormater(date: recipe!.updateDate)
        
        cell.textLabel?.text = recipe!.title
        cell.detailTextLabel?.text = "Yield: \(recipe!.yield!), updated: \(updated)"
        
        return cell
    }
    

    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchText = searchController.searchBar.text!
        let array = RecipesManager.shared.searchAll(searchWord: searchText)
        
        //used to create a list of items depending on the search
        if isSearchBarEmpty {
            filteredTableData = recipesArray
        }else{
            filteredTableData = array!
        }
        
        self.tableView.reloadData()
        
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowSearchRecipes", sender: nil)
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let recipeVC = segue.destination as! RecipeViewController
        
        
        recipeVC.navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        //Here is to display, depending on the identifier of the segue
        if segue.identifier == "ShowSearchRecipes" {
            if let selectedNoteIndexPath = self.tableView.indexPathForSelectedRow {
                
                var recipeObject: Recipe?
                
                if (resultSearchController.isActive) {
                    recipeObject = filteredTableData[selectedNoteIndexPath.row]
                }
                else {
                    recipeObject = recipesArray[selectedNoteIndexPath.row]
                }
                
                recipeVC.recipeObject = recipeObject
            }
        }
        //to remove search bar when moved to next page
        resultSearchController.isActive = false
    }

}
