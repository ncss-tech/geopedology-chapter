# geopedology-chapter

## Organization
We can coordinate our work by placing our sections into files (`dylan.Rmd` or something like that), working there, and then combining at the end.

## Deadlines
 * internal review: ASAP
 * abstract: June 30
 * chapter: Nov 31, or when it is done.

## Abstract


**Algorithms for Quantitative Pedology**

*D.E. Beaudette, A.G. Brown, S.M. Roecker, P.Roudier, and J. Skovlin*

The Algorithms for Quantitative Pedology (AQP) project is a suite of packages for the R programming language that simplify quantitative analysis of soil profile data. The "aqp" package provides a vocabulary (functions and data structures) tailored to the complexity of soil profile information. The "soilDB" package provides interfaces to databases and web services; leveraging the "aqp" vocabulary. The "sharpshootR" package provides tools to assist with summary and visualization. Bridging the gap between pedometric theory and practice is central to the purpose of the AQP project. The AQP R packages have been extensively tested and documented, applied to projects involving hundreds of thousands of soil profiles, and integrated into widely used tools such as SoilWeb. These packages serve an important role in routine data analysis within the U.S. Department of Agriculture and in other soil survey programs across the world. 

## Topics to Cover
*add/remove as-needed, and pick 1-3 that you want to write about*
 
 * Intro (Dylan)
 * the `SoilProfileCollection`, method dispatch, subsetting, iteration, inspection, etc. (Dylan / Andrew)
 * data cleaning, fixing, validity, etc. (Andrew)
 * scaling via `data.table` back-end (Andrew)
 * thickness, soil depth estimation (Stephen)
 * profile sketches (Dylan)
 * all things soil color (Dylan)
 * soil data aggregation (Stephen)
 * pair-wise distance (Dylan)
 * misc. vizualization methods (via `sharpshootR`) (Jay)
 * Soil Taxonomy related (Andrew)
 * generalized horizon labels: why / how (Jay)
 * linkages to spectral data (Pierre)
 * **add other topics here**
