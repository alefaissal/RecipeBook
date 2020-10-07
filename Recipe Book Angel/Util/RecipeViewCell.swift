//
//  RecipeViewCell.swift
//  Recipe Book Angel
//
//  Created by Alexandre Ricardo Faissal on 2020-10-05.
//

import UIKit

class RecipeViewCell: UITableViewCell {
    
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTitelLabel: UILabel!
    @IBOutlet weak var searchSubTitleLabel: UILabel!
    
    @IBOutlet weak var favoritesImageView: UIImageView!
    @IBOutlet weak var favoritesTitleLabel: UILabel!
    @IBOutlet weak var favoritesSubtitleLabel: UILabel!
    
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeSubTitleLabel: UILabel!
    
    
    var recipe: Recipe? = Recipe()
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
