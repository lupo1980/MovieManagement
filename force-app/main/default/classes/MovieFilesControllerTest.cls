@isTest
private class MovieFilesControllerTest {
  @isTest
  static void getMovieImagesReturnsLinkedDocuments() {
    Movie__c movie = new Movie__c(Name = 'Arrival');
    insert movie;

    ContentVersion versionRecord = new ContentVersion(
      Title = 'Arrival Poster',
      PathOnClient = 'arrival-poster.jpg',
      VersionData = Blob.valueOf('test image content'),
      IsMajorVersion = true
    );
    insert versionRecord;

    versionRecord = [
      SELECT Id, ContentDocumentId, Title
      FROM ContentVersion
      WHERE Id = :versionRecord.Id
      LIMIT 1
    ];

    insert new ContentDocumentLink(
      ContentDocumentId = versionRecord.ContentDocumentId,
      LinkedEntityId = movie.Id,
      ShareType = 'V',
      Visibility = 'AllUsers'
    );

    Test.startTest();
    List<MovieFilesController.MovieImage> result = MovieFilesController.getMovieImages(
      movie.Id
    );
    Test.stopTest();

    System.assertEquals(1, result.size());
    System.assertEquals(versionRecord.Id, result[0].Id);
    System.assertEquals('Arrival Poster', result[0].Title);
    System.assertEquals(
      '/sfc/servlet.shepherd/version/download/' + versionRecord.Id,
      result[0].Url
    );
    System.assertEquals(
      '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' +
      versionRecord.Id,
      result[0].UrlThumbnail
    );
  }

  @isTest
  static void getMovieImagesReturnsEmptyListForNullMovieId() {
    Test.startTest();
    List<MovieFilesController.MovieImage> result = MovieFilesController.getMovieImages(
      null
    );
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
    System.assertEquals(0, result.size());
  }
}
