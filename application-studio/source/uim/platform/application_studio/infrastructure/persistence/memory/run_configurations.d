/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryRunConfigurationRepository : TenantRepository!(RunConfiguration, RunConfigurationId), RunConfigurationRepository {

    size_t countByProject(ProjectId projectId) {
        return findByProject(projectId).length;
    }

    RunConfiguration[] filterByProject(RunConfiguration[] configs, ProjectId projectId) {
        return configs.filter!(c => c.projectId == projectId).array;
    }

    RunConfiguration[] findByProject(ProjectId projectId) {
        return filterByProject(findAll(), projectId);
    }

    void removeByProject(ProjectId projectId) {
        findByProject(projectId).each!(c => remove(c));
    }
}
