# server.R
# Shiny app to match bibtex file against the retraction watch database
# January 2022

shinyServer(function(input, output) {
  
  # reactive function to get data from bibtex file and create matches with retractionwatch
  matches = reactive({
    
    # don't progress if there's no email
    req(input$bibtex_file)
    
    # change inputs to variables
    infile <- input$bibtex_file$datapath # must use datapath
    email <- "a.barnett@qut.edu.au" # use my own, may as well know if there are problems

    # get the latest retraction data from crossref
    url = paste("https://api.labs.crossref.org/data/retractionwatch?mailto=", email, sep='')
    destfile = file.path(tempdir(), 'retractions.csv') # put in temporary folder
    download.file(url, destfile = destfile, method='curl')
    #print(destfile)
    # now read into a csv
    retractions = read.csv(destfile) %>%
      select(OriginalPaperDOI, Title, Journal) %>%
      rename('DOI' = 'OriginalPaperDOI') %>%
      mutate(DOI = str_squish(DOI))
    # delete file to tidy up
    #unlink('retractions.csv')
    
    # read in the bibtex file
    bibtex = read.table(file = infile, header = FALSE, sep = '!', quote='') # dummy separator to get everything in one variable
    # get the total number of references
    types = c('article','book','booklet','conference','inbook','incollection','inprocedings','manual','misc','mastersthesis','phdthesis','proceedings','techreport','unpublished')
    patterns = paste('@', types, '\\{', sep='')
    patterns = paste(patterns, collapse='|')
    ref_total = sum(str_detect(tolower(bibtex$V1), pattern=patterns))
    # get the DOIs
    bibtex = mutate(bibtex, V1 = str_replace_all(V1, pattern = '\\b ?doi ?=? ?(\\r|\\n)', ' doi ')) %>% # attemp to remove carraige returns
      filter(str_detect(V1, pattern='\\bdoi\\b')) %>%
      mutate(V1 = str_remove_all(V1, ',|(url|doi) ?= ?|\\t|\\{|\\}|http://dx.doi.org/|https://doi.org/'),
             V1 = str_squish(V1)) %>%
      filter(str_detect(V1, '^10\\.')) %>% # all DOIs start 10.
      unique()
    n_bibtex = nrow(bibtex)
    
    # cross-check bibtex against retractions
    cross = semi_join(retractions, bibtex, by=join_by('DOI' == 'V1'))
    n_matches = nrow(cross)
    
    # return
    to.return = list()
    to.return$n_refs = ref_total
    to.return$n_bibtex = n_bibtex
    to.return$cross = cross
    to.return$n_matches = n_matches
    
    return(to.return)
    
  }) # end of reaction function
  
  
  # make text output
  output$results <- renderText({
    text = paste('We found ', matches()$n_refs, ' references in the BibTeX file of which ', matches()$n_bibtex,' had a DOI and so could be matched with the Retraction Watch database.\n ')
    if(matches()$n_matches == 0){text = paste(text, 'There were no retracted papers.\n')}
    if(matches()$n_matches == 1){text = paste(text, 'There was 1 retracted paper.\n')}
    if(matches()$n_matches > 1){text = paste(text, 'There were ', matches()$n_matches,' retracted papers.\n', sep='')}
    text # return
  })
  
  # make table
  output$table <- renderTable(matches()$cross, striped = TRUE)
  
  
}
)
