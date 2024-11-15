# Based on this blog post: https://www.rostrum.blog/2020/09/21/londonmapbot/

# Load libraries ----------------------------------------------------------

library("googlesheets4")
library("bskyr")
library("dplyr")
library("tidyr")
library("stringr")

# Comment to trigger diff for testing.

# Load data ---------------------------------------------------------------

gs4_deauth()
books_source <-
  read_sheet(
    "https://docs.google.com/spreadsheets/d/1vufdtrIzF5wbkWZUG_HGIBAXpT1C4joPx2qTh5aYzDg",
    sheet = "books"
  ) %>%
  separate_rows(chapters, sep = ";") %>%
  mutate(chapters = str_trim(chapters, side = "both"))

head(books_source)

# Choose book and generate url-------------------------------------------------------------


book <- 
  
  #for testing
  # books_source %>%
  # filter(title == "A Business Analyst’s Introduction to Business Analytics") %>%
  # head(1) %>%

  
  #for production
  sample_n(books_source, 1)  %>% 
  mutate(chapters_clean = str_replace_all(str_to_lower(chapters), " ", "%20")) %>% 
  mutate(chapters_clean = str_replace_all((chapters_clean), ",", "")) %>% 
  mutate(chapters_clean = str_replace_all((chapters_clean), "  ", " ")) %>% 
  mutate(title_clean = str_replace_all(str_to_lower(title), " ", "-")) %>% 
  mutate(title_clean = str_replace_all((title_clean), ",", "")) %>% 
  mutate(title_clean = str_replace_all((title_clean), "  ", " ")) %>% 
  mutate(title_clean = str_replace_all((title_clean), "'|’", "")) %>% 
  mutate(title_clean = str_replace_all((title_clean), "&", "")) %>% 
  mutate(title_clean = str_replace_all((title_clean), ":", "")) %>% 
  mutate(url = paste0(
    "https://bigbookofr.com/chapters/",
    chapters_clean,
    ".html#",
    title_clean))

authors <-
  book %>% 
  select(contains("author")) %>% 
  purrr::flatten_chr()

#book_status = paste(book[1, "title"], "#RStats", book[1, "url"], sep="\n")

if (all(is.na(authors))) {
  book_status <-
    book %>%
    glue::glue_data("{title}
                    
                    {url}
                    #RStats")
} else {
  book_status <-
    book %>%
    glue::glue_data("{title}",
                    " by ",
                    glue::glue_collapse(na.omit(authors), sep = ", ", last = " and "),
                    "
                    #RStats
                    {url}")
  }


book_status

# Send tweet --------------------------------------------------------------

bluesky_user = Sys.getenv("BLUESKY_APP_USER")
bluesky_pass = Sys.getenv("BLUESKY_APP_PASS")

set_bluesky_user(bluesky_user)
set_bluesky_pass(bluesky_pass)


bs_post(text = book_status)
