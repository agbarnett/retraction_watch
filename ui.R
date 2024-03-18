# ui.R
# Shiny app to check a BibTeX file against Retraction Watch
# Mar 2024

# 
shinyUI(fluidPage(
  
  # Application title
  titlePanel(HTML(paste0("Cross-checking a BibTeX file against the ", a(href='https://retractionwatch.com/', 'Retraction Watch'), " database to find retracted papers"))),

  # add text with links to examples
  div('To run the check, upload your BibTeX file. The BibTeX file must include the DOIs and these can be as a URL or a separate DOI, but must be on a separate line. Download ', 
  a(href='refs.bib', 'refs.bib', download=NA, target="_blank"), ' for an example BibTeX file.'),

  p(' \n'), # space
    
  div('It takes a short while to upload the latest Retraction Watch database from ', a(href='https://www.crossref.org/', 'Crossref'), '.'),
  
  p(' \n'),
  
  div('If there is an error then try reloading the BibTeX file as the upload of the Retraction Watch database can sometimes fail.'),
  
  p(' \n'),
  
  # Sidebar to read in bibtex file
  sidebarLayout(
    sidebarPanel(
      
      # Input: text ----
      #textInput(inputId ="email", 
      #          label = "Your email",
      #          placeholder = 'myemail@my.org', # just use my email instead
      #          value = ''),

      # Input: Select a file ----
      fileInput(inputId ="bibtex_file", 
                label = "BibTeX file",
                multiple = FALSE,
                accept = c(".bib",'.txt'))
      
    ),
    
    # the matches
    mainPanel(
      #    
      h4("Results"),
      textOutput("results"),
      #    
      h4("Retracted paper(s):"),
      tableOutput("table")
    )
  ),
  
  # footnotes
  mainPanel(
      div("For any issues or improvements email Adrian at: ", a(href="mailto:a.barnett@qut.edu.au?subject=RetractionWatch BibTeX", "a.barnett@qut.edu.au"), ".")
  )
  
))

