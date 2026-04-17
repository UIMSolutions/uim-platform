/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_event_applications;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageEventApplicationsUseCase : UIMUseCase {
    private EventApplicationRepository repo;

    this(EventApplicationRepository repo) {
        this.repo = repo;
    }

    EventApplication* getById(EventApplicationId id) {
        return repo.findById(id);
    }

    EventApplication[] list() {
        return repo.findAll();
    }

    EventApplication[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventApplication[] listByBrokerService(BrokerServiceId brokerServiceId) {
        return repo.findByBrokerService(brokerServiceId);
    }

    CommandResult create(EventApplicationDTO dto) {
        EventApplication a;
        a.id = EventApplicationId(dto.id);
        a.tenantId = dto.tenantId;
        a.brokerServiceId = BrokerServiceId(dto.brokerServiceId);
        a.name = dto.name;
        a.description = dto.description;
        a.applicationDomainId = dto.applicationDomainId;
        a.clientUsername = dto.clientUsername;
        a.clientProfile = dto.clientProfile;
        a.aclProfile = dto.aclProfile;
        a.version_ = dto.version_;
        a.publishTopics = dto.publishTopics;
        a.subscribeTopics = dto.subscribeTopics;
        a.webhookUrl = dto.webhookUrl;
        a.maxConnections = dto.maxConnections;
        a.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidEventApplication(a))
            return CommandResult(false, "", "Invalid event application data");
        repo.save(a);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(EventApplicationDTO dto) {
        auto existing = repo.findById(EventApplicationId(dto.id));
        if (existing is null)
            return CommandResult(false, "", "Event application not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.clientUsername.length > 0) existing.clientUsername = dto.clientUsername;
        if (dto.clientProfile.length > 0) existing.clientProfile = dto.clientProfile;
        if (dto.aclProfile.length > 0) existing.aclProfile = dto.aclProfile;
        if (dto.publishTopics.length > 0) existing.publishTopics = dto.publishTopics;
        if (dto.subscribeTopics.length > 0) existing.subscribeTopics = dto.subscribeTopics;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(EventApplicationId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Event application not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
