jest.mock(
  "lightning/modal",
  () => {
    const { LightningElement } = require("lwc");

    class LightningModal extends LightningElement {
      static open() {
        return Promise.resolve();
      }

      close() {
        return undefined;
      }
    }

    return {
      __esModule: true,
      default: LightningModal
    };
  },
  { virtual: true }
);

import { createElement } from "@lwc/engine-dom";
import ModalUserReviewList from "c/modalUserReviewList";

describe("c-modal-user-review-list", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders without crashing", () => {
    const element = createElement("c-modal-user-review-list", {
      is: ModalUserReviewList
    });

    document.body.appendChild(element);

    expect(element).not.toBeNull();
  });
});
