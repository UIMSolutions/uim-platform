/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.repositories.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

interface BuildConfigurationRepository : ITenantRepository!(BuildConfiguration, BuildConfigurationId) {

    size_t countByProject(ProjectId projectId);
    BuildConfiguration[] findByProject(ProjectId projectId);
    void removeByProject(ProjectId projectId);

    size_t countByStatus(BuildStatus status);
    BuildConfiguration[] findByStatus(BuildStatus status);
    void removeByStatus(BuildStatus status);

}
