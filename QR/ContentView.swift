//
//  ContentView.swift
//  QR
//
//  Created by Simon Hochrein on 5/15/21.
//

import SwiftUI
import Combine

class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { t in
                self.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}

struct QRCode: View {
    
    var text: String

    var body: some View {
        VStack {
            Image(nsImage: getQRCode())
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
    }

    func getQRCode() -> NSImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(text.data(using: String.Encoding.ascii), forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let output = filter.outputImage!.transformed(by: transform)
        
        let rep = NSCIImageRep(ciImage: output)
        
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

struct QRView: View {
    @EnvironmentObject var text: TextFieldObserver;
    @State var debouncedText : String = ""

    var body: some View {
        return VStack {
            TextField("Data", text: $text.searchText)
            QRCode(text: text.debouncedText)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject() var focused: Focused
    var textFieldObserver = TextFieldObserver()

    var body: some View {
        VStack {
            QRView().environmentObject(textFieldObserver)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(25)
        .onReceive(focused.$focused, perform: { val in
            if let pasteboardContent = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) {
                textFieldObserver.searchText = pasteboardContent
                textFieldObserver.debouncedText = pasteboardContent
            }
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
