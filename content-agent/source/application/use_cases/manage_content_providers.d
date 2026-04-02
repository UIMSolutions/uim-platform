module application.usecases.manage_content_providers;

import uim.platform.content_agent.application.dto;
import domain.entities.content_provider;
import domain.entities.content_activity;
import domain.ports.content_provider_repository;
import domain.ports.content_activity_repository;
import domain.types;

import std.conv : to;

/// Application service for content provider registration and management.
class ManageContentProvidersUseCase
{
    private ContentProviderRepository providerRepo;
    private ContentActivityRepository activityRepo;

    this(ContentProviderRepository providerRepo, ContentActivityRepository activityRepo)
    {
        this.providerRepo = providerRepo;
        this.activityRepo = activityRepo;
    }

    CommandResult registerProvider(RegisterProviderRequest req)
    {
        auto existing = providerRepo.findByName(req.tenantId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Provider with name '" ~ req.name ~ "' already exists");

        if (req.name.length == 0)
            return CommandResult(false, "", "Provider name is required");
        if (req.endpoint.length == 0)
            return CommandResult(false, "", "Provider endpoint is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        ContentProvider provider;
        provider.id = id;
        provider.tenantId = req.tenantId;
        provider.name = req.name;
        provider.description = req.description;
        provider.endpoint = req.endpoint;
        provider.authToken = req.authToken;
        provider.status = ProviderStatus.active;
        provider.createdBy = req.registeredBy;
        provider.registeredAt = clockSeconds();

        providerRepo.save(provider);
        recordActivity(req.tenantId, ActivityType.providerRegistered, id, req.name,
            "Provider registered", req.registeredBy);

        return CommandResult(true, id, "");
    }

    CommandResult updateProvider(ContentProviderId id, UpdateProviderRequest req)
    {
        auto provider = providerRepo.findById(id);
        if (provider.id.length == 0)
            return CommandResult(false, "", "Provider not found");

        if (req.description.length > 0) provider.description = req.description;
        if (req.endpoint.length > 0) provider.endpoint = req.endpoint;
        if (req.authToken.length > 0) provider.authToken = req.authToken;

        providerRepo.update(provider);
        return CommandResult(true, id, "");
    }

    CommandResult deregisterProvider(ContentProviderId id)
    {
        auto provider = providerRepo.findById(id);
        if (provider.id.length == 0)
            return CommandResult(false, "", "Provider not found");

        provider.status = ProviderStatus.deregistered;
        providerRepo.update(provider);

        recordActivity(provider.tenantId, ActivityType.providerDeregistered, id, provider.name,
            "Provider deregistered", "");

        return CommandResult(true, id, "");
    }

    CommandResult syncProvider(ContentProviderId id)
    {
        auto provider = providerRepo.findById(id);
        if (provider.id.length == 0)
            return CommandResult(false, "", "Provider not found");

        if (provider.status != ProviderStatus.active)
            return CommandResult(false, "", "Provider is not active");

        // In a real implementation, this would call the provider endpoint
        // to discover available content types
        provider.lastSyncAt = clockSeconds();
        providerRepo.update(provider);

        return CommandResult(true, id, "");
    }

    ContentProvider getProvider(ContentProviderId id)
    {
        return providerRepo.findById(id);
    }

    ContentProvider[] listProviders(TenantId tenantId)
    {
        return providerRepo.findByTenant(tenantId);
    }

    ContentProvider[] listActiveProviders(TenantId tenantId)
    {
        return providerRepo.findByStatus(tenantId, ProviderStatus.active);
    }

    private void recordActivity(TenantId tenantId, ActivityType actType,
        string entityId, string entityName, string desc, string by)
    {
        import std.uuid : randomUUID;
        ContentActivity activity;
        activity.id = randomUUID().toString();
        activity.tenantId = tenantId;
        activity.activityType = actType;
        activity.severity = ActivitySeverity.info;
        activity.entityId = entityId;
        activity.entityName = entityName;
        activity.description = desc;
        activity.performedBy = by;
        activity.timestamp = clockSeconds();
        activityRepo.save(activity);
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }
}
