/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.route;

// import uim.platform.foundry.domain.types;

import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// A route — maps incoming HTTP/TCP traffic to one or more applications
/// via a domain, optional host prefix, and optional URL path.
struct Route {
  mixin TenantEntity!(RouteId);

  SpaceId spaceId; // the space this route belongs to
  CfDomainId domainId; // the domain this route is associated with
  string host; // subdomain portion (e.g. "myapp")
  string path; // URL path prefix (e.g. "/api")
  int port; // port number for TCP routes
  RouteProtocol protocol = RouteProtocol.http;
  string[] mappedAppIds; // applications mapped to this route
  
  Json toJson() const {
    auto j = entityToJson
      .set("spaceId", spaceId)
      .set("domainId", domainId)
      .set("host", host)
      .set("path", path)
      .set("port", port)
      .set("protocol", protocol.to!string)
      .set("mappedAppIds", mappedAppIds);

    return j;
  }
}
