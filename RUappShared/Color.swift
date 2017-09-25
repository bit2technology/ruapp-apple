//
//  Color.swift
//  RUappShared-iOS
//
//  Created by Igor Camilo on 16/09/17.
//  Copyright © 2017 Bit2 Technology. All rights reserved.
//

#if os(macOS)
    public typealias Color = NSColor
#else
    public typealias Color = UIColor
#endif

public extension Color {
    
    static var appDarkBlue: Color {
        return #colorLiteral(red: 0, green: 0.5463507771, blue: 0.7886484265, alpha: 1)
    }
    
    static var appBlue: Color {
        return #colorLiteral(red: 0.01176470588, green: 0.662745098, blue: 0.9568627451, alpha: 1)
    }
    
    static var appLightBlue: Color {
        return #colorLiteral(red: 0.3098039216, green: 0.7647058824, blue: 0.968627451, alpha: 1)
    }
    
    static var appYellow: Color {
        return #colorLiteral(red: 0.9843137255, green: 0.737254902, blue: 0.1411764706, alpha: 1)
    }
    
    static var appOrange: Color {
        return #colorLiteral(red: 1, green: 0.5490196078, blue: 0, alpha: 1)
    }
    
    static var appRed: Color {
        return #colorLiteral(red: 0.8862745098, green: 0.03921568627, blue: 0.03921568627, alpha: 1)
    }
    
    static var appDarkRed: Color {
        return #colorLiteral(red: 0.7882352941, green: 0.3058823529, blue: 0.3725490196, alpha: 1)
    }
    
    static var appGreen: Color {
        return #colorLiteral(red: 0.3960784314, green: 0.8666666667, blue: 0.09019607843, alpha: 1)
    }
    
    static var appDarkGreen: Color {
        return #colorLiteral(red: 0.4078431373, green: 0.7294117647, blue: 0.2588235294, alpha: 1)
    }
    
    static var appGray: Color {
        return #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    }
}
