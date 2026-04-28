/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.cards;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.card;
import uim.platform.workzone.domain.ports.repositories.cards;
import uim.platform.workzone.application.dto;

class ManageCardsUseCase { // TODO: UIMUseCase {
  private CardRepository repo;

  this(CardRepository repo) {
    this.repo = repo;
  }

  CommandResult createCard(CreateCardRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Card title is required");

    auto now = Clock.currStdTime();
    auto c = Card();
    c.id = randomUUID();
    c.tenantId = req.tenantId;
    c.title = req.title;
    c.subtitle = req.subtitle;
    c.description = req.description;
    c.icon = req.icon;
    c.cardType = req.cardType;
    c.dataSource = req.dataSource;
    c.manifest = req.manifest;
    c.createdAt = now;
    c.updatedAt = now;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  Card* getCard(TenantId tenantId, CardId id) {
    return repo.findById(tenantId, id);
  }

  Card[] listCards(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Card[] listByType(TenantId tenantId, CardType cardType) {
    return repo.findByType(tenantId, cardType);
  }

  CommandResult updateCard(UpdateCardRequest req) {
    auto c = repo.findById(req.tenantId, req.id);
    if (c is null)
      return CommandResult(false, "", "Card not found");

    if (req.title.length > 0)
      c.title = req.title;
    if (req.subtitle.length > 0)
      c.subtitle = req.subtitle;
    if (req.description.length > 0)
      c.description = req.description;
    if (req.icon.length > 0)
      c.icon = req.icon;
    c.active = req.active;
    c.dataSource = req.dataSource;
    c.manifest = req.manifest;
    c.updatedAt = Clock.currStdTime();

    repo.update(*c);
    return CommandResult(true, c.id, "");
  }

  void deleteCard(TenantId tenantId, CardId id) {
    repo.removeById(tenantId, id);
  }
}
