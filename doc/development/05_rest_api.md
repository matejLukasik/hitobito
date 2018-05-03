# REST API

The JSON format follows the conventions of [json:api](http://jsonapi.org) (although in an older version according to this issue https://github.com/hitobito/hitobito/issues/207)

## Authentication

* To use the API you need an authentication-token.
* Every user account can create such a token.
* There are no tokens independent of a user account.
* The token has the same permissions as the corresponding user.
* Tokens have no expiration date.

##### These are the user authentication HTTP endpoints:

| Method  | Path                | Function |
| --- | --- | --- |
| POST    | /users/sign_in.json | Read/generate token. |
| POST    | /users/token.json   | Generate a new token. |
| DELETE  | /users/token.json   | Delete token. |

You have to pass `person[email]` and `person[password]` as parameters.
```bash
curl -d "person[email]=mitglied@hitobito.ch" \
     -d "person[password]=demo" \
     http://demo.hitobito.ch/users/sign_in.json
```
##### Response:
```js
    {
      people: [ {
        id: 446,
        href: http://demo.hitobito.ch/groups/1/people/446.json,
        first_name: "Pascal",
        last_name: "Zumkehr",
        nickname: null,
        company_name: null,
        company: false,
        gender: null,
        email: "zumkehr@puzzle.ch",
        authentication_token: "9DDNdpV4hwM76f3J6oNV",
        last_sign_in_at: "2014-07-08T15:40:01.154+02:00",
        current_sign_in_at: "2014-07-08T16:28:02.577+02:00",
        links: {
          primary_group: "1"
        }
      } ]
      linked: {
        groups: [ {
          id: "1",
          name: "CEVI Schweiz",
          group_type: "Dachverband"
        } ]
      }
      links: {
          token.regenerate: {
            href: http://demo.hitobito.ch/users/token.json,
            method: "POST"
          }
          token.delete: {
            href: http://demo.hitobito.ch/users/token.json,
            method: "DELETE"
          }
        }
      } ]
    }
```
To authenticate yourself to use all the other API endpoints you can either:
* **Use parameters**: You provide `user_email` and `user_token` as paramateres in the path, the path has to end with `.json`. Example: `/groups/1.json?user_email=zumkehr@puzzle.ch&user_token=abcdef`.
* **Use headers**: Set the header like this: `X-User-Email`, `X-User-Token` and `Accept` (`application/json`)

## Endpoints

### Groups
| Method | Path                         | Function |
| --- | --- | --- |
| GET     | /groups                      | Root group           |
| GET     | /groups/:id                  | Group Details        |
| GET     | /groups/:id/people           | People of a certain group |
| GET     | /groups/:group_id/people/:id | Person details      |

### Roles
| Method | Path                         | Description |
| --- | --- | --- |
| POST     | /:locale/groups/:id/roles.json                      | Create a new person in the group with `:id` and role provided in the body of the request.|

For this request, you need to know the `id` of the group you want to create the Person in and also the role you want to give him. See *Groups* endpoints for information on how to get available groups and roles.
Use the locale parameter to get validation responses in desired language.


##### Example

```bash
curl --request POST \
  --url http://localhost:3000/en/groups/1/roles.json \
  --header 'accept: application/json' \
  --header 'content-type: application/json' \
  --header 'x-user-email: mat@zeilenwerk.ch' \
  --header 'x-user-token: 5_LpiWSwCVrvt8mxoUzQ' \
  --cookie 'locale=en; _session_id=da14eacd8545853f6e498acebcd15b7f' \
  --data '{
	"role": {
		"new_person": {
			"email": "testw22@xample.com",
			"first_name": "a",
			"last_name": "b",
			"additional_email_attributes": [
				{
					"name": "privat",
					"translated_label": "msn",
					"mailings": "0",
					"public": "1"
				}
			]
		},
		"type": "Group::Root::Administrator"
	}
}'
`
