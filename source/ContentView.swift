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
    @State var oldPrompt:String=""
  @State var prompt:String=""
    @State var seed:Int = -1
    @State var save:Bool=false
    @State var upscale:Bool=false
    @State var thumbnail:Bool=false
    @State var jpeg:Bool=false
    @State var style:Bool=false
    @State var jpglab:String = ".jpg"
    @State var cfg :Float = 0.9
    @State var steps :Float = 2
    @State var filename:String = ""
    @State var subfolder:String = ""
    @State private var isEditing = false
    @ObservedObject var requester = simpleImageRequester.shared
    //version
    @State private var server = "Serve-O-Matic"
        let servers = ["Serve-O-Matic", "Draw Things"]
    //realtime
    @State private var Realtime = false
    @State var Active = false

    var body: some View {
        VStack {
            HStack{
                //version dropdown
                Picker("Select a server", selection: $server) {
                    ForEach(servers, id: \.self) {
                        Text($0)
                    }
                }
                //                VStack{
                //                    // real time button
                //                    Toggle(isOn: $Realtime) {
                //                        Label("Realtime", systemImage: "repeat")
                //                            .padding([.leading], 0)
                //                            .padding([.trailing], 0)
                //                    }
                //                }
                //                .toggleStyle(.button)
                
                if Realtime == false{
                    Button("Realtime", systemImage: "repeat") {
                        Task {
                            Realtime = true
                            seed = Int(Int32.random(in: 0..<99999999))
                            Active = true
                            if Realtime == true {
                                await RealtimeMode()
                                // Continuously generate images in the background
                                while Realtime == true {
                                    print("realtime is \(Realtime)")
                                    let promptsNotChanged = (prompt == oldPrompt)
                                    //  && (negative_prompt == oldnegative_prompt)
                                    print("prompt not changed is \(promptsNotChanged)")
                                    if  promptsNotChanged {
                                        // Wait for a certain duration before the next iteration
                                        print("Waiting for prompts to change...")
                                        print("prompt not changed is \(promptsNotChanged)")
                                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    } else {
                                        // Generate images
                                        await RealtimeMode()
                                        oldPrompt = prompt
                                        // oldnegative_prompt = negative_prompt
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                if Realtime{
                    Button("Realtime On", systemImage: "") {
                        Task {
                            Realtime = false
                        }
                    }
                }
            }
            
            if server == "Serve-O-Matic" {
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
                    
                    Toggle(isOn: $style) {
                        Label("Styles", systemImage: "dice.fill")
                            .padding([.leading], -2)
                            .padding([.trailing], -2)
                    }
                    .toggleStyle(.button)
                    
                    Form {
                        HStack {
                            TextField(text: $filename, prompt: Text("filename")) {
                            }
                            TextField(text: $subfolder, prompt: Text("sub-folder")) {
                            }
                        }
                    }
                }
                Divider()
                
            }
            
            HStack{
                VStack {
                    Slider(
                        value: $steps,
                        in: 1...20,
                        step: 1
                    ) {
                        Text("Steps :")
                        Text(String(steps.formatted(.number.precision(.fractionLength(0)))))
                            .foregroundColor(isEditing ? .red : .blue)
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("20")
                    } onEditingChanged: { editing in
                        isEditing = editing
                    }
                }
                Divider()
                VStack {
                    Slider(
                        value: $cfg,
                        in: 0.1...15,
                        step: 0.1
                    ) {
                        Text("CFG ")
                        Text(String(cfg.formatted(.number.precision(.fractionLength(1)))))                           .foregroundColor(isEditing ? .red : .blue)
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("15")
                    } onEditingChanged: { editing in
                        isEditing = editing
                    }
                }
                
                
                Spacer()
            }
            .frame(maxHeight: 40)
            HStack{
                
                TextField("Prompt:", text: $prompt, axis: .vertical).onSubmit {
                    if Realtime != true {
                        requester.runPrompt(prompt, cfg: cfg, steps: steps, save: save, upscale: upscale, thumbnail: thumbnail, jpeg: jpeg, filename: filename, subfolder: subfolder, style: style, seed: Int(Int32.random(in: 0..<99999999)))
                    }
                }
                .lineLimit(4...)
                .textFieldStyle(.roundedBorder)
            }
            HStack{
                if requester.image != nil {
                    Image(nsImage: requester.image!)
                }
            }
            .padding()
        }
        .padding()
        Spacer()
    }
    func RealtimeMode() async {
        requester.runPrompt(prompt, cfg: cfg, steps: steps, save: save, upscale: upscale, thumbnail: thumbnail, jpeg: jpeg, filename: filename, subfolder: subfolder, style: style, seed: seed)
    }
  }


class simpleImageRequester : ObservableObject {
 static var shared = simpleImageRequester()  //  make it a global, so async routines can find me
  @Published var image:NSImage?
    
    func runPrompt(_ prompt:String, cfg:Float, steps:Float, save:Bool, upscale:Bool, thumbnail:Bool, jpeg:Bool, filename :String, subfolder:String, style:Bool, seed: Int){
      
        SimpleDTClient.shared.runPrompt(prompt,cfg: cfg,steps: Int(steps), save: save, upscale: upscale, thumbnail: thumbnail, jpeg: jpeg, filename: filename, subfolder: subfolder, style: style, seed: seed)
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

