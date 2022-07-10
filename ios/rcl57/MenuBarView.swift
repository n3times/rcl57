import SwiftUI

struct MenuBarView: View {
    let change: Change

    let left: String?
    let title: String
    let right: String?
    let width: CGFloat
    let leftAction: () -> Void?
    let rightAction: () -> Void?

    var body: some View {
        HStack(spacing: 0) {
            if (left != nil) {
                Button(action: {
                    leftAction()
                }) {
                    Text(left!)
                        .frame(width: width / 6, height: Style.headerHeight)
                        .font(Style.directionsFont)
                        .contentShape(Rectangle())
                }
            } else {
                Spacer()
                    .frame(width: width / 6, height: Style.headerHeight)
            }
            Text(title)
                .frame(width: width * 2 / 3, height: Style.headerHeight)
                .font(Style.titleFont)
            if (right != nil) {
                Button(action: {
                    rightAction()
                }) {
                    Text(right!)
                        .frame(width: width / 6, height: Style.headerHeight)
                        .font(Style.directionsFont)
                        .contentShape(Rectangle())
                }
            } else {
                Spacer()
                    .frame(width: width / 6, height: Style.headerHeight)
            }
        }
        .background(Style.blackish)
        .foregroundColor(Style.ivory)
    }
}
