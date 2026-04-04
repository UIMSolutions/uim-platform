/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.use_cases.manage_service_instances;

import uim.platform.html_repository.domain.ports.service_instance_repository;
import uim.platform.html_repository.domain.entities.service_instance;
import uim.platform.html_repository.domain.services.deployment_validator;
import uim.platform.html_repository.domain.types;
import uim.platform.html_repository.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageServiceInstancesUseCase : UIMUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateServiceInstanceRequest r) {
        if (!DeploymentValidator.validateInstanceName(r.name))
            return CommandResult(false, "", "Invalid service instance name");

        ServiceInstance inst;
        inst.id = randomUUID().to!string;
        inst.tenantId = r.tenantId;
        inst.spaceId = r.spaceId;
        inst.name = r.name;
        inst.plan = parsePlan(r.plan);
        inst.sizeQuotaMb = r.sizeQuotaMb > 0 ? r.sizeQuotaMb : 100;
        inst.sizeUsedMb = 0;
        inst.status = InstanceStatus.active;
        inst.createdAt = currentTimestamp();
        inst.updatedAt = inst.createdAt;
        inst.createdBy = r.createdBy;
        inst.modifiedBy = r.createdBy;

        repo.save(inst);
        return CommandResult(true, inst.id, "");
    }

    CommandResult update(ServiceInstanceId id, UpdateServiceInstanceRequest r) {
        auto inst = repo.findById(id);
        if (inst.id.length == 0)
            return CommandResult(false, "", "Service instance not found");

        if (r.name.length > 0) inst.name = r.name;
        if (r.plan.length > 0) inst.plan = parsePlan(r.plan);
        if (r.sizeQuotaMb > 0) inst.sizeQuotaMb = r.sizeQuotaMb;
        inst.updatedAt = currentTimestamp();
        inst.modifiedBy = r.modifiedBy;

        repo.update(inst);
        return CommandResult(true, inst.id, "");
    }

    ServiceInstance get_(ServiceInstanceId id) {
        return repo.findById(id);
    }

    ServiceInstance[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    void remove(ServiceInstanceId id) {
        repo.remove(id);
    }

    long countByTenant(TenantId tenantId) {
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

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
