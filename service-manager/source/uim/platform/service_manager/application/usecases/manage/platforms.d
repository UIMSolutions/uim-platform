module uim.platform.service_manager.application.usecases.manage.platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManagePlatformsUseCase {
    private IPlatformRepository repo;

    this(IPlatformRepository repo) {
        this.repo = repo;
    }

    Platform[] listPlatforms(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Platform getPlatform(TenantId tenantId, PlatformId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createPlatform(CreatePlatformRequest dto) {
        auto platform = Platform(dto.tenantId);

        platform.id = PlatformId(currentTimestamp.to!string);
        platform.name = dto.name;
        platform.description = dto.description;
        platform.brokerUrl = dto.brokerUrl;
        platform.credentials = dto.credentials;
        platform.region = dto.region;
        platform.createdAt = currentTimestamp;
        platform.status = PlatformStatus.active;
        platform.subaccountId = dto.subaccountId;

        if (dto.name.isEmpty)
            return CommandResult(false, "", "Platform name is required");

        repo.save(platform);
        return CommandResult(true, platform.id.value, "");
    }

    CommandResult updatePlatform(UpdatePlatformRequest dto) {
        auto platform = repo.findById(dto.tenantId, dto.platformId);
        if (platform.isNull)
            return CommandResult(false, "", "Platform not found");

        if (dto.name.length > 0)
            platform.name = dto.name;
        if (dto.description.length > 0)
            platform.description = dto.description;
        if (dto.brokerUrl.length > 0)
            platform.brokerUrl = dto.brokerUrl;
        if (dto.credentials.length > 0)
            platform.credentials = dto.credentials;
        if (dto.region.length > 0)
            platform.region = dto.region;
        platform.updatedAt = currentTimestamp;

        repo.update(platform);
        return CommandResult(true, platform.id.value, "");
    }

    CommandResult deletePlatform(TenantId tenantId, PlatformId id) {
        auto platform = repo.findById(tenantId, id);
        if (platform.isNull)
            return CommandResult(false, "", "Platform not found");

        repo.remove(platform);
        return CommandResult(true, platform.id.value, "");
    }
}

///
unittest {
    auto repo = new PlatformRepository();
    auto usecase = new ManagePlatformsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreatePlatformRequest createDto;
    createDto.tenantId = tenantId;
    createDto.platformId = PlatformId("platform-1");
    createDto.name = "Test Platform";
    auto createResult = usecase.createPlatform(createDto);
    // TODO: assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listPlatforms(tenantId);
    // TODO: assert(items.length == 1);

    // Test get
    auto item = usecase.getPlatform(tenantId, PlatformId("platform-1"));
    // TODO: assert(!item.isNull);

    // Test update
    UpdatePlatformRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.platformId = PlatformId("platform-1");
    updateDto.name = "Updated Platform";
    auto updateResult = usecase.updatePlatform(updateDto);
    // TODO: assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deletePlatform(tenantId, PlatformId("platform-1"));
    // TODO: assert(deleteResult.success, deleteResult.message);
    // TODO: assert(usecase.listPlatforms(tenantId).length == 0);

}
