
# Load libraries ----------------------------------------------------------

library("googlesheets4")





# Load data ---------------------------------------------------------------


gs4_deauth()
books_source <- read_sheet("https://docs.google.com/spreadsheets/d/1vufdtrIzF5wbkWZUG_HGIBAXpT1C4joPx2qTh5aYzDg",
                           sheet = "books")



