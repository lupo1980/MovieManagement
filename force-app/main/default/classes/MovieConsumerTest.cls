@isTest
private class MovieConsumerTest {
  @testSetup
  static void setupData() {
    insert new List<Movie__c>{
      new Movie__c(Name = 'Arrival', Genre__c = 'Sci-Fi', IMDB_Rating__c = 8.0),
      new Movie__c(Name = 'Jaws', Genre__c = 'Thriller', IMDB_Rating__c = 8.1),
      new Movie__c(Name = 'Zodiac', Genre__c = 'Mystery', IMDB_Rating__c = 7.7)
    };
  }

  @isTest
  static void getMoviesReturnsOrderedPage() {
    Test.startTest();
    MovieConsumer.MoviePage result = MovieConsumer.getMovies(1);
    Test.stopTest();

    System.assertEquals(3, result.totalItems);
    System.assertEquals(1, result.page);
    System.assertEquals(MovieResource.PAGE_SIZE, result.perPage);
    System.assertEquals(3, result.data.size());
    System.assertEquals('Arrival', result.data[0].Name);
    System.assertEquals('Sci-Fi', result.data[0].Genre);
    System.assertEquals(8.0, result.data[0].IMDB_Rating);
  }

  @isTest
  static void getMoviesReturnsEmptyPageWhenPageIsPastEnd() {
    Test.startTest();
    MovieConsumer.MoviePage result = MovieConsumer.getMovies(2);
    Test.stopTest();

    System.assertEquals(3, result.totalItems);
    System.assertEquals(2, result.page);
    System.assertEquals(0, result.data.size());
  }

  @isTest
  static void getMoviesRejectsNullPage() {
    try {
      MovieConsumer.getMovies(null);
      System.assert(false, 'Expected invalid page error.');
    } catch (AuraHandledException handledError) {
      System.assertEquals('Script-thrown exception', handledError.getMessage());
    }
  }

  @isTest
  static void getMoviesRejectsZeroPage() {
    try {
      MovieConsumer.getMovies(0);
      System.assert(false, 'Expected invalid page error.');
    } catch (AuraHandledException handledError) {
      System.assertEquals('Script-thrown exception', handledError.getMessage());
    }
  }
}
