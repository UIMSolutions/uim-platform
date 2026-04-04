/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.adapters.console_notification;

import uim.platform.analytics.app.ports.notification_port;

// import vibe.core.log;

/// Adapter: logs notifications to console (development stand-in for email/push).
class ConsoleNotificationAdapter : NotificationPort {

  void notify(string userId, string subject, string body_)
  {
    logInfo("NOTIFICATION [%s] %s: %s", userId, subject, body_);
  }

  void notifyGroup(string[] userIds, string subject, string body_)
  {
    foreach (uid; userIds)
      notify(uid, subject, body_);
  }
}
