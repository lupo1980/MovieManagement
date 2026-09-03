public with sharing class MovieDataManager {
  public static List<Movie__c> getMoviesByPage(
    Integer pageNumber,
    Integer pageSize
  ) {
    Integer offset = (pageNumber - 1) * pageSize;
    List<Movie__c> movies = [
      SELECT Id, Name, Genre__c, IMDB_Rating__c
      FROM Movie__c
      ORDER BY Name
      LIMIT :pageSize
      OFFSET :offset
    ];
    return movies;
  }
}
