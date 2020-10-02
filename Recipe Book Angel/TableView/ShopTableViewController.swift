//
//  ShopTableViewController.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-09-25.
//

import UIKit


class ShopTableViewController: UITableViewController {
    
    var shopArray = [ShoppingList]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadData()
    }
    
            
    func loadData() {
        if let checkedItems = RecipesManager.shared.getAllShoppingListByChecked(isChecked: true){
            if let uncheckedItems = RecipesManager.shared.getAllShoppingListByChecked(isChecked: false){
                shopArray = uncheckedItems + checkedItems
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    @IBAction func addShopItem(_ sender: Any) {
        let addAlert = UIAlertController(title: "Add Item", message: "Enter item to shopping list", preferredStyle: .alert)
        addAlert.addTextField{
            (textField: UITextField) in textField.placeholder = "Item and qty"
        }
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            (action) in if let item = addAlert.textFields?.first?.text {
                RecipesManager.shared.addItemtoShoppingList(title: item)
                self.loadData()
            }
        }))
        
        self.present(addAlert, animated: true, completion: nil)
    }
    
   
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shopArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCell", for: indexPath) as! ShopViewCell

        let item = shopArray[indexPath.row]
        
        cell.item = item
        cell.setImage(isChecked: item.isChecked)
        cell.itemLabel.text = item.title
        cell.isChecked = item.isChecked
//        cell.textLabel?.text = item.title
        
        return cell
    }
    
    
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let addAlert = UIAlertController(title: "Delete item", message: "Confirm to delete this item from your shopping List", preferredStyle: .alert)
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ (action) in
        
        if editingStyle == .delete {
            let shopObjectToDelete = self.shopArray[indexPath.row]
            RecipesManager.shared.deleteShopItem(item: shopObjectToDelete)
            self.shopArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        } ))
        
        self.present(addAlert, animated: true, completion: nil)
    }

    
    
    
}
