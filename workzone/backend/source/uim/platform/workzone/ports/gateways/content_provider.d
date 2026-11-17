/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.gateways.content_provider;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Outcome of a call to an external content provider ("" error = success).
struct ProviderOutcome {
  string error;
  int itemCount;
  string message;

  bool ok() const {
    return error.length == 0;
  }
}

/// Driven port: the remote content sources behind external content providers
/// (SAP BTP destinations, OData / REST / GraphQL endpoints).
interface IContentProviderGateway {
  /// Check the endpoint and the credentials.
  ProviderOutcome connect(const ExternalContentProvider provider);
  /// Fetch the current content (returns the number of items).
  ProviderOutcome sync(const ExternalContentProvider provider);
}
