//
//  SearchCityViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit

class SearchCityViewController: UIViewController {

    // MARK: - ViewController Outlets
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewController Action
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Controller variables
    var results: [City] = [City]()
    var timer: Timer!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.delegate = self
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    // MARK: - Get all the cities with specific data (Function called by searchBarController)
    func getCities(_ sender: Timer) {
        DataService.instance.getCitiesByFirebase(sender.userInfo as AnyObject) { (cities: [City]) -> () in
            self.results = cities
            self.tableView.reloadData()
        }
    }
    
    // MARK: - PrepareForSegue method
    // Before the segue occurs, we convert RawCity object to a SearchedCity and save it into coreData
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.Segue.viewWeatherDetailForCitySearched {
            if let destinationController = segue.destination as? DetailViewController, let city = sender as? City {
                destinationController.city = city
            }
        }
    }
    
}

// MARK: - UINavigationBarDelegate
extension SearchCityViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
}

// MARK: - UISearchBarDelegate
extension SearchCityViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        if searchText == "" {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        } else {
            var searchInfo: Dictionary<String, String> = [String: String]()
            
            if let keyboardInputMode = self.searchBar.textInputMode?.primaryLanguage {
                let language = NSString(string: keyboardInputMode).substring(to: 2)
                let resultOfGetSearchTextStringFunction = getSearchTextString(searchText, language: language)
                searchInfo["searchText"] = resultOfGetSearchTextStringFunction.latinVersionSearchText
                searchInfo["language"] = language
                
                if let localeVersion = resultOfGetSearchTextStringFunction.localeVersionSearchText {
                    searchInfo["localeVersion"] = localeVersion
                }
            } else {
                searchInfo["searchText"] = searchText
            }
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SearchCityViewController.getCities(_:)), userInfo: searchInfo, repeats: false)

        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func getSearchTextString(_ searchText: String, language:String) -> (latinVersionSearchText: String, localeVersionSearchText: String?) {
        
        let mutableSearchText = NSMutableString(string: searchText) as CFMutableString
        CFStringTransform(mutableSearchText, nil, kCFStringTransformToLatin, false)
        
        let tokenizer = CFStringTokenizerCreate(nil, mutableSearchText, CFRangeMake(0, CFStringGetLength(mutableSearchText)), 0, CFLocaleCopyCurrent())
        
        var valueToReturn = mutableSearchText as String
        
        print(language)
        
        switch language {
            
        case "zh", "ja", "ko", "ru", "el", "ar":
            CFStringTransform(mutableSearchText, nil, kCFStringTransformStripCombiningMarks, false)
            
            var mutableTokens: [String] = []
            var type: CFStringTokenizerTokenType
            repeat {
                type = CFStringTokenizerAdvanceToNextToken(tokenizer)
                let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
                let token = CFStringCreateWithSubstring(nil, mutableSearchText, range) as NSString
                mutableTokens.append(token as String)
            } while type != CFStringTokenizerTokenType()

            valueToReturn = ""
            for token in mutableTokens {
                valueToReturn += token
            }
            
            return (valueToReturn.capitalized, searchText)
            
        case "th":
            CFStringTransform(mutableSearchText, nil, kCFStringTransformStripCombiningMarks, false)
            let city = mutableSearchText as String
            return (city.capitalized, searchText)
            
        default:
            return (valueToReturn.capitalized, nil)
        }
    }
    
}

// MARK: - UITableViewDelegate
extension SearchCityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity: City = self.results[indexPath.row]
        self.performSegue(withIdentifier: Storyboard.Segue.viewWeatherDetailForCitySearched, sender: selectedCity)
    }
}

// MARK: - UITableViewDataSource
extension SearchCityViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CityResultCell", for: indexPath) as! SearchCityCell
        
        cell.configureCell(self.results[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print(self.results.count)
        return self.results.count
    }
}
