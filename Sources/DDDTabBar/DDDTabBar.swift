import SwiftUI
import DDDAnimatableColorViewWrapper

public struct DDDTabBar<ChildView>: View where ChildView: View {
    // MARK: Property
    private let tabBarheight: CGFloat = 49
    @Binding var selectedIndex: Int
    let backgroundColor: Color
    let shadowColor: Color
    let tabItems: [DDDTabBarItem]
    let child: () -> ChildView
    
    // MARK: Init
    public init(
        selectedIndex: Binding<Int>,
        backgroundColor: Color = Color.white,
        shadowColor: Color = Color.black.opacity(0.4),
        tabItems: [DDDTabBarItem],
        child: @escaping () -> ChildView
    ) {
        self._selectedIndex = selectedIndex
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.tabItems = tabItems
        self.child = child
    }
    
    // MARK: Body
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    child()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width, height: tabBarheight)
                    
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
                VStack {
                    GeometryReader { grHStack in
                        ZStack(alignment: .top) {
                            DDDTabBarShape(
                                itemCount: tabItems.count,
                                index: selectedIndex,
                                size: CGSize(width: geometry.size.width, height: grHStack.size.height)
                            )
                            .fill(backgroundColor)
                            .shadow(color: shadowColor, radius: 2, x: 0, y: -2)
                            
                            HStack(spacing: 0) {
                                ForEach(0..<tabItems.count) { i in
                                    tabItems[i]
                                        .onTapGesture {
                                            withAnimation(Animation.easeInOut(duration: 0.3)) {
                                                selectedIndex = i
                                            }
                                        }
                                }
                            }
                            .frame(width: geometry.size.width, height: tabBarheight)
                            .padding(.trailing, 5)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: tabBarheight + geometry.safeAreaInsets.bottom)
                .background(backgroundColor)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

public struct DDDTabBarItem: View {
    let isActived: Bool
    
    let selectedColor: Color
    let unselectedColor: Color
    let selectedIcon: () -> Image
    let unselectedIcon: () -> Image
    let selectedText: String
    let unselectedText: String
    
    
    public init(
        isActived: Bool,
        selectedColor: Color,
        unselectedColor: Color,
        selectedIcon: @escaping () -> Image,
        unselectedIcon: (() -> Image)? = nil,
        selectedText: String,
        unselectedText: String? = nil
    ) {
        self.isActived = isActived
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon ?? selectedIcon
        self.selectedText = selectedText
        self.unselectedText = unselectedText ?? selectedText
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DDDAnimatableColorViewWrapper(from: selectedColor, to: unselectedColor, pct: isActived ? 0 : 1) {
                (isActived ? selectedIcon() : unselectedIcon())
                    .scaleEffect(isActived ? 1.5 : 1).offset(x: 0, y: isActived ? -5 : 0)
            }
            DDDAnimatableColorViewWrapper(from: selectedColor, to: unselectedColor, pct: isActived ? 0 : 1) {
                Text(isActived ? selectedText : unselectedText)
                    .font(.system(size: 10))
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}


private struct DDDTabBarShape: Shape, Animatable {
    var index: Int
    var itemCount: Int
    
    var top: CGFloat
    
    var size: CGSize
    
    private var baseWidth: CGFloat
    
    init(itemCount: Int, index: Int, size: CGSize, top: CGFloat = 15) {
        self.itemCount = itemCount
        self.index = index
        self.size = size
        self.baseWidth = CGFloat(index)
        
        self.top = -top
    }
    
    var animatableData: CGFloat {
        get { baseWidth }
        set { self.baseWidth = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = size.width / CGFloat(itemCount)
        let itemCenterX = width / 2 * (baseWidth * 2 + 1)
        
        path.move(to: CGPoint.zero)
        
        path.addLine(to: CGPoint(x: itemCenterX - width / 2, y: 0))
        
        path.addCurve(
            to: CGPoint(x: itemCenterX, y: top),
            control1: CGPoint(x: itemCenterX - width / 4, y: 0),
            control2: CGPoint(x: itemCenterX - width / 4, y: top)
        )
        
        path.addCurve(
            to: CGPoint(x: itemCenterX + width / 2, y: 0),
            control1: CGPoint(x: itemCenterX + width / 4, y: top),
            control2: CGPoint(x: itemCenterX + width / 4, y: 0)
        )
        
        path.addLine(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
        return path
    }
}
