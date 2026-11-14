/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tabular projections of the domain entities, shared by the text based
/// presentation adapters (CLI tables and GtkD list views).
module uim.platform.identity_authentication.presentation.tabular;

import uim.platform.identity_authentication;

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

Table userTable(const IAUser[] items) {
  Table t;
  t.headers = ["User", "Name", "E-Mail", "Status", "MFA", "Groups", "Failed", "Last Login", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.userName, e.displayName, e.email, enumValue(e.status), e.mfaType == MfaType.none ? "" : enumValue(e.mfaType),
      e.groupIds.length.to!string, e.failedLoginAttempts > 0 ? e.failedLoginAttempts.to!string : "",
      formatCliTime(e.lastLoginAt), e.id.value
    ];
  return t;
}

Table groupTable(const IAGroup[] items) {
  Table t;
  t.headers = ["Name", "Description", "Members", "ID"];
  foreach (e; items)
    t.rows ~= [e.name, e.description, e.memberUserIds.length.to!string, e.id.value];
  return t;
}

Table applicationTable(const Application[] items) {
  Table t;
  t.headers = ["Name", "Protocol", "Client ID", "Scopes", "Redirect URIs", "Active", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, enumValue(e.protocol), e.clientId, e.allowedScopes.join(" "), e.redirectUris.join(" "),
      yes(e.active), e.id.value
    ];
  return t;
}

Table policyTable(const AuthorizationPolicy[] items) {
  Table t;
  t.headers = ["Name", "Rules", "Applications", "Active", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, e.rules.map!(r => r.toText).join("; "),
      e.applicationIds.length ? e.applicationIds.join(", ") : "(all)", yes(e.active), e.id.value
    ];
  return t;
}

Table riskRuleTable(const RiskRule[] items) {
  Table t;
  t.headers = ["Name", "Conditions", "Risk", "MFA", "Deny", "Active", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, e.conditions.map!(c => c.toText).join("; "), enumValue(e.riskLevel),
      e.requiredMfa == MfaType.none ? "" : enumValue(e.requiredMfa), yes(e.denyAccess), yes(e.active), e.id.value
    ];
  return t;
}

Table identityProviderTable(const IdpConfig[] items) {
  Table t;
  t.headers = ["Name", "Type", "Domains", "Authorization Endpoint", "Default", "Active", "ID"];
  foreach (e; items)
    t.rows ~= [
      e.name, enumValue(e.idpType), e.domainHints.join(", "), e.authorizationEndpoint,
      yes(e.isDefault), yes(e.active), e.id.value
    ];
  return t;
}

Table sessionTable(const IASession[] items) {
  Table t;
  auto now = Clock.currStdTime();
  t.headers = ["Started", "User", "IP Address", "MFA", "Risk", "Expires", "State", "ID"];
  foreach (e; items)
    t.rows ~= [
      formatCliTime(e.createdAt), e.userId.value, e.ipAddress, e.mfaUsed == MfaType.none ? "" : enumValue(e.mfaUsed),
      enumValue(e.riskLevel), formatCliTime(e.expiresAt),
      e.revoked ? "revoked" : e.isExpired(now) ? "expired" : "active", e.id.value
    ];
  return t;
}

Table tokenTable(const Token[] items) {
  Table t;
  auto now = Clock.currStdTime();
  t.headers = ["Issued", "Type", "User", "Application", "Scopes", "Expires", "State", "ID"];
  foreach (e; items)
    t.rows ~= [
      formatCliTime(e.issuedAt), enumValue(e.tokenType), e.userId.value, e.applicationId.value, e.scopes.join(" "),
      formatCliTime(e.expiresAt), e.revoked ? "revoked" : e.isExpired(now) ? "expired" : "active", e.id.value
    ];
  return t;
}

/// Key/value view of the statistics.
Table statisticsTable(const IdentityStatistics s) {
  Table t;
  t.headers = ["Figure", "Value"];
  t.rows ~= ["Tenant", s.tenantId.value];
  t.rows ~= ["Users", s.users.to!string];
  t.rows ~= ["  active / locked / inactive / pending", "%d / %d / %d / %d".format(s.activeUsers, s.lockedUsers,
      s.inactiveUsers, s.pendingUsers)];
  t.rows ~= ["  with MFA", "%d (%d %%)".format(s.mfaUsers, s.mfaCoverage)];
  t.rows ~= ["  with failed logins", s.usersWithFailedLogins.to!string];
  t.rows ~= ["Last login", formatCliTime(s.lastLoginAt)];
  t.rows ~= ["Groups", s.groups.to!string];
  t.rows ~= ["Applications (active)", "%d (%d)".format(s.applications, s.activeApplications)];
  t.rows ~= ["Policies", s.policies.to!string];
  t.rows ~= ["Risk rules", s.riskRules.to!string];
  t.rows ~= ["Identity providers", s.identityProviders.to!string];
  t.rows ~= ["Sessions (active)", "%d (%d)".format(s.sessions, s.activeSessions)];
  t.rows ~= ["Tokens (active)", "%d (%d)".format(s.tokens, s.activeTokens)];
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
  assert(formatCliTime(parseCliTime("2026-11-09")) == "2026-11-09 00:00:00");
  auto u = IAUser(TenantId("t"), UserId("u1"));
  u.userName = "jane";
  assert(userTable([u]).rows[0][$ - 1] == "u1");
  assert(statisticsTable(IdentityStatistics.init).rows.length == 13);
}
