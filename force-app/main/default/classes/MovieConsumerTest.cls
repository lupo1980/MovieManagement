@isTest
private class MovieConsumerTest {
  private class MovieResponseMock implements HttpCalloutMock {
    private Integer statusCode;
    private String body;

    MovieResponseMock(Integer statusCode, String body) {
      this.statusCode = statusCode;
      this.body = body;
    }

    public HttpResponse respond(HttpRequest request) {
      System.assertEquals('GET', request.getMethod());
      System.assertEquals(
        'callout:Movie_Provider/services/apexrest/movies?pageNumber=2',
        request.getEndpoint()
      );

      HttpResponse response = new HttpResponse();
      response.setStatusCode(statusCode);
      response.setBody(body);
      return response;
    }
  }

  @isTest
  static void getMoviesReturnsPage() {
    Test.setMock(
      HttpCalloutMock.class,
      new MovieResponseMock(
        200,
        '{"totalItems":1,"page":2,"perPage":1000,"data":[{"Name":"Arrival","Genre":"Sci-Fi","IMDB_Rating":8.0}]}'
      )
    );

    Test.startTest();
    MovieConsumer.MoviePage result = MovieConsumer.getMovies(2);
    Test.stopTest();

    System.assertEquals(1, result.totalItems);
    System.assertEquals('Arrival', result.data[0].Name);
    System.assertEquals(8.0, result.data[0].IMDB_Rating);
  }

  @isTest
  static void getMoviesRejectsInvalidPage() {
    try {
      MovieConsumer.getMovies(0);
      System.assert(false, 'Expected invalid page error.');
    } catch (AuraHandledException handledError) {
      System.assertEquals('Script-thrown exception', handledError.getMessage());
    }
  }

  @isTest
  static void getMoviesRejectsProviderError() {
    Test.setMock(
      HttpCalloutMock.class,
      new MovieResponseMock(500, '{"error":"failure"}')
    );

    try {
      Test.startTest();
      MovieConsumer.getMovies(2);
      Test.stopTest();
      System.assert(false, 'Expected provider error.');
    } catch (AuraHandledException handledError) {
      System.assertEquals('Script-thrown exception', handledError.getMessage());
    }
  }
}
