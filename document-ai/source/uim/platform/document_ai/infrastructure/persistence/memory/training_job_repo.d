/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.training_job_repo;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.training_job;
import uim.platform.document_ai.domain.ports.training_job_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryTrainingJobRepository : TrainingJobRepository {
  private TrainingJob[][string] store;

  TrainingJob findById(TrainingJobId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (ref tj; *cl) {
        if (tj.id == id)
          return tj;
      }
    }
    return TrainingJob.init;
  }

  TrainingJob[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  TrainingJob[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(tj => tj.documentTypeId == typeId).array;
    return [];
  }

  TrainingJob[] findByStatus(TrainingJobStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(tj => tj.status == status).array;
    return [];
  }

  void save(TrainingJob tj) {
    store[tj.clientId] ~= tj;
  }

  void update(TrainingJob tj) {
    if (auto cl = tj.clientId in store) {
      foreach (ref existing; *cl) {
        if (existing.id == tj.id) {
          existing = tj;
          return;
        }
      }
    }
  }

  void remove(TrainingJobId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).filter!(tj => tj.id != id).array;
    }
  }

  long countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).length;
    return 0;
  }

  long countByStatus(TrainingJobStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).filter!(tj => tj.status == status).array.length;
    return 0;
  }
}
