//
//  CardsListView.swift
//  CreditCardPayApp
//

import SwiftUI

struct CardsListView: View {
    @EnvironmentObject var cardViewModel: CardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(cardViewModel.cards) { card in
                    NavigationLink(destination: CardDetailView(card: card).environmentObject(cardViewModel)) {
                        CreditCardRow(card: card)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("All Credit Cards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CardsListView()
            .environmentObject(CardViewModel())
    }
}
