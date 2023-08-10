import SwiftUI

/// A generic navigation bar with a title and 2 optional controls, on the left and on the right.
struct NavigationBar: View {
    let left: String?
    let title: String
    let right: String?
    let leftAction: (() -> Void)?
    let rightAction: (() -> Void)?

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            HStack(spacing: 0) {
                if let left {
                    Button(action: {
                        if let leftAction {
                            leftAction()
                        }
                    }) {
                        Text(left)
                            .frame(width: width / 5,
                                   height: Style.headerHeight,
                                   alignment: .leading)
                            .offset(x: 15)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                } else {
                    Spacer()
                        .frame(width: width / 5, height: Style.headerHeight)
                }
                Text(title)
                    .frame(width: width * 3 / 5, height: Style.headerHeight)
                    .font(Style.headerTitleFont)
                if let right {
                    Button(action: {
                        if let rightAction {
                            rightAction()
                        }
                    }) {
                        Text(right)
                            .frame(width: width / 5,
                                   height: Style.headerHeight,
                                   alignment: .trailing)
                            .offset(x: -15)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                } else {
                    Spacer()
                        .frame(width: width / 5, height: Style.headerHeight)
                }
            }
        }
        .frame(height: Style.headerHeight)
        .foregroundColor(.ivory)
    }
}
