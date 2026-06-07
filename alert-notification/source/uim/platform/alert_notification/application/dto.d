/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.dto;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Event Producer DTOs
// ---------------------------------------------------------------------------

struct PostAffectedResourceRequest {
    string        name;
    string        type_;
    string        instance_;
    string[string] tags;
}

struct PostAlertEventRequest {
    string        eventType;
    string        category;     /// EventCategory string
    string        severity;     /// EventSeverity string
    string        subject;
    string        body;
    string        region;
    string[string] tags;
    PostAffectedResourceRequest affectedResource;
}

// ---------------------------------------------------------------------------
// Condition management DTOs
// ---------------------------------------------------------------------------

struct CreateConditionRequest {
    string   name;
    string   description;
    string   propertyKey;   /// PropertyKey string
    string   predicate;     /// Predicate string
    string   propertyValue;
    bool     mandatory;
    string[] labels;
}

struct UpdateConditionRequest {
    string   description;
    string   propertyKey;
    string   predicate;
    string   propertyValue;
    bool     mandatory;
    string[] labels;
}

// ---------------------------------------------------------------------------
// Action management DTOs
// ---------------------------------------------------------------------------

struct CreateActionRequest {
    string        name;
    string        description;
    string        type_;       /// ActionType string
    string        state;       /// ResourceState string ("ENABLED"|"DISABLED")
    string[string] properties;
    string[]      labels;
    string        fallbackAction;
    bool          enableDeliveryStatus;
}

struct UpdateActionRequest {
    string        description;
    string        state;
    string[string] properties;
    string[]      labels;
    string        fallbackAction;
    bool          enableDeliveryStatus;
}

// ---------------------------------------------------------------------------
// Subscription management DTOs
// ---------------------------------------------------------------------------

struct CreateSubscriptionRequest {
    TenantId tenantId;
    GlobalAccountId globalAccountId;
    string   name;
    string   description;
    string[] conditions;
    string[] actions;
    string   state;       /// ResourceState string
    string[] labels;
}

struct UpdateSubscriptionRequest {
    GlobalAccountId globalAccountId;
    TenantId tenantId;

    string   description;
    string[] conditions;
    string[] actions;
    string   state;
    string[] labels;
    UserId   updatedBy;
}

// ---------------------------------------------------------------------------
// Query DTOs
// ---------------------------------------------------------------------------

struct QueryResult {
    bool   success;
    string message;
    Json   data;
    size_t errorCode;

    this(bool success, string message = "", Json data = Json.emptyObject, size_t errorCode = 0) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.errorCode = errorCode;
    }

    bool hasError() const {
        return !success;
    }

    Json toJson() const {
        return Json.emptyObject
            .set("success", success)
            .set("message", message)
            .set("data", data)
            .set("errorCode", errorCode);
    }
}
