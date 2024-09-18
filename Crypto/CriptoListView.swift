//
//  ContentView.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import SwiftUI

struct CriptoListView: View {
    @ObservedObject var viewModel: CoinViewModel
    
    private struct Constants {
        static let height: CGFloat = 30
        static let defaultIcon: String = "bitcoinsign.circle"
        static let spacing: CGFloat = 10
        static let horizontalSpacing: CGFloat = 16
        static let opacity: CGFloat = 0.3
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.spacing) {
                    ForEach(viewModel.coins) { coin in
                        let viewModel = CoinRowViewModel(coin: coin, coinViewModel: viewModel)
                        CoinRowView(viewModel: viewModel)
                            .padding(.vertical, 4)
                            .padding(.horizontal, .zero)
                            .overlay(separatorLine, alignment: .bottom)
                    }
                }
                .padding(.horizontal, Constants.horizontalSpacing)
                
            }
            .navigationBarTitle("Market")
            .onAppear {
                viewModel.connectToAPI()
            }
            .onDisappear {
                viewModel.disconnectFromAPI()
            }
        }
    }
    
    private var separatorLine: some View {
        Rectangle()
            .fill(.gray.opacity(Constants.opacity))
            .frame(height: Constants.opacity)
            .frame(maxWidth: .infinity)
            .padding(.top, Constants.spacing)
    }
}
