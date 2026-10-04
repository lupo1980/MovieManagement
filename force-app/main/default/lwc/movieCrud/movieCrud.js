import { LightningElement, wire } from "lwc";
import { gql, graphql } from "lightning/graphql";
import { deleteRecord } from "lightning/uiRecordApi";
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MOVIE_OBJECT from "@salesforce/schema/Movie__c";
import NAME_FIELD from "@salesforce/schema/Movie__c.Name";
import GENRE_FIELD from "@salesforce/schema/Movie__c.Genre__c";
import IMDB_RATING_FIELD from "@salesforce/schema/Movie__c.IMDB_Rating__c";
import getMovieImages from "@salesforce/apex/MovieFilesController.getMovieImages";
import { refreshApex } from "@salesforce/apex";
const PAGE_SIZE = 25;
const MOVIE_QUERY = gql`
  query MovieList($first: Int!, $after: String, $searchTerm: String!) {
    uiapi {
      query {
        Movie__c(
          first: $first
          after: $after
          where: { Name: { like: $searchTerm } }
          orderBy: { Name: { order: ASC } }
        ) {
          edges {
            cursor
            node {
              Id
              Name {
                value
              }
              Genre__c {
                value
              }
              IMDB_Rating__c {
                value
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    }
  }
`;
/*
//a second graphql is not working, so I will use apex to get the files and reviews
const FILES_QUERY = gql`
  query MovieFiles($movieId: ID!) {
    uiapi {
      query {
        ContentDocumentLink(
          where: { LinkedEntityId: { eq: $movieId } }
          orderBy: { ContentDocument: { Title: { order: ASC } } }
        ) {
          edges {
            node {
              ContentDocument {
                Id
                Title
                FileType
                LatestPublishedVersion {
                  Id
                  VersionDataUrl
                  FileExtension
                }
              }
            }
          }
        }
      }
    }
  }
`;

const REVIEWS_QUERY = gql`
  query MovieReviews($movieId: ID!) {
    uiapi {
      query {
        Movie_Review__c(
          where: { Movie__c: { eq: $movieId } }
        ) {
          edges {
            node {
                Id
                Name
                Nickname__c
                Status__c
                Score__c
                Review_Text__c
              }
            }
          }
        }
      }
    }
`;
*/
const ROW_ACTIONS = [
  { label: "View", name: "view" },
  { label: "Edit", name: "edit" },
  { label: "Delete", name: "delete" }
];

const COLUMNS = [
  { label: "Movie", fieldName: "Name", type: "text" },
  { label: "Genre", fieldName: "Genre__c", type: "text" },
  {
    label: "IMDB Rating",
    fieldName: "IMDB_Rating__c",
    type: "number",
    typeAttributes: { minimumFractionDigits: 1, maximumFractionDigits: 1 }
  },
  { type: "action", typeAttributes: { rowActions: ROW_ACTIONS } }
];

export default class MovieCrud extends LightningElement {
  movieObjectApiName = MOVIE_OBJECT;
  nameField = NAME_FIELD;
  genreField = GENRE_FIELD;
  imdbRatingField = IMDB_RATING_FIELD;
  columns = COLUMNS;
  movies = [];
  searchTerm = "";
  committedSearchTerm = "";
  afterCursor = null;
  endCursor = null;
  hasNextPage = false;
  isLoading = true;
  errorMessage;
  formMode = "list";
  selectedMovieId;
  refreshGraphQL;
  files = [];
  filesWired;
  //refreshFiles;
  //reviews = [];
  //refreshReviews;

  connectedCallback() {
    this.isLoading = true;
  }

  @wire(graphql, { query: MOVIE_QUERY, variables: "$variables" })
  wiredMovies({ data, errors, refresh }) {
    this.refreshGraphQL = refresh;

    if (data) {
      const connection = data.uiapi.query.Movie__c;
      const page = connection.edges.map(({ node }) => ({
        Id: node.Id,
        Name: node.Name?.value,
        Genre__c: node.Genre__c?.value,
        IMDB_Rating__c: node.IMDB_Rating__c?.value
      }));

      this.movies = this.afterCursor ? [...this.movies, ...page] : page;
      this.endCursor = connection.pageInfo.endCursor;
      this.hasNextPage = connection.pageInfo.hasNextPage;
      this.errorMessage = undefined;
      this.isLoading = false;
    } else if (errors?.length) {
      console.log("GraphQL errors:", errors);
      this.errorMessage = errors.map((error) => error.message).join("; ");
      this.isLoading = false;
    }
  }

  get variables() {
    const search = this.committedSearchTerm;
    return {
      first: PAGE_SIZE,
      after: this.afterCursor,
      searchTerm: search ? `%${search}%` : "%"
    };
  }

  /*
  @wire(graphql, { query: FILES_QUERY, variables: "$fileVariables" })
  wiredFiles({ data, errors, refresh }) {

    this.refreshFiles = refresh;

    if (data) {
      const connection = data.uiapi.query.ContentDocumentLink;
      const files = connection.edges.map(({ node }) => {
        const doc = node.ContentDocument;
        const version = doc.LatestPublishedVersion;

        return {
          Id: doc.Id,
          Title: doc.Title,
          FileType: doc.FileType,
          ContentUrl: version?.ContentUrl
        };
      });

      this.files = files;
    } else if (errors?.length) {
      console.log("GraphQL errors:", errors);
      this.errorMessage = errors.map((error) => error.message).join("; ");
    }
  }

  get fileVariables() {
    console.log("Selected movie ID:", this.selectedMovieId);
    return {
      movieId: this.selectedMovieId
    };
  }

  @wire(graphql, {query: REVIEWS_QUERY, variables: "$reviewVariables"})
  wiredReviews({data, errors, refresh}) {
    this.refreshReviews = refresh;

    if(data){
      const connection = data.uiapi.query.Movie_Review__c;
      const reviews = connection.edges.map( (node) => {
        return {
          Id: node.Id,
          Name: node.Name,
          Nickname__c: node.Nickname__c,
          Status__c: node.Status__c,
          Score__c: node.Score__c,
          Review_Text__c: node.Review_Text__c,
        };
      });
      this.reviews = reviews;
    } else if(errors?.length){
      console.log("GraphQL errors:", errors);
      this.errorMessage = errors.map( (error) => error.message.join("; ") );
    }
  }

  get reviewVariables() {
    return {
      movieId: this.selectedMovieId
    };
  }
*/

  @wire(getMovieImages, { movieId: "$selectedMovieId" })
  wiredFiles(value) {
    this.filesWired = value;
    const { data, error } = value;
    if (data) {
      this.files = data; //[...this.files, data];
      console.log("Fetched files:", this.files);
      this.errorMessage = undefined;
    } else if (error) {
      console.log("Apex getMovieImages errors:", error);
      this.errorMessage = error.body.message || "Unable to fetch files.";
    }
  }

  get isListView() {
    return this.formMode === "list";
  }

  get isCreateOrEdit() {
    return this.formMode === "create" || this.formMode === "edit";
  }

  get isViewMode() {
    return this.formMode === "view";
  }

  get isEditMode() {
    return this.formMode === "edit";
  }

  get hasMovies() {
    return this.movies.length > 0;
  }

  get showEmptyState() {
    return !this.isLoading && !this.errorMessage && !this.hasMovies;
  }

  get formTitle() {
    return this.formMode === "create" ? "New movie" : "Edit movie";
  }

  get acceptedFormats() {
    return [".jpg", ".png"];
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    console.log("No. of files uploaded : " + uploadedFiles.length);
    // if (this.refreshFiles) {
    //   this.refreshFiles();
    // }
    this.handleRefreshFiles();
    for (let i = 0; i < uploadedFiles.length; i++) {
      console.log("File name: " + uploadedFiles[i].name);
      console.log("File documentId: " + uploadedFiles[i].documentId);
    }
  }

  handleRefreshFiles() {
    console.log("Refreshing files for movie ID:", this.selectedMovieId);
    refreshApex(this.filesWired);
  }

  handleSearchChange(event) {
    this.searchTerm = event.detail.value;
    this.committedSearchTerm = this.searchTerm.trim();
    this.afterCursor = null;
    this.endCursor = null;
    this.hasNextPage = false;
    this.movies = [];
    this.errorMessage = undefined;
    this.isLoading = true;
  }

  handleNew() {
    this.selectedMovieId = undefined;
    this.errorMessage = undefined;
    this.formMode = "create";
  }

  handleEditSelected() {
    this.formMode = "edit";
  }

  handleDeleteSelected() {
    const movie = this.movies.find(({ Id }) => Id === this.selectedMovieId);
    if (movie) {
      this.handleDelete(movie);
    }
  }

  handleRowAction(event) {
    const { action, row } = event.detail;
    this.selectedMovieId = row.Id;
    this.errorMessage = undefined;

    if (action.name === "view") {
      this.formMode = "view";
    } else if (action.name === "edit") {
      this.formMode = "edit";
    } else if (action.name === "delete") {
      this.handleDelete(row);
    }
  }

  async handleDelete(movie) {
    try {
      const confirmed = await LightningConfirm.open({
        message: `Delete ${movie.Name}? This action cannot be undone.`,
        label: "Delete movie",
        variant: "header"
      });

      if (!confirmed) {
        return;
      }

      await deleteRecord(movie.Id);
      this.showToast("Movie deleted", `${movie.Name} was deleted.`, "success");
      this.afterCursor = null;
      this.endCursor = null;
      this.hasNextPage = false;
      this.movies = [];
      this.isLoading = true;
      await this.refreshMovies();
      this.formMode = "list";
      this.selectedMovieId = undefined;
    } catch (error) {
      this.handleError(error);
    }
  }

  handleFormSubmit(event) {
    const ratingValue = event.detail.fields.IMDB_Rating__c;
    const rating = Number(ratingValue);
    if (
      ratingValue === undefined ||
      ratingValue === "" ||
      !Number.isFinite(rating) ||
      rating < 0 ||
      rating > 10
    ) {
      event.preventDefault();
      this.errorMessage = "IMDB Rating must be between 0 and 10.";
      return;
    }

    this.errorMessage = undefined;
  }

  async handleSaveSuccess() {
    const wasCreating = this.formMode === "create";
    this.errorMessage = undefined;
    this.showToast(
      "Movie saved",
      wasCreating ? "The movie was created." : "The movie was updated.",
      "success"
    );
    this.formMode = "list";
    this.selectedMovieId = undefined;

    if (wasCreating) {
      this.searchTerm = "";
      this.committedSearchTerm = "";
      this.afterCursor = null;
      this.endCursor = null;
      this.hasNextPage = false;
      this.movies = [];
    }

    this.isLoading = true;
    try {
      await this.refreshMovies();
    } catch (error) {
      this.handleError(error);
    }
  }

  handleFormError(event) {
    this.handleError(event.detail);
  }

  handleBackToList() {
    this.formMode = "list";
    this.selectedMovieId = undefined;
    this.errorMessage = undefined;
  }

  handleLoadMore() {
    if (!this.isLoading && this.hasNextPage && this.endCursor) {
      this.afterCursor = this.endCursor;
      this.isLoading = true;
    }
  }

  async refreshMovies() {
    if (this.refreshGraphQL) {
      await this.refreshGraphQL();
    }
  }

  handleError(error) {
    this.errorMessage =
      error?.body?.message || error?.message || "Unable to save the movie.";
    this.showToast("Error", this.errorMessage, "error");
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
