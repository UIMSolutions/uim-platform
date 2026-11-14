/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port to external webhook endpoints (HTTP push).
module uim.platform.events.ports.gateways.webhook_endpoint;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// One push request.
struct WebhookRequest {
  string url;
  string[string] headers;
  string contentType;
  string body;
  WebhookAuthType authenticationType;
  string credentials;
  string tokenUrl;
  string clientId;
}

/// Result of a push; status 0 = transport error.
struct WebhookResponse {
  int status;
  string error;

  bool succeeded() const {
    return status >= 200 && status < 300;
  }
}

interface IWebhookEndpointGateway {
  WebhookResponse push(const WebhookRequest request);
}
