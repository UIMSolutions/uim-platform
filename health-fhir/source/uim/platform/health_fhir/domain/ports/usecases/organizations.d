/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.organizations;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManageOrganizationsUseCase {

  UsecaseResult createOrganization(CreateOrganizationRequest r);

  UsecaseResult updateOrganization(UpdateOrganizationRequest r);

  Organization getOrganization(TenantId tenantId, OrganizationId id);

  Organization[] listOrganizations(TenantId tenantId);

  UsecaseResult deleteOrganization(TenantId tenantId, OrganizationId id);
  
}
