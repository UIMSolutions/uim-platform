/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Namespaces and topics.
///
/// A namespace has at least two non-empty segments separated by "/", e.g.
/// "acme/sales/orders" (orgName/appName/serviceName). A topic is a namespace
/// followed by one or more segments: "acme/sales/orders/ce/created".
///
/// Topic patterns (queue subscriptions) support two wildcards:
///   "*"  exactly one segment            acme/sales/orders/ce/*
///   "#"  the remaining segments (≥ 0);  acme/sales/#   (last segment only)
module uim.platform.events.domain.types.topics;

import uim.platform.events;

mixin(ShowModule!());

@safe:

private bool isSegmentChar(dchar c) pure nothrow {
  import std.ascii : isAlphaNum;

  return isAlphaNum(c) || c == '-' || c == '_' || c == '.';
}

private bool isPlainSegment(string s) pure {
  return s.length > 0 && s.all!isSegmentChar;
}

/// "a/b" or longer, plain segments only.
bool isValidNamespace(string ns) pure {
  auto parts = ns.split("/");
  return parts.length >= 2 && parts.all!isPlainSegment;
}

/// Concrete topic (no wildcards), at most 150 characters like SAP Event Mesh.
bool isValidTopic(string topic) pure {
  auto parts = topic.split("/");
  return topic.length <= 150 && parts.length >= 2 && parts.all!isPlainSegment;
}

/// Pattern with optional "*" segments and a trailing "#".
bool isValidTopicPattern(string pattern) pure {
  auto parts = pattern.split("/");
  if (pattern.length > 150 || parts.length < 2)
    return false;
  foreach (i, p; parts) {
    if (p == "#") {
      if (i + 1 != parts.length)
        return false;
    } else if (p != "*" && !isPlainSegment(p))
      return false;
  }
  return true;
}

/// True if the topic lies within the namespace.
bool isInNamespace(string topic, string ns) pure {
  return ns.length > 0 && topic.length > ns.length && topic.startsWith(ns) && topic[ns.length] == '/';
}

/// True if a pattern refers to the namespace (its literal prefix lies in it
/// or the namespace lies under a leading wildcard-free part of the pattern).
bool isPatternInNamespace(string pattern, string ns) pure {
  auto p = pattern.split("/");
  auto n = ns.split("/");
  if (p.length <= n.length && p[$ - 1] != "#")
    return false;
  foreach (i, seg; n) {
    if (i >= p.length)
      return false;
    if (p[i] == "#")
      return true;
    if (p[i] != "*" && p[i] != seg)
      return false;
  }
  return true;
}

/// Match a concrete topic against a pattern.
bool topicMatches(string pattern, string topic) pure {
  auto p = pattern.split("/");
  auto t = topic.split("/");
  foreach (i, seg; p) {
    if (seg == "#")
      return true;
    if (i >= t.length)
      return false;
    if (seg != "*" && seg != t[i])
      return false;
  }
  return p.length == t.length;
}

///
unittest {
  assert(isValidNamespace("acme/sales/orders"));
  assert(!isValidNamespace("acme") && !isValidNamespace("acme//x") && !isValidNamespace("a/b c"));
  assert(isValidTopic("acme/sales/orders/ce/created"));
  assert(!isValidTopic("acme/sales/*"));
  assert(isValidTopicPattern("acme/sales/orders/ce/*") && isValidTopicPattern("acme/sales/#"));
  assert(!isValidTopicPattern("acme/#/x") && !isValidTopicPattern("acme"));

  assert(isInNamespace("acme/sales/orders/ce/created", "acme/sales/orders"));
  assert(!isInNamespace("acme/sales/ordersX/a", "acme/sales/orders"));
  assert(!isInNamespace("acme/sales/orders", "acme/sales/orders"));
  assert(isPatternInNamespace("acme/sales/orders/*", "acme/sales/orders"));
  assert(isPatternInNamespace("acme/*/orders/#", "acme/sales/orders"));
  assert(!isPatternInNamespace("other/sales/orders/*", "acme/sales/orders"));

  assert(topicMatches("acme/sales/orders/ce/*", "acme/sales/orders/ce/created"));
  assert(!topicMatches("acme/sales/orders/ce/*", "acme/sales/orders/ce/created/v1"));
  assert(topicMatches("acme/sales/#", "acme/sales/orders/ce/created"));
  assert(topicMatches("acme/sales/orders/#", "acme/sales/orders"));
  assert(topicMatches("acme/sales/orders", "acme/sales/orders"));
  assert(!topicMatches("acme/sales/orders", "acme/sales/orders/x"));
}
