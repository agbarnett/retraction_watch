# Check for retracted papers on the Retraction Watch database using a BibTeX file

Shiny app to cross-check a BibTeX file against the *[Retraction Watch](https://retractionwatch.com/)* database using the latest data provided by *Crossref*.
The BibTeX file must include DOIs.

### R version and packages

```
R version 4.3.1 (2023-06-16 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default


locale:
[1] LC_COLLATE=English_Australia.utf8  LC_CTYPE=English_Australia.utf8   
[3] LC_MONETARY=English_Australia.utf8 LC_NUMERIC=C                      
[5] LC_TIME=English_Australia.utf8    

time zone: Australia/Brisbane
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] dplyr_1.1.2   shiny_1.7.4   stringr_1.5.0

loaded via a namespace (and not attached):
 [1] jsonlite_1.8.5   compiler_4.3.1   promises_1.2.0.1 tidyselect_1.2.0 Rcpp_1.0.10     
 [6] later_1.3.1      jquerylib_0.1.4  fastmap_1.1.1    mime_0.12        R6_2.5.1        
[11] generics_0.1.3   curl_5.0.1       tibble_3.2.1     openssl_2.0.6    bslib_0.5.0     
[16] pillar_1.9.0     rlang_1.1.1      utf8_1.2.3       cachem_1.0.8     stringi_1.7.12  
[21] httpuv_1.6.11    sass_0.4.6       memoise_2.0.1    cli_3.6.1        withr_2.5.0     
[26] magrittr_2.0.3   digest_0.6.31    rstudioapi_0.14  xtable_1.8-4     askpass_1.1     
[31] lifecycle_1.0.3  vctrs_0.6.3      glue_1.6.2       rsconnect_0.8.29 fansi_1.0.4     
[36] tools_4.3.1      pkgconfig_2.0.3  ellipsis_0.3.2   htmltools_0.5.5
```