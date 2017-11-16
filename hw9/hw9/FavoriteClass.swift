//
//  FavoriteClass.swift
//  Pods
//
//  Created by Suyash Shetty on 11/15/17.
//

import UIKit

class Favorite: NSObject {
    private var id: Int = 0;
    private var stockSymbol: String = "";
    private var price: Float = 0.0;
    private var change: Float = 0.0;
    private var changePercent: Float = 0.0;
    
    init(id: Int, stockSymbol: String, price: Float, change: Float, changePercent: Float) {
        self.id = id;
        self.stockSymbol = stockSymbol;
        self.price = price;
        self.change = change;
        self.changePercent = changePercent;
    }
    
    func setId(id: Int) {
        self.id = id;
    }
    
    func getId() -> Int {
        return self.id;
    }
    
    func setStockSymbol(stockSymbol: String) {
        self.stockSymbol = stockSymbol;
    }
    
    func getStockSymbol() -> String {
        return self.stockSymbol;
    }
    
    func setPrice(price: Float) {
        self.price = price;
    }
    
    func getPrice() -> Float {
        return self.price;
    }
    
    func setChange(change: Float) {
        self.change = change;
    }
    
    func setChangePercent(changePercent: Float) {
        self.changePercent = changePercent;
    }
    
    func getChangeString() -> String {
        return String(format: "%.2f (%.2f%%)", self.change, self.changePercent);
    }
    
    func getChange() -> Float {
        return self.change;
    }
    
    func getChangePercent() -> Float {
        return self.changePercent;
    }
}
