/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// SAP Task Center style service: a unified inbox that federates human tasks
/// from task providers (S/4HANA, SuccessFactors, Ariba, Fieldglass, Concur,
/// SAP Build, custom REST), with a task lifecycle (claim, release, forward,
/// approve, reject, complete, cancel, escalate, resubmit), substitution rules
/// with auto-forwarding, comments, attachments, saved filters and an audit trail.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.task_center;

public {
  import uim.platform.service;

  import uim.platform.task_center.domain;
  import uim.platform.task_center.ports;
  import uim.platform.task_center.application;
  import uim.platform.task_center.persistence;
  import uim.platform.task_center.infrastructure;
  import uim.platform.task_center.presentation;
}
