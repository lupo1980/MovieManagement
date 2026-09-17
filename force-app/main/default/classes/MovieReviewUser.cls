public with sharing class MovieReviewUser {
  @auraenabled
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

  @auraenabled
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
}
