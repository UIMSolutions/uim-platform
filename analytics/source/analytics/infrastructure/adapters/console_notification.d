module analytics.infrastructure.adapters.console_notification;

import analytics.app.ports.notification_port;
import vibe.core.log;

/// Adapter: logs notifications to console (development stand-in for email/push).
class ConsoleNotificationAdapter : NotificationPort {

    void notify(string userId, string subject, string body_) {
        logInfo("NOTIFICATION [%s] %s: %s", userId, subject, body_);
    }

    void notifyGroup(string[] userIds, string subject, string body_) {
        foreach (uid; userIds)
            notify(uid, subject, body_);
    }
}
