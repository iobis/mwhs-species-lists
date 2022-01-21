library(xlsx)
library(dplyr)
library(taxize)
library(purrr)
library(glue)
library(stringr)
library(worrms)
library(tidyr)

# read species lists from Excel

df <- read.xlsx("species list 11jan.xlsx", 1) %>%
  setNames(c("scientificName", "site", "endemic")) %>%
  select(scientificName_original = scientificName, site, endemic) %>%
  filter(!is.na(scientificName_original) & !is.na(site))

# clean names

df <- df %>%
  mutate(scientificName_cleaned = str_replace(scientificName_original, "\\([A-Z]+\\)", "")) %>%
  mutate(scientificName_cleaned = str_replace(scientificName_cleaned, "\\[[A-Z]+\\]", "")) %>%
  mutate(scientificName_cleaned = str_trim(scientificName_cleaned))
  
# parse names using EOL's name parser

unique_cleaned_names <- unique(df$scientificName_cleaned)

if (!file.exists("parsed_names_list.Rdata")) {
  parsed_names_list <- imap(unique_cleaned_names, function(name, i) {
    message(glue("{i} - {name}"))
    gni_parse(name)
  })
  save(parsed_names_list, file = "parsed_names_list.Rdata")
} else {
  load("parsed_names_list.Rdata")
}

parsed_names <- bind_rows(parsed_names_list) %>%
  as_tibble() %>%
  filter(!is.na(genus) & !is.na(species)) %>%
  select(scientificName_cleaned = verbatim, genus, species) %>%
  mutate(scientificName_parsed = paste(genus, species))

# taxon matching

unique_parsed_names <- unique(parsed_names$scientificName_parsed)

match_name <- function(name) {
  res <- tryCatch(
    {
      wm_records_taxamatch(name, marine_only = FALSE)
    },
    error = function(e) {
      message(e)
      return(NULL)
    }
  )
  if (length(res) > 0) {
    valid <- res[[1]] %>%
      head(1) %>%
      select(valid_AphiaID, valid_name)
    if (is.na(valid$valid_AphiaID)) {
      return(NULL)
    } else {
      valid_classification <- wm_classification(valid$valid_AphiaID) %>%
        select(rank, scientificname) %>%
        spread(rank, scientificname)
      return(bind_cols(valid, valid_classification))  
    }
  } else {
    return(NULL)
  }
}

if (!file.exists("matched_names_list.Rdata")) {
  match_name_memoise <- memoise::memoise(match_name)
  matched_names_list <- imap(unique_parsed_names, function(name, i) {
    message(glue("{i} - {name}"))
    return(match_name_memoise(name))
  })
  for (i in 1:length(unique_names)) {
    if (!is.null(matched_names_list[[i]])) {
      matched_names_list[[i]]$scientificName_parsed = unique_names[i]
    }
  }
  save(matched_names_list, file = "matched_names_list.Rdata")
} else {
  load("matched_names_list.Rdata")
}

matched_names <- bind_rows(matched_names_list) %>%
  as_tibble() %>%
  select(scientificName_parsed, class = Class, order = Order, valid_AphiaID)

# combine parsed and matched names

parsed_names <- parsed_names %>%
  left_join(matched_names, by = "scientificName_parsed")

# combine lists and matched names

df <- df %>%
  left_join(parsed_names, by = "scientificName_cleaned")

# output

write.csv(df, "other_lists.csv", row.names = FALSE, na = "")
