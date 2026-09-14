import { LightningElement } from "lwc";
import getMovies from "@salesforce/apex/MovieConsumer.getMovies";
import { loadScript } from "lightning/platformResourceLoader";
import reactBundle from "@salesforce/resourceUrl/movieReactBundle";
/**
 * Example of a Lightning Web Component that loads a React application from a static resource and displays it in the component.
 * The React application is expected to expose a global object `MovieReact` with a `mount` method that takes a DOM element and a page of movies.
 * The component handles loading the React bundle, fetching movie data from an Apex controller, and passing it to the React app.
 * It also handles errors and displays an error message if the React app cannot be loaded or if there is an issue fetching movie data.
 */
export default class MovieBrowser extends LightningElement {
  isLoading = true;
  errorMessage;
  currentPage = 1;
  reactApp;

  renderedCallback() {
    if (this.reactApp || this.resourceLoad) {
      return;
    }

    this.resourceLoad = loadScript(this, reactBundle)
      .then(() => this.loadPage(this.currentPage))
      .catch((error) => {
        console.log("Error loading React bundle:", error);
        this.isLoading = false;
        this.errorMessage = "The movie interface could not be loaded.";
      });
  }

  disconnectedCallback() {
    if (this.reactApp && typeof this.reactApp.unmount === "function") {
      this.reactApp.unmount();
    }
    this.reactApp = undefined;
    this.resourceLoad = undefined;
  }

  loadPage(pageNumber) {
    this.isLoading = true;
    this.errorMessage = undefined;

    return getMovies({ pageNumber })
      .then((page) => {
        const mountPoint = this.template.querySelector(".react-mount");
        if (
          !window.MovieReact ||
          typeof window.MovieReact.mount !== "function"
        ) {
          throw new Error("React bundle did not expose MovieReact.mount.");
        }

        if (this.reactApp) {
          this.reactApp.update(page);
        } else {
          this.reactApp = window.MovieReact.mount(mountPoint, page, {
            onPageChange: (nextPage) => this.loadPage(nextPage)
          });
        }
        this.currentPage = page.page;
      })
      .catch((error) => {
        this.errorMessage =
          error?.body?.message || error.message || "Unable to load movies.";
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
}
