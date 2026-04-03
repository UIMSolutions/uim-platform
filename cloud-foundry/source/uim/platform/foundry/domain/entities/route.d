/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.route;

import uim.platform.foundry.domain.types;

/// A route — maps incoming HTTP/TCP traffic to one or more applications
/// via a domain, optional host prefix, and optional URL path.
struct Route
{
  RouteId id;
  SpaceId spaceId;
  DomainId domainId;
  TenantId tenantId;
  string host; // subdomain portion (e.g. "myapp")
  string path; // URL path prefix (e.g. "/api")
  int port; // port number for TCP routes
  RouteProtocol protocol = RouteProtocol.http;
  string[] mappedAppIds; // applications mapped to this route
  string createdBy;
  long createdAt;
  long updatedAt;
}
