module uim.platform.service_manager.application.usecases.manage.manage_platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManagePlatformsUseCase { // TODO: UIMUseCase {
    private PlatformRepository repo;

    this(PlatformRepository repo) {
        this.repo = repo;
    }

    Platform[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Platform getById(TenantId tenantId, PlatformId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult create(TenantId tenantId, CreatePlatformRequest dto) {
        import std.conv : to;

        Platform e;
        e.id = PlatformId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.brokerUrl = dto.brokerUrl;
        e.credentials = dto.credentials;
        e.region = dto.region;
        e.subaccountId = dto.subaccountId;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Platform name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, PlatformId id, UpdatePlatformRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Platform not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.brokerUrl.length > 0) existing.brokerUrl = dto.brokerUrl;
        if (dto.credentials.length > 0) existing.credentials = dto.credentials;
        if (dto.region.length > 0) existing.region = dto.region;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, PlatformId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Platform not found");

        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
