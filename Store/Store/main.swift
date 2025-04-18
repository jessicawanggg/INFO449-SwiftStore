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
    let isTwoForOne: Bool

    init(name: String, priceEach: Int) {
        self.name = name
        self.priceEach = priceEach
        self.isTwoForOne = false
    }
    init(name: String, priceEach: Int, isTwoForOne: Bool) {
        self.name = name
        self.priceEach = priceEach
        self.isTwoForOne = isTwoForOne
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
        return subtotal() + tax()
    }
    private func groupItemsByName() -> [String: [SKU]] {
        var groups: [String: [SKU]] = [:]
        for item in scannedItems {
            groups[item.name, default: []].append(item)
        }
        return groups
    }
    func subtotal() -> Int {
        var total = 0
        var itemGroups = groupItemsByName()
        for (name, items) in itemGroups {
            guard let firstItem = items.first else { continue }
            if let item = firstItem as? Item, item.isTwoForOne {
                let count = items.count
                let chargeableCount = count / 2 + count % 2
                total += chargeableCount * item.priceEach
            } else {
                total += items.reduce(0) { $0 + $1.price() }
            }
        }
        return total
    }
    func output() -> String {
        var lines: [String] = ["Receipt:"]
        var taxTotal = 0
        for item in scannedItems {
            let priceDollars = Double(item.price()) / 100.0
            lines.append("\(item.name): $\(String(format: "%.2f", priceDollars))")
            
            if let taxableItem = item as? Taxable {
                let taxAmount = Double(taxableItem.tax()) / 100.0
                taxTotal += taxableItem.tax()
                lines.append("Tax: $\(String(format: "%.2f", taxAmount))")
            }
        }
        lines.append("------------------")
        let taxDollars = Double(taxTotal) / 100.0
        let totalDollars = Double(subtotal() + taxTotal) / 100.0
        lines.append("TAX: $\(String(format: "%.2f", taxDollars))")
        lines.append("TOTAL: $\(String(format: "%.2f", totalDollars))")
        return lines.joined(separator: "\n")
    }
    func tax() -> Int {
        return scannedItems
            .compactMap { $0 as? Taxable }
            .reduce(0) { $0 + $1.tax() }
    }
}

class Register {
    private var receipt: Receipt
    private(set) var items: [Item] = []
    private var pricingSchemes: [PricingScheme] = []
    private var coupons: [Coupon] = []
    private var rainChecks: [RainCheck] = []

    init() {
        self.receipt = Receipt()
    }
    func scan(_ item: SKU) {
        receipt.addItem(item)
    }
    func applyPricingScheme(_ scheme: PricingScheme) {
        pricingSchemes.append(scheme)
    }
    func applyCoupon(_ coupon: Coupon) {
        coupons.append(coupon)
    }
    func applyRainCheck(_ rainCheck: RainCheck) {
        rainChecks.append(rainCheck)
    }
    func subtotal() -> Int {
        var total = receipt.total()
        for scheme in pricingSchemes {
            total = scheme.apply(to: receipt.items())
        }
        for coupon in coupons {
            total = receipt.items().map { coupon.apply(to: $0) }.reduce(0, +)
        }
        for rainCheck in rainChecks {
            total = receipt.items().map { rainCheck.apply(to: $0) }.reduce(0, +)
        }
        return total
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

// Extra credit
protocol PricingScheme {
    func apply(to items: [SKU]) -> Int
}

class GroupedPricing: PricingScheme {
    let groupedItems: [String]
    let discount: Double

    init(groupedItems: [String], discount: Double) {
        self.groupedItems = groupedItems
        self.discount = discount
    }
    func apply(to items: [SKU]) -> Int {
        let filteredItems = items.filter { groupedItems.contains($0.name) }
        let total = filteredItems.reduce(0) { $0 + $1.price() }
        return Int(Double(total) * (1 - discount))
    }
}

class WeightBasedPricing: SKU {
    let name: String
    let pricePerPound: Int
    let weight: Double

    init(name: String, pricePerPound: Int, weight: Double) {
        self.name = name
        self.pricePerPound = pricePerPound
        self.weight = weight
    }
    func price() -> Int {
        return Int(Double(pricePerPound) * weight)
    }
}

class Coupon {
    let itemName: String
    let discount: Double

    init(itemName: String, discount: Double) {
        self.itemName = itemName
        self.discount = discount
    }
    func apply(to item: SKU) -> Int {
        if item.name == itemName {
            return Int(Double(item.price()) * (1 - discount))
        }
        return item.price()
    }
}

class RainCheck {
    let itemName: String
    let price: Int

    init(itemName: String, price: Int) {
        self.itemName = itemName
        self.price = price
    }
    func apply(to item: SKU) -> Int {
        if item.name == itemName {
            return price
        }
        return item.price()
    }
}

protocol Taxable {
    func tax() -> Int
}

class TaxableItem: SKU, Taxable {
    let name: String
    let priceEach: Int
    let isEdible: Bool

    init(name: String, priceEach: Int, isEdible: Bool) {
        self.name = name
        self.priceEach = priceEach
        self.isEdible = isEdible
    }
    func price() -> Int {
        return priceEach
    }
    func tax() -> Int {
        if isEdible {
            return 0
        } else {
            let tax = Double(priceEach) * 0.10
            return Int(tax.rounded())
        }
    }
}
