import SwiftUI

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

fileprivate extension Color {
    #if os(macOS)
    typealias SystemColor = NSColor
    #else
    typealias SystemColor = UIColor
    #endif
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        return (r, g, b, a)
    }

    var hexValue: String? {
        guard let components = self.rgba else { return nil }
        return String(format: "#%02X%02X%02X", Int(components.red * 255), Int(components.green * 255), Int(components.blue * 255))
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case name, hex
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let colorName = try container.decodeIfPresent(String.self, forKey: .name) {
            switch colorName {
            case "red": self = .red
            case "green": self = .green
            case "blue": self = .blue
            case "yellow": self = .yellow
            case "orange": self = .orange
            case "accentColor": self = .accentColor
            case "black": self = .black
            case "white": self = .white
            case "gray": self = .gray
            case "brown": self = .brown
            case "clear": self = .clear
            case "cyan": self = .cyan
            case "indigo": self = .indigo
            case "mint": self = .mint
            case "pink": self = .pink
            case "primary": self = .primary
            case "secondary": self = .secondary
            case "teal": self = .teal
            case "purple": self = .purple
                
            default:
                throw DecodingError.dataCorruptedError(forKey: .name,
                                                       in: container,
                                                       debugDescription: "Unsupported color name")
            }
        } else if let hex = try container.decodeIfPresent(String.self, forKey: .hex) {
            guard let color = Color(hex: hex) else {
                throw DecodingError.dataCorruptedError(forKey: .hex,
                                                       in: container,
                                                       debugDescription: "Invalid hex code")
            }
            self = color
        } else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.hex,
                                                   in: container,
                                                   debugDescription: "Color must have either a name or hex value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .red:
            try container.encode("red", forKey: .name)
        case .green:
            try container.encode("green", forKey: .name)
        case .blue:
            try container.encode("blue", forKey: .name)
        default:
            if let hexValue = self.hexValue {
                try container.encode(hexValue, forKey: .hex)
            } else {
                throw EncodingError.invalidValue(self,
                                                 EncodingError.Context(codingPath: encoder.codingPath,
                                                                       debugDescription: "Non-standard color cannot be encoded"))
            }
        }
    }
}

extension Color {
    init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0

                    self = Color(red: r, green: g, blue: b, opacity: a)
                    return
                }
            }
        }
        
        return nil
    }
}
