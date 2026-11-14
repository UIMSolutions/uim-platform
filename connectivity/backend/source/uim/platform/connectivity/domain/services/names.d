/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming rules of destinations, connectors, channels, hosts and ports.
module uim.platform.connectivity.domain.services.names;

import std.ascii : isAlphaNum, isHexDigit;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// A destination name: 1–200 characters, letters, digits, "-" and "_".
void validateDestinationName(string name) {
  validate(name.length > 0, "Destination name is required");
  validate(name.length <= 200, "Destination name must not exceed 200 characters");
  foreach (c; name)
    validate(isAlphaNum(c) || c == '-' || c == '_',
      "Destination name may only contain letters, digits, '-' and '_' (got '" ~ name ~ "')");
}

/// A display name (connector, channel, rule, certificate): 1–120 characters, no surrounding blanks.
void validateDisplayName(string kind, string name) {
  validate(name.strip.length > 0, kind ~ " name is required");
  validate(name.length <= 120, kind ~ " name must not exceed 120 characters");
  validate(name == name.strip, kind ~ " name must not start or end with blanks");
}

/// A Cloud Connector location ID: empty (default location) or up to 64
/// letters, digits, ".", "-", "_".
void validateLocationId(string locationId) {
  validate(locationId.length <= 64, "Location ID must not exceed 64 characters");
  foreach (c; locationId)
    validate(isAlphaNum(c) || c == '.' || c == '-' || c == '_',
      "Location ID may only contain letters, digits, '.', '-' and '_'");
}

/// A host name or IP address (no scheme, no port).
bool isValidHost(string host) pure {
  if (host.length == 0 || host.length > 253)
    return false;
  if (host[0] == '-' || host[0] == '.' || host[$ - 1] == '.')
    return false;
  foreach (c; host)
    if (!(isAlphaNum(c) || c == '.' || c == '-' || c == '_' || c == ':'))
      return false;
  return true;
}

void validateHost(string what, string host) {
  validate(host.length > 0, what ~ " is required");
  validate(isValidHost(host), what ~ " '" ~ host ~ "' is not a valid host name");
}

/// A TCP port: 1–65535.
void validatePort(string what, long port) {
  validate(port >= 1 && port <= 65_535, what ~ " must be between 1 and 65535 (got " ~ port.to!string ~ ")");
}

/// An http(s) URL with a host.
bool isHttpUrl(string url) pure {
  return (url.startsWith("https://") && url.length > 8) || (url.startsWith("http://") && url.length > 7);
}

/// A certificate fingerprint: SHA-1 (40) or SHA-256 (64) hex digits, ":" and
/// blanks are ignored. Returns the normalized lower case form ("" stays "").
string normalizeFingerprint(string fingerprint) {
  string hex;
  foreach (c; fingerprint) {
    if (c == ':' || c == ' ')
      continue;
    validate(isHexDigit(c), "Fingerprint may only contain hex digits");
    hex ~= c;
  }
  validate(hex.length == 0 || hex.length == 40 || hex.length == 64,
    "Fingerprint must be a SHA-1 (40) or SHA-256 (64) hex digest");
  return hex.toLower;
}

///
unittest {
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (ConnectivityValidationException)
      return true;
    return false;
  }

  validateDestinationName("S4_ONPREM-odata");
  assert(failed(() => validateDestinationName("S4 ONPREM")));
  assert(failed(() => validateDestinationName("")));
  validateLocationId("");
  validateLocationId("dc-frankfurt.1");
  assert(failed(() => validateLocationId("dc frankfurt")));
  assert(isValidHost("erp.corp.local") && isValidHost("10.0.0.1") && !isValidHost("-x") && !isValidHost("a b"));
  assert(failed(() => validatePort("Port", 0)) && failed(() => validatePort("Port", 70_000)));
  assert(normalizeFingerprint("AB:CD" ~ ":00".replicate(18)) == "abcd" ~ "00".replicate(18));
  assert(failed(() { normalizeFingerprint("xyz"); }));
}
