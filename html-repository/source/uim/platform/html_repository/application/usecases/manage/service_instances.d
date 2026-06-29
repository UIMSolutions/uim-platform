/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.service_instances;
// import uim.platform.html_repository.domain.ports.repositories.service_instances;
// import uim.platform.html_repository.domain.entities.service_instance;
// import uim.platform.html_repository.domain.services.deployment_validator;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase { // TODO: UIMUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) {
        this.repo = repo;
    }

    CommandResult createServiceInstance(CreateServiceInstanceRequest r) {
        if (!DeploymentValidator.validateInstanceName(r.name))
            return CommandResult(false, "", "Invalid service instance name");

        ServiceInstance inst;
        inst.initEntity(r.tenantId, r.createdBy);
        inst.spaceId = r.spaceId;
        inst.name = r.name;
        inst.plan = parsePlan(r.plan);
        inst.sizeQuotaMb = r.sizeQuotaMb > 0 ? r.sizeQuotaMb : 100;
        inst.sizeUsedMb = 0;
        inst.status = InstanceStatus.active;

        repo.save(inst);
        return CommandResult(true, inst.id.value, "");
    }

    CommandResult updateServiceInstance(ServiceInstanceId id, UpdateServiceInstanceRequest r) {
        auto inst = repo.findById(tenantId, id);
        if (inst.isNull)
            return CommandResult(false, "", "Service instance not found");

        if (r.name.length > 0) inst.name = r.name;
        if (r.plan.length > 0) inst.plan = parsePlan(r.plan);
        if (r.sizeQuotaMb > 0) inst.sizeQuotaMb = r.sizeQuotaMb;
        inst.updatedAt = currentTimestamp();
        inst.updatedBy = r.updatedBy;

        repo.update(inst);
        return CommandResult(true, inst.id.value, "");
    }

    ServiceInstance getServiceInstance(ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    ServiceInstance[] listServiceInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteServiceInstance(ServiceInstanceId id) {
        auto inst = repo.findById(tenantId, id);
        if (inst.isNull)
            return CommandResult(false, "", "Service instance not found");

        repo.remove(inst);
        return CommandResult(true, inst.id.value, "");
    }

    size_t countServiceInstances(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    private static ServicePlan parsePlan(string p) {
        switch (p) {
            case "app-host": return ServicePlan.appHost;
            case "app-runtime": return ServicePlan.appRuntime;
            case "free": return ServicePlan.free;
            default: return ServicePlan.appHost;
        }
    }

}
