/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.types;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
// --- Type aliases ---
struct DatasetId {
  mixin(IdTemplate);
}

struct DataRecordId {
  mixin(IdTemplate);
}

struct ModelConfigurationId {
  mixin(IdTemplate);
}

struct TrainingJobId {
  mixin(IdTemplate);
}

struct DeploymentId {
  mixin(IdTemplate);
}

struct InferenceRequestId {
  mixin(IdTemplate);
}

struct InferenceResultId {
  mixin(IdTemplate);
}