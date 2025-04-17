//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//

import Foundation

protocol SKU {
    var name: String { get }
    func price() -> Int
}

class Item: SKU {
    let name: String
    let priceEach: Int

    init(name: String, priceEach: Int) {
        self.name = name
        self.priceEach = priceEach
    }
    func price() -> Int {
        return priceEach
    }
}

class Receipt {
    private var scannedItems: [SKU] = []

    func addItem(_ item: SKU) {
        scannedItems.append(item)
    }
    func items() -> [SKU] {
        return scannedItems
    }
    func total() -> Int {
        return scannedItems.reduce(0) { $0 + $1.price() }
    }
    func output() -> String {
        var lines: [String] = ["Receipt:"]
        for item in scannedItems {
            let priceDollars = Double(item.price()) / 100.0
            lines.append("\(item.name): $\(String(format: "%.2f", priceDollars))")
        }
        lines.append("------------------")
        let totalDollars = Double(total()) / 100.0
        lines.append("TOTAL: $\(String(format: "%.2f", totalDollars))")
        return lines.joined(separator: "\n")
    }
}

class Register {
    private var receipt: Receipt
    private(set) var items: [Item] = []

    init() {
        self.receipt = Receipt()
    }
    func scan(_ item: SKU) {
        receipt.addItem(item)
    }
    func subtotal() -> Int {
        return receipt.total()
    }
    func total() -> Receipt {
        let completed = receipt
        self.receipt = Receipt()
        return completed
    }
}

class Store {
    let version = "0.1"

    func helloWorld() -> String {
        return "Hello world"
    }
}
