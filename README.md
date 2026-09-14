# Movie Management

This project is a Salesforce DX movie-management app with Lightning Web Components, Apex data access, user movie reviews, and an embedded React example.

The main user-facing flow lets users search for movies, select a movie, and submit a review with a score from 0 to 5. The project also includes a separate React-in-LWC integration example backed by paged movie data.

## Current implementation

### Movie review components

The `movieReviewUser` LWC in `force-app/main/default/lwc/movieReviewUser/` provides the movie search and review entry point. It:

- searches movies by title after the user enters more than two characters
- displays each matching movie with its genre and IMDb rating
- opens the `modalUserReview` Lightning modal when a movie is selected
- passes the selected movie and the current Salesforce user's name to the modal
- displays a success toast after a review is submitted

The `modalUserReview` LWC collects the review text and score. It calls `MovieReviewUser.submitReview` and displays an error toast when submission fails.

### React example host component

The `movieBrowser` LWC in `force-app/main/default/lwc/movieBrowser/` demonstrates an embedded React application. It is responsible for:

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

## Apex review and movie services

`MovieReviewUser` provides the Apex methods used by the review flow:

- `getMovies(movieTitle)` searches `Movie__c` records by name and returns genre and IMDb rating data.
- `submitReview(movieId, reviewText, nickname, score)` validates the review, inserts a `Movie_Review__c` record, and returns its ID.

Review submission rejects blank review text, a missing movie ID, and scores outside the inclusive range of 0 to 5.

`MovieReviewUser` is declared `with sharing`, so the service respects the running user's sharing rules.

`MovieResource` exposes the paged movie data through the Apex REST endpoint:

```http
GET /services/apexrest/movies?pageNumber=1
```

## React example inside LWC

The React source is in `react-app/src/main.jsx`.

It renders a sample paged movie browser with:

- title, genre, and IMDb rating columns
- previous and next page controls
- a simple filter/search state
- sort-by and sort-direction controls

This remains an example of React being hosted inside an LWC. The production movie search and review workflow is implemented separately in the `movieReviewUser` and `modalUserReview` LWCs.

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

Run the LWC unit tests and lint checks from the repository root:

```bash
npm install
npm test
npm run lint
```

For test coverage:

```bash
npm run test:unit:coverage
```

## Project structure

- `force-app/main/default/classes/` - Apex classes and REST/data access logic
- `force-app/main/default/lwc/movieBrowser/` - LWC wrapper and mount point
- `force-app/main/default/lwc/movieReviewUser/` - movie title search and review entry point
- `force-app/main/default/lwc/modalUserReview/` - review submission modal
- `force-app/main/default/staticresources/` - compiled React bundle used by the LWC
- `react-app/src/` - React source that demonstrates the embedded UI
- `scripts/apex/` - helper Apex scripts and data setup utilities
- `config/` - scratch org config
- `manifest/` - metadata manifest

## Notes

The current architecture is:

- Salesforce Apex provides paged movie data
- `movieReviewUser` provides title search and opens the review modal
- `modalUserReview` submits validated reviews through Apex
- the `movieBrowser` LWC loads a React bundle as a static resource
- the React UI is an embedded example inside the LWC host
