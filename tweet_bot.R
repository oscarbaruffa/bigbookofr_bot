
# Load libraries ----------------------------------------------------------

library("googlesheets4")
library("rtweet")
library("dplyr")
library("tidyr")
library("stringr")




# Load data ---------------------------------------------------------------


gs4_deauth()
books_source <- read_sheet("https://docs.google.com/spreadsheets/d/1vufdtrIzF5wbkWZUG_HGIBAXpT1C4joPx2qTh5aYzDg",
                           sheet = "books") %>% 
  separate_rows(chapters, sep = ";")




# Choose book and generate url-------------------------------------------------------------


book <- sample_n(books_source, 1) %>% 
  mutate(url = paste0("https://bigbookofr.com/",
                      str_replace_all(str_to_lower(chapters), " ", "-"),
                      ".html#",
                      str_replace_all(str_to_lower(title), " ", "-")))




# Send tweet --------------------------------------------------------------


# 
# Create a token containing your Twitter keys
rtweet::create_token(
  app = "BigBookofR",  # the name of the Twitter app
  consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Example: post a tweet via the API
# The keys will are in your environment thanks to create_token()
rtweet::post_tweet(status = "Hello, world5")
