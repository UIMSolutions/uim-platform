/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.usecases.training_jobs;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IManageTrainingJobsUseCase {
  
  CommandResult createTrainingJob(CreateTrainingJobRequest r);
  CommandResult patchTrainingJob(PatchTrainingJobRequest r);
  TrainingJob getTrainingJob(ClientId clientId, TrainingJobId id);
  TrainingJob[] listTrainingJobs(ClientId clientId);
  TrainingJob[] listTrainingJobs(ClientId clientId, TrainingJobStatus status);
  TrainingJob[] listTrainingJobs(ClientId clientId, DocumentTypeId typeId);
  CommandResult deleteTrainingJob(ClientId clientId, TrainingJobId id);
  size_t countTrainingJobs(ClientId clientId);

}
