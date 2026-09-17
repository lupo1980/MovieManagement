public with sharing class MovieReviewService {
  private static final String INITIAL_STATUS = 'Awaiting_approval';

  public Movie_Review__c submitReview(
    Id movieId,
    String reviewText,
    String nickname,
    Integer score
  ) {
    if (movieId == null) {
      throw new AuraHandledException('Movie ID cannot be null.');
    }
    if (String.isBlank(reviewText)) {
      throw new AuraHandledException('Review text cannot be empty.');
    }
    if (String.isBlank(nickname)) {
      throw new AuraHandledException('Nickname cannot be empty.');
    }
    if (score == null || score < 0 || score > 5) {
      throw new AuraHandledException('Score must be between 0 and 5.');
    }

    Movie_Review__c review = new MovieReviewBuilder()
      .setMovieId(movieId)
      .setReviewText(reviewText)
      .setNickname(nickname)
      .setScore(score)
      .setAwaitingApprovalStatus()
      .build();

    insert review;

    return review;
  }

  public class MovieReviewBuilder {
    private Movie_Review__c review;

    public MovieReviewBuilder() {
      review = new Movie_Review__c();
    }

    public MovieReviewBuilder setMovieId(Id movieId) {
      review.Movie__c = movieId;
      return this;
    }

    public MovieReviewBuilder setReviewText(String reviewText) {
      review.Review_Text__c = reviewText;
      return this;
    }

    public MovieReviewBuilder setNickname(String nickname) {
      review.Nickname__c = nickname;
      return this;
    }

    public MovieReviewBuilder setScore(Integer score) {
      review.Score__c = score;
      return this;
    }

    public MovieReviewBuilder setAwaitingApprovalStatus() {
      review.Status__c = INITIAL_STATUS;
      return this;
    }

    public Movie_Review__c build() {
      if (review.Movie__c == null) {
        throw new AuraHandledException('Movie ID cannot be null.');
      }
      if (String.isBlank(review.Review_Text__c)) {
        throw new AuraHandledException('Review text cannot be empty.');
      }
      if (String.isBlank(review.Nickname__c)) {
        throw new AuraHandledException('Nickname cannot be empty.');
      }
      if (
        review.Score__c == null ||
        review.Score__c < 0 ||
        review.Score__c > 5
      ) {
        throw new AuraHandledException('Score must be between 0 and 5.');
      }
      if (String.isBlank(review.Status__c)) {
        throw new AuraHandledException('Review status cannot be empty.');
      }
      return review;
    }
  }
}
