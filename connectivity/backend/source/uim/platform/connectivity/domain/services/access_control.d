/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Access control of the Cloud Connector: a request to a virtual host, port
/// and path is allowed only if an enabled rule exposes it.
module uim.platform.connectivity.domain.services.access_control;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Outcome of an access check.
struct AccessDecision {
  bool allowed;
  AccessRuleId ruleId; /// matched rule (null if none)
  string ruleName;
  string internalHost; /// where the request is forwarded to
  int internalPort;
  bool principalPropagation;
  string reason;
}

/// "/sap/opu/" → "/sap/opu", "sap" → "/sap", "" → "/". Query and fragment are dropped.
string normalizePath(string path) pure {
  auto p = path.strip;
  auto q = p.indexOfFirst("?#");
  if (q >= 0)
    p = p[0 .. q];
  if (p.length == 0 || p[0] != '/')
    p = "/" ~ p;
  while (p.length > 1 && p[$ - 1] == '/')
    p = p[0 .. $ - 1];
  return p;
}

/// True if `rule` covers `path` (always true for protocols without paths).
bool pathMatches(const AccessRule rule, string path) pure {
  if (!rule.protocol.hasPaths)
    return true;
  auto prefix = normalizePath(rule.urlPathPrefix);
  auto p = normalizePath(path);
  if (!rule.includeSubPaths)
    return p == prefix;
  return prefix == "/" || p == prefix || p.startsWith(prefix ~ "/");
}

/// Default name of a rule: "https://erp.virtual:443/sap/opu".
string ruleNameOf(const AccessRule rule) {
  auto name = enumText(rule.protocol) ~ "://" ~ rule.virtualHost.toLower ~ ":" ~ rule.virtualPort.to!string;
  return rule.protocol.hasPaths ? name ~ normalizePath(rule.urlPathPrefix) : name;
}

/// Evaluate `rules` (of one connector) for a request. The most specific match
/// (longest path prefix) wins; at equal specificity "deny" wins.
AccessDecision evaluateAccess(const AccessRule[] rules, AccessProtocol protocol, string host, int port, string path) {
  size_t bestIndex = size_t.max;
  size_t bestLength;
  foreach (i, ref rule; rules) {
    if (!rule.enabled || rule.protocol != protocol || rule.virtualPort != port
        || rule.virtualHost.toLower != host.toLower || !pathMatches(rule, path))
      continue;
    auto len = rule.protocol.hasPaths ? normalizePath(rule.urlPathPrefix).length : 0;
    if (bestIndex == size_t.max || len > bestLength || (len == bestLength && rule.policy == AccessPolicy.deny)) {
      bestIndex = i;
      bestLength = len;
    }
  }

  auto target = enumText(protocol) ~ "://" ~ host.toLower ~ ":" ~ port.to!string ~ (protocol.hasPaths ? normalizePath(path) : "");
  AccessDecision d;
  if (bestIndex == size_t.max) {
    d.reason = "No access rule exposes " ~ target ~ " (unknown resources are denied)";
    return d;
  }
  auto best = rules[bestIndex];
  d.ruleId = best.id;
  d.ruleName = best.name;
  if (best.policy == AccessPolicy.deny) {
    d.reason = "Denied by rule '" ~ best.name ~ "'";
    return d;
  }
  d.allowed = true;
  d.internalHost = best.internalHost.length > 0 ? best.internalHost : best.virtualHost;
  d.internalPort = best.internalPort > 0 ? best.internalPort : best.virtualPort;
  d.principalPropagation = best.principalPropagation;
  d.reason = "Allowed by rule '" ~ best.name ~ "' → " ~ d.internalHost ~ ":" ~ d.internalPort.to!string;
  return d;
}

///
unittest {
  AccessRule rule(string prefix, AccessPolicy policy = AccessPolicy.allow, bool sub = true) {
    AccessRule r;
    r.id = AccessRuleId(prefix ~ enumText(policy));
    r.name = prefix;
    r.protocol = AccessProtocol.https;
    r.virtualHost = "erp.virtual";
    r.virtualPort = 443;
    r.internalHost = "erp.corp.local";
    r.internalPort = 44_300;
    r.urlPathPrefix = prefix;
    r.includeSubPaths = sub;
    r.policy = policy;
    return r;
  }

  auto rules = [rule("/sap/opu"), rule("/sap/opu/odata/secret", AccessPolicy.deny), rule("/ping", AccessPolicy.allow, false)];

  auto ok = evaluateAccess(rules, AccessProtocol.https, "ERP.virtual", 443, "/sap/opu/odata/sap/API_X?$top=1");
  assert(ok.allowed && ok.internalHost == "erp.corp.local" && ok.internalPort == 44_300, ok.reason);
  assert(!evaluateAccess(rules, AccessProtocol.https, "erp.virtual", 443, "/sap/opu/odata/secret/x").allowed);
  assert(!evaluateAccess(rules, AccessProtocol.https, "erp.virtual", 443, "/sap/opux").allowed); // segment boundary
  assert(evaluateAccess(rules, AccessProtocol.https, "erp.virtual", 443, "/ping/").allowed);
  assert(!evaluateAccess(rules, AccessProtocol.https, "erp.virtual", 443, "/ping/deep").allowed);
  assert(!evaluateAccess(rules, AccessProtocol.http, "erp.virtual", 443, "/sap/opu").allowed);
  assert(!evaluateAccess(rules, AccessProtocol.https, "erp.virtual", 8443, "/sap/opu").allowed);

  auto same = [rule("/a"), rule("/a", AccessPolicy.deny)];
  assert(!evaluateAccess(same, AccessProtocol.https, "erp.virtual", 443, "/a/b").allowed); // deny wins ties

  auto disabled = rule("/");
  disabled.enabled = false;
  assert(!evaluateAccess([disabled], AccessProtocol.https, "erp.virtual", 443, "/").allowed);
  assert(normalizePath("sap/") == "/sap" && normalizePath("") == "/");
  assert(ruleNameOf(rule("/sap/")) == "https://erp.virtual:443/sap");
}
