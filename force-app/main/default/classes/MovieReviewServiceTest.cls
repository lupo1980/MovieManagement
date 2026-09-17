@isTest
private class MovieReviewServiceTest {
  @testSetup
  static void setupData() {
    insert new Movie__c(Name = 'Arrival');
  }

  @isTest
  static void builderBuildsReviewWithExpectedFields() {
    Movie__c movie = [SELECT Id FROM Movie__c LIMIT 1];

    Movie_Review__c review = new MovieReviewService.MovieReviewBuilder()
      .setMovieId(movie.Id)
      .setReviewText('A thoughtful science-fiction film.')
      .setNickname('Reviewer')
      .setScore(5)
      .setAwaitingApprovalStatus()
      .build();

    System.assertEquals(movie.Id, review.Movie__c);
    System.assertEquals(
      'A thoughtful science-fiction film.',
      review.Review_Text__c
    );
    System.assertEquals('Reviewer', review.Nickname__c);
    System.assertEquals(5, review.Score__c);
    System.assertEquals('Awaiting_approval', review.Status__c);
  }

  @isTest
  static void builderRejectsIncompleteReview() {
    Boolean rejected = false;
    try {
      new MovieReviewService.MovieReviewBuilder().build();
    } catch (AuraHandledException error) {
      rejected = true;
    }
    System.assert(
      rejected,
      'Expected incomplete builder state to be rejected.'
    );
  }

  @isTest
  static void submitReviewInsertsReview() {
    Movie__c movie = [SELECT Id FROM Movie__c LIMIT 1];

    Test.startTest();
    Movie_Review__c review = new MovieReviewService()
      .submitReview(
        movie.Id,
        'A thoughtful science-fiction film.',
        'Reviewer',
        0
      );
    Test.stopTest();

    Movie_Review__c savedReview = [
      SELECT Movie__c, Review_Text__c, Nickname__c, Score__c, Status__c
      FROM Movie_Review__c
      WHERE Id = :review.Id
    ];
    System.assertEquals(movie.Id, savedReview.Movie__c);
    System.assertEquals(0, savedReview.Score__c);
    System.assertEquals('Awaiting_approval', savedReview.Status__c);
  }
}
