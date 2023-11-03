import SwiftUI
import shared

struct GroupView: View {
    
    @State private var selectedTab: Int = 0

    let tabs: [Tab] = [
        .init(icon: Image(systemName: ""), title: "Friends"),
        .init(icon: Image(systemName: ""), title: "Local"),
    ]


    @Binding var text: String
    
    

	var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Groups")
                    .font(.system(size:38, weight: .bold, design: .default))
                Spacer()
                Image(systemName:"ellipsis.circle")
                    .resizable()
                    .frame(width: 25, height:25, alignment: .center)
                    .padding(8)
                
                Image(systemName:"qrcode.viewfinder")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .center)
                    .padding(8)
                
                Image(systemName:"person.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .center)
                    .padding(8)
                
            }
            .padding()
            
            TextField("Search...", text: $text)
                .padding(7)
                .background(Color(.systemGray5))
                .cornerRadius(13)
                .padding(.horizontal, 15)
            NavigationView {
                       GeometryReader { geo in
                           VStack(spacing: 0) {
                               // Tabs
                               Tabs(tabs: tabs, geoWidth: geo.size.width, selectedTab: $selectedTab)

                               // Views
                               TabView(selection: $selectedTab,
                                       content: {
                                           FriendView()
                                               .tag(0)
                                           LocalView()
                                               .tag(1)
                                       })
                                       .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                           }
                           .ignoresSafeArea()
                       }
                   }
        }
	}
}

struct GroupView_Previews: PreviewProvider {
	static var previews: some View {
        GroupView(text: .constant(""))
	}
}
