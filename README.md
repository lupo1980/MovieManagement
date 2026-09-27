# Movie Management

A Salesforce DX sample app for browsing movies, submitting reviews, and demonstrating Lightning Web Component patterns with Apex-backed data access.

## Short summary

This project combines:

- A movie search experience in LWC
- Apex classes for data access and review submission
- A review workflow that includes modal-based user interactions
- A small React example embedded inside an LWC for demonstration purposes

## Lightning Modal example

The app includes a concrete example of a Salesforce Lightning Modal for reviewing movies. The modal UI is implemented in:

- `force-app/main/default/lwc/modalUserReviewList/modalUserReviewList.js`
- `force-app/main/default/lwc/modalUserReviewList/modalUserReviewList.html`

It demonstrates how to:

- load reviews for a selected movie
- edit an existing review inline
- validate review text and score
- save and delete reviews
- display success and error notifications using `ShowToastEvent`

This makes it a practical reference for building modal-driven UX patterns in Salesforce LWC.

## Main components

- `movieReviewUser` — search for movies and launch the review flow
- `modalUserReview` — submit a new review
- `modalUserReviewList` — review list with edit and delete actions
- `movieBrowser` — embedded React example inside an LWC
- Apex classes — data access and server-side validation

## Project structure

- `force-app/main/default/classes/` — Apex logic
- `force-app/main/default/lwc/` — Lightning components
- `react-app/` — React source example
- `scripts/apex/` — helper Apex scripts
- `config/` — scratch org metadata
- `manifest/` — deployment manifest

## Build and test

```bash
cd react-app
npm install
npm run build
```

From the repo root:

```bash
npm install
npm test
npm run lint
```

## Notes

This repository is intended as a lightweight Salesforce example app for LWC patterns, Apex service logic, and an embedded React/Lightning integration workflow.
