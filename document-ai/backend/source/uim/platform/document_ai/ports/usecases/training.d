/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the training jobs.
module uim.platform.document_ai.ports.usecases.training;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IManageTrainingJobs : IManageResource!(TrainingJob, TrainingJobId, TrainingJobInput) {
  /// Needs an active schema and enough confirmed documents; one running job per schema.
  TrainingJob start(TenantId t, TrainingJobId id, UserId actor);
  TrainingJob cancel(TenantId t, TrainingJobId id, UserId actor);
  /// Complete the running jobs whose training time is over (background worker); returns the number completed.
  long advance(TenantId t, UserId actor);
  /// Training time of a job in seconds (for the progress).
  long durationSeconds();
}
