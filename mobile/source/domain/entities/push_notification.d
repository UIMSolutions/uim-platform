module domain.entities.push_notification;

import domain.types;

/// A push notification message sent to one or more devices.
struct PushNotification
{
    PushNotificationId id;
    MobileAppId appId;
    TenantId tenantId;
    PushTemplateId templateId;      // optional template reference
    string title;
    string body_;
    string imageUrl;
    string deepLink;                // in-app navigation target
    PushPriority priority = PushPriority.normal;
    PushStatus status = PushStatus.pending;
    string[] targetDeviceIds;       // specific devices
    string[] targetUserIds;         // specific users (all their devices)
    string targetSegment;           // user segment expression
    MobilePlatform[] targetPlatforms;
    string[string] customData;      // key/value payload
    int badge = 0;                  // iOS badge count
    string sound = "default";
    bool silent = false;            // background/data-only
    long scheduledAt;               // 0 = send immediately
    long sentAt;
    long expiresAt;
    int deliveredCount;
    int failedCount;
    string createdBy;
    long createdAt;
}
