/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface RunConfigurationRepository {
    bool existsById(RunConfigurationId id);
    RunConfiguration findById(RunConfigurationId id);

    RunConfiguration[] findAll();
    RunConfiguration[] findByTenant(TenantId tenantId);
    RunConfiguration[] findByProject(ProjectId projectId);

    void save(RunConfiguration entity);
    void update(RunConfiguration entity);
    void remove(RunConfigurationId id);
}
