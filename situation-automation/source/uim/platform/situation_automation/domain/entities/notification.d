/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.notification;
// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
struct Notification {
    mixin TenantEntity!(NotificationId);

    SituationInstanceId situationInstanceId;
    string recipientId;
    string title;
    string message;
    NotificationChannel channel;
    NotificationStatus status;
    NotificationPriority priority;
    string actionUrl;
    long sentAt;
    long readAt;

    Json toJson() const {
        auto j = entityToJson
            .set("situationInstanceId", situationInstanceId.value)
            .set("recipientId", recipientId)
            .set("title", title)
            .set("message", message)
            .set("channel", channel.to!string())
            .set("status", status.to!string())
            .set("priority", priority.to!string())
            .set("actionUrl", actionUrl)
            .set("sentAt", sentAt)
            .set("readAt", readAt);

        return j;
    }
}
