# Movie Management

Movie Management is a Salesforce DX project that exposes movie records through an Apex REST resource. A second Salesforce org will consume that API through a planned `MovieConsumer` service and display the records in a Lightning Web Component (LWC).

The project currently contains the provider side of the integration. The consumer and the event-driven notification utility are part of the planned roadmap.

## Current API

`MovieResource` is a global, `with sharing` Apex REST class mapped to `/movies/*`.

### Request

```http
GET /services/apexrest/movies?pageNumber=1
```

`pageNumber` is required and starts at `1`. Each response contains at most `1,000` records. The current query orders records by `CreatedDate DESC, Id DESC`, so the newest movies are returned first.

### Response

```json
{
	"totalItems": 2500,
	"page": 1,
	"perPage": 1000,
	"data": [
		{
			"Name": "Movie 1",
			"Genre": "Action",
			"IMDB_Rating": 8.4
		}
	]
}
```

The API exposes the following fields from `Movie__c`:

| API field | Salesforce field | Description |
| --- | --- | --- |
| `Name` | `Movie__c.Name` | Movie title |
| `Genre` | `Movie__c.Genre__c` | Movie genre |
| `IMDB_Rating` | `Movie__c.IMDB_Rating__c` | IMDb rating |

Invalid or missing page numbers return HTTP `400`. Unexpected server errors return HTTP `500`.

## Planned MovieConsumer

`MovieConsumer` will be developed in the consuming Salesforce org. Its responsibility will be to call the provider org, transform the JSON response into a view model, and provide the data to an LWC.

The intended flow is:

```text
Consumer LWC -> MovieConsumer Apex -> Named Credential / OAuth -> MovieResource
																									 <- JSON page <-
```

### Cross-org connection

The consumer should use a Salesforce **Named Credential** rather than hard-coded URLs or credentials:

1. Create a Connected App in the provider org.
2. Configure OAuth authentication and the required scopes.
3. Create an External Credential and Named Credential in the consumer org.
4. Give the integration principal permission to use the credential.
5. Perform the Apex callout using the Named Credential endpoint, for example:

```apex
HttpRequest request = new HttpRequest();
request.setEndpoint('callout:Movie_Provider/services/apexrest/movies?pageNumber=1');
request.setMethod('GET');
HttpResponse response = new Http().send(request);
```

The consumer should validate the HTTP status, handle an empty page, and surface authentication, timeout, and malformed-response errors to the LWC in a user-friendly way.

## Planned LWC sorting

The LWC will present the movie records in a table or data grid and allow users to order them by genre and IMDb rating.

### Option 1: sort in Apex

Server-side sorting is preferable when the consumer must sort the complete dataset or when the number of records can grow. The provider query could accept a validated sort option and apply a fixed allow-list of fields:

```apex
// Example query shape; validate the requested field and direction first.
List<Movie__c> movies = [
		SELECT Id, Name, Genre__c, IMDB_Rating__c
		FROM Movie__c
		ORDER BY Genre__c ASC, IMDB_Rating__c DESC, Id ASC
		LIMIT :pageSize
		OFFSET :offset
];
```

Dynamic SOQL must never concatenate an unchecked field name or sort direction. A fixed map of allowed values is required. Sorting in the API also keeps pagination correct because ordering happens before the page is selected.

### Option 2: sort in JavaScript

Client-side sorting is simple when the LWC has already loaded the records it needs. The comparator should handle blank genres and ratings consistently:

```js
sortMovies(movies, field, direction = 'asc') {
		const multiplier = direction === 'desc' ? -1 : 1;

		return [...movies].sort((left, right) => {
				const leftValue = left[field] ?? '';
				const rightValue = right[field] ?? '';

				if (leftValue === rightValue) {
						return 0;
				}

				return (leftValue > rightValue ? 1 : -1) * multiplier;
		});
}
```

JavaScript sorting only affects the records currently loaded in the browser. It is therefore appropriate for a small result set or for sorting one page, but it does not provide a globally sorted, paginated result.

## Future Platform Events utility

After the consumer is working, a reusable LWC utility will subscribe to a Platform Event channel so the UI can react when a new movie is created. The planned design is:

```text
Movie creation -> Movie__c trigger/automation -> Movie_Created__e
																									 |
												 utility LWC <- EMP API / lightning/empApi
																									 |
																			refresh MovieConsumer data
```

The utility will use the Lightning `empApi` module to subscribe to the event channel, for example `/event/Movie_Created__e`. It should expose a small event contract to host components, unsubscribe when disconnected, and reconnect or report a meaningful state when the streaming connection is interrupted.

The Platform Event should contain only the data needed by subscribers, such as the movie record ID and an event timestamp. The consumer should still refresh or retrieve the authoritative movie record through the API instead of treating the event payload as the complete source of truth.

## Project structure

- **`force-app/main/default/classes/`** - Apex REST resource and tests
- **`force-app/main/default/objects/Movie__c/`** - Movie object and custom fields
- **`force-app/main/default/lwc/`** - Lightning Web Components, including the planned consumer UI
- **`scripts/apex/`** - Anonymous Apex scripts for development and data seeding
- **`config/`** - Scratch org definitions
- **`manifest/`** - Metadata package manifest

## Prerequisites

Before you start, make sure you have:

- **Salesforce CLI** - Download from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli). See [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for details.
- **VS Code with Salesforce Extension Pack** - See [Installation Instructions](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html) for details. Includes the Agentforce Vibes extension.
- **A development org** - Sign up for a free Developer Edition org [here](https://developer.salesforce.com/signup).
- **Dev Hub enabled** (optional, required to create scratch orgs) - You can enable Dev Hub in your development org under Setup > Dev Hub.  See [Provide Developers Access to Salesforce DX Tools](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_dx_tools.htm).

## Project Structure

Your DX project follows this structure:

- **`force-app/main/default/`** - Your metadata source files live in this default package directory. You can configure additional package directories in the `sfdx-project.json` file.
- **`config/`** - Scratch org definitions and project settings
- **`scripts/`** - Automation scripts for common tasks
- **`sfdx-project.json`** - Project manifest that defines package directories, namespace, API version, and other project-level settings

See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm).

## Get Started

Ready to start developing? The [Get Started with Salesforce DX](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_get_started_dx.htm) guide walks you through your first project, from creating a scratch org to creating a simple Apex class or LWC to deploying your code to a sandbox.

## Common Salesforce CLI Commands

Here are common CLI commands that you'll use the most:

- `sf org login web`: Authorize an org
- `sf org open`: Open your org in a browser
- `sf org create scratch`: Create a scratch org
- `sf project deploy start`: Deploy metadata to your org
- `sf project retrieve start`: Retrieve metadata from your org
- `sf template generate <artifact>`: Scaffold new components, such as Apex classes and triggers, LWC components, Lightning apps, and more
- `sf apex <command>`: Run Apex tests, run anonymous Apex blocks, and view logs
- `sf data <command>`: Work with test data
- `sf alias <command>`: Manage org aliases
- `sf config <command>`: Configure CLI settings

## Use Agentforce Vibes to Build Lightning Apps

Transform your ideas into custom Lightning apps that extend CRM workflows directly in Lightning Experience. Through natural conversations with Agentforce Vibes, implement custom objects and fields, complex business logic, and dynamic UI components. See [Build a Lightning App Using Agentforce Vibes](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/lexapp-overview.html).

## Additional Resources

- [Agentforce Vibes Developer Guide](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/einstein-overview.html)
- [Salesforce CLI Installation Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce CLI Plugin Development Guide](https://developer.salesforce.com/docs/platform/salesforce-cli-plugin/guide/conceptual-overview.html)
- [Salesforce VS Code Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
# Salesforce DX Project

Salesforce DX is a development approach that brings source-driven development, team collaboration, and continuous integration to the Salesforce Platform. Instead of working directly in an org through a web browser, you work with metadata as source files in a local DX project, track changes in version control, and deploy through automated processes.

This project template gets you started with the tools and structure you need to build Salesforce applications using source control, scratch orgs, and the Salesforce CLI.

## Prerequisites

Before you start, make sure you have:

- **Salesforce CLI** - Download from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli). See [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for details.
- **VS Code with Salesforce Extension Pack** - See [Installation Instructions](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html) for details. Includes the Agentforce Vibes extension.
- **A development org** - Sign up for a free Developer Edition org [here](https://developer.salesforce.com/signup).
- **Dev Hub enabled** (optional, required to create scratch orgs) - You can enable Dev Hub in your development org under Setup > Dev Hub.  See [Provide Developers Access to Salesforce DX Tools](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_dx_tools.htm).

## Project Structure

Your DX project follows this structure:

- **`force-app/main/default/`** - Your metadata source files live in this default package directory. You can configure additional package directories in the `sfdx-project.json` file.
- **`config/`** - Scratch org definitions and project settings
- **`scripts/`** - Automation scripts for common tasks
- **`sfdx-project.json`** - Project manifest that defines package directories, namespace, API version, and other project-level settings

See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm).

## Get Started

Ready to start developing? The [Get Started with Salesforce DX](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_get_started_dx.htm) guide walks you through your first project, from creating a scratch org to creating a simple Apex class or LWC to deploying your code to a sandbox.

## Common Salesforce CLI Commands

Here are common CLI commands that you'll use the most:

- `sf org login web`: Authorize an org
- `sf org open`: Open your org in a browser
- `sf org create scratch`: Create a scratch org
- `sf project deploy start`: Deploy metadata to your org
- `sf project retrieve start`: Retrieve metadata from your org
- `sf template generate <artifact>`: Scaffold new components, such as Apex classes and triggers, LWC components, Lightning apps, and more
- `sf apex <command>`: Run Apex tests, run anonymous Apex blocks, and view logs
- `sf data <command>`: Work with test data
- `sf alias <command>`: Manage org aliases
- `sf config <command>`: Configure CLI settings

## Use Agentforce Vibes to Build Lightning Apps

Transform your ideas into custom Lightning apps that extend CRM workflows directly in Lightning Experience. Through natural conversations with Agentforce Vibes, implement custom objects and fields, complex business logic, and dynamic UI components. See [Build a Lightning App Using Agentforce Vibes](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/lexapp-overview.html).

## Additional Resources

- [Agentforce Vibes Developer Guide](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/einstein-overview.html)
- [Salesforce CLI Installation Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce CLI Plugin Development Guide](https://developer.salesforce.com/docs/platform/salesforce-cli-plugin/guide/conceptual-overview.html)
- [Salesforce VS Code Extensions Documentation](https://developer.salesforce.com/tools/vscode/)

