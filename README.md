- Clone the codebase to your local machine.
- Run `make build`
- Run `make up`
- Run `docker-compose run web rake db:create`
- Run `docker-compose run web rake db:migrate`
- You should be able to access the application at `http://localhost:3000`
- Use [Postman](https://https://www.postman.com/) or [Advanced Rest Client](https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo?hl=en-US) to interact with the application.


# New Resource: Tag
- Create a new tag
```
POST /tags
{
  name: "new tag name"
}
```
- Retrieve tags
```
GET /tags
GET /tags?filter=tagKeyWord # Returns tags containing the filter keywords
```
- Update tags
```
PUT /tags/:tag_id
{
  name: "updated tag name"
}
```
- Delete tags
```
DELETE /tags/:tag_id
```
- Retrieve articles by tag IDs
```
GET /tags/:tag_id/articles
```
---
- Attach a tag to an article
```
POST /articles/:article_id/tags
{
  tag_id: "6"
}
```
- Detach a tag from an article
```
DELETE /articles/:article_id/tags/:tag_id
```
- Retrieve all tags attached to an article
```
GET /articles/:article_id/tags
```