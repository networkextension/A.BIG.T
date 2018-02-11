//
//  SFApplication.swift
//  Surf
//
//  Created by 孔祥波 on 25/11/2016.
//  Copyright © 2016 abigt. All rights reserved.
//

import Cocoa
@objc(SFApplication)
class SFApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if event.type == NSEvent.EventType.keyDown {
            //NSEventModifierFlags
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSEvent.ModifierFlags.command.rawValue {
                switch event.charactersIgnoringModifiers!.lowercased() {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return }
                default:
                    break
                }
            }
            else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue == (NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)) {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return }
                }
            }
        }
        return super.sendEvent(event)
    }
    
}
