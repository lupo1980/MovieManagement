import LightningModal from "lightning/modal";
import { api, wire } from "lwc";
import getReviews from "@salesforce/apex/MovieReviewCrud.getReviews";
import submitReview from "@salesforce/apex/MovieReviewCrud.submitReview";
import updateReview from "@salesforce/apex/MovieReviewCrud.updateReview";
import deleteReview from "@salesforce/apex/MovieReviewCrud.deleteReview";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

export default class ModalUserReviewList extends LightningModal {
  @api movieId;
  @api movieName;
  @api nickname;
  reviews = [];
  error;
  editingReviewId;
  draftReviewText = "";
  draftScore;
  wiredReviews;
  showFormNewReview = false;

  @wire(getReviews, { movieId: "$movieId" })
  wiredReviewList(result) {
    this.wiredReviews = result;
    if (result.data) {
      this.reviews = result.data;
      this.error = undefined;
    } else if (result.error) {
      this.handleError(result.error);
    }
  }

  get hasReviews() {
    return this.reviews.length > 0;
  }

  get reviewCards() {
    return this.reviews.map((review) => ({
      ...review,
      isEditing: review.Id === this.editingReviewId,
      isNotEditing: review.Id !== this.editingReviewId
    }));
  }

  get hasError() {
    return Boolean(this.error);
  }

  openFormNewReview() {
    this.showFormNewReview = true;
  }

  async handleSubmitReview(event) {
    try {
      console.log(
        `Submitting review for movie: ${this.movieName} and user: ${this.nickname}`
      );
      console.log("Payload data:", event.detail);
      console.log(`Review text: ${event.reviewText}`);
      console.log(`Score: ${event.score}`);
      // Call the Apex method to submit the review
      let reviewId = await submitReview({
        movieId: this.movieId,
        reviewText: event.detail.reviewText,
        nickname: this.nickname,
        score: event.detail.score
      });
      if (reviewId) {
        this.showToast("Success", "Review inserted.", "success");
        this.showFormNewReview = false;
        await refreshApex(this.wiredReviews);
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

  handleEdit(event) {
    const review = this.reviews.find(
      (item) => item.Id === event.currentTarget.dataset.id
    );
    this.editingReviewId = review.Id;
    this.draftReviewText = review.Review_Text__c;
    this.draftScore = review.Score__c;
  }

  handleCancel() {
    this.editingReviewId = undefined;
  }

  handleReviewTextChange(event) {
    this.draftReviewText = event.target.value;
  }

  handleScoreChange(event) {
    this.draftScore = Number(event.target.value);
  }

  handleClose() {
    this.close();
  }

  async handleSave() {
    try {
      await updateReview({
        reviewId: this.editingReviewId,
        reviewText: this.draftReviewText,
        score: this.draftScore
      });
      this.editingReviewId = undefined;
      this.showToast("Success", "Review updated.", "success");
      await refreshApex(this.wiredReviews);
    } catch (error) {
      this.handleError(error);
    }
  }

  async handleDelete(event) {
    const reviewId = event.currentTarget.dataset.id;
    try {
      await deleteReview({ reviewId });
      this.showToast("Success", "Review deleted.", "success");
      await refreshApex(this.wiredReviews);
    } catch (error) {
      this.handleError(error);
    }
  }

  handleError(error) {
    this.error =
      error.body?.message || error.message || "Unable to load reviews.";
    this.showToast("Error", this.error, "error");
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
