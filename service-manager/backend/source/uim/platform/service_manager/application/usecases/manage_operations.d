/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageOperationsUseCase : IManageOperations {
  protected IOperationRepository operations;
  protected IServiceInstanceRepository instances;
  protected IServiceBindingRepository bindings;
  protected ILabelRepository labels;

  this(IOperationRepository operations, IServiceInstanceRepository instances, IServiceBindingRepository bindings,
    ILabelRepository labels) {
    this.operations = operations;
    this.instances = instances;
    this.bindings = bindings;
    this.labels = labels;
  }

  Operation[] listOperations(TenantId tenantId) {
    return operations.findAll(tenantId);
  }

  Operation getOperation(TenantId tenantId, OperationId id) {
    return operations.findById(tenantId, id).required("Operation '" ~ id.value ~ "'");
  }

  Operation completeOperation(CompleteOperationRequest r) {
    auto t = r.tenantId;
    auto op = getOperation(t, r.id);
    if (op.isFinal)
      throw ServiceManagerException.conflict("Operation '" ~ op.id.value ~ "' is already " ~ cast(string) op.status);
    auto now = nowStdTime();
    if (r.succeeded)
      op.succeed(now);
    else
      op.fail(r.errorMessage, now);

    final switch (op.resourceType) {
    case ResourceType.serviceInstance:
      applyToInstance(t, op, r.succeeded);
      break;
    case ResourceType.serviceBinding:
      applyToBinding(t, op, r.succeeded);
      break;
    case ResourceType.platform, ResourceType.serviceBroker, ResourceType.serviceOffering, ResourceType.servicePlan:
      break;
    }
    stampUpdated(op, r.actor);
    operations.save(op);
    return op;
  }

  void deleteOperation(TenantId tenantId, OperationId id) {
    auto op = getOperation(tenantId, id);
    if (!op.isFinal)
      throw ServiceManagerException.ruleViolation("Operation '" ~ op.id.value ~ "' is still " ~ cast(string) op.status);
    operations.removeById(tenantId, id);
  }

  protected void applyToInstance(TenantId t, const Operation op, bool ok) {
    auto inst = instances.findById(t, ServiceInstanceId(op.resourceId));
    if (inst.isNull)
      return;
    if (op.type == OperationType.delete_ && ok) {
      instances.removeById(t, inst.id);
      labels.removeByResource(t, ResourceType.serviceInstance, inst.id.value);
      return;
    }
    inst.transitionTo(ok ? ServiceInstanceStatus.created : ServiceInstanceStatus.failed);
    inst.updatedAt = op.completedAt;
    instances.save(inst);
  }

  protected void applyToBinding(TenantId t, const Operation op, bool ok) {
    auto b = bindings.findById(t, ServiceBindingId(op.resourceId));
    if (b.isNull)
      return;
    if (op.type == OperationType.unbind && ok) {
      bindings.removeById(t, b.id);
      labels.removeByResource(t, ResourceType.serviceBinding, b.id.value);
      return;
    }
    b.transitionTo(ok ? ServiceBindingStatus.created : ServiceBindingStatus.failed);
    b.updatedAt = op.completedAt;
    bindings.save(b);
  }
}
