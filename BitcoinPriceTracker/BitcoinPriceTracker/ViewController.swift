//
//  ViewController.swift
//  BitcoinPriceTracker
//
//  Created by ADG RIT 1 on 31/03/19.
//  Copyright © 2019 ADG RIT 1. All rights reserved.
//

import UIKit
import SwiftChart
import EFCountingLabel
class ViewController: UIViewController,ChartDelegate{
    var arrayUSD:[Double] = [4000.00]
    var arrayINR:[Double] = [40000.00]
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        //
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        //
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        //
    }
    
    
    struct Prices: Decodable{
        let bpi : [String: Bpi]
    }
    struct Bpi: Decodable{
        let code: String?
        let rate_float: Double?
    }
    
    func updateChart(usdValue: Double, priceArray: inout [Double]){
        if priceArray.count > 20{
            priceArray.remove(at: 0)
        }
    priceArray.append(usdValue)
    let series = ChartSeries(priceArray)
    chartView.removeAllSeries()
    chartView.add(series)
    }
    override func viewDidLoad() {let _:[Double]? = nil
        super.viewDidLoad()
        getPrice()
        chartView.delegate = self
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getPrice), userInfo: nil, repeats: true)//call itself after 2 secs
        print(segment.selectedSegmentIndex)//to toggle between two segments
        // Do any additional setup after loading the view, typically from a nib.
    }

   
    @IBOutlet weak var chartView: Chart!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var label: EFCountingLabel!
    
    
    @IBAction func buttonTapped(_ sender: Any) {
        getPrice()
    }
    
    @objc func getPrice(){
        let url=URL(string:"https://api.coindesk.com/v1/bpi/currentprice/INR.json")//converting url into string
        URLSession.shared.dataTask(with: url!){//sure about the url exist,hence "!" else "??"
            data,reponse,error in //apis
            if error != nil{
                print(error!.localizedDescription)
            }
            if let data = data{
                let price = try? JSONDecoder().decode(Prices.self,from:data)
                let bpi = price?.bpi //To call structure bpi
                var code = bpi!["USD"]!.code
                let rateUSD = bpi!["USD"]!.rate_float!
                let rateINR = bpi!["INR"]!.rate_float!
                DispatchQueue.main.async{
                    if self.segment.selectedSegmentIndex == 0{
                       
                        self.label.format = "%.2f"
                        self.label.countFromCurrentValueTo(CGFloat(rateUSD))
                        self.updateChart(usdValue: rateUSD,priceArray: &self.arrayUSD)
                    }
                    else
                    {
                        self.label.text = "\(rateINR)"
                        self.updateChart(usdValue: rateINR,priceArray: &self.arrayINR)
                    }
                   
                }
            }
            
        }.resume()
    }
}

