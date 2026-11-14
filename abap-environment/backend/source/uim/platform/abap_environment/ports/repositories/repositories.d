/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.repositories.repositories;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Persistence of system instances (tenant scoped, unique names).
interface ISystemInstanceRepository : ITenantRepository!(SystemInstance, SystemInstanceId) {
  SystemInstance findByName(TenantId tenantId, string name);
  SystemInstance findBySid(TenantId tenantId, string sapSystemId);
}

/// Persistence of aggregates that live inside one system (names unique per system).
interface ISystemScopedRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  TEntity findByName(TenantId tenantId, SystemInstanceId systemId, string name);
  TEntity[] findBySystem(TenantId tenantId, SystemInstanceId systemId);
}

interface ISoftwareComponentRepository : ISystemScopedRepository!(SoftwareComponent, SoftwareComponentId) {
}

interface ICommunicationArrangementRepository
  : ISystemScopedRepository!(CommunicationArrangement, CommunicationArrangementId) {
}

interface IServiceBindingRepository : ISystemScopedRepository!(ServiceBinding, ServiceBindingId) {
}

interface IBusinessUserRepository : ISystemScopedRepository!(BusinessUser, BusinessUserId) {
  BusinessUser findByEmail(TenantId tenantId, SystemInstanceId systemId, string email);
  BusinessUser[] findByRole(TenantId tenantId, BusinessRoleId roleId);
}

interface IBusinessRoleRepository : ISystemScopedRepository!(BusinessRole, BusinessRoleId) {
}

interface IApplicationJobRepository : ISystemScopedRepository!(ApplicationJob, ApplicationJobId) {
}

/// Transports belong to their source system; `findBySystem` returns those.
interface ITransportRequestRepository : ISystemScopedRepository!(TransportRequest, TransportRequestId) {
  TransportRequest[] findByTarget(TenantId tenantId, SystemInstanceId systemId);
}
