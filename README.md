
# Notes from Editors

The number of your chapter is 11. Please, note that this number should head the titles, subtitles, tables, and figures, as indicated in the manuscript guidelines that we attach herewith.
 
Kindly note that the manuscript should have a length of no more than 15 typeset pages. The main text should not exceed 6,000 words (excluding Abstract, References, and figure and table captions). The abstract should have 250 words maximum. Some overlap with the Abstract is acceptable.
 
There are no specific requirements for the main body of the text. You can organize it in a way that best suits the theme of the chapter.
 
Figure captions should not have more than 40 words per figure, and Tables should fit in one page.

  * 30/01/2022 Full manuscript
  * 28/02/2022 Editors review and provide feedback
  * 30/03/2022 Final draft submitted 
  * 30/09/2022 Publication 

Update: we have a one month extension.

## Style Notes

  * A key objective of this new edition of the book is to provide an update on soil-geomorphic landscape relationships and their link with geodiversity and relevant features of biodiversity. It will not only focus on existing challenges, but also provide insight into the possibility and opportunity of problem solving. 

  * I think most readers of this book are within the classical methods of soil mapping. I thought it would be nice to show how you can use AQP to study the soil-landscape relations, comparing soil profiles, horizons associations, etc. For most readers this will be the first time they hear about AQP and R, so it should not go into much coding details.

  * Authors should use citation-style vs. in-line URLs: `Doe J (2000) Title of supplementary material. http://www.privatehomepage.com. Accessed 22 Feb 2000`

# Abstract


**Algorithms for Quantitative Pedology**

*D.E. Beaudette, A.G. Brown, S.M. Roecker, P.Roudier, and J. Skovlin*

The Algorithms for Quantitative Pedology (AQP) project is a suite of packages for the R programming language that simplify quantitative analysis of soil profile data. The "aqp" package provides a vocabulary (functions and data structures) tailored to the complexity of soil profile information. The "soilDB" package provides interfaces to databases and web services; leveraging the "aqp" vocabulary. The "sharpshootR" package provides tools to assist with summary and visualization. Bridging the gap between pedometric theory and practice is central to the purpose of the AQP project. The AQP R packages have been extensively tested and documented, applied to projects involving hundreds of thousands of soil profiles, and integrated into widely used tools such as SoilWeb. These packages serve an important role in routine data analysis within the U.S. Department of Agriculture and in other soil survey programs across the world. 



# A Common Narrative
I'd suggest we use a related set of tasks / problems associated with the synthesis of pedon data to describe key features of the packages. The [competing series tutorial](http://ncss-tech.github.io/AQP/soilDB/competing-series.html) is close to what I'm envisioning. We could use a single series, multiple series, or a single subgroup as the example dataset. Once we decide (ASAP) it will be critical to "freeze" the example data such that changes to pedons or OSDs do not impact the results as we are writing. In addition, having all code + data in a companion GH repo would make the chapter a lot more useful.

Jay and I are thinking about the [CLARSKVILLE](https://casoilresource.lawr.ucdavis.edu/sde/?series=clarksville) series. See example data in `local-data` folder.

# TODO
 - [x] Jay: assemble Clarksville example data
 - [x] GHL assignment
 - [] Dylan: add relevant citations (and remove unused) in [bibtex DB](sections/bibliography.bib)
 - [] Dylan: find "salty slices" paper from Spain
 - [] everything else


# Figures
0-2 figures per major section heading, max of 8 figures.

# Notes
Consider using [wordcountaddin](https://github.com/benmarwick/wordcountaddin) for checking word-counts within RStudio. Try `wordcountaddin::word_count()` and `wordcountaddin::readability()`.


# Outline

## Introduction
[800 words](sections/introduction.Rmd) (Dylan / Pierre)

  * brief history
  * motivation
  * evolution
  * current use
  * major TODOs / vision


## SoilProfileCollection Object / Methods
[1,000 words](sections/SPC-objects.Rmd) (Andrew / Dylan / Pierre)

  * rationale
  * basic design / strategy
  * various back-ends

### Subsetting

  * `[`-methods, `.FIRST` style keywords, spatial predicates (Andrew)
  * `subset()` and NSE (Andrew)
  * `glom()`, `trunc()` and related (Andrew) 
  * other methods

### Iteration

  * implicit vectorization
  * `profileApply()` (Andrew)

### Misc.

 * data cleaning, fixing, validity, etc. (Andrew)
 * functions that return SPC objects via soilDB (Dylan, Jay, Stephen)
 


## Soil Morphology
[1,600 words.](sections/soil-morphology.Rmd) (Dylan, ???)

  * aqp + SPC is designed for the modeling / analysis of soil morphology (site+pedon/horizons)
  * major goals
  * limitation (analysis vs. archival formats)
  * critical data: depths, horizon designations, color, ...

### Sketches
[profile sketches](sections/sketches.Rmd) (Dylan)

  * `plotSPC()`
  * annotation
  * other profile plotting functions
  * future work (grid graphics, pattern fill)
  

### Genetic / Generalized Horizons
 * generalized horizon labels: why / how (Jay)
 * horizon boundaries
 * regular expressions used to "find" contact etc. (Andrew, Stephen)
 

### Soil Color
(Dylan)

  * Munsell system and other color spaces
  * conversion functions / limitations
  * contrast
  * simulated, subtractive mixtures
  * RIC (?)

### Depth

 * thickness, soil depth estimation (Stephen)
 * `depthOf()` family of functions (Andrew)

### Misc.

 * misc. visualization methods (via `sharpshootR`) (Jay)



## Resampling / Aggregation
[800 words.](sections/resampling-aggregation.Rmd)

  * slicing - `dice()`
  * `slab()`, continuous and categorical
  * `segment()`
  * `L1`, if there is space

### Visualization


## Numerical Classification
[800 words](sections/numerical-classification.Rmd) (Dylan)

  * major concepts, cite / rely on two papers for details

### Visualization

  * dendrogram + profiles


## Spectral Data ?
[800 words](sections/spectral-data.Rmd) (Pierre)

  * use some NZ data, or Clarksville MIR if available


## Conclusions
[500 words](sections/conclusion.Rmd) (All)



## Soil Taxonomy (space-permitting)
< 800 words, still over limit (Andrew)


