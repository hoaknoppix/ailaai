import SwiftUI
import shared

struct ContentView: View {
	let greet = Greeting().greet()

    var body: some View {
        TabView {

            GroupView(text: .constant(""))
            //            .badge(2)
                .tabItem {
                    Label("", systemImage: "person.2.fill")
                }
            ExploreView()
            //            .badge(2)
                .tabItem {
                    Label("", systemImage: "eye.fill")
                }
            StoryView()
                .tabItem {
                    Label("", systemImage: "bookmark.fill")
                }
        }
        Button(action: {
        }) {
            Text("Next")
                .font(.system(.headline, design: .rounded))
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10.0)
                .padding()
     
        }
    }
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
