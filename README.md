# geopedology-chapter

## Organization
We can coordinate our work by placing our sections into files (`dylan.Rmd` or something like that), working there, and then combining at the end.

## Deadlines
 * 30/01/2022 Full manuscript due
 * 28/02/2022 Editors review and provide feedback
 * 30/03/2022 Final draft submitted 
 * 30/09/2022 Publication 
 


## Abstract


**Algorithms for Quantitative Pedology**

*D.E. Beaudette, A.G. Brown, S.M. Roecker, P.Roudier, and J. Skovlin*

The Algorithms for Quantitative Pedology (AQP) project is a suite of packages for the R programming language that simplify quantitative analysis of soil profile data. The "aqp" package provides a vocabulary (functions and data structures) tailored to the complexity of soil profile information. The "soilDB" package provides interfaces to databases and web services; leveraging the "aqp" vocabulary. The "sharpshootR" package provides tools to assist with summary and visualization. Bridging the gap between pedometric theory and practice is central to the purpose of the AQP project. The AQP R packages have been extensively tested and documented, applied to projects involving hundreds of thousands of soil profiles, and integrated into widely used tools such as SoilWeb. These packages serve an important role in routine data analysis within the U.S. Department of Agriculture and in other soil survey programs across the world. 

## Topics to Cover
*add/remove as-needed, and pick 1-3 that you want to write about*
 
 * [Intro](sections/introduction.Rmd) (Dylan / Pierre)
 * [The `SoilProfileCollection`, method dispatch, subsetting, iteration, inspection, etc.](sections/SPC-objects.Rmd) (Andrew / Dylan / Pierre)
 * data cleaning, fixing, validity, etc. (Andrew)
 * scaling via `data.table` back-end (Andrew)
 * thickness, soil depth estimation (Stephen)
 * [profile sketches](sections/sketches.Rmd) (Dylan)
 * [soil color](sections/soil-color.Rmd) (Dylan)
 * soil data aggregation (Stephen)
 * [pair-wise distance](sections/pair-wise-distances.Rmd) (Dylan)
 * misc. visualization methods (via `sharpshootR`) (Jay)
 * Soil Taxonomy related (Andrew)
 * generalized horizon labels: why / how (Jay)
 * linkages to spectral data (Pierre)
 * **add other topics here** 
 * *Suggestion: something about linking/plotting with spatial data?*


## A Common Narrative
I'd suggest we use a related set of tasks / problems associated with the synthesis of pedon data to describe key features of the packages. The [competing series tutorial](http://ncss-tech.github.io/AQP/soilDB/competing-series.html) is close to what I'm envisioning. We could use a single series, multiple series, or a single subgroup as the example dataset. Once we decide (ASAP) it will be critical to "freeze" the example data such that changes to pedons or OSDs do not impact the results as we are writing. In addition, having all code + data in a companion GH repo would make the chapter a lot more useful.

Jay and I are thinking about the [CLARSKVILLE](https://casoilresource.lawr.ucdavis.edu/sde/?series=clarksville) series. See example data in `local-data` folder.

I've asked the editors for a one month extension.

# Notes from Editors

The number of your chapter is 11. Please, note that this number should head the titles, subtitles, tables, and figures, as indicated in the manuscript guidelines that we attach herewith.
 
Kindly note that the manuscript should have a length of no more than 15 typeset pages. The main text should not exceed 6,000 words (excluding Abstract, References, and figure and table captions). The abstract should have 250 words maximum. Some overlap with the Abstract is acceptable.
 
There are no specific requirements for the main body of the text. You can organize it in a way that best suits the theme of the chapter.
 
Figure captions should not have more than 40 words per figure, and Tables should fit in one page.

  * 30/01/2022 Full manuscript
  * 28/02/2022 Editors review and provide feedback
  * 30/03/2022 Final draft submitted 
  * 30/09/2022 Publication 

