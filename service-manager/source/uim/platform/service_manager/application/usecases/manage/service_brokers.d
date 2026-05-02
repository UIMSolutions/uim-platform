module uim.platform.service_manager.application.usecases.manage.manage_service_brokers;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBrokersUseCase { // TODO: UIMUseCase {
    private ServiceBrokerRepository repo;

    this(ServiceBrokerRepository repo) {
        this.repo = repo;
    }

    ServiceBroker[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBroker* getById(TenantId tenantId, ServiceBrokerId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult create(TenantId tenantId, CreateServiceBrokerRequest dto) {
        import std.conv : to;

        ServiceBroker e;
        e.id = ServiceBrokerId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.brokerUrl = dto.brokerUrl;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service broker name is required");
        if (dto.brokerUrl.length == 0)
            return CommandResult(false, "", "Broker URL is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, ServiceBrokerId id, UpdateServiceBrokerRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service broker not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.brokerUrl.length > 0) existing.brokerUrl = dto.brokerUrl;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, ServiceBrokerId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service broker not found");

        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
