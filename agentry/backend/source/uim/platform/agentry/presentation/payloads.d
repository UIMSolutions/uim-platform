/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reading request payloads (JSON objects) into use case DTOs. Shared by the
/// REST, vibe.d REST-interface and OData adapters. Only keys that are present
/// are copied, so the same readers serve create (POST) and merge (PATCH/PUT)
/// requests: for updates the DTO is first filled from the current entity.
module uim.platform.agentry.presentation.payloads;

import std.datetime.systime : SysTime;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Invalid request payload — reported as HTTP 400.
class PayloadException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

private bool has(Json body, string key) {
  auto v = key in body;
  return v !is null && v.type != Json.Type.undefined && v.type != Json.Type.null_;
}

/// Copy a string property (numbers / booleans are stringified).
void readString(Json body, string key, ref string target) {
  if (!has(body, key))
    return;
  auto v = body[key];
  target = v.type == Json.Type.string ? v.get!string : v.toString;
}

void readBool(Json body, string key, ref bool target) {
  if (!has(body, key))
    return;
  auto v = body[key];
  if (v.type == Json.Type.bool_)
    target = v.get!bool;
  else if (v.type == Json.Type.string)
    target = ["true", "1", "yes", "on"].canFind(v.get!string.toLower);
  else
    throw new PayloadException(key ~ " must be a boolean");
}

void readLong(Json body, string key, ref long target) {
  if (!has(body, key))
    return;
  auto v = body[key];
  try {
    if (v.type == Json.Type.int_)
      target = v.get!long;
    else if (v.type == Json.Type.float_)
      target = cast(long) v.get!double;
    else if (v.type == Json.Type.string)
      target = v.get!string.to!long; // Edm.Int64 with IEEE754Compatible=true
    else
      throw new PayloadException(key ~ " must be a number");
  } catch (ConvException) {
    throw new PayloadException(key ~ " must be a number");
  }
}

/// A timestamp: stdTime number or ISO 8601 / Edm.DateTimeOffset string.
void readTime(Json body, string key, ref long target) {
  if (!has(body, key))
    return;
  auto v = body[key];
  if (v.type == Json.Type.string) {
    auto s = v.get!string;
    if (s.length == 0) {
      target = 0;
      return;
    }
    try
      target = SysTime.fromISOExtString(s).stdTime;
    catch (Exception)
      throw new PayloadException(key ~ " must be an ISO 8601 timestamp");
  } else
    readLong(body, key, target);
}

void readId(TId)(Json body, string key, ref TId target) {
  string value;
  readString(body, key, value);
  if (value.length)
    target = TId(value);
}

/// The id of a referenced application: "mobileApplicationId" or "applicationId".
private void readApplicationId(Json body, ref MobileApplicationId target) {
  readId(body, "applicationId", target);
  readId(body, "mobileApplicationId", target);
}

private void requireObject(Json body) {
  if (body.type != Json.Type.object)
    throw new PayloadException("Request body must be a JSON object");
}

void readPayload(ref MobileApplicationDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.applicationId);
  readString(body, "name", d.name);
  readString(body, "description", d.description);
  readString(body, "platform", d.platform);
  readString(body, "status", d.status);
  readString(body, "iconUrl", d.iconUrl);
  readString(body, "category", d.category);
  readString(body, "vendor", d.vendor);
  readString(body, "contactEmail", d.contactEmail);
  readString(body, "backendSystemId", d.backendSystemId);
  readBool(body, "offlineCapable", d.offlineCapable);
  readBool(body, "pushNotificationsEnabled", d.pushNotificationsEnabled);
  readString(body, "minOsVersion", d.minOsVersion);
  readString(body, "packageName", d.packageName);
}

void readPayload(ref AppDefinitionDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.definitionId);
  readApplicationId(body, d.applicationId);
  readString(body, "name", d.name);
  readString(body, "description", d.description);
  readString(body, "status", d.status);
  readString(body, "definitionContent", d.definitionContent);
  readString(body, "definitionFormat", d.definitionFormat);
  readString(body, "schemaVersion", d.schemaVersion);
  readId(body, "authoredBy", d.authoredBy);
  readString(body, "targetPlatform", d.targetPlatform);
  readString(body, "businessObjectModel", d.businessObjectModel);
}

void readPayload(ref AppVersionDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.versionId);
  readApplicationId(body, d.applicationId);
  readId(body, "definitionId", d.definitionId);
  readString(body, "versionNumber", d.versionNumber);
  readString(body, "releaseNotes", d.releaseNotes);
  readString(body, "status", d.status);
  readString(body, "artifactUrl", d.artifactUrl);
  readString(body, "checksum", d.checksum);
  readString(body, "minOsVersion", d.minOsVersion);
  readString(body, "changeLog", d.changeLog);
  readBool(body, "isMandatoryUpdate", d.isMandatoryUpdate);
}

void readPayload(ref DeviceDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.deviceId);
  readApplicationId(body, d.applicationId);
  readString(body, "deviceName", d.deviceName);
  readString(body, "deviceModel", d.deviceModel);
  readString(body, "manufacturer", d.manufacturer);
  readString(body, "platform", d.platform);
  readString(body, "osVersion", d.osVersion);
  readString(body, "appVersionInstalled", d.appVersionInstalled);
  readString(body, "status", d.status);
  readString(body, "pushToken", d.pushToken);
  readId(body, "userId", d.userId);
  readString(body, "userEmail", d.userEmail);
  readString(body, "groupName", d.groupName);
  readBool(body, "isManaged", d.isManaged);
  readString(body, "mdmDeviceId", d.mdmDeviceId);
}

void readPayload(ref SyncSessionDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.sessionId);
  readId(body, "deviceId", d.deviceId);
  readApplicationId(body, d.applicationId);
  readId(body, "connectionId", d.connectionId);
  readString(body, "status", d.status);
  readString(body, "direction", d.direction);
  readId(body, "triggeredBy", d.triggeredBy);
  readString(body, "clientAppVersion", d.clientAppVersion);
}

void readPayload(ref SyncMetricsDTO d, Json body) {
  requireObject(body);
  readLong(body, "bytesSent", d.bytesSent);
  readLong(body, "bytesReceived", d.bytesReceived);
  readLong(body, "recordsSent", d.recordsSent);
  readLong(body, "recordsReceived", d.recordsReceived);
}

void readPayload(ref BackendConnectionDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.connectionId);
  readString(body, "name", d.name);
  readString(body, "description", d.description);
  readString(body, "backendType", d.backendType);
  readString(body, "status", d.status);
  readString(body, "backendUrl", d.backendUrl);
  readString(body, "clientId", d.clientId);
  readString(body, "authMethod", d.authMethod);
  readString(body, "sysId", d.sysId);
  readString(body, "sysNumber", d.sysNumber);
  readString(body, "client", d.client);
  readString(body, "language", d.language);
  readString(body, "destinationName", d.destinationName);
  readBool(body, "sslEnabled", d.sslEnabled);
  readString(body, "certificateFingerprint", d.certificateFingerprint);
}

void readPayload(ref DeploymentDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.deploymentId);
  readApplicationId(body, d.applicationId);
  readId(body, "appVersionId", d.versionId);
  readId(body, "versionId", d.versionId);
  readString(body, "status", d.status);
  readString(body, "scope", d.scope_);
  readString(body, "targetDeviceId", d.targetDeviceId);
  readString(body, "targetGroupName", d.targetGroupName);
  readTime(body, "scheduledAt", d.scheduledAt);
  readId(body, "deployedBy", d.deployedBy);
  readString(body, "notes", d.notes);
}

/// HTTP status for a use case result (400/404/409/422, default 400).
int httpStatusOf(const UsecaseResult result) {
  switch (result.code) {
  case 404, 409, 422:
    return cast(int) result.code;
  default:
    return 400;
  }
}

///
unittest {
  mixin(ShowTest!("payloads"));

  DeviceDTO d;
  readPayload(d, parseJsonString(`{"mobileApplicationId": "a1", "deviceName": "X", "isManaged": "true"}`));
  assert(d.applicationId.value == "a1" && d.deviceName == "X" && d.isManaged);

  DeploymentDTO dep;
  readPayload(dep, parseJsonString(`{"appVersionId": "v1", "scheduledAt": "2026-11-09T10:00:00Z", "scope": "group"}`));
  assert(dep.versionId.value == "v1" && dep.scheduledAt > 0 && dep.scope_ == "group");

  SyncMetricsDTO m;
  readPayload(m, parseJsonString(`{"bytesSent": "1024", "recordsSent": 3}`));
  assert(m.bytesSent == 1024 && m.recordsSent == 3);

  bool failed;
  try
    readPayload(m, parseJsonString(`{"bytesSent": "many"}`));
  catch (PayloadException)
    failed = true;
  assert(failed);
}
