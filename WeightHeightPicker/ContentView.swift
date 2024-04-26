//
//  ContentView.swift
//  WeightHeightPicker
//
//  Created by Alisa Serhiienko on 26.04.2024.
//
//

import SwiftUI

extension Color {
    
    static var systemPurple: Color {
        Color(UIColor(red: 103/255, green: 82/255, blue: 240/255, alpha: 1))
    }
}

struct ContentView: View {
    @State var offset: CGFloat = 0
    @State var unit: String = "kg"
    let kgStartWeight = 40
    let kgEndWeight = 250
    let lbsStartWeight = Int(40 * 2.20462)
    let lbsEndWeight = Int(250 * 2.20462)
    
    var body: some View {
        ZStack {
            Color.systemPurple
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("What is your weight?")
                    .font(.system(size: 24, weight: .medium))
                    .padding(.bottom, 88)
                    .foregroundColor(.white)
                
                Text("\(getWeight()) \(unit)")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.yellow)
                    .padding(.bottom, 32)
                
                
                let pickerCount = unit == "kg" ? kgEndWeight - kgStartWeight : lbsEndWeight - lbsStartWeight + 1
                
                CustomSlider(pickerCount: pickerCount, offset: $offset, unit: $unit) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(unit == "kg" ? kgStartWeight ... kgEndWeight : lbsStartWeight ... lbsEndWeight, id: \.self) { weight in
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(.yellow.opacity(0.6))
                                        .frame(width: 2, height: weight % 5 == 0 ? 40 : 20)
                                }
                                .frame(width: 13)
                            }
                        }
                        .background(Color.systemPurple)
                        .offset(x: (getRect().width - 75) / 2 - offset)
                        .padding(.trailing, getRect().width / 2 - 15)
                        .padding(.bottom, 64)
                    }
                    .background(Color.systemPurple)
                }
                .frame(height: 100)
                .overlay(content: {
                    Rectangle()
                        .fill(.yellow)
                        .frame(width: 2.3, height: 64)
                        .offset(x:1, y:-28)
                })
                .padding()
                
                HStack {
                    
                    Button("kg") {
                        withAnimation(.linear) {
                            unit = "kg"
                            offset = 0
                        }
                        
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(unit == "kg" ? Color.systemPurple : Color.white)
                    .padding(12)
                    .background(unit == "kg" ? Color.white : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .clipShape(Circle())
                    .padding(.horizontal, 20)
                    
                    
                    Button("lbs") {
                        withAnimation(.linear) {
                            unit = "lbs"
                            offset = 0
                        }
                        
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(unit == "lbs" ? Color.systemPurple : Color.white)
                    .padding(12)
                    .background(unit == "lbs" ? Color.white : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .clipShape(Circle())
                    .padding(.horizontal, 20)
                    
                    
                }
            }
            .padding()
        }
    }
    
    func getWeight() -> String {
        let startWeight = unit == "kg" ? kgStartWeight : lbsStartWeight
        let weightIncrement = Int(round(Double(offset / CGFloat(13))))
        let calculatedWeight = startWeight + weightIncrement
        let maxWeight = unit == "kg" ? kgEndWeight : lbsEndWeight
        return "\(min(maxWeight, calculatedWeight))"
    }
}

func getRect() -> CGRect {
    UIScreen.main.bounds
}

struct CustomSlider<Content: View>: UIViewRepresentable {
    var content: Content
    @Binding var offset: CGFloat
    @Binding var unit: String
    var pickerCount: Int
    
    init(pickerCount: Int, offset: Binding<CGFloat>, unit: Binding<String>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._offset = offset
        self._unit = unit
        self.pickerCount = pickerCount
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let swiftUIView = UIHostingController(rootView: content).view!
        swiftUIView.backgroundColor = .clear
        let width = CGFloat(pickerCount * 13) + getRect().width
        swiftUIView.frame = CGRect(x: 0, y: 0, width: width, height: 100)
        scrollView.contentSize = swiftUIView.frame.size
        scrollView.addSubview(swiftUIView)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let newWidth = CGFloat(pickerCount * 13) + getRect().width
        uiView.subviews.first?.frame.size.width = newWidth
        uiView.contentSize = CGSize(width: newWidth, height: 100)
        
        UIView.animate(withDuration: 0.3, animations: {
            uiView.contentOffset.x = offset
        })
        
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: CustomSlider
        
        init(parent: CustomSlider) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                let maxOffsetX = CGFloat((self.parent.pickerCount - 1) * 13)
                self.parent.offset = min(scrollView.contentOffset.x, maxOffsetX)
            }
        }
    }
}


#Preview {
    ContentView()
}
