/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Conversion of domain entities to OData v4 JSON payloads.
/// Requests are read with presentation.payloads (shared with REST).
module uim.platform.agentry.presentation.odata.serializers;

import core.time : Duration;
import std.datetime.systime : SysTime;
import std.datetime.timezone : UTC;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// stdTime (hnsecs) → Edm.DateTimeOffset ("2026-11-09T10:00:00Z"); 0 → null.
Json odataTime(long stdTime) {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime, UTC());
  t.fracSecs = Duration.zero;
  return Json(t.toISOExtString);
}

private void base(T)(ref Json j, const ref T e) {
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdBy"] = e.createdBy.value;
  j["createdAt"] = odataTime(e.createdAt);
  j["updatedBy"] = e.updatedBy.value;
  j["updatedAt"] = odataTime(e.updatedAt);
}

Json toOData(const MobileApplication e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["platform"] = enumValue(e.platform);
  j["status"] = enumValue(e.status);
  j["iconUrl"] = e.iconUrl;
  j["category"] = e.category;
  j["vendor"] = e.vendor;
  j["contactEmail"] = e.contactEmail;
  j["backendSystemId"] = e.backendSystemId;
  j["offlineCapable"] = e.offlineCapable;
  j["pushNotificationsEnabled"] = e.pushNotificationsEnabled;
  j["minOsVersion"] = e.minOsVersion;
  j["packageName"] = e.packageName;
  return j;
}

Json toOData(const AppDefinition e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["applicationId"] = e.applicationId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = enumValue(e.status);
  j["definitionContent"] = e.definitionContent;
  j["definitionFormat"] = e.definitionFormat;
  j["schemaVersion"] = e.schemaVersion;
  j["authoredBy"] = e.authoredBy.value;
  j["targetPlatform"] = e.targetPlatform;
  j["businessObjectModel"] = e.businessObjectModel;
  j["validationPassed"] = e.validationPassed;
  j["validationErrors"] = e.validationErrors;
  j["publishedAt"] = odataTime(e.publishedAt);
  return j;
}

Json toOData(const AppVersion e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["mobileApplicationId"] = e.mobileApplicationId.value;
  j["definitionId"] = e.definitionId.value;
  j["versionNumber"] = e.versionNumber;
  j["releaseNotes"] = e.releaseNotes;
  j["status"] = enumValue(e.status);
  j["builtAt"] = odataTime(e.builtAt);
  j["publishedAt"] = odataTime(e.publishedAt);
  j["artifactUrl"] = e.artifactUrl;
  j["checksum"] = e.checksum;
  j["minOsVersion"] = e.minOsVersion;
  j["changeLog"] = e.changeLog;
  j["isMandatoryUpdate"] = e.isMandatoryUpdate;
  return j;
}

Json toOData(const MobileDevice e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["mobileApplicationId"] = e.mobileApplicationId.value;
  j["deviceName"] = e.deviceName;
  j["deviceModel"] = e.deviceModel;
  j["manufacturer"] = e.manufacturer;
  j["platform"] = enumValue(e.platform);
  j["osVersion"] = e.osVersion;
  j["appVersionInstalled"] = e.appVersionInstalled;
  j["status"] = enumValue(e.status);
  j["enrolledAt"] = odataTime(e.enrolledAt);
  j["lastSeenAt"] = odataTime(e.lastSeenAt);
  j["userId"] = e.userId.value;
  j["userEmail"] = e.userEmail;
  j["groupName"] = e.groupName;
  j["isManaged"] = e.isManaged;
  j["mdmDeviceId"] = e.mdmDeviceId;
  return j;
}

Json toOData(const SyncSession e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["deviceId"] = e.deviceId.value;
  j["applicationId"] = e.applicationId.value;
  j["connectionId"] = e.connectionId.value;
  j["status"] = enumValue(e.status);
  j["direction"] = enumValue(e.direction);
  j["startedAt"] = odataTime(e.startedAt);
  j["completedAt"] = odataTime(e.completedAt);
  j["bytesSent"] = e.bytesSent;
  j["bytesReceived"] = e.bytesReceived;
  j["recordsSent"] = e.recordsSent;
  j["recordsReceived"] = e.recordsReceived;
  j["errorMessage"] = e.errorMessage;
  j["clientAppVersion"] = e.clientAppVersion;
  j["triggeredBy"] = e.triggeredBy.value;
  return j;
}

Json toOData(const BackendConnection e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["backendType"] = enumValue(e.backendType);
  j["status"] = enumValue(e.status);
  j["backendUrl"] = e.backendUrl;
  j["clientId"] = e.clientId;
  j["authMethod"] = e.authMethod;
  j["sysId"] = e.sysId;
  j["sysNumber"] = e.sysNumber;
  j["client"] = e.client;
  j["language"] = e.language;
  j["destinationName"] = e.destinationName;
  j["lastTestedAt"] = odataTime(e.lastTestedAt);
  j["lastTestedBy"] = e.lastTestedBy;
  j["sslEnabled"] = e.sslEnabled;
  j["certificateFingerprint"] = e.certificateFingerprint;
  return j;
}

Json toOData(const Deployment e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["mobileApplicationId"] = e.mobileApplicationId.value;
  j["appVersionId"] = e.appVersionId.value;
  j["status"] = enumValue(e.status);
  j["scope"] = enumValue(e.scope_);
  j["targetDeviceId"] = e.targetDeviceId;
  j["targetGroupName"] = e.targetGroupName;
  j["scheduledAt"] = odataTime(e.scheduledAt);
  j["startedAt"] = odataTime(e.startedAt);
  j["completedAt"] = odataTime(e.completedAt);
  j["rollbackVersionId"] = e.rollbackVersionId;
  j["deployedBy"] = e.deployedBy.value;
  j["notes"] = e.notes;
  j["devicesTotal"] = cast(int) e.devicesTotal;
  j["devicesSucceeded"] = cast(int) e.devicesSucceeded;
  j["devicesFailed"] = cast(int) e.devicesFailed;
  return j;
}

Json toOData(const AgentryStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId.value;
  j["mobileApplications"] = cast(int) s.mobileApplications;
  j["activeApplications"] = cast(int) s.activeApplications;
  j["appDefinitions"] = cast(int) s.appDefinitions;
  j["publishedDefinitions"] = cast(int) s.publishedDefinitions;
  j["appVersions"] = cast(int) s.appVersions;
  j["publishedVersions"] = cast(int) s.publishedVersions;
  j["devices"] = cast(int) s.devices;
  j["activeDevices"] = cast(int) s.activeDevices;
  j["suspendedDevices"] = cast(int) s.suspendedDevices;
  j["syncSessions"] = cast(int) s.syncSessions;
  j["runningSyncs"] = cast(int) s.runningSyncs;
  j["failedSyncs"] = cast(int) s.failedSyncs;
  j["backendConnections"] = cast(int) s.backendConnections;
  j["connectionErrors"] = cast(int) s.connectionErrors;
  j["deployments"] = cast(int) s.deployments;
  j["runningDeployments"] = cast(int) s.runningDeployments;
  j["failedDeployments"] = cast(int) s.failedDeployments;
  j["bytesTransferred"] = s.bytesTransferred;
  j["recordsTransferred"] = s.recordsTransferred;
  j["lastSyncAt"] = odataTime(s.lastSyncAt);
  int platform(string name) {
    if (auto v = name in s.devicesByPlatform)
      return cast(int)*v;
    return 0;
  }
  j["devicesIos"] = platform("ios");
  j["devicesAndroid"] = platform("android");
  j["devicesWindows"] = platform("windows");
  j["devicesWeb"] = platform("web");
  j["devicesCross"] = platform("cross");
  return j;
}

///
unittest {
  mixin(ShowTest!("odata serializers"));

  auto model = agentryODataModel();
  auto d = MobileDevice(TenantId("t1"), DeviceId("d1"));
  d.pushToken = "secret";
  auto j = toOData(d);
  assert(j["id"].get!string == "d1");
  assert("pushToken" !in j);
  assert(j["lastSeenAt"].type == Json.Type.null_);
  // every serialized property is declared in $metadata and vice versa
  foreach (key, value; j.get!(Json[string]))
    assert(model.find("Devices").hasProperty(key), key);
  foreach (prop; model.find("Devices").properties)
    assert(prop.name in j, prop.name);
  foreach (prop; model.find("Statistics").properties)
    assert(prop.name in toOData(AgentryStatistics.init), prop.name);
  assert(odataTime(SysTime.fromISOExtString("2026-11-09T10:00:00Z").stdTime).get!string == "2026-11-09T10:00:00Z");
}
