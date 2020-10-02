//
//  ShopViewCell.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-10-01.
//

import UIKit

class ShopViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var checkBoxImage: UIButton!
    
    var isChecked: Bool = false
    var image2: UIImage?
    let checkedImage = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedImage = UIImage(systemName: "circle")
    
    var item: ShoppingList? = ShoppingList()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func checkBoxBUtton(_ sender: Any ) {
        isChecked = !isChecked
        setImage(isChecked: isChecked)
        if item != nil {
            RecipesManager.shared.updateShopListCheck(item: item!, checked: isChecked)
        }
    }
    
    func setImage(isChecked:Bool) {
        if isChecked {
            checkBoxImage.setImage(checkedImage, for: .normal)
        } else {
            checkBoxImage.setImage(uncheckedImage, for: .normal)
        }
    }
    
}
