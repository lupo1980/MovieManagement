public with sharing class MovieConsumer {
  private static final String PROVIDER_ENDPOINT = 'callout:Movie_Provider/services/apexrest/movies?pageNumber=';

  public class MoviePage {
    @AuraEnabled
    public Integer totalItems;
    @AuraEnabled
    public Integer page;
    @AuraEnabled
    public Integer perPage;
    @AuraEnabled
    public List<Movie> data;
  }

  public class Movie {
    @AuraEnabled
    public String Name;
    @AuraEnabled
    public String Genre;
    @AuraEnabled
    public Decimal IMDB_Rating;
  }

  @AuraEnabled
  public static MoviePage getMovies(Integer pageNumber) {
    if (pageNumber == null || pageNumber < 1) {
      throw new AuraHandledException('pageNumber must be at least 1.');
    }

    HttpRequest request = new HttpRequest();
    request.setEndpoint(PROVIDER_ENDPOINT + String.valueOf(pageNumber));
    request.setMethod('GET');
    request.setTimeout(10000);

    HttpResponse response;
    try {
      response = new Http().send(request);
    } catch (CalloutException calloutError) {
      throw new AuraHandledException('Unable to reach the movie service.');
    }

    if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
      throw new AuraHandledException(
        'Movie service returned HTTP ' + response.getStatusCode() + '.'
      );
    }

    try {
      return (MoviePage) JSON.deserialize(response.getBody(), MoviePage.class);
    } catch (JSONException parseError) {
      throw new AuraHandledException(
        'Movie service returned an invalid response.'
      );
    }
  }
}
