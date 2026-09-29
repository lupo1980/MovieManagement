import { LightningElement } from "lwc";

import { api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { label } from "c/labelUtility";
export default class ModalUserReview extends LightningElement {
  @api movieName;
  @api nickname;
  reviewText;
  score;

  error;

  @track myLabel = label;

  errorCallback(error, stack) {
    console.error("Error in modalUserReview component:", error, stack);
    this.error = error;
  }

  handleChangeReviewText(event) {
    this.reviewText = event.target.value;
  }

  handleChangeScore(event) {
    this.score = event.target.value;
  }

  async handleSubmitReview() {
    try {
      console.log(
        `Submitting review to parent component. Movie: ${this.movieName} and user: ${this.nickname} 
        and Review text: ${this.reviewText} and Score: ${this.score}`
      );

      const eventSubmit = new CustomEvent("submitreview", {
        detail: { reviewText: this.reviewText, score: this.score }
      });

      this.dispatchEvent(eventSubmit);
    } catch (error) {
      console.error("Error submitting review:", error);
      const evt = new ShowToastEvent({
        title: "Error",
        message: `Failed to submit review: ${error.body?.message || error.message}`,
        variant: "error"
      });
      this.dispatchEvent(evt);
    }
  }
}
