-- Table: public.noc_regions

DROP TABLE IF EXISTS public.noc_regions;

CREATE TABLE IF NOT EXISTS public.noc_regions
(
    NOC character varying COLLATE pg_catalog."default",
    region character varying COLLATE pg_catalog."default",
    notes character varying COLLATE pg_catalog."default"
)


select * from noc_regions;

select count(1) from noc_regions;