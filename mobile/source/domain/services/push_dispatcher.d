module uim.platform.xyz.domain.services.push_dispatcher;

import uim.platform.xyz.domain.entities.push_notification;
import uim.platform.xyz.domain.entities.push_template;
import uim.platform.xyz.domain.entities.device_registration;
import uim.platform.xyz.domain.types;

/// Domain service: validates and prepares push notifications for dispatch.
class PushDispatcher
{
    /// Validate a push notification has valid targets and content.
    DispatchValidation validateNotification(PushNotification notification)
    {
        DispatchValidation v;
        v.valid = true;

        if (notification.title.length == 0 && !notification.silent)
        {
            v.valid = false;
            v.reason = "Non-silent notification must have a title";
            return v;
        }

        bool hasTargets = notification.targetDeviceIds.length > 0
            || notification.targetUserIds.length > 0
            || notification.targetSegment.length > 0;
        if (!hasTargets)
        {
            v.valid = false;
            v.reason = "Notification must have at least one target (devices, users, or segment)";
            return v;
        }

        return v;
    }

    /// Resolve template placeholders in notification text.
    string resolveTemplate(string template_, string[string] variables)
    {
        string result = template_;
        foreach (key, value; variables)
        {
            import std.string : replace;
            result = result.replace("{{" ~ key ~ "}}", value);
        }
        return result;
    }

    /// Filter devices matching the notification target platforms.
    DeviceRegistration[] filterTargetDevices(
        DeviceRegistration[] devices, MobilePlatform[] targetPlatforms)
    {
        if (targetPlatforms.length == 0)
            return devices;

        import std.algorithm : filter, canFind;
        import std.array : array;
        return devices.filter!(d => targetPlatforms.canFind(d.platform)).array;
    }
}

/// Result of dispatch validation.
struct DispatchValidation
{
    bool valid;
    string reason;
}
