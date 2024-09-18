//
//  CoinRowView.swift
//  Crypto
//
//  Created by Sergiu on 20.08.2024.
//

import SwiftUI

struct CoinRowView: View {
    @ObservedObject var viewModel: CoinRowViewModel
    
    @State private var bg: Color = .primary
    @State private var isAnimating = false
    
    private struct Constants {
        static let height: CGFloat = 30
        static let defaultIcon: String = "bitcoinsign.circle"
        static let spacing: CGFloat = 10
    }
    
    var body: some View {
        HStack {
            iconView
            detailsView
            Spacer()
            currentPriceView
        }
        .padding(0)
        .background(backgroundView)
        .animation(.easeInOut, value: viewModel.priceChangeAnimationTrigger)
    }
    
    private var iconView: some View {
        Group() {
            if let coinImage = viewModel.imageUrl {
                AsyncImage(url: URL(string: coinImage)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: Constants.height, height: Constants.height)
                    case .success(let image):
                        image
                            .resizable()
                    case .failure:
                        failureIcon
                    @unknown default:
                        failureIcon
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.height, height: Constants.height)
            }
        }
        .padding(.zero)
    }
    
    private var failureIcon: some View {
        Image(systemName: Constants.defaultIcon)
            .resizable()
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: Constants.spacing) {
                Text(viewModel.name)
                    .font(.subheadline)
                Text(viewModel.code)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            HStack(spacing: Constants.spacing) {
                HStack(spacing: .zero) {
                    Text("min: ")
                    Text(viewModel.minPrice)
                        .foregroundStyle(.black)
                }
                .fontWeight(.light)
                .font(.system(size: Constants.spacing))
                
                HStack(spacing: .zero) {
                    Text("max: ")
                    Text(viewModel.maxPrice)
                        .foregroundStyle(.black)
                }
                .fontWeight(.light)
                .font(.system(size: Constants.spacing))
            }
            .font(.caption)
            .foregroundStyle(.gray)
        }
        .padding(.zero)
    }
    
    private var currentPriceView: some View {
        Group {
            if viewModel.priceChange == .increased || viewModel.priceChange == .decreased {
                Text(viewModel.currentPrice)
                    .font(.subheadline)
                    .padding(8)
                    .background(backgroundColor)
                    .clipShape(.rect(cornerRadius: 5))
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: viewModel.priceChangeAnimationTrigger)
                    .onAppear {
                        animatePriceLabel()
                    }
            } else {
                Text(viewModel.currentPrice)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .animation(nil) // No animation for unchanged price
            }
        }
    }
    
    private func animatePriceLabel() {
        isAnimating.toggle()
        if viewModel.priceChange == .increased {
            bg = .green
        } else if viewModel.priceChange == .decreased {
            bg = .red
        }
        // Delay to reset background color after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            bg = .primary
        }
    }
    
    private var backgroundView: Color {
        viewModel.priceChangeAnimationTrigger ? backgroundColor.opacity(0.2) : .clear
    }
    
    private var backgroundColor: Color {
        switch viewModel.priceChange {
        case .decreased: .red
        case .increased: .green
        case .unchanged: .primary
        }
    }
}
