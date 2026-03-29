module application.use_cases.manage_cards;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.card;
import domain.ports.card_repository;
import application.dto;

class ManageCardsUseCase
{
    private CardRepository repo;

    this(CardRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createCard(CreateCardRequest req)
    {
        if (req.title.length == 0)
            return CommandResult("", "Card title is required");

        auto now = Clock.currStdTime();
        auto c = Card();
        c.id = randomUUID().toString();
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
        return CommandResult(c.id, "");
    }

    Card* getCard(CardId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    Card[] listCards(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    Card[] listByType(CardType cardType, TenantId tenantId)
    {
        return repo.findByType(cardType, tenantId);
    }

    CommandResult updateCard(UpdateCardRequest req)
    {
        auto c = repo.findById(req.id, req.tenantId);
        if (c is null)
            return CommandResult("", "Card not found");

        if (req.title.length > 0) c.title = req.title;
        if (req.subtitle.length > 0) c.subtitle = req.subtitle;
        if (req.description.length > 0) c.description = req.description;
        if (req.icon.length > 0) c.icon = req.icon;
        c.active = req.active;
        c.dataSource = req.dataSource;
        c.manifest = req.manifest;
        c.updatedAt = Clock.currStdTime();

        repo.update(*c);
        return CommandResult(c.id, "");
    }

    void deleteCard(CardId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
