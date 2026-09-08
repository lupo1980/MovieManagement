# Movie Management

This project is a Salesforce DX app that demonstrates an embedded React example hosted inside a Lightning Web Component.

The current code is intentionally an example of React running inside LWC, not a completed sort/filter feature. The actual implementation in this repo is the LWC + React integration pattern, and the sorting/filtering work is planned as a separate React component to be built later.

## Current implementation

### LWC host component

The `movieBrowser` LWC in `force-app/main/default/lwc/movieBrowser/` is responsible for:

- loading the React bundle via `lightning/platformResourceLoader`
- calling `MovieConsumer.getMovies({ pageNumber })`
- mounting the React app into a manual DOM container
- updating the React view when the user changes pages

Runtime flow:

```text
movieBrowser LWC
  -> load React bundle from static resource
  -> call Apex getMovies(pageNumber)
  -> mount the table into the DOM
  -> render the current page of movies
```

### Apex data access

`MovieConsumer` is the data entry point used by the LWC. It validates the page number and reads records using `MovieDataManager`.

The current page response contains:

- `totalItems`
- `page`
- `perPage`
- `data`

Each movie item includes:

- `Name`
- `Genre`
- `IMDB_Rating`

The project also contains `MovieResource`, which exposes the same movie data through the Apex REST endpoint:

```http
GET /services/apexrest/movies?pageNumber=1
```

## React example inside LWC

The React source is in `react-app/src/main.jsx`.

It renders a sample movie browser with:

- title, genre, and IMDb rating columns
- previous and next page controls
- a simple filter/search state
- sort-by and sort-direction controls

This is an example of React being hosted inside an LWC. It is not yet a final or isolated feature component for production sorting/filtering logic. The code is meant to show the integration pattern and the UI shell, while keeping the actual sort/filter implementation for a separate React component in the next step.

## Build and deploy

From the repo root:

```bash
cd react-app
npm install
npm run build
```

This generates the bundle used by the LWC from the Salesforce static resource path:

```text
force-app/main/default/staticresources/movieReactBundle.resource
```

Deploy the generated resource alongside the related Apex and LWC metadata.

## Project structure

- `force-app/main/default/classes/` - Apex classes and REST/data access logic
- `force-app/main/default/lwc/movieBrowser/` - LWC wrapper and mount point
- `force-app/main/default/staticresources/` - compiled React bundle used by the LWC
- `react-app/src/` - React source that demonstrates the embedded UI
- `scripts/apex/` - helper Apex scripts and data setup utilities
- `config/` - scratch org config
- `manifest/` - metadata manifest

## Planned next step

The next logical enhancement is to extract the sorting and genre-filter behavior into a separate React component, for example:

- a dedicated sort controls component
- a dedicated genre filter component
- a parent component that combines the selected state with the current page data

This should be built in a separate React component rather than being mixed into the current embedded example. The current implementation remains an example of React inside LWC and should not be treated as the finished feature architecture for sorting or filtering.

## Notes

This repo already reflects the actual architecture in use today:

- Salesforce Apex provides paged movie data
- the LWC loads a React bundle as a static resource
- the React UI is an embedded example inside the LWC host

The sorting and filter-by-genre feature is a future follow-up task, not part of the current implementation.
