-- View: public.clean_reviews

-- DROP VIEW public.clean_reviews;

CREATE OR REPLACE VIEW public.clean_reviews
 AS
 SELECT clothing_id,
    age,
    title,
    review_text,
    rating,
    recommended,
    positive_feedback,
    dept_name,
    class_name
   FROM reviews_raw
  WHERE review_text IS NOT NULL AND length(review_text) > 20;

ALTER TABLE public.clean_reviews
    OWNER TO postgres;

