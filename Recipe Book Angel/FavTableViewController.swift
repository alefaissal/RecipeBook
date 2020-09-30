//
//  FavTableViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import UIKit

class FavTableViewController: UITableViewController {
    
    
    
    var recipesArray = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    
    
    func loadData() {
        if let recipes = RecipesManager.shared.getAllFav() {
            recipesArray = recipes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipesArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath)
        
        let recipe = recipesArray[indexPath.row]
        
        cell.textLabel?.text = recipe.title
        cell.detailTextLabel?.text = recipe.yield
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showFavRecipes", sender: nil)
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let recipeVC = segue.destination as! RecipeViewController
        
        
        recipeVC.navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        //Here is to display, depending on the identifier of the segue
        if segue.identifier == "showFavRecipes" {
            if let selectedNoteIndexPath = self.tableView.indexPathForSelectedRow {
                let recipeObject = recipesArray[selectedNoteIndexPath.row]
                recipeVC.recipeObject = recipeObject
            }
        }
        
    }
    
    
    
    
}
