//  Copyright © 2019 650 Industries. All rights reserved.

import ExpoModulesCore

public class QueueUpdatesEventManager: UpdatesEventManager {
  private let logger: UpdatesLogger

  required init(logger: UpdatesLogger) {
    self.logger = logger
  }

  public private(set) weak var appContext: AppContext?
  public private(set) var shouldEmitJsEvents = false {
    didSet {
      if shouldEmitJsEvents == true {
        sendQueuedEventsToAppContext()
      }
    }
  }
  public func setAppContext(appContext: AppContext?) {
    self.appContext = appContext
  }

  public func setShouldEmitJsEvents(shouldEmitJsEvents: Bool) {
    self.shouldEmitJsEvents = shouldEmitJsEvents
  }

  private var eventsToSendToJS: [[String: Any?]] = []

  public func sendUpdateStateChangeEventToAppContext(_ eventType: UpdatesStateEventType, context: UpdatesStateContext) {
    logger.info(message: "sendUpdateStateChangeEventToAppContext(): type = \(eventType)")
    sendEventToAppContext(EXUpdatesStateChangeEventName, "\(eventType)", body: [
      "context": context.json
    ])
  }

  private func sendEventToAppContext(_ eventName: String, _ eventType: String, body: [String: Any?]) {
    var mutableBody = body
    mutableBody["type"] = eventType

    guard let appContext = appContext,
      let eventEmitter = appContext.eventEmitter,
      shouldEmitJsEvents == true else {
      eventsToSendToJS.append([
        "eventName": eventName,
        "mutableBody": mutableBody
      ])
      logger.warn(message: "EXUpdates: Could not emit event: name = \(eventName), type = \(eventType). Event will be emitted when the appContext is available", code: .jsRuntimeError)
      return
    }
    logger.debug(message: "sendEventToAppContext: \(eventName), \(mutableBody)")
    eventEmitter.sendEvent(withName: eventName, body: mutableBody)
  }

  private func sendQueuedEventsToAppContext() {
    guard let appContext = appContext,
      let eventEmitter = appContext.eventEmitter,
      shouldEmitJsEvents == true else {
      return
    }
    eventsToSendToJS.forEach { event in
      guard let eventName = event["eventName"] as? String,
        let mutableBody = event["mutableBody"] as? [String: Any?] else {
        return
      }
      logger.debug(message: "sendEventToAppContext: \(eventName), \(mutableBody)")
      eventEmitter.sendEvent(withName: eventName, body: mutableBody)
    }
    eventsToSendToJS = []
  }
}
