/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.enumerations.access;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Effect of an access control rule.
enum AccessPolicy {
  allow,
  deny,
}

/// Back-end protocol an access rule applies to.
enum AccessProtocol {
  http,
  https,
  rfc,
  rfcs, /// RFC over SNC / TLS
  tcp,
  tcpSsl,
  ldap,
  ldaps,
}

/// The access protocol used for a URL scheme ("" / unknown → http).
AccessProtocol accessProtocolOf(string scheme) {
  switch (scheme.toLower) {
  case "https":
    return AccessProtocol.https;
  case "rfc":
    return AccessProtocol.rfc;
  case "rfcs":
    return AccessProtocol.rfcs;
  case "tcp", "smtp", "imap", "pop3":
    return AccessProtocol.tcp;
  case "tcps", "ssl", "tls", "smtps", "imaps", "pop3s":
    return AccessProtocol.tcpSsl;
  case "ldap":
    return AccessProtocol.ldap;
  case "ldaps":
    return AccessProtocol.ldaps;
  default:
    return AccessProtocol.http;
  }
}

/// True for protocols whose rules are matched on URL paths.
bool hasPaths(AccessProtocol p) pure nothrow {
  return p == AccessProtocol.http || p == AccessProtocol.https;
}

///
unittest {
  assert(accessProtocolOf("HTTPS") == AccessProtocol.https);
  assert(accessProtocolOf("ldaps") == AccessProtocol.ldaps);
  assert(accessProtocolOf("") == AccessProtocol.http);
  assert(AccessProtocol.https.hasPaths && !AccessProtocol.rfc.hasPaths);
}
