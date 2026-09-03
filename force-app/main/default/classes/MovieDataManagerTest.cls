@isTest
private class MovieDataManagerTest {
  @testSetup
  static void setupData() {
    insert new List<Movie__c>{
      new Movie__c(Name = 'Arrival', Genre__c = 'Sci-Fi', IMDB_Rating__c = 8.0),
      new Movie__c(Name = 'Jaws', Genre__c = 'Thriller', IMDB_Rating__c = 8.1),
      new Movie__c(Name = 'Zodiac', Genre__c = 'Mystery', IMDB_Rating__c = 7.7)
    };
  }

  @isTest
  static void getMoviesByPageReturnsMoviesOrderedByName() {
    Test.startTest();
    List<Movie__c> result = MovieDataManager.getMoviesByPage(1, 2);
    Test.stopTest();

    System.assertEquals(2, result.size());
    System.assertEquals('Arrival', result[0].Name);
    System.assertEquals('Jaws', result[1].Name);
  }

  @isTest
  static void getMoviesByPageAppliesOffset() {
    Test.startTest();
    List<Movie__c> result = MovieDataManager.getMoviesByPage(2, 2);
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals('Zodiac', result[0].Name);
  }

  @isTest
  static void getMoviesByPageReturnsEmptyListPastEnd() {
    Test.startTest();
    List<Movie__c> result = MovieDataManager.getMoviesByPage(3, 2);
    Test.stopTest();

    System.assertEquals(0, result.size());
  }
}
