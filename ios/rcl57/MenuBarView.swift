import SwiftUI

struct MenuBarView: View {
    let change: Change

    let left: String?
    let title: String
    let right: String?
    let width: CGFloat
    var background = Style.blackish
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
                .frame(maxWidth: width * 2 / 3, maxHeight: Style.headerHeight)
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
        .background(background)
        .foregroundColor(Style.ivory)
    }
}
