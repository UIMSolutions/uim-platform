/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.message_client;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// An application that connects to a messaging service (OAuth2 client).
struct MessageClient {
  mixin TenantEntity!MessageClientId;

  MessagingServiceId serviceId;
  string name;
  string description;
  MessageClientStatus status = MessageClientStatus.active;
  MessageClientProtocol protocol = MessageClientProtocol.httprest;
  string clientId; /// OAuth2 client id
  string clientSecret; /// secret — never returned by adapters
  string tokenUrl;
  string permittedNamespace; /// namespace (or sub-namespace) the client may use

  bool isActive() const {
    return status == MessageClientStatus.active;
  }

  void validate() const {
    requireText(name, "Message client name");
    if (serviceId.isNull)
      throw EventsException.invalid("Message client needs a serviceId");
    if (tokenUrl.length > 0 && !isHttpUrl(tokenUrl))
      throw EventsException.invalid("tokenUrl must be an http(s) URL");
  }
}
