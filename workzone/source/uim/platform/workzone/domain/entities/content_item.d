module uim.platform.xyz.domain.entities.content_item;

import domain.types;

/// A content item within a workspace — blog, wiki, KB article, forum post, etc.
struct ContentItem
{
    ContentId id;
    WorkspaceId workspaceId;
    TenantId tenantId;
    string title;
    string body_;            // rich text / markdown body
    string summary;
    ContentType contentType = ContentType.blogPost;
    ContentStatus status = ContentStatus.draft;
    UserId authorId;
    string authorName;
    string[] tags;
    string[] attachmentUrls;
    string language;
    int viewCount;
    int likeCount;
    bool pinned;
    bool commentsEnabled = true;
    long publishedAt;
    long createdAt;
    long updatedAt;
}
