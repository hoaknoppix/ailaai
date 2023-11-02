import SwiftUI
import shared

struct StoryView: View {
	let greet = Greeting().greet()

	var body: some View {
		Text("Hello Story" + greet)
	}
}

struct StoryView_Previews: PreviewProvider {
	static var previews: some View {
		StoryView()
	}
}
