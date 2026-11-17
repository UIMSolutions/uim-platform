/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.clients.content_provider;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Deterministic stand-in for the remote content sources (no network I/O), so
/// that server, CLI, GUI and tests behave the same. Replace with an HTTP client
/// using SAP BTP destinations for production use.
///
/// Conventions: an endpoint containing "[fail]" fails to connect, one
/// containing "[sync-fail]" fails to synchronise; the item count is derived
/// from the endpoint so repeated syncs are stable.
class SimulatedContentProviderGateway : IContentProviderGateway {
  string[] calls;

  ProviderOutcome connect(const ExternalContentProvider provider) {
    calls ~= "connect " ~ provider.name;
    if (provider.endpointUrl.canFind("[fail]"))
      return ProviderOutcome("Connection to " ~ provider.endpointUrl ~ " refused");
    if (provider.authType != "none" && provider.authConfig.length == 0)
      return ProviderOutcome("Credentials missing for " ~ provider.authType);
    return ProviderOutcome("", 0, "Connected via " ~ enumText(provider.providerType));
  }

  ProviderOutcome sync(const ExternalContentProvider provider) {
    calls ~= "sync " ~ provider.name;
    if (provider.endpointUrl.canFind("[sync-fail]"))
      return ProviderOutcome("Synchronisation of " ~ provider.endpointUrl ~ " failed (HTTP 503)");
    auto items = cast(int)(provider.endpointUrl.length % 37 + 3);
    return ProviderOutcome("", items, items.to!string ~ " item(s) fetched");
  }
}

///
unittest {
  auto gw = new SimulatedContentProviderGateway();
  ExternalContentProvider p;
  p.name = "News";
  p.endpointUrl = "https://news.example.com/feed";
  assert(gw.connect(p).ok);
  assert(gw.sync(p).itemCount == gw.sync(p).itemCount);
  p.endpointUrl = "https://x/[fail]";
  assert(!gw.connect(p).ok);
}
