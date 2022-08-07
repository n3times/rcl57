import SwiftUI

private struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

/** Shows the name and description of a program and let's the user take different actions on the program. */
struct ProgramView: View {
    @EnvironmentObject var change: Change

    @State private var isPresentingShare: Bool = false
    @State private var isPresentingDelete: Bool = false
    @State private var isPresentingCopy: Bool = false

    let program: Prog57

    var body: some View {
        let loaded = program == change.loadedProgram
        let loadButtonText = loaded ? "RELOAD" : "LOAD"

        GeometryReader { geometry in
            let width = geometry.size.width

            VStack(spacing: 0) {
                MenuBarView(change: change,
                            left: Style.leftArrow,
                            title: program.getName(),
                            right: Style.downArrow,
                            width: width,
                            leftAction: { withAnimation {change.programView = nil} },
                            rightAction: { withAnimation {change.currentView = .calc} })
                .background(Style.deepBlue)

                if program.getDescription() == "" {
                    GeometryReader { geometry in
                        Text("No description available")
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                            .background(Style.ivory)
                            .foregroundColor(Style.blackish)
                    }
                } else {
                    HelpView(helpString: program.getDescription())
                }

                // Footer
                HStack(spacing: 0) {
                    Button(action: {
                        isPresentingShare = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(Style.directionsFont)
                            .offset(x: 15)
                            .frame(width: width / 5, height: Style.footerHeight, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .sheet(isPresented: $isPresentingShare) {
                        ActivityViewController(activityItems: [program.url!])
                    }

                    Button(action: {
                        program.loadStepsIntoMemory()
                        program.loadRegistersIntoMemory()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            change.setLoadedProgram(program: program)
                        }
                        withAnimation {
                            change.currentView = .calc
                        }
                    }) {
                        Text(loadButtonText)
                            .font(Style.footerFont)
                            .frame(maxWidth: width * 3 / 5, maxHeight: Style.footerHeight, alignment: .center)
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                    }

                    if program.readOnly {
                        Spacer()
                            .frame(width: width / 5, height: Style.footerHeight)
                    } else {
                        Menu {
                            Button(action: {
                                isPresentingDelete = true
                            }) {
                                Text("Delete")
                            }
                            Button(action: {
                                change.isPreviewInEditProgram = false
                                withAnimation {
                                    change.isEditInProgramView = true
                                }
                            }) {
                                Text("Edit")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(Style.directionsFont)
                                .frame(maxWidth: width / 5, maxHeight: Style.footerHeight, alignment: .trailing)
                                .offset(x: -15)
                                .contentShape(Rectangle())
                        }
                        .frame(maxWidth: width / 5, maxHeight: Style.footerHeight, alignment: .trailing)
                        .offset(x: -15)
                        .contentShape(Rectangle())
                        .confirmationDialog("Delete?", isPresented: $isPresentingDelete) {
                            Button("Delete " + program.getName(), role: .destructive) {
                                _ = Lib57.userLib.deleteProgram(program)
                                if program == change.loadedProgram {
                                    change.loadedProgram = nil
                                }
                                change.isUserLibExpanded = true
                                withAnimation {
                                    change.programView = nil
                                }
                            }
                        }
                    }
                }
            }
            .background(Style.deepBlue)
            .foregroundColor(Style.ivory)

            if change.isEditInProgramView {
                ProgramEditView(program: program)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    @EnvironmentObject var change: Change

    static var previews: some View {
        ProgramView(program: Prog57(name: "", description: ""))
    }
}
