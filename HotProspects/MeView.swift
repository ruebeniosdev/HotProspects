//
//  MeView.swift
//  HotProspects
//
//  Created by RUEBEN on 09/09/2022.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins


struct MeView: View {
    @State private var name = "Anonymous"
    @State private var emailAdress = "you@yoursite.com"
    @State private var qrCode = UIImage()
    
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email Address", text: $emailAdress)
                    .textContentType(.emailAddress)
                    .font(.title)
                
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotAlbum(image: qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                        
                    }
            }
            .navigationTitle("Your code")
            .onAppear (perform: updateCode)
            
            .onChange(of: name) { _ in
                updateCode()
            }
            .onChange(of: emailAdress) { _ in
                updateCode()
            }
        }
        
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAdress)")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)

            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
