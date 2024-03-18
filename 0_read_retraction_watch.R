# 0_read_retraction_watch.R
# read the retraction watch data from a search
# file:///C:/Users/barnetta/Downloads/Retraction%20Watch%20Database.html
# May 2019
library(dplyr)
library(stringr)
library(tidyr)

# not interested in authors or paywalled (yes/no)

## prepare lists
# list of countries (must be just this word)
country.list = c('Australia','Bangladesh','Brazil','Canada','Colombia','Chile','China','France','Grenada','Germany','Israel','India','Ireland','Italy','Japan','Kuwait','Lebanon','Hong Kong','Hungary','Macau','Morocco','Netherlands','Norway','Russia','Saudi Arabia','South Africa','Spain','Sweden','Switzerland','Taiwan','Thailand','United States','United Kingdom', 'New Zealand')
country.list = paste("^", country.list, "$", sep='')
country.list = paste(country.list, collapse='|', sep='')
# list of article types (must be just this word)
article.list = c('Conference Abstract/Paper','Review Article','Research Article','Letter','Clinical Study','Case Report','Commentary/Editorial')
article.list = paste("^", article.list, "$", sep='')
article.list = paste(article.list, collapse='|', sep='')

# read data into just one variable
# Australian data has 284 results
# cut top part of search, so first line is the first ID
raw = read.table("data/Retraction Watch Database.txt", sep='\t', skip=0, stringsAsFactors = FALSE, header=FALSE, quote = '') %>%
  mutate(var = '', # empty column that stores variable
    num.char = nchar(V1), # number of characters
    id = str_count(V1, pattern='[0-9]'), # count the number of numbers
    id = ifelse(num.char & num.char<=5, as.numeric(V1), NA), # id numbers are less than 5
    var = ifelse(is.na(id)==FALSE, 'id', var), # flag id 
    var = ifelse(is.na(lag(id))==FALSE, 'title', var), # title is straight after id
    var = ifelse(is.na(lag(id, 2))==FALSE, 'subject', var), # subject is straight after title
    var = ifelse(is.na(lag(id, 3))==FALSE, 'journal', var), # journal is next
    var = ifelse(is.na(lag(id, 4))==FALSE, 'affiliation', var), # affiliation is next
    var = ifelse(str_detect(V1, pattern='http'), 'url', var), # 
    var = ifelse(str_detect(V1, pattern=article.list), 'atype', var), # 
    var = ifelse(str_detect(V1, pattern='Retraction|Correction|Expression of Concern|Expression of concern'), 'rtype', var), # 
    var = ifelse(str_detect(V1, pattern=country.list), 'country', var), # 
    var = ifelse(str_detect(V1, pattern='10\\.') & str_detect(V1, pattern='/'), 'doi', var), # DOIs - can be multiple per paper
    var = ifelse(str_count(V1, pattern='/') ==2 & num.char == 10, 'date', var), # dates - are multiple per paper
    var = ifelse(str_detect(V1, pattern='^\\+'), 'reason', var), # reasons start with a plus
    # one edit
    V1 = ifelse(str_detect(V1, pattern='^Expression of Concern'), 'Expression of concern', V1)
  ) %>%
  select(-num.char)

# carry-forward ID number; and number dates, article types
date.num = reason.num = article.num = country.num = r.num = 0
raw$dummy = NA
for (k in 2:nrow(raw)){ 
  if(is.na(raw$id[k]) == TRUE){raw$id[k] = raw$id[k-1]}
  # number dates
  if(raw$var[k]=='date'){date.num = date.num+1; raw$var[k]=paste(raw$var[k], date.num, sep='')}
  if(date.num==2){date.num = 0} # reset as there are only two dates per paper
  # number article types
  if(raw$var[k]=='atype'){
    if(str_detect(raw$var[k-1], '^atype') ==  FALSE){article.num = 1} # if first
    if(str_detect(raw$var[k-1], '^atype') ==  TRUE){article.num = article.num + 1}
    raw$var[k]=paste(raw$var[k], article.num, sep='')
  }
  # number retraction types
  if(raw$var[k]=='rtype'){
    if(str_detect(raw$var[k-1], '^rtype') ==  FALSE){r.num = 1} # if first
    if(str_detect(raw$var[k-1], '^rtype') ==  TRUE){r.num = r.num + 1}
    raw$var[k]=paste(raw$var[k], r.num, sep='')
  }
  # number reason
  if(raw$var[k]=='reason'){
    if(str_detect(raw$var[k-1], '^reason') ==  FALSE){reason.num = 1} # if first
    if(str_detect(raw$var[k-1], '^reason') ==  TRUE){reason.num = reason.num + 1}
    raw$var[k]=paste(raw$var[k], reason.num, sep='')
  }
  # number country
  if(raw$var[k]=='country'){
    raw$dummy = (str_detect(raw$var[k-1], '^country') ==  FALSE) & (str_detect(raw$var[k-1], 'rtype') == FALSE)
    if((str_detect(raw$var[k-1], '^country') ==  FALSE) & (str_detect(raw$var[k-1], 'rtype') == FALSE)){country.num = 1} # if first
    if(str_detect(raw$var[k-1], '^country') ==  TRUE){country.num = country.num + 1}
    raw$var[k]=paste(raw$var[k], country.num, sep='')
  }
}

## switch from wide to long
wide = filter(raw, 
              var != '', 
              !str_detect('country', string=var), # saved below
              !str_detect('reason', string=var), # saved below
              var != 'doi', # not interested in DOI
              var != 'url', # not interested in URL
              var != 'id') %>% # can drop ID row %>%
  dplyr::select(id, var, V1) %>%
  spread(key=var, value=V1) %>%
  mutate(id = as.numeric(id),
         date1 = as.Date(date1, '%m/%d/%Y'),
         date2 = as.Date(date2, '%m/%d/%Y')) %>%
  rename('paper.date' = 'date1',
         'retraction.date' = 'date2')

# data set of reasons
reasons = filter(raw, str_detect(var, 'reason')) %>%
  mutate(V1 = str_remove(V1, '\\+'),
    number = as.numeric(str_remove(var, 'reason'))) %>%
  rename('reason' = 'V1') %>%
  select(id, number, reason)

# data set of countries
countries = filter(raw, str_detect(var, 'country')) %>%
  mutate(number = as.numeric(str_remove(var, 'country'))) %>%
  rename('country' = 'V1') %>%
  select(id, number, country)

## save the data
date.search = as.Date('2019-11-22')
save(reasons, countries, wide, date.search, file='data/AnalysisReady.RData')
