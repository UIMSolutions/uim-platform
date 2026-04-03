module application.usecases.manage_api_clients;

import domain.entities.api_client;
import domain.entities.audit_event;
import domain.types;
import domain.ports.api_client_repository;
import domain.ports.audit_repository;
import uim.platform.xyz.application.dto;

import std.uuid;
import std.datetime.systime : Clock;

/// Application use case: API client / technical user management.
class ManageApiClientsUseCase
{
    private ApiClientRepository clientRepo;
    private AuditRepository auditRepo;

    this(ApiClientRepository clientRepo, AuditRepository auditRepo)
    {
        this.clientRepo = clientRepo;
        this.auditRepo = auditRepo;
    }

    /// Create a new API client.
    ApiClientResponse createClient(CreateApiClientRequest req)
    {
        auto now = Clock.currStdTime();
        auto id = randomUUID().toString();
        auto clientId = randomUUID().toString();
        auto clientSecret = randomUUID().toString() ~ "-" ~ randomUUID().toString();

        auto client = ApiClient(
            id,
            req.tenantId,
            req.name,
            req.description,
            clientId,
            clientSecret,
            req.scopes,
            true,
            now,
            req.expiresAt,
            0, // lastUsedAt
        );
        clientRepo.save(client);

        auditRepo.save(AuditEvent(
            randomUUID().toString(),
            req.tenantId,
            AuditEventType.apiClientCreated,
            "system", "System",
            id, "ApiClient",
            "API client created: " ~ req.name,
            "", "", null,
            now,
        ));

        return ApiClientResponse(clientId, clientSecret, "");
    }

    /// Get client by ID.
    ApiClient getClient(ApiClientId id)
    {
        return clientRepo.findById(id);
    }

    /// List clients for a tenant.
    ApiClient[] listClients(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        return clientRepo.findByTenant(tenantId, offset, limit);
    }

    /// Revoke an API client.
    string revokeClient(ApiClientId id)
    {
        auto client = clientRepo.findById(id);
        if (client == ApiClient.init)
            return "API client not found";

        client.active = false;
        clientRepo.update(client);

        auditRepo.save(AuditEvent(
            randomUUID().toString(),
            client.tenantId,
            AuditEventType.apiClientRevoked,
            "system", "System",
            id, "ApiClient",
            "API client revoked: " ~ client.name,
            "", "", null,
            Clock.currStdTime(),
        ));

        return "";
    }
}
