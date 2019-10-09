//
//  ContentView.swift
//  sample
//
//  Created by Anderson Lucas C. Ramos on 09/10/19.
//  Copyright © 2019 Globo.com. All rights reserved.
//

import SwiftUI
import SSDP

struct ContentView: View {
    let controller = DeviceController.init()
    
    var body: some View {
        VStack() {
            Button.init("Send Notify request") {
                self.controller.notify()
            }.frame(height: 50, alignment: Alignment.center)
            
            Button.init("Send Search request") {
                self.controller.search()
            }.frame(height: 50, alignment: Alignment.center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
