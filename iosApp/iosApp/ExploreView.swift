import SwiftUI
import shared

struct ExploreView: View {
	let greet = Greeting().greet()

	var body: some View {
		Text("Hello Explore" + greet)
	}
}

struct ExploreView_Previews: PreviewProvider {
	static var previews: some View {
		ExploreView()
	}
}
