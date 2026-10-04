import { createElement } from "@lwc/engine-dom";
import MovieCrud from "c/movieCrud";

describe("c-movie-crud", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders the movie search and table", () => {
    const element = createElement("c-movie-crud", { is: MovieCrud });
    document.body.appendChild(element);

    expect(element.shadowRoot.querySelector("lightning-input")).not.toBeNull();
    expect(element.shadowRoot.querySelector("lightning-datatable")).toBeNull();
    expect(
      element.shadowRoot.querySelector("lightning-spinner")
    ).not.toBeNull();
  });

  it("opens the standard record form when New movie is selected", async () => {
    const element = createElement("c-movie-crud", { is: MovieCrud });
    document.body.appendChild(element);

    element.shadowRoot.querySelector("lightning-button").click();
    await Promise.resolve();

    expect(
      element.shadowRoot.querySelector("lightning-record-edit-form")
    ).not.toBeNull();
    expect(
      element.shadowRoot.querySelector("lightning-input-field")
    ).not.toBeNull();
  });

  it("rejects an IMDB rating above 10", async () => {
    const element = createElement("c-movie-crud", { is: MovieCrud });
    document.body.appendChild(element);

    element.shadowRoot.querySelector("lightning-button").click();
    await Promise.resolve();

    const form = element.shadowRoot.querySelector("lightning-record-edit-form");
    const submitEvent = new CustomEvent("submit", {
      detail: { fields: { IMDB_Rating__c: "10.1" } },
      bubbles: true,
      composed: true,
      cancelable: true
    });
    form.dispatchEvent(submitEvent);

    expect(submitEvent.defaultPrevented).toBe(true);
    await Promise.resolve();
    expect(
      element.shadowRoot.querySelector('[role="alert"]').textContent
    ).toContain("between 0 and 10");
  });
});
