/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Parsing and validation of destination URLs.
module uim.platform.connectivity.domain.services.endpoints;

import std.ascii : isDigit;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// The default port of a URL scheme (0 = none).
int defaultPort(string scheme) pure nothrow {
  switch (scheme) {
  case "http":
    return 80;
  case "https":
    return 443;
  case "ldap":
    return 389;
  case "ldaps":
    return 636;
  case "smtp":
    return 25;
  case "smtps":
    return 465;
  case "imap":
    return 143;
  case "imaps":
    return 993;
  case "pop3":
    return 110;
  case "pop3s":
    return 995;
  case "rfc":
    return 3300;
  case "rfcs":
    return 4800;
  default:
    return 0;
  }
}

/// Index of the first character of `s` that occurs in `chars` (-1 if none).
ptrdiff_t indexOfFirst(string s, string chars) pure nothrow @nogc {
  foreach (i, c; s)
    foreach (x; chars)
      if (c == x)
        return cast(ptrdiff_t) i;
  return -1;
}

private int parsePort(string text) pure nothrow {
  if (text.length == 0 || text.length > 5)
    return -1;
  int port;
  foreach (c; text) {
    if (!isDigit(c))
      return -1;
    port = port * 10 + (c - '0');
  }
  return port >= 1 && port <= 65_535 ? port : -1;
}

/// "https://User@ERP.corp:8443/sap/opu?x=1" → {https, erp.corp, 8443, /sap/opu}.
/// Returns Endpoint.init for anything that is not scheme://host[:port][/path].
Endpoint parseEndpoint(string url) {
  auto u = url.strip;
  auto sep = u.indexOf("://");
  if (sep <= 0)
    return Endpoint.init;
  Endpoint e;
  e.scheme = u[0 .. sep].toLower;
  auto rest = u[sep + 3 .. $];
  size_t cut = rest.length;
  foreach (i, c; rest)
    if (c == '/' || c == '?' || c == '#') {
      cut = i;
      break;
    }
  auto authority = rest[0 .. cut];
  auto tail = rest[cut .. $];
  auto at = authority.lastIndexOf('@');
  if (at >= 0)
    authority = authority[at + 1 .. $];

  string host = authority;
  int port;
  if (authority.startsWith("[")) { // IPv6 literal
    auto close = authority.indexOf(']');
    if (close < 0)
      return Endpoint.init;
    host = authority[1 .. close];
    auto after = authority[close + 1 .. $];
    if (after.startsWith(":"))
      port = parsePort(after[1 .. $]);
  } else {
    auto colon = authority.lastIndexOf(':');
    if (colon >= 0) {
      host = authority[0 .. colon];
      port = parsePort(authority[colon + 1 .. $]);
    }
  }
  if (port < 0 || !isValidHost(host))
    return Endpoint.init;
  e.host = host.toLower;
  e.port = port > 0 ? port : defaultPort(e.scheme);

  auto q = tail.indexOfFirst("?#");
  auto path = q >= 0 ? tail[0 .. q] : tail;
  e.path = path.length > 0 ? path : "/";
  return e;
}

/// URL schemes allowed per destination type.
string[] schemesOf(DestinationType t) pure {
  final switch (t) {
  case DestinationType.http:
    return ["http", "https"];
  case DestinationType.ldap:
    return ["ldap", "ldaps"];
  case DestinationType.mail:
    return ["smtp", "smtps", "imap", "imaps", "pop3", "pop3s"];
  case DestinationType.tcp:
    return ["tcp", "tcps"];
  case DestinationType.rfc:
    return ["rfc", "rfcs"];
  }
}

/// Validate the URL of a destination and return its endpoint. RFC destinations
/// may omit the URL (they are addressed via jco.client.* properties).
Endpoint validateDestinationUrl(DestinationType t, string url) {
  if (t == DestinationType.rfc && url.strip.length == 0)
    return Endpoint.init;
  validate(url.strip.length > 0, "Destination URL is required");
  auto e = parseEndpoint(url);
  validate(!e.isNull, "Destination URL '" ~ url ~ "' is not a valid URL (scheme://host[:port][/path])");
  validate(schemesOf(t).canFind(e.scheme), "A " ~ enumText(t) ~ " destination needs a URL with scheme "
      ~ schemesOf(t).join(" / ") ~ " (got '" ~ e.scheme ~ "')");
  validate(e.port > 0, "Destination URL '" ~ url ~ "' needs an explicit port");
  return e;
}

///
unittest {
  auto e = parseEndpoint("https://User@ERP.corp:8443/sap/opu/odata?x=1");
  assert(e.scheme == "https" && e.host == "erp.corp" && e.port == 8443 && e.path == "/sap/opu/odata");
  assert(parseEndpoint("http://erp").port == 80 && parseEndpoint("http://erp").path == "/");
  assert(parseEndpoint("ldaps://[::1]").host == "::1" && parseEndpoint("ldaps://[::1]").port == 636);
  assert(parseEndpoint("erp.corp/sap").isNull);
  assert(parseEndpoint("http://erp:99999").isNull);

  bool failed(void delegate() @safe f) {
    try
      f();
    catch (ConnectivityValidationException)
      return true;
    return false;
  }

  assert(validateDestinationUrl(DestinationType.http, "https://api.example.com").port == 443);
  assert(failed(() { validateDestinationUrl(DestinationType.http, "ldap://x"); }));
  assert(failed(() { validateDestinationUrl(DestinationType.tcp, "tcp://x"); }));
  assert(validateDestinationUrl(DestinationType.tcp, "tcp://x:5000").port == 5000);
  assert(validateDestinationUrl(DestinationType.rfc, "").isNull);
}
