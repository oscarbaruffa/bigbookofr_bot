# Based on this blog post: https://www.rostrum.blog/2020/09/21/londonmapbot/

# Load libraries ----------------------------------------------------------

library("googlesheets4")
library("rtweet")
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
  
  # #for testing
  # books_source %>%
  # filter(title == "APIs for social scientists: A collaborative review") %>%
  # head(1) %>% 

  
  #for production
  sample_n(books_source, 1)  %>% 
  mutate(chapters_clean = str_replace_all(str_to_lower(chapters), " ", "-")) %>% 
  mutate(chapters_clean = str_replace_all((chapters_clean), ",", "")) %>% 
  mutate(chapters_clean = str_replace_all((chapters_clean), "  ", " ")) %>% 
  mutate(title_clean = str_replace_all(str_to_lower(title), " ", "-")) %>% 
  mutate(title_clean = str_replace_all((title_clean), ",", "")) %>% 
  mutate(title_clean = str_replace_all((title_clean), "  ", " ")) %>% 
  mutate(title_clean = str_replace_all((title_clean), "'", "")) %>% 
  mutate(title_clean = str_replace_all((title_clean), "&", "")) %>% 
  mutate(title_clean = str_replace_all((title_clean), ":", "")) %>% 
  mutate(url = paste0(
    "https://bigbookofr.com/",
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
                    
                    {url}
                    #RStats")
  }


book_status

# Send tweet --------------------------------------------------------------

# Create a token containing your Twitter keys
rbot_token <- rtweet::create_token(
  app = "BigBookofR",
  # the name of the Twitter app
  consumer_key = Sys.getenv("RBOT_TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("RBOT_TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("RBOT_TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("RBOT_TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv = FALSE
)

# Example: post a tweet via the API
# The keys are in your environment thanks to create_token()
rtweet::post_tweet(status = book_status,
                   token = rbot_token)
