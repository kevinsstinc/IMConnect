//
//  SearchBar.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 13/6/25.
//
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
            TextField("", text: $searchText)
                .foregroundStyle(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(10)
        .background(Color(.white).opacity(0.3))
        .cornerRadius(20)
    }
}
