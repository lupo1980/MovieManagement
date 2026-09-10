List<Movie__c> movies = [SELECT Id, Name FROM Movie__c];

if (movies.isEmpty()) {
    System.debug('No movies found.');
    return;
}

List<String> reviewers = new List<String>{
    'Ava', 'Liam', 'Sophia', 'Noah', 'Mia', 'Ethan', 'Olivia', 'Lucas', 'Emma', 'Mason',
    'Charlotte', 'James', 'Isabella', 'Benjamin', 'Harper', 'Leo', 'Amelia', 'Henry', 'Ella', 'Jack'
};

List<String> reviewBodies = new List<String>{
    'A fun and engaging film with memorable scenes and strong performances.',
    'The story was compelling, though a few moments felt a little predictable.',
    'Visually stunning and emotionally rich from start to finish.',
    'Great pacing and a memorable soundtrack made this easy to enjoy.',
    'An ambitious movie that mostly works thanks to excellent acting.',
    'A solid watch with a few rough spots, but overall highly entertaining.',
    'The atmosphere was fantastic, and the ending really landed.',
    'A mixed bag but still worth watching for the performances and visuals.',
    'Well crafted and heartfelt, with a lot of charm and personality.',
    'Enjoyable and creative, even if it could have been tighter in places.'
};

List<Movie_Review__c> reviewsToInsert = new List<Movie_Review__c>();

public class Checker {
    public Boolean checkLimit(List<Movie_Review__c> reviewsToInsert) {
        if(Limits.getdmlrows() + reviewsToInsert.size() >= Limits.getLimitDMLRows()){
            System.debug(LoggingLevel.Error, 'Trying to insert ' + reviewsToInsert.size() 
            + ' review records, but only ' + (Limits.getLimitDMLRows() - Limits.getDMLRows()) 
            + ' DML rows are available. Skipping insert.');
            return false;
        }
        return true;
    }
}

for (Movie__c movie : movies) {
    // if(!new Checker().checkLimit(reviewsToInsert)){
    //     break; // Exit the loop if we are about to exceed DML limits
    // }
    Integer reviewCount = Integer.valueOf(Math.floor(Math.random() * 101));
    
    for (Integer i = 0; i < reviewCount; i++) {
        if(!new Checker().checkLimit(reviewsToInsert)){
            break; // Exit the loop if we are about to exceed DML limits
        }
        String nickname = reviewers[Integer.valueOf(Math.floor(Math.random() * reviewers.size()))];
        String reviewText = reviewBodies[Integer.valueOf(Math.floor(Math.random() * reviewBodies.size()))];
        Integer score = Integer.valueOf(Math.floor(Math.random() * 10));

        reviewsToInsert.add(new Movie_Review__c(
            Movie__c = movie.Id,
            Nickname__c = nickname,
            Score__c = score,
            Review__c = reviewText
        ));
    }
}
system.debug('Limits.getdmlrows(): ' + Limits.getdmlrows() 
+', reviewsToInsert.size(): ' + reviewsToInsert.size() +', Limits.getLimitDMLRows(): '+ Limits.getLimitDMLRows());
try {
    if (!reviewsToInsert.isEmpty()) {
        insert reviewsToInsert;
        System.debug('Inserted ' + reviewsToInsert.size() + ' review records.');
        
    } else {
        System.debug('No reviews generated.');
    }
} catch (DmlException e) {
    System.debug(LoggingLevel.Error, 'Error inserting review records: ' + e.getMessage());
    System.debug(LoggingLevel.Error, e.getCause());
    System.debug(LoggingLevel.Error, e.getStackTraceString());
} catch (Exception e) {
    System.debug(LoggingLevel.Error, 'Unexpected error: ' + e.getMessage());
    System.debug(LoggingLevel.Error, e.getCause());
    System.debug(LoggingLevel.Error, e.getStackTraceString());
}
