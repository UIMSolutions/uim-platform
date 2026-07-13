/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.application.usecases.manage.api_clients;
// import uim.platform.identity_directory.domain.entities.api_client;
// import uim.platform.identity_directory.domain.entities.audit_event;

// import uim.platform.identity_directory.domain.ports.repositories.api_clients;
// import uim.platform.identity_directory.domain.ports.repositories.audits;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

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
    auto now = currentTimestamp();
    auto clientId = randomUUID().toString(); /// ~ "-" ~ randomUUID().toString();
    auto clientSecret = randomUUID().toString() ~ "-" ~ randomUUID().toString();

    auto client = ApiClient(req.tenantId, ApiClientId(randomUUID().toString()));
    client.name = req.name;
    client.description = req.description;
    client.scopes = req.scopes;
    client.clientId = clientId;
    client.clientSecret = clientSecret;
    client.active = true;
    client.expiresAt = req.expiresAt;
    client.lastUsedAt = 0;

    clientRepo.save(client);

    auto event = AuditEvent(req.tenantId);
    event.id = randomUUID().toString(); 
    event.eventType = AuditEventType.apiClientCreated;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = client.id.value;
    event.targetType = "ApiClient";
    event.description = "API client created: " ~ req.name;
    event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;

    auditRepo.save(event);

    return ApiClientResponse(clientId, clientSecret, "");
  }

  /// Get client by ID.
  ApiClient getClient(TenantId tenantId, ApiClientId id) {
    return clientRepo.findById(tenantId, id);
  }

  /// List clients for a tenant.
  ApiClient[] listClients(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return clientRepo.findByTenant(tenantId, offset, limit);
  }

  /// Revoke an API client.
  CommandResult revokeClient(TenantId tenantId, ApiClientId id) {
    auto client = clientRepo.findById(tenantId, id);
    if (client.isNull)
      return CommandResult(false, "", "API client not found");

    client.active = false;
    clientRepo.update(client);

    auto event = AuditEvent(tenantId);
    event.id = randomUUID().toString();
    event.eventType = AuditEventType.apiClientRevoked;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = client.id.value;
    event.targetType = "ApiClient";
    event.description = "API client revoked: " ~ client.name;
    event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;

    auditRepo.save(event);

    return CommandResult(true, client.id.value, "API client revoked successfully.");
  }
}
