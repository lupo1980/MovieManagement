public with sharing class MovieConsumer {
  //private static final String PROVIDER_ENDPOINT = 'callout:Movie_Provider/services/apexrest/movies?pageNumber=';

  public class MoviePage {
    @AuraEnabled
    public Integer totalItems;
    @AuraEnabled
    public Integer page;
    @AuraEnabled
    public Integer perPage;
    @AuraEnabled
    public List<Movie> data;

    public MoviePage(
      Integer totalItems,
      Integer page,
      Integer perPage,
      List<Movie__c> data
    ) {
      this.totalItems = totalItems;
      this.page = page;
      this.perPage = perPage;
      this.data = new List<Movie>();
      for (Movie__c movie : data) {
        this.data.add(new Movie(movie));
      }
    }
  }

  public class Movie {
    @AuraEnabled
    public String Name;
    @AuraEnabled
    public String Genre;
    @AuraEnabled
    public Decimal IMDB_Rating;
    public Movie(Movie__c movie) {
      this.Name = movie.Name;
      this.Genre = movie.Genre__c;
      this.IMDB_Rating = movie.IMDB_Rating__c;
    }
  }

  @AuraEnabled
  public static MoviePage getMovies(Integer pageNumber) {
    if (pageNumber == null || pageNumber < 1) {
      throw new AuraHandledException('pageNumber must be at least 1.');
    }

    try {
      Integer pageSize = MovieResource.PAGE_SIZE;
      List<Movie__c> movies = MovieDataManager.getMoviesByPage(
        pageNumber,
        pageSize
      );
      Integer totalItems = [SELECT COUNT() FROM Movie__c];
      return new MoviePage(totalItems, pageNumber, pageSize, movies);
      //return (MoviePage) JSON.deserialize(response.getBody(), MoviePage.class);
    } catch (JSONException parseError) {
      throw new AuraHandledException(
        'Movie service returned an invalid response.'
      );
    }
  }

  //TODO create named credential for movie provider and use it here to call the provider's REST API
  //   public static MoviePage getMoviesFromProvider(Integer pageNumber) {
  //     if (pageNumber == null || pageNumber < 1) {
  //       throw new AuraHandledException('pageNumber must be at least 1.');
  //     }

  //     HttpRequest request = new HttpRequest();
  //     request.setEndpoint('callout:Movie_Provider/services/apexrest/movies?pageNumber=' + pageNumber);
  //     request.setMethod('GET');

  //     Http http = new Http();
  //     HttpResponse response = http.send(request);

  //     if (response.getStatusCode() != 200) {
  //       throw new AuraHandledException(
  //         'Movie service returned an error: ' + response.getStatusCode()
  //       );
  //     }

  //     try {
  //       return (MoviePage) JSON.deserialize(response.getBody(), MoviePage.class);
  //     } catch (JSONException parseError) {
  //       throw new AuraHandledException(
  //         'Movie service returned an invalid response.'
  //       );
  //     }
  //   }
}
