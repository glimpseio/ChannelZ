//
//  Observables+AppKit.swift
//  ChannelZ
//
//  Created by Marc Prud'hommeaux <marc@glimpse.io>
//  License: MIT (or whatever)
//

/// Support for AppKit UI channels
#if os(OSX)
    import AppKit

    extension NSControl : KeyValueChannelSupplementing {

        public func controlz() -> EventObservable<NSEvent> {

            if self.target != nil && !(self.target is DispatchTarget) {
                fatalError("controlz event handling overrides existing target/action for control; if this is really what you want to do, explicitly nil the target & action of the control")
            }

            let observer = self.target as? DispatchTarget ?? DispatchTarget() // use the existing dispatch target if it exists
            self.target = observer
            self.action = Selector("execute")

            var observable = EventObservable<NSEvent>(nil)
            observable.dispatchTarget = observer // someone needs to retain the dispatch target; NSControl only holds a weak ref
            observer.actions += [{ observable.outlets.receive($0) }]

            return observable
        }

        public func supplementKeyValueChannel(forKeyPath: String, outlet: (AnyObject?)->()) -> (()->())? {
            // NSControl action events do not trigger KVO notifications, so we manually supplement any outlets with control events

            if forKeyPath == "doubleValue" {
                let outlet = self.controlz().subscribe({ [weak self] _ in outlet(self?.doubleValue) })
                return { outlet.detach() }
            }

            if forKeyPath == "floatValue" {
                let outlet = self.controlz().subscribe({ [weak self] _ in outlet(self?.floatValue) })
                return { outlet.detach() }
            }

            if forKeyPath == "integerValue" {
                let outlet = self.controlz().subscribe({ [weak self] _ in outlet(self?.integerValue) })
                return { outlet.detach() }
            }

            if forKeyPath == "stringValue" {
                let outlet = self.controlz().subscribe({ [weak self] _ in outlet(self?.stringValue) })
                return { outlet.detach() }
            }

            if forKeyPath == "attributedStringValue" {
                let outlet = self.controlz().subscribe({ [weak self] _ in outlet(self?.attributedStringValue) })
                return { outlet.detach() }
            }

            if forKeyPath == "objectValue" {
                let outlet = self.controlz().subscribe({ [weak self] _ in outlet(self?.objectValue) })
                return { outlet.detach() }
            }

            return nil
        }

    }

    extension NSMenuItem {

        public func controlz() -> EventObservable<NSEvent> {

            if self.target != nil && !(self.target is DispatchTarget) {
                fatalError("controlz event handling overrides existing target/action for menu item; if this is really what you want to do, explicitly nil the target & action of the control")
            }

            let observer = self.target as? DispatchTarget ?? DispatchTarget() // use the existing dispatch target if it exists
            self.target = observer
            self.action = Selector("execute")

            var observable = EventObservable<NSEvent>(nil)
            observable.dispatchTarget = observer // someone needs to retain the dispatch target; NSControl only holds a weak ref
            observer.actions += [{ observable.outlets.receive($0) }]
            
            return observable
        }
    }

    @objc public class DispatchTarget : NSObject {
        public var actions : [(NSEvent)->(Void)] = []

        public func execute() {
            let event = NSApplication.sharedApplication().currentEvent ?? NSEvent()
            for action in actions {
                action(event)
            }
        }
    }


#endif
