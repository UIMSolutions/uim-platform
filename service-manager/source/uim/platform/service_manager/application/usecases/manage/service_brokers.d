module uim.platform.service_manager.application.usecases.manage.service_brokers;

import uim.platform.service_manager;
mixin(ShowModule!());

@safe:

class ManageServiceBrokersUseCase { // TODO: UIMUseCase {
    private ServiceBrokerRepository repo;

    this(ServiceBrokerRepository repo) {
        this.repo = repo;
    }

    ServiceBroker[] listBrokers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBroker getBroker(TenantId tenantId, ServiceBrokerId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createBroker(CreateServiceBrokerRequest dto) {
        auto broker = ServiceBroker(dto.tenantId);
        broker.id = ServiceBrokerId(currentTimestamp.to!string);
        broker.name = dto.name;
        broker.description = dto.description;
        broker.brokerUrl = dto.brokerUrl;

        if (dto.name.isEmpty)
            return CommandResult(false, "", "Service broker name is required");
        if (dto.brokerUrl.length == 0)
            return CommandResult(false, "", "Broker URL is required");

        repo.save(broker);
        return CommandResult(true, broker.id.value, "");
    }

    CommandResult updateBroker(UpdateServiceBrokerRequest dto) {
        auto broker = repo.findById(dto.tenantId, dto.brokerId);
        if (broker.isNull)
            return CommandResult(false, "", "Service broker not found");

        if (dto.name.length > 0)
            broker.name = dto.name;
        if (dto.description.length > 0)
            broker.description = dto.description;
        if (dto.brokerUrl.length > 0)
            broker.brokerUrl = dto.brokerUrl;
        broker.updatedAt = currentTimestamp;

        repo.update(broker);
        return CommandResult(true, broker.id.value, "");
    }

    CommandResult deleteBroker(TenantId tenantId, ServiceBrokerId id) {
        auto broker = repo.findById(tenantId, id);
        if (broker.isNull)
            return CommandResult(false, "", "Service broker not found");

        repo.remove(broker);
        return CommandResult(true, broker.id.value, "");
    }
}
