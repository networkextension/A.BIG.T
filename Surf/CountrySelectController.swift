//
//  CountrySelectController.swift
//  Surf
//
//  Created by abigt on 16/2/22.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
protocol CountryDelegate:class {
    func countrySelected(controller: CountrySelectController, code:String)//
}
class CountrySelectController: SFTableViewController {
    var list:[String] = []
    weak var delegate:CountryDelegate?
    //var code:String!
    func loadCountrys(){
        let path = Bundle.main.path(forResource: "ISO_3166.txt", ofType: nil)
        
        do {
            let str = try String.init(contentsOfFile: path!, encoding: .utf8)
            list = str.components(separatedBy: "\n")
        }catch let error  {
            alertMessageAction("\(error.localizedDescription)",complete: nil)
        }
    }
    override func viewDidLoad() {
        self.title = "Select Country"
        loadCountrys()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        self.delegate?.countrySelected(controller: self, code: list[indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)
    }
}
