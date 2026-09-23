import MovieReviewLabel from "@salesforce/label/c.Movie_Review_Instruction";

//Load labels in one place to be used in other components.
//This is to avoid having to import the same label in multiple components.
const label = {
  movieReviewInstruction: MovieReviewLabel
};

export { label };
