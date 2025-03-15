//
//  ContentView.swift
//  ThreadBrowser
//
//  Created by Tomas McGuinness on 04/03/2025.
//

import SwiftUI

#if(canImport(ThreadNetwork))
import ThreadNetwork
#endif

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

struct ContentView: View {
    
    @State var hasCredentials: Bool = false
    @State var operationalDataSet: String?
    
    @State var showingShareSheet: Bool = false
    @State var shareSheetItems: [Any] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 50) {
                if hasCredentials {
                    Text(operationalDataSet!)
                    HStack {
                        Button("Start Over", systemImage: "arrow.clockwise") {
                            hasCredentials = false
                            operationalDataSet = nil
                        }.buttonStyle(.bordered)
                        
                        Button("Share", systemImage: "square.and.arrow.up") {
                            shareSheetItems = [operationalDataSet!]
                            showingShareSheet = true
                        }.buttonStyle(.borderedProminent)
                    }
                } else {
                    Text("To connect to your preferred Thread network and retrieve the Operational Data, click the button below. \n\nYou will be promoted to grant the app access to your Local Network. This is necessary to pull down the credentials.").multilineTextAlignment(.center)
                    Button("Obtain Credentials", systemImage: "square.and.arrow.down") {
                        Task {
                            await obtainPreferredNetworkCredentials()
                        }
                    }.buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle(Text("Thread Credentials"))
            .sheet(isPresented: $showingShareSheet, onDismiss: {
                print("Cancel")
            }, content: {
                ActivityViewController(activityItems: $shareSheetItems)
            })
        }
    }
    
    struct ActivityViewController: UIViewControllerRepresentable {
        @Binding var activityItems: [Any]
        var applicationActivities: [UIActivity]? = nil
        @Environment(\.presentationMode) var presentationMode
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems,
                                                      applicationActivities: applicationActivities)
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
    }
    
    func obtainPreferredNetworkCredentials() async -> (Void) {
        
#if(canImport(ThreadNetwork))
        let client = THClient()
        
        let bIsPreferredAvailable = await client.isPreferredAvailable()
        
        if bIsPreferredAvailable == true
        {
            do {
                let credential = try await client.preferredCredentials()
                
                if let dataset = credential.activeOperationalDataSet {
                    
                    operationalDataSet = dataset.hexDescription
                    hasCredentials = true
                    
                    //print(dataset.hexDescription)
                    //print("Channel: \(credential.channel)")
                    //print("NetworkKey: \(credential.networkKey.hexDescription)")
                }
            } catch {
                print("Failed to get the credentials")
            }
        }
#else
        hasCredentials = true
        operationalDataSet = "OPERATIONSAL DATASET HERE"
#endif
    }
}

#Preview {
    ContentView()
}
