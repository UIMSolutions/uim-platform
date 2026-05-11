/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.situation_action;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct ApiConfig {
    string baseUrl;
    string path;
    HttpMethod method;
    string authType;
    string destinationName;
    string[][] headers;
    string bodyTemplate;
    int timeoutSeconds;
    int retryCount;

    Json toJson() const {
        return Json.emptyObject
            .set("baseUrl", baseUrl)
            .set("path", path)
            .set("method", method.to!string())
            .set("authType", authType)
            .set("destinationName", destinationName)
            .set("headers", headers.map!(h => [h[0], h[1]]).array.toJson)
            .set("bodyTemplate", bodyTemplate)
            .set("timeoutSeconds", timeoutSeconds)
            .set("retryCount", retryCount);
    }
}

struct SituationAction {
    mixin TenantEntity!(SituationActionId);

    string name;
    string description;
    ActionType type;
    ActionStatus status;
    ApiConfig apiConfig;
    string webhookUrl;
    string emailTemplate;
    string scriptContent;
    string[] applicableTemplateIds;
    long lastExecutedAt;
    long executionCount;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("type", type.to!string())
            .set("status", status.to!string())
            .set("apiConfig", apiConfig.toJson())
            .set("webhookUrl", webhookUrl)
            .set("emailTemplate", emailTemplate)
            .set("scriptContent", scriptContent)
            .set("applicableTemplateIds", applicableTemplateIds.array.toJson)
            .set("lastExecutedAt", lastExecutedAt)
            .set("executionCount", executionCount);
    }
}
