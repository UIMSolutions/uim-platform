/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface BuildConfigurationRepository {
    bool existsById(BuildConfigurationId id);
    BuildConfiguration findById(BuildConfigurationId id);

    BuildConfiguration[] findAll();
    BuildConfiguration[] findByTenant(TenantId tenantId);
    BuildConfiguration[] findByProject(ProjectId projectId);
    BuildConfiguration[] findByStatus(BuildStatus status);

    void save(BuildConfiguration entity);
    void update(BuildConfiguration entity);
    void remove(BuildConfigurationId id);
}
