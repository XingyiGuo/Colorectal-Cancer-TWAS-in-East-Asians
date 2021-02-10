library(sqldf) 
R2 <- "CRC_Asian_models.csv"
Weight <- "CRC_Asian_weights.csv"
dbfile <- "CRC_Asian.db"
db <- dbConnect(SQLite(), dbname= dbfile)
dbWriteTable(conn = db, name = "extra", value = R2, row.names = FALSE, header = TRUE)
dbWriteTable(conn = db, name = "weights", value = Weight,row.names = FALSE, header = TRUE)