public with sharing class MovieFilesController {
  public class MovieImage {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String Title { get; set; }
    @AuraEnabled
    public String Url { get; set; }
    @AuraEnabled
    public String UrlThumbnail { get; set; }
  }

  @auraEnabled(cacheable=true)
  public static List<MovieImage> getMovieImages(Id movieId) {
    List<MovieImage> movieImages = new List<MovieImage>();
    if (movieId != null) {
      List<ContentDocumentLink> contentDocumentLinks = [
        SELECT
          ContentDocumentId,
          ContentDocument.Title,
          ContentDocument.FileType,
          ContentDocument.LatestPublishedVersionId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :movieId
      ];

      for (ContentDocumentLink link : contentDocumentLinks) {
        MovieImage movieImage = new MovieImage();
        movieImage.Id = link.ContentDocument.LatestPublishedVersionId;
        movieImage.Title = link.ContentDocument.Title;
        movieImage.Url =
          '/sfc/servlet.shepherd/version/download/' +
          link.ContentDocument.LatestPublishedVersionId;
        movieImage.UrlThumbnail =
          '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' +
          link.ContentDocument.LatestPublishedVersionId;
        movieImages.add(movieImage);
      }
    }
    return movieImages;
  }
}
