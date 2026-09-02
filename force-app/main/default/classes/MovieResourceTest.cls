/**
 * Unit test class for MovieResource
 */
@isTest
private class MovieResourceTest {

    
    @testSetup 
    static void setupData() {
        // Create test data for Movie__c records
        List<Movie__c> movies = new List<Movie__c>();
        String[] genres = new String[]{'Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi'};
        for (Integer i = 1; i <= 2500; i++) {
            movies.add(new Movie__c(
                Name = 'Movie ' + i,
                Genre__c = genres[Math.mod(i, genres.size())],
                IMDB_Rating__c = Decimal.valueOf(Math.random() * 10).setScale(1, RoundingMode.HALF_UP)
            ));
        }
        insert movies;
    }

    @isTest
    static void testGetByPageReturnsMovies() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/movies';
        request.httpMethod = 'GET';
        request.params.put('pageNumber', '1');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        MovieResource.MoviePage result = MovieResource.getByPage();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(2500, result.totalItems);
        System.assertEquals(1, result.page);
        System.assertEquals(MovieResource.PAGE_SIZE, result.perPage);
        System.assertEquals(MovieResource.PAGE_SIZE, result.data.size());
        System.assertNotEquals(null, result.data[0].Name);
    }

    @isTest
    static void testGetByPageReturnsMoviesPage2() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/movies';
        request.httpMethod = 'GET';
        request.params.put('pageNumber', '2');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        MovieResource.MoviePage result = MovieResource.getByPage();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(2500, result.totalItems);
        System.assertEquals(2, result.page);
        System.assertEquals(MovieResource.PAGE_SIZE, result.perPage);
        System.assertEquals(MovieResource.PAGE_SIZE, result.data.size());
        System.assertNotEquals(null, result.data[0].Name);
    }

    @isTest
    static void testGetByPageRejectsZero() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/movies';
        request.httpMethod = 'GET';
        request.params.put('pageNumber', '0');
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        MovieResource.MoviePage result = MovieResource.getByPage();
        Test.stopTest();

        System.assertEquals(null, result);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));
    }


}