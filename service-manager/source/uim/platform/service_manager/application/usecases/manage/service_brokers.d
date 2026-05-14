module uim.platform.service_manager.application.usecases.manage.service_brokers;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBrokersUseCase { // TODO: UIMUseCase {
    private ServiceBrokerRepository repo;

    this(ServiceBrokerRepository repo) {
        this.repo = repo;
    }

    ServiceBroker[] listServiceBrokers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBroker getServiceBroker(TenantId tenantId, ServiceBrokerId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createServiceBroker(TenantId tenantId, CreateServiceBrokerRequest dto) {
        ServiceBroker e;
        e.initEntity(tenantId);

        e.id = ServiceBrokerId(MonoTime.currTime.ticks.to!string);
        e.name = dto.name;
        e.description = dto.description;
        e.brokerUrl = dto.brokerUrl;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service broker name is required");
        if (dto.brokerUrl.length == 0)
            return CommandResult(false, "", "Broker URL is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServiceBroker(TenantId tenantId, ServiceBrokerId id, UpdateServiceBrokerRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service broker not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.brokerUrl.length > 0) existing.brokerUrl = dto.brokerUrl;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceBroker(TenantId tenantId, ServiceBrokerId id) {
        auto broker = repo.findById(tenantId, id);
        if (broker.isNull)
            return CommandResult(false, "", "Service broker not found");

        repo.remove(broker);
        return CommandResult(true, broker.id.value, "");
    }
}
