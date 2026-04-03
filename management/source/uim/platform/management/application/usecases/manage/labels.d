/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage_labels;

import uim.platform.management.application.dto;
import uim.platform.management.domain.entities.label;
import uim.platform.management.domain.ports.label_repository;
import uim.platform.management.domain.types;

/// Use case: manage labels (tags) on BTP resources.
class ManageLabelsUseCase
{
  private LabelRepository repo;

  this(LabelRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateLabelRequest req)
  {
    if (req.resourceId.length == 0)
      return CommandResult(false, "", "Resource ID is required");
    if (req.key.length == 0)
      return CommandResult(false, "", "Label key is required");
    if (req.values.length == 0)
      return CommandResult(false, "", "At least one label value is required");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();

    Label lbl;
    lbl.id = id;
    lbl.resourceType = parseResourceType(req.resourceType);
    lbl.resourceId = req.resourceId;
    lbl.key = req.key;
    lbl.values = req.values;
    lbl.createdBy = req.createdBy;
    lbl.createdAt = clockSeconds();
    lbl.modifiedAt = lbl.createdAt;

    repo.save(lbl);
    return CommandResult(true, id, "");
  }

  CommandResult update(LabelId id, UpdateLabelRequest req)
  {
    auto lbl = repo.findById(id);
    if (lbl.id.length == 0)
      return CommandResult(false, "", "Label not found");

    lbl.values = req.values;
    lbl.modifiedAt = clockSeconds();
    repo.update(lbl);
    return CommandResult(true, id, "");
  }

  Label getById(LabelId id)
  {
    return repo.findById(id);
  }

  Label[] listByResource(string resourceType, string resourceId)
  {
    return repo.findByResource(parseResourceType(resourceType), resourceId);
  }

  Label[] listByKey(string resourceType, string key)
  {
    return repo.findByKey(parseResourceType(resourceType), key);
  }

  CommandResult remove(LabelId id)
  {
    auto lbl = repo.findById(id);
    if (lbl.id.length == 0)
      return CommandResult(false, "", "Label not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  CommandResult removeByResource(string resourceType, string resourceId)
  {
    repo.removeByResource(parseResourceType(resourceType), resourceId);
    return CommandResult(true, "", "");
  }

  private LabeledResourceType parseResourceType(string s)
  {
    switch (s)
    {
    case "globalAccount":
      return LabeledResourceType.globalAccount;
    case "directory":
      return LabeledResourceType.directory;
    case "subaccount":
      return LabeledResourceType.subaccount;
    case "environmentInstance":
      return LabeledResourceType.environmentInstance;
    case "subscription":
      return LabeledResourceType.subscription;
    default:
      return LabeledResourceType.subaccount;
    }
  }

  private long clockSeconds()
  {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / 10_000_000;
  }
}
