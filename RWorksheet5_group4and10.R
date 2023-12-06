library(polite)
library(rvest)
library(httr)
library(dplyr)

url <- 'https://www.imdb.com/chart/toptv/?ref_=nv_tvv_250'


session <- bow(url,user_agent="Educational")
session

rank_title <- character(0)
links <- character(0)

title_list <- scrape(session) %>%
  html_nodes('h3.ipc-title__text') %>%
  html_text
class(title_list)

title_list_sub <- as.data.frame(title_list[2:51])
head(title_list_sub)

tail(title_list_sub)

colnames(title_list_sub) <- "ranks"
split_df <- strsplit(as.character(title_list_sub$ranks),".",fixed = TRUE)
split_df <- data.frame(do.call(rbind,split_df))

split_df <- split_df[-c(3:4)]

colnames(split_df) <- c("ranks","title")

str(split_df)

head(split_df)

rank_title <- data.frame(
  rank_title = split_df)
write.csv(rank_title,file = "title.csv")

link_list <- scrape(session) %>%
  html_nodes('a.ipc-title-link-wrapper') %>%
  html_attr('href')
head(link_list)

link_list[45:57]

link <- as.vector(link_list[1:50])
names(link) <- "links"
head(link)
tail(link)

for (i in 1:50) {
  link[i] <- paste0("https://imdb.com", link[i], sep = "")
}

links <- as.data.frame(link)
rank_title <- data.frame(
  rank_title = split_df, link)

scrape_df <- data.frame(rank_title,links)
names(scrape_df) <- c("Rank","Title","Link")
head(scrape_df)

write.csv(scrape_df,file = "data_top50.csv")

current_row <- 1
imdb_top_50 <- data.frame()

for (row in 1:2) {
 
  url <- links$link[current_row]
 
  session2 <- bow(url,
                  user_agent = "Educational")
  webpage <- scrape(session2)
  
  
  rating <- html_text(html_nodes(webpage, ".sc-bde20123-1.cMEQkK"))
  rating <- rating[-2]
  
  votecount <- html_text(html_nodes(webpage,'div.sc-bde20123-3.gPVQxL'))
  votecount <- votecount[-2]
 
  numof_episodes <- html_text(html_nodes(webpage,'.sc-1371769f-3.kKFedM'))
  numof_episodes <- numof_episodes[-2]
  
  year <- html_text(html_nodes(webpage,'.sc-1371769f-3.kKFedM'))
  year <- year[-2]


  cat("Rating for", url, "is:", rating, "vote count is", votecount, "number of episodes" ,numof_episodes, "\n")
  current_row <- current_row + 1
}


names(imdb_top_50) <- c("Rating","VoteCount","Description")
names(imdb_top_50)
write.csv(imdb_top_50,file = "data/imdb_top_50.csv")

imdb_top_50 <- data.frame(scrape_df,imdb_top_50)
write.csv(imdb_top_50,file = "data/imdb_top_50.csv")
