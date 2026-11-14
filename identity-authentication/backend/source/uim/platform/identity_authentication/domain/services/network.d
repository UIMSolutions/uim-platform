/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// IPv4 address and CIDR range matching used by policies and risk rules.
module uim.platform.identity_authentication.domain.services.network;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Parse a dotted IPv4 address. Returns false for anything else (IPv6, junk).
bool parseIPv4(string text, out uint address) pure {
  auto parts = text.strip.split(".");
  if (parts.length != 4)
    return false;
  uint value;
  foreach (p; parts) {
    if (p.length == 0 || p.length > 3 || !p.all!(c => c >= '0' && c <= '9'))
      return false;
    auto octet = p.to!uint;
    if (octet > 255)
      return false;
    value = (value << 8) | octet;
  }
  address = value;
  return true;
}

/// True if ip equals `range` or lies within the CIDR block `range` ("10.0.0.0/8").
/// Non-IPv4 input falls back to exact string comparison.
bool ipMatches(string ip, string range) pure {
  auto slash = range.indexOf('/');
  if (slash < 0)
    return ip.strip == range.strip;

  uint addr, net;
  if (!parseIPv4(ip, addr) || !parseIPv4(range[0 .. slash], net))
    return false;
  int bits;
  try
    bits = range[slash + 1 .. $].strip.to!int;
  catch (Exception)
    return false;
  if (bits < 0 || bits > 32)
    return false;
  uint mask = bits == 0 ? 0 : (0xFFFF_FFFFu << (32 - bits));
  return (addr & mask) == (net & mask);
}

/// True if ip matches any of the comma separated ranges.
bool ipMatchesAny(string ip, string ranges) pure {
  return ranges.split(",").any!(r => r.strip.length > 0 && ipMatches(ip, r.strip));
}
///
unittest {
  mixin(ShowTest!("ipMatches"));

  assert(ipMatches("10.1.2.3", "10.0.0.0/8"));
  assert(!ipMatches("11.1.2.3", "10.0.0.0/8"));
  assert(ipMatches("192.168.1.7", "192.168.1.7"));
  assert(ipMatches("192.168.1.7", "192.168.1.0/24"));
  assert(!ipMatches("192.168.2.7", "192.168.1.0/24"));
  assert(ipMatches("1.2.3.4", "0.0.0.0/0"));
  assert(!ipMatches("::1", "10.0.0.0/8"));
  assert(!ipMatches("10.0.0.1", "10.0.0.0/33"));
  assert(ipMatchesAny("172.16.5.5", "10.0.0.0/8, 172.16.0.0/12"));
  uint a;
  assert(!parseIPv4("256.1.1.1", a));
}
