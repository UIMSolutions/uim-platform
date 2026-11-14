/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tabular projections of the domain entities, shared by the text based
/// presentation adapters (CLI tables and GtkD list views).
module uim.platform.agentry.presentation.tabular;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// A table: column headers + string cells. The last column is the ID.
struct Table {
  string[] headers;
  string[][] rows;

  size_t length() const {
    return rows.length;
  }

  /// Render as aligned plain text (columns capped at maxWidth characters).
  string render(size_t maxWidth = 40) const {
    import std.array : appender;
    import std.utf : count;

    auto widths = headers.map!(h => h.count).array;
    foreach (r; rows)
      foreach (i, c; r)
        if (i < widths.length)
          widths[i] = max(widths[i], min(c.count, maxWidth));

    string cell(string s, size_t w) {
      auto n = s.count;
      if (n > w) {
        import std.range : take;
        import std.conv : text;

        return s.take(w - 1).text ~ "…";
      }
      return s ~ ' '.repeat(w - n).array.idup;
    }

    auto buf = appender!string;
    void line(const string[] cells) {
      foreach (i, w; widths)
        buf.put((i ? "  " : "") ~ cell(i < cells.length ? cells[i] : "", w));
      buf.put("\n");
    }

    line(headers);
    line(widths.map!(w => '-'.repeat(w).array.idup).array);
    foreach (r; rows)
      line(r);
    return buf.data;
  }
}

/// stdTime → "2026-11-09 10:00:00" (UTC); 0 → "".
string formatCliTime(long stdTime) {
  if (stdTime <= 0)
    return "";
  try {
    auto t = SysTime(stdTime, UTC());
    t.fracSecs = Duration.zero;
    return t.toISOExtString.replace("T", " ").stripRight("Z");
  } catch (Exception) {
    return "";
  }
}

/// "2026-11-09", "2026-11-09T10:00:00Z" or "2026-11-09 10:00:00" → stdTime; "" → 0.
long parseCliTime(string value) {
  auto v = value.strip;
  if (v.length == 0)
    return 0;
  if (v.length == 10)
    v ~= "T00:00:00";
  v = v.replace(" ", "T");
  if (!v.endsWith("Z") && !v[10 .. $].canFind('+') && !v[10 .. $].canFind('-'))
    v ~= "Z";
  return SysTime.fromISOExtString(v).stdTime;
}

/// Human readable byte count.
string formatBytes(long bytes) {
  if (bytes < 1024)
    return bytes.to!string ~ " B";
  if (bytes < 1024 * 1024)
    return "%.1f KiB".format(bytes / 1024.0);
  if (bytes < 1024L * 1024 * 1024)
    return "%.1f MiB".format(bytes / (1024.0 * 1024));
  return "%.1f GiB".format(bytes / (1024.0 * 1024 * 1024));
}

private string yes(bool b) {
  return b ? "yes" : "";
}

Table mobileApplicationTable(const MobileApplication[] items) {
  Table t;
  t.headers = ["Name", "Package", "Platform", "Status", "Vendor", "Offline", "Push", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, e.packageName, enumValue(e.platform), enumValue(e.status), e.vendor,
      yes(e.offlineCapable), yes(e.pushNotificationsEnabled), e.id.value
    ];
  return t;
}

Table appDefinitionTable(const AppDefinition[] items) {
  Table t;
  t.headers = ["Name", "Application", "Format", "Schema", "Status", "Valid", "Published", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, e.applicationId.value, e.definitionFormat, e.schemaVersion, enumValue(e.status),
      e.validationPassed ? "yes" : "no", formatCliTime(e.publishedAt), e.id.value
    ];
  return t;
}

Table appVersionTable(const AppVersion[] items) {
  Table t;
  t.headers = ["Version", "Application", "Definition", "Status", "Mandatory", "Published", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.versionNumber, e.mobileApplicationId.value, e.definitionId.value, enumValue(e.status),
      yes(e.isMandatoryUpdate), formatCliTime(e.publishedAt), e.id.value
    ];
  return t;
}

Table deviceTable(const MobileDevice[] items) {
  Table t;
  t.headers = ["Device", "Platform", "OS", "App Version", "Status", "Group", "User", "Last Seen", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.deviceName, enumValue(e.platform), e.osVersion, e.appVersionInstalled, enumValue(e.status),
      e.groupName, e.userEmail.length ? e.userEmail : e.userId.value, formatCliTime(e.lastSeenAt), e.id.value
    ];
  return t;
}

Table syncSessionTable(const SyncSession[] items) {
  Table t;
  t.headers = ["Started", "Device", "Direction", "Status", "Records", "Transferred", "Error", "ID"];
  foreach (e; items)
    t.rows ~= [
      formatCliTime(e.startedAt), e.deviceId.value, enumValue(e.direction), enumValue(e.status),
      (e.recordsSent + e.recordsReceived).to!string, formatBytes(e.bytesSent + e.bytesReceived),
      e.errorMessage, e.id.value
    ];
  return t;
}

Table backendConnectionTable(const BackendConnection[] items) {
  Table t;
  t.headers = ["Name", "Type", "URL", "Auth", "Status", "Last Test", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, enumValue(e.backendType), e.backendUrl, e.authMethod, enumValue(e.status),
      formatCliTime(e.lastTestedAt), e.id.value
    ];
  return t;
}

Table deploymentTable(const Deployment[] items) {
  Table t;
  t.headers = ["Version", "Application", "Scope", "Target", "Status", "Devices", "OK", "Failed", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.appVersionId.value, e.mobileApplicationId.value, enumValue(e.scope_),
      e.scope_ == DeploymentScope.device ? e.targetDeviceId : e.targetGroupName, enumValue(e.status),
      e.devicesTotal.to!string, e.devicesSucceeded.to!string, e.devicesFailed.to!string, e.id.value
    ];
  return t;
}

/// Key/value view of the statistics.
Table statisticsTable(const AgentryStatistics s) {
  Table t;
  t.headers = ["Figure", "Value"];
  t.rows ~= ["Tenant", s.tenantId.value];
  t.rows ~= ["Applications (active)", "%d (%d)".format(s.mobileApplications, s.activeApplications)];
  t.rows ~= ["Definitions (published)", "%d (%d)".format(s.appDefinitions, s.publishedDefinitions)];
  t.rows ~= ["Versions (published)", "%d (%d)".format(s.appVersions, s.publishedVersions)];
  t.rows ~= ["Devices (active / suspended)", "%d (%d / %d)".format(s.devices, s.activeDevices, s.suspendedDevices)];
  t.rows ~= ["Sync sessions (running / failed)", "%d (%d / %d)".format(s.syncSessions, s.runningSyncs, s.failedSyncs)];
  t.rows ~= ["Data transferred", formatBytes(s.bytesTransferred)];
  t.rows ~= ["Records transferred", s.recordsTransferred.to!string];
  t.rows ~= ["Last sync", formatCliTime(s.lastSyncAt)];
  t.rows ~= ["Backend connections (errors)", "%d (%d)".format(s.backendConnections, s.connectionErrors)];
  t.rows ~= ["Deployments (running / failed)", "%d (%d / %d)".format(s.deployments, s.runningDeployments, s.failedDeployments)];
  foreach (k; s.devicesByPlatform.keys.sort)
    t.rows ~= ["Devices " ~ k, s.devicesByPlatform[k].to!string];
  return t;
}

///
unittest {
  mixin(ShowTest!("Table"));

  Table t;
  t.headers = ["A", "B"];
  t.rows ~= ["x", "longer"];
  auto text = t.render();
  assert(text.canFind("A  B"));
  assert(text.canFind("x  longer"));

  assert(formatCliTime(0) == "");
  auto st = parseCliTime("2026-11-09");
  assert(formatCliTime(st) == "2026-11-09 00:00:00");
  assert(formatBytes(512) == "512 B");
  assert(formatBytes(2048) == "2.0 KiB");
  assert(deviceTable([MobileDevice(TenantId("t"), DeviceId("d1"))]).rows[0][$ - 1] == "d1");
}
