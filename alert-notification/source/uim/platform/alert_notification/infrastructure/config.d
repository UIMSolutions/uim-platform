/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.infrastructure.config;
import std.process : environment;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host        = "0.0.0.0";
    ushort port        = 8095;
    string serviceName = "Alert Notification Service";
    size_t maxEventsBuffer   = 10_000;
    size_t retentionSeconds  = 604_800; /// 7 days
}

SrvConfig loadConfig() {
    import std.process : environment;
    import std.conv    : to, ConvException;

    SrvConfig cfg;

    auto host = environment.get("ALERT_NOTIFICATION_HOST", "");
    if (host.length) cfg.host = host;

    auto portStr = environment.get("ALERT_NOTIFICATION_PORT", "");
    if (portStr.length) {
        try cfg.port = portStr.to!ushort;
        catch (ConvException) {}
    }

    auto bufStr = environment.get("ALERT_NOTIFICATION_MAX_EVENTS_BUFFER", "");
    if (bufStr.length) {
        try cfg.maxEventsBuffer = bufStr.to!size_t;
        catch (ConvException) {}
    }

    auto retStr = environment.get("ALERT_NOTIFICATION_RETENTION_SECONDS", "");
    if (retStr.length) {
        try cfg.retentionSeconds = retStr.to!size_t;
        catch (ConvException) {}
    }

    return cfg;
}
