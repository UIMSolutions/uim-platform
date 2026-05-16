module uim.platform.service_manager.application.usecases.manage.platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManagePlatformsUseCase { // TODO: UIMUseCase {
    private PlatformRepository repo;

    this(PlatformRepository repo) {
        this.repo = repo;
    }

    Platform[] listPlatforms(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Platform getPlatform(TenantId tenantId, PlatformId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createPlatform(TenantId tenantId, CreatePlatformRequest dto) {
            Platform e;
        e.initEntity(tenantId);

        e.id = PlatformId(currentTimestamp.to!string);
        e.name = dto.name;
        e.description = dto.description;
        e.brokerUrl = dto.brokerUrl;
        e.credentials = dto.credentials;
        e.region = dto.region;
        e.subaccountId = dto.subaccountId;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Platform name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updatePlatform(TenantId tenantId, PlatformId id, UpdatePlatformRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Platform not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.brokerUrl.length > 0) existing.brokerUrl = dto.brokerUrl;
        if (dto.credentials.length > 0) existing.credentials = dto.credentials;
        if (dto.region.length > 0) existing.region = dto.region;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult deletePlatform(TenantId tenantId, PlatformId id) {
        auto platform = repo.findById(tenantId, id);
        if (platform.isNull)
            return CommandResult(false, "", "Platform not found");

        repo.remove(platform);
        return CommandResult(true, platform.id.value, "");
    }
}
