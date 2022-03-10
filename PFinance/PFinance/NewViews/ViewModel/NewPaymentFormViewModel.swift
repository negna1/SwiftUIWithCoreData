//
//  NewPaymentFormViewModel.swift
//  PFinance
//
//  Created by Nato Egnatashvili on 18.02.22.
//

import Combine
import Foundation
import SwiftUI


class NewPaymentFormViewModel: ObservableObject {
    //Input
    @Published var name: String = ""
    @Published var location: String = ""
    @Published var memo: String = ""
    @Published var amount: Double = 0
    @Published var date: Date = Date.today
    @Published var type: PaymentCategory = .expense
    
    //output
    @Published var nameIsValid: Bool = false
    @Published var formIsValid: Bool = false
    @Published var memoIsValid: Bool = true
    @Published var amountIsValid: Bool = true
    
    var cancallables = Set<AnyCancellable>()
    public init() {
        
        $name.receive(on: RunLoop.main)
            .map { publisher in
               return  publisher.count > 0
            }
            .assign(to: \.nameIsValid, on: self)
            .store(in: &cancallables)
        
        $amount.receive(on: RunLoop.main)
            .map { amount in
                return amount > 0
            }.assign(to: \.amountIsValid, on: self)
            .store(in: &cancallables)
        
        $memo.receive(on: RunLoop.main)
            .map { memo in
                return memo.count < 300
            }.assign(to: \.memoIsValid, on: self)
            .store(in: &cancallables)
        
        Publishers.CombineLatest3($nameIsValid, $memoIsValid, $amountIsValid)
            .map { a, b, c in
                return a && b && c
            }.assign(to: \.formIsValid, on: self)
            .store(in: &cancallables)
    }
}
