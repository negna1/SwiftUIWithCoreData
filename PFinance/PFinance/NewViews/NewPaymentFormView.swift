//
//  NewPaymentFormView.swift
//  PFinance
//
//  Created by Nato Egnatashvili on 18.02.22.
//

import SwiftUI

struct NewPaymentFormView: View {
    //Context ისთვის
    @Environment(\.managedObjectContext) var context
    //present  ro gaaketos
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: NewPaymentFormViewModel
    
    init() {
        viewModel = NewPaymentFormViewModel()
    }
    
    var body: some View {
        ScrollView {
            Group {
                if !viewModel.nameIsValid {
                    ValidationFormView(title: "Name is not Valid")
                }
                
                if !viewModel.amountIsValid {
                    ValidationFormView(title: "amount is not Valid")
                }
                
                if !viewModel.formIsValid {
                    ValidationFormView(title: "Form is not Valid")
                }
            }
        }
    }
}

struct ValidationFormHeader<Content>: View where Content: View {
    var modalContent: () -> Content
    
    var body: some View {
        HStack {
            Text("New Payment")
                .fontWeight(.heavy)
                .font(.headline)
            Button {
                modalContent()
            } label: {
                Image(systemName: "multiply")
            }
            
            
        }
    }
}

struct ValidationFormView: View {
    var title: String
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.red)
            Text(title)
                .foregroundColor(Color("IncomeCard"))
        }
    }
}
