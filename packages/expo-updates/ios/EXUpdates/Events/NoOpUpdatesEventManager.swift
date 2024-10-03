//  Copyright © 2019 650 Industries. All rights reserved.

import ExpoModulesCore

public class NoOpUpdatesEventManager: UpdatesEventManager {
  public private(set) var appContext: AppContext?
  public private(set) var shouldEmitJsEvents: Bool = false

  public func setAppContext(appContext: AppContext?) {
    self.appContext = appContext
  }

  public func setShouldEmitJsEvents(shouldEmitJsEvents: Bool) {
    self.shouldEmitJsEvents = shouldEmitJsEvents
  }

  public func sendUpdateStateChangeEventToAppContext(_ eventType: UpdatesStateEventType, context: UpdatesStateContext) {}
}
