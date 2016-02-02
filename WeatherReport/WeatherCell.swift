//
//  WeatherCell.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/24.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
