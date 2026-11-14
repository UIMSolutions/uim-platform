/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.webhook;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Push delivery of the messages of a queue to an HTTP endpoint.
struct Webhook {
  mixin TenantEntity!WebhookId;

  MessagingServiceId serviceId; /// derived from the queue
  QueueId queueId;
  string name;
  string description;
  WebhookStatus status = WebhookStatus.active;
  string url;
  string headers; /// JSON object of additional HTTP headers
  bool exemptHandshake;
  WebhookAuthType authenticationType = WebhookAuthType.none;
  string credentials; /// secret (user:password, API key or client secret) — never returned
  string tokenUrl; /// OAuth2 token endpoint
  string clientId; /// OAuth2 client id
  WebhookDeliveryMode deliveryMode = WebhookDeliveryMode.atLeastOnce;
  int batchSize = 10; /// messages per delivery run

  // delivery statistics (server managed)
  long deliveredCount;
  long failedCount;
  long lastDeliveryAt;
  string lastError;

  bool isActive() const {
    return status == WebhookStatus.active;
  }

  /// Additional headers as a map (invalid JSON yields an empty map).
  string[string] headerMap() const @trusted {
    string[string] map;
    if (headers.strip.length == 0)
      return map;
    try {
      auto j = parseJsonString(headers);
      if (j.type == Json.Type.object)
        foreach (string k, v; j)
          if (v.type == Json.Type.string)
            map[k] = v.get!string;
    } catch (Exception) {
    }
    return map;
  }

  void validate() const @trusted {
    requireText(name, "Webhook name");
    if (queueId.isNull)
      throw EventsException.invalid("Webhook needs a queueId");
    if (!isHttpUrl(url))
      throw EventsException.invalid("Webhook url must be an http(s) URL");
    if (headers.strip.length > 0) {
      Json j;
      try
        j = parseJsonString(headers);
      catch (Exception)
        throw EventsException.invalid("Webhook headers must be a JSON object");
      if (j.type != Json.Type.object)
        throw EventsException.invalid("Webhook headers must be a JSON object");
    }
    if (authenticationType == WebhookAuthType.oauth2 && (tokenUrl.length == 0 || clientId.length == 0))
      throw EventsException.invalid("OAuth2 webhooks need tokenUrl and clientId");
    if (tokenUrl.length > 0 && !isHttpUrl(tokenUrl))
      throw EventsException.invalid("tokenUrl must be an http(s) URL");
    if (batchSize < 1 || batchSize > 1000)
      throw EventsException.invalid("batchSize must be between 1 and 1000");
  }
}

///
unittest {
  Webhook w;
  w.name = "erp";
  w.queueId = QueueId("q");
  w.url = "https://erp.example.com/events";
  w.headers = `{"X-Source": "mesh"}`;
  w.validate();
  assert(w.headerMap["X-Source"] == "mesh");
  w.headers = "[1]";
  assert(failsWith(EventsErrorKind.invalid, () { w.validate(); }));
  w.headers = "";
  w.authenticationType = WebhookAuthType.oauth2;
  assert(failsWith(EventsErrorKind.invalid, () { w.validate(); }));
}
