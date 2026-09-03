import { createElement } from "lwc";
import MovieBrowser from "c/movieBrowser";
import getMovies from "@salesforce/apex/MovieConsumer.getMovies";
import { loadScript } from "lightning/platformResourceLoader";

jest.mock(
  "@salesforce/apex/MovieConsumer.getMovies",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock(
  "lightning/platformResourceLoader",
  () => ({
    loadScript: jest.fn()
  }),
  { virtual: true }
);

describe("c-movie-browser", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("loads a page and mounts the React integration", async () => {
    loadScript.mockResolvedValue();
    getMovies.mockResolvedValue({
      totalItems: 1,
      page: 1,
      perPage: 1000,
      data: [{ Name: "Arrival", Genre: "Sci-Fi", IMDB_Rating: 8.0 }]
    });
    window.MovieReact = {
      mount: jest.fn(() => ({
        update: jest.fn(),
        unmount: jest.fn()
      }))
    };

    const element = createElement("c-movie-browser", { is: MovieBrowser });
    document.body.appendChild(element);
    await Promise.resolve();
    await Promise.resolve();

    expect(loadScript).toHaveBeenCalled();
    expect(getMovies).toHaveBeenCalledWith({ pageNumber: 1 });
    expect(window.MovieReact.mount).toHaveBeenCalled();
  });
});
