module uim.platform.analytics.app.ports.notification_port;
@safe:

/// Outgoing port: send notifications (email, in-app, webhook).
interface NotificationPort {
    void notify(string userId, string subject, string body_);
    void notifyGroup(string[] userIds, string subject, string body_);
}
