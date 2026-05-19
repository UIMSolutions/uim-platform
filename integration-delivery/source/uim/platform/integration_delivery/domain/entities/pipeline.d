/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.pipeline;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct Pipeline {
    mixin TenantEntity!(PipelineId);

    string name;
    string description;
    PipelineType pipelineType = PipelineType.cap;
    string[] enabledStages;
    string configurationYaml;
    PipelineStatus status = PipelineStatus.active;
    string version_;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("pipelineType", pipelineType.to!string)
            .set("configurationYaml", configurationYaml)
            .set("status", status.to!string)
            .set("version", version_);
    }
}
