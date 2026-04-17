/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.training_job;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.training_job;
import uim.platform.document_ai.domain.ports.repositories.training_jobs;

import std.algorithm : filter;
import std.array : array;

class MemoryTrainingJobRepository : TrainingJobRepository {
  private TrainingJob[][string] store;

  bool existsById(ClientId clientId, TrainingJobId id) {
    if (clientId !in store)
      return false;

    return store[clientId].any!(tj => tj.id == id);
  }

  TrainingJob findById(ClientId clientId, TrainingJobId id) {
    if (clientId !in store)
      return TrainingJob.init;

    foreach (tj; store[clientId]) {
      if (tj.id == id)
        return tj;
    }
    return TrainingJob.init;
  }

  TrainingJob[] findByClient(ClientId clientId) {
    return clientId in store ? store[clientId] : null;
  }

  TrainingJob[] findByDocumentType(ClientId clientId, DocumentTypeId typeId) {
    return findByClient(clientId)
      .filter!(tj => tj.documentTypeId == typeId).array;
  }

  TrainingJob[] findByStatus(ClientId clientId, TrainingJobStatus status) {
    return findByClient(clientId)
      .filter!(tj => tj.status == status).array;
  }

  void save(TrainingJob tj) {
    store[tj.clientId] ~= tj;
  }

  void update(TrainingJob tj) {
    if (tj.clientId !in store)
      return;

    store[tj.clientId] = findByClient(tj.clientId).map!(j => j.id == tj.id ? tj : j).array;
  }

  void remove(TrainingJobId id, ClientId clientId) {
    if (clientId !in store)
      return;

    store[clientId] = store[clientId].filter!(tj => tj.id != id).array;
  }

  size_t countByClient(ClientId clientId) {
    return findByClient(clientId).length;
  }

  size_t countByStatus(ClientId clientId, TrainingJobStatus status) {
    return findByClient(clientId)
      .filter!(tj => tj.status == status).array.length;
  }
}
