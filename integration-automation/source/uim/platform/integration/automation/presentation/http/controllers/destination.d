/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.controllers.destination;




// import uim.platform.integration.automation.application.usecases.manage.destinations;
// import uim.platform.integration.automation.application.dto;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.destination;
// import uim.platform.integration.automation.presentation.http.scenario_controller : parseSystemType;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class DestinationController : ManageController {
  private ManageDestinationsUseCase useCase;

  this(ManageDestinationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGet);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateDestinationRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.systemId = data.getString("systemId");
      r.destinationType = parseDestinationType(data.getString("destinationType"));
      r.url = data.getString("url");
      r.authenticationType = parseAuthenticationType(data.getString("authenticationType"));
      r.proxyType = parseProxyType(data.getString("proxyType"));
      r.cloudConnectorLocationId = data.getString("cloudConnectorLocationId");
      r.user = data.getString("user");
      r.tokenServiceUrl = data.getString("tokenServiceUrl");
      r.tokenServiceUser = data.getString("tokenServiceUser");
      r.audience = data.getString("audience");
      r.scope_ = data.getString("scope");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createDestination(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto destinations = useCase.listDestinations(tenantId);

      auto arr = destinations.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", destinations.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto dest = useCase.getDestination(tenantId, id);
      if (dest.isNull) {
        writeError(res, 404, "Destination not found");
        return;
      }
      res.writeJsonBody(dest.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateDestinationRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.systemId = data.getString("systemId");
      r.destinationType = parseDestinationType(data.getString("destinationType"));
      r.url = data.getString("url");
      r.authenticationType = parseAuthenticationType(data.getString("authenticationType"));
      r.proxyType = parseProxyType(data.getString("proxyType"));
      r.cloudConnectorLocationId = data.getString("cloudConnectorLocationId");
      r.user = data.getString("user");
      r.tokenServiceUrl = data.getString("tokenServiceUrl");
      r.tokenServiceUser = data.getString("tokenServiceUser");
      r.audience = data.getString("audience");
      r.scope_ = data.getString("scope");
      r.isEnabled = j.getBoolean("isEnabled", true);

      auto result = useCase.updateDestination(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteDestination(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDestination(const Destination d) {
    return Json.emptyObject
      .set("id", d.id)
      .set("tenantId", d.tenantId)
      .set("name", d.name)
      .set("description", d.description)
      .set("systemId", d.systemId)
      .set("destinationType", d.destinationType.to!string)
      .set("url", d.url)
      .set("authenticationType", d.authenticationType.to!string)
      .set("proxyType", d.proxyType.to!string)
      .set("cloudConnectorLocationId", d.cloudConnectorLocationId)
      .set("user", d.user)
      .set("tokenServiceUrl", d.tokenServiceUrl)
      .set("audience", d.audience)
      .set("scope", d.scope_)
      .set("isEnabled", d.isEnabled)
      .set("createdBy", d.createdBy)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);
  }
}

DestinationType parseDestinationType(string s) {
  switch (s) {
  case "http":
    return DestinationType.http;
  case "rfc":
    return DestinationType.rfc;
  case "odata":
    return DestinationType.odata;
  case "soap":
    return DestinationType.soap;
  case "restApi":
    return DestinationType.restApi;
  default:
    return DestinationType.http;
  }
}

AuthenticationType parseAuthenticationType(string s) {
  switch (s) {
  case "basic":
    return AuthenticationType.basic;
  case "oauth2ClientCredentials":
    return AuthenticationType.oauth2ClientCredentials;
  case "oauth2Saml":
    return AuthenticationType.oauth2Saml;
  case "certificate":
    return AuthenticationType.certificate;
  case "samlBearer":
    return AuthenticationType.samlBearer;
  case "principalPropagation":
    return AuthenticationType.principalPropagation;
  case "noAuthentication":
    return AuthenticationType.noAuthentication;
  default:
    return AuthenticationType.basic;
  }
}

ProxyType parseProxyType(string s) {
  switch (s) {
  case "internet":
    return ProxyType.internet;
  case "onPremise":
    return ProxyType.onPremise;
  case "privateLink":
    return ProxyType.privateLink;
  default:
    return ProxyType.internet;
  }
}
