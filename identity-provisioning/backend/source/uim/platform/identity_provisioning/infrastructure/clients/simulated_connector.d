/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.infrastructure.clients.simulated_connector;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Deterministic connector for development, tests and demos. It behaves like
/// a real connector — tests reachability, reads identities, accepts or rejects
/// writes — without network access. Replace with SCIM / LDAP / Graph clients
/// behind the same IIdentityConnector port for production.
///
/// Connector properties (set on the system):
///   sim.users=<n>        users of a source system (default 5)
///   sim.groups=<n>       groups of a source system (default 2)
///   sim.domain=<domain>  e-mail domain (default: system name + ".example.com")
///   sim.revision=<n>     shifts the departments — changes attributes for delta runs
///   sim.inactive=<names> comma separated userNames read with active=false
///   sim.fail=connect|read|write   simulate an outage
///
/// Targets of type ias, scim and azureAd reject users without e-mail address.
class SimulatedIdentityConnector : IIdentityConnector {
  static immutable string[2][] people = [
    ["Ada", "Lovelace"], ["Alan", "Turing"], ["Grace", "Hopper"], ["Linus", "Torvalds"],
    ["Margaret", "Hamilton"], ["Dennis", "Ritchie"], ["Barbara", "Liskov"], ["Ken", "Thompson"],
    ["Donald", "Knuth"], ["Frances", "Allen"], ["John", "Backus"], ["Radia", "Perlman"],
  ];
  static immutable string[] departments = ["Engineering", "Finance", "Sales", "HR", "Operations"];

  ConnectionTestResult test(const ConnectionSettings s) {
    if (property(s, "sim.fail") == "connect" || s.url.canFind("invalid") || s.url.canFind("unreachable"))
      return ConnectionTestResult(false, "Connection refused: " ~ s.url, 0);
    if ((s.authenticationType == AuthenticationType.basic
        || s.authenticationType == AuthenticationType.oauth2ClientCredentials) && s.password.length == 0)
      return ConnectionTestResult(false, "401 Unauthorized — " ~ (s.authenticationType == AuthenticationType.basic
          ? "password" : "client secret") ~ " missing", 12);
    auto latency = 20 + cast(int)(s.url.length % 60);
    return ConnectionTestResult(true, enumText(s.systemType) ~ " connection OK (" ~ latency.to!string ~ " ms)", latency);
  }

  SourceIdentity[] read(const ConnectionSettings s) {
    if (property(s, "sim.fail") == "read" || property(s, "sim.fail") == "connect")
      throw new ConnectorException("Reading from '" ~ s.systemName ~ "' failed: connection reset by peer");
    auto users = intProperty(s, "sim.users", 5);
    auto groups = intProperty(s, "sim.groups", 2);
    auto revision = intProperty(s, "sim.revision", 0);
    auto domain = property(s, "sim.domain");
    if (domain.length == 0)
      domain = s.systemName.toLower.filter!(c => c >= 'a' && c <= 'z' || c >= '0' && c <= '9').array.to!string
        ~ ".example.com";
    auto inactive = property(s, "sim.inactive").split(",").map!(x => x.strip).array;

    SourceIdentity[] result;
    string[][string] members;
    foreach (i; 0 .. users) {
      auto p = people[i % people.length];
      auto suffix = i < people.length ? "" : (i / people.length + 1).to!string;
      auto userName = (p[0] ~ "." ~ p[1]).toLower ~ suffix;
      auto department = departments[(i + revision) % departments.length];
      members[department] ~= userName;
      SourceIdentity u;
      u.externalId = "u%04d".format(i + 1);
      u.entityType = EntityType.user;
      u.name = userName;
      u.attributes = [
        Attribute("userName", userName),
        Attribute("givenName", p[0]),
        Attribute("familyName", p[1] ~ suffix),
        Attribute("displayName", p[0] ~ " " ~ p[1] ~ suffix),
        // every 7th user has no e-mail address (rejected by IAS / SCIM targets)
        Attribute("email", (i + 1) % 7 == 0 ? "" : userName ~ "@" ~ domain),
        Attribute("department", department),
        Attribute("employeeNumber", "%06d".format(100_000 + i + 1)),
        Attribute("active", inactive.canFind(userName) ? "false" : "true"),
      ];
      result ~= u;
    }
    foreach (i; 0 .. min(groups, cast(int) departments.length)) {
      auto department = departments[i];
      SourceIdentity g;
      g.externalId = "g%04d".format(i + 1);
      g.entityType = EntityType.group;
      g.name = department;
      g.attributes = [
        Attribute("displayName", department),
        Attribute("description", department ~ " department"),
        Attribute("members", members.get(department, null).join(",")),
      ];
      result ~= g;
    }
    return result;
  }

  string write(const ConnectionSettings s, const PlannedOperation op) {
    if (property(s, "sim.fail") == "write")
      throw new ConnectorException("503 Service Unavailable from '" ~ s.systemName ~ "'");
    auto needsMail = s.systemType == SystemType.ias || s.systemType == SystemType.scim
      || s.systemType == SystemType.azureAd;
    if (op.entityType == EntityType.user && needsMail && !hasEmail(op.attributes))
      throw new ConnectorException("400 Bad Request: " ~ enumText(s.systemType) ~ " requires an e-mail address for user '"
          ~ op.name ~ "'");
    if (op.targetId.length > 0)
      return op.targetId;
    auto hash = attributeChecksum([Attribute(s.systemName, op.externalId)]);
    return s.systemType == SystemType.ias ? "P" ~ hash[0 .. 6].toUpper : hash[0 .. 8] ~ "-" ~ hash[8 .. 12];
  }

  void remove(const ConnectionSettings s, const PlannedOperation op) {
    if (property(s, "sim.fail") == "write")
      throw new ConnectorException("503 Service Unavailable from '" ~ s.systemName ~ "'");
  }

  protected static bool hasEmail(const Attribute[] attributes) {
    foreach (a; attributes)
      if ((a.key == "email" || a.key == "mail" || a.key.startsWith("emails")) && a.value.canFind("@"))
        return true;
    return false;
  }

  protected static string property(const ConnectionSettings s, string key) {
    return attributeValue(s.properties, key).strip;
  }

  protected static int intProperty(const ConnectionSettings s, string key, int fallback) {
    auto v = property(s, key);
    if (v.length == 0)
      return fallback;
    try
      return max(0, min(v.to!int, 10_000));
    catch (Exception)
      return fallback;
  }
}

///
unittest {
  mixin(ShowTest!("SimulatedIdentityConnector"));

  auto c = new SimulatedIdentityConnector();
  ConnectionSettings hr;
  hr.systemName = "HR";
  hr.systemType = SystemType.successFactors;
  hr.url = "https://api.successfactors.com";
  hr.authenticationType = AuthenticationType.basic;
  hr.user = "admin";
  assert(!c.test(hr).success); // password missing
  hr.password = "secret";
  assert(c.test(hr).success);

  auto identities = c.read(hr);
  assert(identities.length == 7 && identities[0].name == "ada.lovelace");
  assert(attributeValue(identities[0].attributes, "email") == "ada.lovelace@hr.example.com");
  assert(identities[5].entityType == EntityType.group && identities[5].name == "Engineering");
  assert(c.read(hr) == identities); // deterministic

  hr.properties = [Attribute("sim.users", "8"), Attribute("sim.revision", "1"), Attribute("sim.inactive", "alan.turing")];
  auto changed = c.read(hr);
  assert(attributeValue(changed[0].attributes, "department") == "Finance");
  assert(attributeValue(changed[1].attributes, "active") == "false");
  assert(attributeValue(changed[6].attributes, "email") == ""); // 7th user

  ConnectionSettings ias;
  ias.systemName = "IAS";
  ias.systemType = SystemType.ias;
  PlannedOperation op;
  op.entityType = EntityType.user;
  op.externalId = "u0001";
  op.attributes = [Attribute("emails[0].value", "ada@x.com")];
  auto id = c.write(ias, op);
  assert(id.length == 7 && id[0] == 'P' && c.write(ias, op) == id);
  op.attributes = null;
  bool rejected;
  try c.write(ias, op);
  catch (ConnectorException) rejected = true;
  assert(rejected);
  ias.properties = [Attribute("sim.fail", "read")];
  rejected = false;
  try c.read(ias);
  catch (ConnectorException) rejected = true;
  assert(rejected);
}
