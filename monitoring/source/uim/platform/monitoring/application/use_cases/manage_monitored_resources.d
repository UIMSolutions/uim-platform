module uim.platform.xyz.application.usecases.manage_monitored_resources;

import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.monitored_resource;
import uim.platform.xyz.domain.ports.monitored_resource_repository;
import uim.platform.xyz.domain.types;

import std.conv : to;

/// Application service for monitored resource CRUD operations.
class ManageMonitoredResourcesUseCase
{
    private MonitoredResourceRepository repo;

    this(MonitoredResourceRepository repo)
    {
        this.repo = repo;
    }

    CommandResult register(RegisterResourceRequest req)
    {
        auto existing = repo.findByName(req.tenantId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Resource with name '" ~ req.name ~ "' already exists");

        if (req.name.length == 0)
            return CommandResult(false, "", "Resource name is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        MonitoredResource r;
        r.id = id;
        r.tenantId = req.tenantId;
        r.subaccountId = req.subaccountId;
        r.name = req.name;
        r.description = req.description;
        r.resourceType = parseResourceType(req.resourceType);
        r.state = ResourceState.unknown;
        r.url = req.url;
        r.runtime = req.runtime;
        r.region = req.region;
        r.instanceCount = req.instanceCount;
        r.tags = req.tags;
        r.registeredBy = req.registeredBy;
        r.registeredAt = clockSeconds();
        r.lastSeenAt = r.registeredAt;

        repo.save(r);
        return CommandResult(true, id, "");
    }

    CommandResult updateResource(MonitoredResourceId id, UpdateResourceRequest req)
    {
        auto r = repo.findById(id);
        if (r.id.length == 0)
            return CommandResult(false, "", "Resource not found");

        if (req.description.length > 0) r.description = req.description;
        if (req.url.length > 0) r.url = req.url;
        if (req.runtime.length > 0) r.runtime = req.runtime;
        if (req.state.length > 0) r.state = parseResourceState(req.state);
        if (req.instanceCount > 0) r.instanceCount = req.instanceCount;
        if (req.tags.length > 0) r.tags = req.tags;
        r.lastSeenAt = clockSeconds();

        repo.update(r);
        return CommandResult(true, id, "");
    }

    MonitoredResource getResource(MonitoredResourceId id)
    {
        return repo.findById(id);
    }

    MonitoredResource[] listResources(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    MonitoredResource[] listByType(TenantId tenantId, string typeStr)
    {
        return repo.findByType(tenantId, parseResourceType(typeStr));
    }

    CommandResult removeResource(MonitoredResourceId id)
    {
        auto r = repo.findById(id);
        if (r.id.length == 0)
            return CommandResult(false, "", "Resource not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }

    private static ResourceType parseResourceType(string s)
    {
        switch (s)
        {
            case "html5Application":    return ResourceType.html5Application;
            case "hanaXsApplication":   return ResourceType.hanaXsApplication;
            case "databaseSystem":      return ResourceType.databaseSystem;
            case "nodeApplication":     return ResourceType.nodeApplication;
            case "customApplication":   return ResourceType.customApplication;
            case "service":             return ResourceType.service;
            default:                    return ResourceType.javaApplication;
        }
    }

    private static ResourceState parseResourceState(string s)
    {
        switch (s)
        {
            case "started": return ResourceState.started;
            case "stopped": return ResourceState.stopped;
            case "error":   return ResourceState.error;
            default:        return ResourceState.unknown;
        }
    }
}
