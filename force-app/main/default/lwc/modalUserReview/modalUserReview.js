import LightningModal from "lightning/modal";
import submitReview from "@salesforce/apex/MovieReviewUser.submitReview";
import { api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { label } from "c/labelUtility";
export default class ModalUserReview extends LightningModal {
  @api movieSelected;
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
        `Submitting review for movie: ${this.movieSelected.name} and user: ${this.nickname}`
      );
      console.log(`Review text: ${this.reviewText}`);
      console.log(`Score: ${this.score}`);
      // Call the Apex method to submit the review
      let reviewId = await submitReview({
        movieId: this.movieSelected.id,
        reviewText: this.reviewText,
        nickname: this.nickname,
        score: this.score
      });
      if (reviewId) {
        this.close(reviewId);
      }
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
