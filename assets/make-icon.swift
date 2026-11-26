// Renders the OneDrive Watchdog app icon as a 1024x1024 PNG.
// Run: swift assets/make-icon.swift <output.png>
import AppKit

let size: CGFloat = 1024
let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

// Background squircle — macOS icon grid: 824pt tile on a 1024 canvas.
let tile = NSRect(x: 100, y: 100, width: 824, height: 824)
let squircle = NSBezierPath(roundedRect: tile, xRadius: 185, yRadius: 185)
NSGradient(
    starting: NSColor(red: 0.13, green: 0.17, blue: 0.28, alpha: 1),
    ending: NSColor(red: 0.06, green: 0.08, blue: 0.15, alpha: 1)
)!.draw(in: squircle, angle: -90)

NSGraphicsContext.saveGraphicsState()
squircle.setClip()
NSColor.white.withAlphaComponent(0.07).setStroke()
let edge = NSBezierPath(roundedRect: tile.insetBy(dx: 3, dy: 3), xRadius: 182, yRadius: 182)
edge.lineWidth = 6
edge.stroke()
NSGraphicsContext.restoreGraphicsState()

// Cloud: a flat base plus three overlapping circles.
let cloud = NSBezierPath(roundedRect: NSRect(x: 222, y: 380, width: 580, height: 190), xRadius: 95, yRadius: 95)
cloud.append(NSBezierPath(ovalIn: NSRect(x: 290, y: 440, width: 230, height: 230)))
cloud.append(NSBezierPath(ovalIn: NSRect(x: 420, y: 470, width: 300, height: 300)))
cloud.append(NSBezierPath(ovalIn: NSRect(x: 612, y: 425, width: 190, height: 190)))
cloud.append(NSBezierPath(rect: NSRect(x: 707, y: 475, width: 95, height: 45)))   // fills the dip between base and right puff
cloud.windingRule = .nonZero
NSGradient(
    starting: NSColor(red: 0.42, green: 0.70, blue: 1.00, alpha: 1),
    ending: NSColor(red: 0.13, green: 0.45, blue: 0.90, alpha: 1)
)!.draw(in: cloud, angle: -90)

// Badge: green circle with a white "restart" arrow, bottom right.
let c = NSPoint(x: 680, y: 330)
let r: CGFloat = 135
NSColor(red: 0.06, green: 0.08, blue: 0.15, alpha: 1).setFill()   // ring separating badge from cloud
NSBezierPath(ovalIn: NSRect(x: c.x - r - 18, y: c.y - r - 18, width: (r + 18) * 2, height: (r + 18) * 2)).fill()
let badge = NSBezierPath(ovalIn: NSRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
NSGradient(
    starting: NSColor(red: 0.22, green: 0.75, blue: 0.45, alpha: 1),
    ending: NSColor(red: 0.12, green: 0.60, blue: 0.34, alpha: 1)
)!.draw(in: badge, angle: -90)

let ar: CGFloat = 70
let arc = NSBezierPath()
arc.appendArc(withCenter: c, radius: ar, startAngle: 110, endAngle: 400)
arc.lineWidth = 26
arc.lineCapStyle = .round
NSColor.white.setStroke()
arc.stroke()

// Arrowhead at the arc's end (400° = 40°), pointing counter-clockwise along the arc.
let end = 40.0 * Double.pi / 180
let tip = NSPoint(x: c.x + ar * CGFloat(cos(end)), y: c.y + ar * CGFloat(sin(end)))
let dir = CGFloat(end + .pi / 2)              // tangent, direction of travel
let normal = CGFloat(end)
let head = NSBezierPath()
head.move(to: NSPoint(x: tip.x + 52 * cos(dir), y: tip.y + 52 * sin(dir)))
head.line(to: NSPoint(x: tip.x + 40 * cos(normal), y: tip.y + 40 * sin(normal)))
head.line(to: NSPoint(x: tip.x - 40 * cos(normal), y: tip.y - 40 * sin(normal)))
head.close()
NSColor.white.setFill()
head.fill()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fputs("Failed to render icon\n", stderr)
    exit(1)
}
try! png.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath)")
