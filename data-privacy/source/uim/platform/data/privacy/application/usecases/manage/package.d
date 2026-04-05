/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation;

public {
  import uim.platform.data.privacy.domain.entities.data_processing_activity;
  import uim.platform.data.privacy.domain.entities.data_access_request;
  import uim.platform.data.privacy.domain.entities.consent;
  import uim.platform.data.privacy.domain.entities.privacy_policy;
  import uim.platform.data.privacy.domain.entities.data_subject;
  
  import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
  import uim.platform.data.privacy.domain.ports.repositories.data_processing_activities;
  import uim.platform.data.privacy.domain.ports.repositories.data_access_requests;
  import uim.platform.data.privacy.domain.ports.repositories.consents;
  import uim.platform.data.privacy.domain.ports.repositories.privacy_policies;
}