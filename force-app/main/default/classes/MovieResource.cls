@restResource(urlMapping='/movies/*')
global with sharing class MovieResource {
  //TODO move to custom settings or custom metadata for easier configuration
  global static final Integer PAGE_SIZE = 1000;
  /**
   * DTO classes to represent the paginated response
   */
  global class MoviePage {
    public Integer totalItems;
    public Integer page; //current page
    public Integer perPage; //num data per page
    public List<MovieDTO> data;
    public MoviePage(
      Integer totalItems,
      Integer page,
      Integer perPage,
      List<Movie__c> movies
    ) {
      this.data = new List<MovieDTO>();
      for (Movie__c movie : movies) {
        this.data.add(new MovieDTO(movie));
      }
      this.totalItems = totalItems;
      this.page = page;
      this.perPage = perPage;
    }
  }

  global class MovieDTO {
    public String Name;
    public String Genre;
    public Decimal IMDB_Rating;

    public MovieDTO(Movie__c movie) {
      this.Name = movie.Name;
      this.Genre = movie.Genre__c;
      this.IMDB_Rating = movie.IMDB_Rating__c;
    }
  }

  /**
   * Retrieves a page of movies based on the requested page number
   * @return MoviePage containing the paginated movie data
   */
  @HttpGet
  global static MoviePage getByPage() {
    RestResponse res = RestContext.response;
    try {
      RestRequest req = RestContext.request;
      Map<String, String> params = req.params;
      Integer pageNumber = params.containsKey('pageNumber')
        ? Integer.valueOf(params.get('pageNumber'))
        : null;

      if (pageNumber == null || pageNumber < 1) {
        res.statusCode = 400;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(
          '{"error": "pageNumber: ' + pageNumber + ' cannot be less than 1."}'
        );
        return null;
      }

      Integer pageSize = PAGE_SIZE;
      Integer offset = (pageNumber - 1) * pageSize;
      //TODO cursor based pagination to avoid OFFSET performance issues for large datasets
      // List<Movie__c> movies = [SELECT Id, Name, Genre__c, IMDB_Rating__c FROM Movie__c
      // Order By CreatedDate DESC, ID DESC LIMIT :pageSize OFFSET :offset ];

      List<Movie__c> movies = MovieDataManager.getMoviesByPage(
        pageNumber,
        pageSize
      );

      Integer totalItems = [SELECT COUNT() FROM Movie__c];

      return new MoviePage(totalItems, pageNumber, pageSize, movies);
    } catch (Exception e) {
      system.debug(e);
      // Fallback for general server errors
      res.statusCode = 500;
      res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
      return null;
    }
  }
}
