/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.gateways.content_provider;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Result of probing a content provider.
struct ProviderProbe {
  bool reachable;
  string message;
}

/// Driven port: the content endpoint of a remote / federated provider
/// (HTML5 application repository, another Work Zone / launchpad).
interface IContentProviderGateway {
  ProviderProbe probe(const ContentProvider provider);
}
