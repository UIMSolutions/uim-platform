/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.usecases.manage.api_clients;

// import uim.platform.identity.directory.domain.entities.api_client;
// import uim.platform.identity.directory.domain.entities.audit_event;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.api_clients;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
// import uim.platform.identity.directory.application.dto;

import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:

// import std.uuid;
// import std.datetime.systime : Clock;

/// Application use case: API client / technical user management.
class ManageApiClientsUseCase { // TODO: UIMUseCase {
  private ApiClientRepository clientRepo;
  private AuditRepository auditRepo;

  this(ApiClientRepository clientRepo, AuditRepository auditRepo) {
    this.clientRepo = clientRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new API client.
  ApiClientResponse createClient(CreateApiClientRequest req) {
    auto now = Clock.currStdTime();
    auto id = randomUUID();
    auto clientId = randomUUID();
    auto clientSecret = randomUUID().toString() ~ "-" ~ randomUUID().toString();

    ApiClient client;
    client.initEntity(req.tenantId);

    client.name = req.name;
    client.description = req.description;
    client.scopes = req.scopes;
    client.clientId = clientId;
    client.clientSecret = clientSecret;
    client.active = true;
    client.expiresAt = req.expiresAt;
    client.lastUsedAt = null;

    clientRepo.save(client);
    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId, AuditEventType.apiClientCreated,
        "system", "System", client.id, "ApiClient",
        "API client created: " ~ req.name, "", "", null, now,));

    return ApiClientResponse(clientId, clientSecret, "");
  }

  /// Get client by ID.
  ApiClient getClient(ApiClientId id) {
    return clientRepo.findById(tenantId, id);
  }

  /// List clients for a tenant.
  ApiClient[] listClients(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return clientRepo.findByTenant(tenantId, offset, limit);
  }

  /// Revoke an API client.
  CommandResult revokeClient(ApiClientId id) {
    auto client = clientRepo.findById(tenantId, id);
    if (client == ApiClient.init)
      return CommandResult(false, "", "API client not found");

    client.active = false;
    clientRepo.update(client);

    auditRepo.save(AuditEvent(randomUUID().toString(), client.tenantId, AuditEventType.apiClientRevoked,
        "system", "System", id, "ApiClient", "API client revoked: " ~ client.name,
        "", "", null, Clock.currStdTime(),));

    return CommandResult(true, client.id.value, "API client revoked successfully.");
  }
}
