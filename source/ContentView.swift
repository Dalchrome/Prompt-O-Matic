///  A Super Simple client for Draw Things.
/// by SoDoTo


import SwiftUI
import Foundation

@main
struct PictureThisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
  @State var prompt:String=""
    @State var seed:Int = -1
    @State var save:Bool=false
    @State var upscale:Bool=false
    @State var thumbnail:Bool=false
    @State var jpeg:Bool=false
    @State var jpglab:String = ".jpg"
    @State var cfg :Float = 8.5
    @State var steps :Float = 9
    @State var filename:String = ""
    @State var subfolder:String = ""
    @State private var isEditing = false
    @ObservedObject var requester = simpleImageRequester.shared

    var body: some View {
        VStack {
            HStack{
                Toggle(isOn: $upscale) {
                    Label(" ", systemImage: "square.resize.up")
                        .padding([.leading], -4)
                        .padding([.trailing], -16)
                }
                .toggleStyle(.button)
                Toggle(isOn: $thumbnail) {
                    Label(" ", systemImage: "square.resize.down")
                        .padding([.leading], -4)
                        .padding([.trailing], -16)
                }
                .toggleStyle(.button)
                Toggle(isOn: $jpeg) {
                    Label(jpglab, systemImage: "")
                        .padding([.leading], -12)
                        .padding([.trailing], -2)
                }
                .toggleStyle(.button)
                Toggle(isOn: $save) {
                    Label(" ", systemImage: "square.and.arrow.down")
                        .padding([.leading], -4)
                        .padding([.trailing], -16)
                }
                .toggleStyle(.button)
                Form {
                    HStack {
                        TextField(text: $filename, prompt: Text("filename")) {
//                            Label("  ", systemImage: "doc.questionmark")
//                                .padding([.trailing], -16)
                        }
                        TextField(text: $subfolder, prompt: Text("sub-folder")) {
//                            Label("  ", systemImage: "plus.rectangle.on.folder.fill")
//                                .padding([.trailing], -16)
                        }
                    }
                }
            }
            HStack{
                VStack {
                    Slider(
                           value: $steps,
                           in: 1...20,
                           step: 1
                       ) {
                           Text("Steps")
                       } minimumValueLabel: {
                           Text("0")
                       } maximumValueLabel: {
                           Text("20")
                       } onEditingChanged: { editing in
                           isEditing = editing
                       }
                       Text("\(steps)")
                           .foregroundColor(isEditing ? .red : .blue)
                }
                VStack {
                    Slider(
                           value: $cfg,
                           in: 0.1...15,
                           step: 0.1
                       ) {
                           Text("CFG")
                       } minimumValueLabel: {
                           Text("0")
                       } maximumValueLabel: {
                           Text("15")
                       } onEditingChanged: { editing in
                           isEditing = editing
                       }
                       Text("\(cfg)")
                           .foregroundColor(isEditing ? .red : .blue)
                }
                
                //save square.and.arrow.down
                //seed dice.fill
                
                
                //detect som/dt
                //models
                //schedulers
                //
                Spacer()
            }
          TextField("Prompt:", text: $prompt).onSubmit {
                
              requester.runPrompt(prompt, cfg: cfg, steps: steps, save: save, upscale: upscale, thumbnail: thumbnail, jpeg: jpeg, filename: filename, subfolder: subfolder)
          }

          if requester.image != nil {
            Image(nsImage: requester.image!)
          }
        }
        .padding()
        Spacer()
    }
  }


class simpleImageRequester : ObservableObject {
 static var shared = simpleImageRequester()  //  make it a global, so async routines can find me
  @Published var image:NSImage?

    func runPrompt(_ prompt:String, cfg:Float, steps:Float, save:Bool, upscale:Bool, thumbnail:Bool, jpeg:Bool, filename :String, subfolder:String){
      
        SimpleDTClient.shared.runPrompt(prompt,cfg: cfg,steps: Int(steps), save: save, upscale: upscale, thumbnail: thumbnail, jpeg: jpeg, filename: filename, subfolder: subfolder)
  }

  func returnImage(_ imageData:Data){
    self.image = NSImage(data: imageData)
  }
  

  /// not currently used. you can save the image received
  func saveTmpImage(_ imageData:Data)->URL?
  {
    //    let tempDirectoryURL = FileManager.default.temporaryDirectory
    let tempDirectoryURL = FileManager.default.temporaryDirectory
    let tempFileURL = tempDirectoryURL.appendingPathComponent("tmpImage.png")

    do{
      try imageData.write(to: tempFileURL)
    }
    catch{return nil}
    return tempFileURL
  }
}


#Preview {
    ContentView()
}

