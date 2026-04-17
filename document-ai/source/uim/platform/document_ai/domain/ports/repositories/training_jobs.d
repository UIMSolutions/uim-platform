/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.training_jobs;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.training_job;

interface TrainingJobRepository {
  bool existsById(TrainingJobId id, ClientId clientId);
  TrainingJob findById(TrainingJobId id, ClientId clientId);

  size_t countByClient(ClientId clientId);
  TrainingJob[] findByClient(ClientId clientId);

  TrainingJob[] findByDocumentType(DocumentTypeId typeId, ClientId clientId);

  size_t countByStatus(TrainingJobStatus status, ClientId clientId);
  TrainingJob[] findByStatus(TrainingJobStatus status, ClientId clientId);

  void save(TrainingJob tj);
  void update(TrainingJob tj);
  void remove(TrainingJobId id, ClientId clientId);
}
