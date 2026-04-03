/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.ports.notification_port;
@safe:

/// Outgoing port: send notifications (email, in-app, webhook).
interface NotificationPort
{
  void notify(string userId, string subject, string body_);
  void notifyGroup(string[] userIds, string subject, string body_);
}
