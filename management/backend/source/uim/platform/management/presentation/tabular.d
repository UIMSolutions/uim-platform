/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tabular projections of the domain entities, shared by the text based
/// presentation adapters (CLI tables and GtkD list views).
module uim.platform.management.presentation.tabular;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// A table: column headers + string cells.
struct Table {
  string[] headers;
  string[][] rows;

  size_t length() const {
    return rows.length;
  }

  /// Render as aligned plain text (columns capped at maxWidth characters).
  string render(size_t maxWidth = 48) const {
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

private string idOrDash(string id) {
  return id.length > 0 ? id : "—";
}

Table globalAccountTable(const GlobalAccount[] items) {
  Table t;
  t.headers = ["Name", "Company", "License", "Region", "Subaccounts", "Directories", "Status", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.displayName, e.companyName, enumName(e.licenseType), e.region,
      e.currentSubaccounts.to!string ~ "/" ~ e.maxSubaccounts.to!string,
      e.currentDirectories.to!string ~ "/" ~ e.maxDirectories.to!string,
      enumName(e.status), e.id.value
    ];
  return t;
}

Table directoryTable(const AccountDirectory[] items) {
  Table t;
  t.headers = ["Name", "Global Account", "Parent", "Features", "Status", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.displayName, e.globalAccountId.value, idOrDash(e.parentDirectoryId.value),
      e.features.map!(f => enumName(f)).join(", "), enumName(e.status), e.id.value
    ];
  return t;
}

Table subaccountTable(const Subaccount[] items) {
  Table t;
  t.headers = ["Name", "Subdomain", "Region", "Usage", "Directory", "Status", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.displayName, e.subdomain, e.region, enumName(e.usage),
      idOrDash(e.parentDirectoryId.value), enumName(e.status), e.id.value
    ];
  return t;
}

Table entitlementTable(const Entitlement[] items) {
  Table t;
  t.headers = ["Service", "Plan", "Assigned To", "Quota (used/assigned)", "Status", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.serviceName, e.planDisplayName.length ? e.planDisplayName : e.planName,
      e.subaccountId.value.length ? "subaccount " ~ e.subaccountId.value
      : (e.directoryId.value.length ? "directory " ~ e.directoryId.value : "global account " ~ e.globalAccountId.value),
      e.unlimited ? e.quotaUsed.to!string ~ "/∞" : e.quotaUsed.to!string ~ "/" ~ e.quotaAssigned.to!string,
      enumName(e.status), e.id.value
    ];
  return t;
}

Table environmentTable(const Environment[] items) {
  Table t;
  t.headers = ["Name", "Type", "Plan", "Landscape", "Subaccount", "Status", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, enumName(e.environmentType), e.planName, e.landscapeLabel,
      e.subaccountId.value, enumName(e.status), e.id.value
    ];
  return t;
}

Table subscriptionTable(const Subscription[] items) {
  Table t;
  t.headers = ["Application", "Plan", "Subaccount", "Subscribed At", "Status", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.appDisplayName.length ? e.appDisplayName : e.appName, e.planName, e.subaccountId.value,
      formatCliTime(e.subscribedAt), enumName(e.status), e.id.value
    ];
  return t;
}

Table servicePlanTable(const ServicePlan[] items) {
  Table t;
  t.headers = ["Service", "Plan", "Category", "Pricing", "Max Quota", "Regions", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.serviceName, e.planName ~ (e.isBeta ? " (beta)" : ""), enumName(e.category),
      enumName(e.pricingModel), e.isUnlimited ? "∞" : e.maxQuota.to!string ~ " " ~ e.unit,
      e.availableRegions.join(", "), e.id.value
    ];
  return t;
}

Table labelTable(const Label[] items) {
  Table t;
  t.headers = ["Key", "Values", "Resource Type", "Resource", "ID"];
  foreach (e; items)
    t.rows ~= [e.key, e.values.join(", "), enumName(e.resourceType), e.resourceId, e.id.value];
  return t;
}

Table eventTable(const EnvironmentEvent[] items) {
  Table t;
  t.headers = ["Time", "Severity", "Category", "Event", "Description", "By", "ID"];
  foreach (e; items)
    t.rows ~= [
      formatCliTime(e.timestamp), enumName(e.severity), enumName(e.category), e.eventType,
      e.description, e.initiatedBy.value, e.id.value
    ];
  return t;
}

/// Key/value table of the tenant overview.
Table overviewTable(const TenantOverview o) {
  Table t;
  t.headers = ["Figure", "Value"];
  t.rows = [
    ["Tenant", o.tenantId.value],
    ["Global accounts", o.globalAccounts.to!string ~ " (" ~ o.activeGlobalAccounts.to!string ~ " active, "
      ~ o.suspendedGlobalAccounts.to!string ~ " suspended)"],
    ["Directories", o.directories.to!string],
    ["Subaccounts", o.subaccounts.to!string ~ " (" ~ o.activeSubaccounts.to!string ~ " active, "
      ~ o.suspendedSubaccounts.to!string ~ " suspended)"],
    ["Entitlements", o.entitlements.to!string ~ " (" ~ o.revokedEntitlements.to!string ~ " revoked, "
      ~ o.overQuotaEntitlements.to!string ~ " over quota)"],
    ["Quota used / assigned", o.quotaUsed.to!string ~ " / " ~ o.quotaAssigned.to!string],
    ["Environments", o.environments.to!string],
    ["Subscriptions", o.subscriptions.to!string],
    ["Service plans", o.servicePlans.to!string],
    ["Labels", o.labels.to!string],
    ["Events", o.events.to!string ~ " (" ~ o.warningEvents.to!string ~ " warnings)"],
    ["Last event", formatCliTime(o.lastEventAt)],
  ];
  return t;
}

///
unittest {
  mixin(ShowTest!("tabular"));

  auto s = Subaccount(TenantId("t"));
  s.displayName = "Dev";
  s.subdomain = "dev";
  auto t = subaccountTable([s]);
  assert(t.length == 1 && t.rows[0][$ - 1] == s.id.value);
  assert(t.render.canFind("Subdomain"));
  assert(formatCliTime(0) == "");
  assert(parseCliTime("2026-11-09") > 0);
}
