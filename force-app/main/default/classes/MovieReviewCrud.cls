public with sharing class MovieReviewCrud {
  @AuraEnabled(cacheable=true)
  public static List<Movie__c> getMovies(String movieTitle) {
    List<Movie__c> movies = new List<Movie__c>();
    if (String.isNotBlank(movieTitle)) {
      movies = [
        SELECT Id, Name, Genre__c, IMDB_Rating__c
        FROM Movie__c
        WHERE Name LIKE :('%' + movieTitle + '%')
      ];
    }
    return movies;
  }

  @AuraEnabled
  public static Id submitReview(
    Id movieId,
    String reviewText,
    String nickname,
    Integer score
  ) {
    try {
      MovieReviewService service = new MovieReviewService();
      Movie_Review__c review = service.submitReview(
        movieId,
        reviewText,
        nickname,
        score
      );
      return review.Id;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error submitting review: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Movie_Review__c> getReviews(Id movieId) {
    if (movieId == null) {
      return new List<Movie_Review__c>();
    }

    return [
      SELECT Id, Movie__c, Review_Text__c, Nickname__c, Score__c, Status__c
      FROM Movie_Review__c
      WHERE Movie__c = :movieId
      ORDER BY CreatedDate DESC
    ];
  }

  @AuraEnabled
  public static void updateReview(
    Id reviewId,
    String reviewText,
    Integer score
  ) {
    if (reviewId == null) {
      throw new AuraHandledException('Review ID cannot be null.');
    }
    if (String.isBlank(reviewText)) {
      throw new AuraHandledException('Review text cannot be empty.');
    }
    if (score == null || score < 0 || score > 5) {
      throw new AuraHandledException('Score must be between 0 and 5.');
    }

    update new Movie_Review__c(
      Id = reviewId,
      Review_Text__c = reviewText,
      Score__c = score
    );
  }

  @AuraEnabled
  public static void deleteReview(Id reviewId) {
    if (reviewId == null) {
      throw new AuraHandledException('Review ID cannot be null.');
    }

    delete new Movie_Review__c(Id = reviewId);
  }
}
