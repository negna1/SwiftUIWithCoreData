//
//  NewDashboardView.swift
//  PFinance
//
//  Created by Nato Egnatashvili on 17.02.22.
//

import SwiftUI

struct NewDashboardView: View {
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(
        entity: PaymentActivity.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \PaymentActivity.date, ascending: false) ])
    var paymentActivities: FetchedResults<PaymentActivity>
    
    private var datasource: [PaymentActivity] {
        return paymentActivities.sorted { activity, activity2 in
            activity.date < activity2.date
        }.filter { activity in
            switch listType {
            case .all:
                return true
            case .income:
                return activity.type == .income
            case .expense:
                return activity.type == .expense
            }
        }
    }
    
    private var balance: Double {
        paymentActivities.reduce(0) { partialResult, activity in
            return partialResult + activity.amount
        }
    }
    
    private  var income: Double {
        paymentActivities.reduce(0) { partialResult, activity in
            return partialResult +  ( activity.amount > 0 ? activity.amount : 0)
        }
    }
    
    private  var expence: Double {
        paymentActivities.reduce(0) { partialResult, activity in
            return partialResult +  ( activity.amount < 0 ? activity.amount : 0)
        }
    }
    
    @State private var listType: TransactionDisplayType = .all
    
    var body: some View {
        ScrollView {
            MenuBarNew(){
                NewPaymentFormView().environment(\.managedObjectContext, self.context)
                //PaymentFormView().environment(\.managedObjectContext, self.context)
            }
            TotalBalanceNewView(balance: balance)
            IncomeExpenceView(income: income, expence: expence)
            FiltersView(listType: $listType)
            
            ForEach(datasource) {elem in
                TransactionCell(transaction: elem)
            }
        }
    }
    
    
}

struct MenuBarNew <Content>: View where Content: View  {
    @State var showPaymentForm: Bool = false
    let modalContent: () -> Content
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(alignment: .center) {
                Spacer()
                
                VStack(alignment: .center) {
                    Text(Date.today.string(with: "EEEE, MMM d, yyyy"))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Personal Finance")
                        .font(.title)
                        .fontWeight(.black)
                }
                
                Spacer()
            }
            Button {
                self.showPaymentForm = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(.primary)
            }
            .sheet(isPresented: $showPaymentForm) {
                self.showPaymentForm = false
            } content: {
                self.modalContent()
            }
            
        }
    }
    
}


struct TotalBalanceNewView: View {
    var balance: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color("IncomeCard"))
                .padding(EdgeInsets.init(top: 10, leading: 16, bottom: 10, trailing: 16))
                .frame( height: 200, alignment: .center)
            VStack {
                Text("Total Balance")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Text(NumberFormatter.currency(from: balance))
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
            }
        }
    }
}

struct IncomeExpenceView: View {
    var income: Double
    var expence: Double
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("IncomeCard"))
                    .frame(height: UIScreen.main.bounds.width/2 - 24, alignment: .center)
                VStack {
                    Text("Income")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    Text(NumberFormatter.currency(from: income))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("ExpenseCard"))
                    .frame(height: UIScreen.main.bounds.width/2 - 24, alignment: .center)
                VStack {
                    Text("Expence")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    Text(NumberFormatter.currency(from: expence))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }.padding(.horizontal, 16.0)
        
    }
}

struct FiltersView: View {
    @Binding var listType: TransactionDisplayType
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Transactions")
                .frame(alignment: .leading)
            
            HStack {
                Button {
                    listType = .all
                } label: {
                    Text("All")
                        .foregroundColor(.white)
                        .padding(.horizontal, 5.0)
                        
                }
                .background(listType == .all ? Color.blue : Color.gray)
                .cornerRadius(10)
                
                Button {
                    listType = .income
                } label: {
                    Text("Income")
                        .foregroundColor(.white)
                        .padding(.horizontal, 5.0)
                }
                .background(listType == .income ? Color.blue : Color.gray)
                .cornerRadius(5)
                
                Button {
                    listType = .expense
                } label: {
                    Text("Expence")
                        .foregroundColor(.white)
                        .padding(.horizontal, 5.0)
                }
                .background(listType == .expense ? Color.blue : Color.gray)
                .cornerRadius(5)
                
                Spacer()
                
            }
            
        }
        .padding(.leading, 16.0)
    }
}


struct TransactionCell: View {
    @ObservedObject var transaction: PaymentActivity
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Image(systemName: transaction.type == .income ? "arrowtriangle.up.circle.fill" : "arrowtriangle.down.circle.fill")
                    .font(.title)
                    .foregroundColor(Color(transaction.type == .income ? "IncomeCard" : "ExpenseCard"))
                VStack(alignment: .leading, spacing: 5) {
                    Text(transaction.name)
                        .fontWeight(.bold)
                    Text(transaction.address ?? "")
                }
                Spacer()
                Text(NumberFormatter.currency(from: transaction.amount))
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 5.0)
           
        
        
    }
    
}
