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
      if (String.isBlank(reviewText)) {
        throw new AuraHandledException('Review text cannot be empty.');
      }
      if (score == null || score < 0 || score > 5) {
        throw new AuraHandledException(
          'Invalid score. Please enter a score between 0 and 5.'
        );
      }
      if (movieId == null) {
        throw new AuraHandledException('Movie ID cannot be null.');
      }
      Movie_Review__c review = new Movie_Review__c();
      review.Movie__c = movieId;
      review.Review__c = reviewText;
      review.Nickname__c = nickname;
      review.Score__c = score;
      insert review;
      return review.Id;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error submitting review: ' + e.getMessage()
      );
    }
  }
}
