#' Get Billboard Hot 100 Chart Data
#'
#' @description
#' Fetches the Billboard Hot 100 chart data for a given date and rank range.
#' The function uses the RapidAPI Billboard API endpoint.
#'
#' @param date Character string in "YYYY-MM-DD" format (e.g., "2026-11-10").
#'   This represents the week ending on that date.
#' @param range Character string specifying the rank range (e.g., "1-10" for
#'   top 10, or "1-100" for full chart).
#' @param file_dir Character string specifying directory path where CSV and RDS
#'   files will be written if `save_file = TRUE`. If NULL, files are not saved.
#' @param save_file Logical, default FALSE. If TRUE, saves the result to both
#'   a `.csv` and `.rds` file with timestamp in filename.
#'
#' @return A data frame containing chart data with columns: rank, title, artist,
#'   weeks_at_no.1, last_week, peak_position, weeks_on_chart, detail.
#'   Each row corresponds to one song at the given rank.
#'
#' @export
#'
#' @examples
#' # Fetch top 10 songs for a given week (requires RAPIDAPI_KEY set)
#' \dontrun{
#' data <- get_hot_100(date = "2026-11-10", range = "1-10")
#' head(data)
#' }

get_hot_100 <- function(date, range, file_dir = NULL, save_file = FALSE) {
  # TODO: Consider rate limiting - add delay between requests or use caching
  
  url <- paste0("https://billboard-api2.p.rapidapi.com/hot-100?date=", date, "&range=", range)
  
  headers <- list(
    "x-rapidapi-host" = "billboard-api2.p.rapidapi.com",
    "x-rapidapi-key" = Sys.getenv("RAPIDAPI_KEY", "")
  )
  
  # Check if API key is provided
  api_key <- Sys.getenv("RAPIDAPI_KEY", "")
  if (nchar(api_key) == 0) {
    stop("RAPIDAPI_KEY environment variable is not set. Please set it before calling this function.")
  }
  
  # Make the request using httr
  req <- httr::GET(url, .headers = headers)
  
  # Check for HTTP errors
  if (httr::http_error(req)) {
    status <- httr::status_code(req)
    stop(paste("API request failed with status", status, ":", conditionMessage(httr::http_response(req))))
  }
  
  # Parse JSON response using jsonlite
  raw_json_text <- httr::content(req, "text")
  response_json <- jsonlite::fromJSON(raw_json_text)
  
  # Extract content from API response structure
  chart_data <- response_json$content
  
  # The API returns songs as named keys ("1", "2", etc.) - convert to proper structure
  # Each song entry has fields: rank, title, artist, weeks at no.1, last week,
  # peak position, weeks on chart, detail
  
  song_list <- list()
  for (key in names(chart_data)) {
    song_entry <- chart_data[[key]]
    
    # Convert all character values to integers where appropriate
    rank_int <- as.integer(song_entry$rank)
    weeks_at_no1 <- if (!is.na(song_entry$`weeks at no.1`)) as.integer(song_entry$`weeks at no.1`) else NA
    peak_pos <- if (!is.na(song_entry$`peak position`)) as.integer(song_entry$`peak position`) else NA
    last_week_num <- if (!is.na(song_entry$last_week)) as.integer(as.character(song_entry$last_week)) else NA
    weeks_on_chart <- if (!is.na(song_entry$`weeks on chart`)) as.integer(song_entry$`weeks on chart`) else NA
    
    song_list[[length(song_list) + 1]] <- data.frame(
      rank = rank_int,
      title = song_entry$title,
      artist = song_entry$artist,
      weeks_at_no_1 = weeks_at_no1,
      last_week = ifelse(is.na(last_week_num), "", sprintf("%d", last_week_num)),
      peak_position = peak_pos,
      weeks_on_chart = weeks_on_chart,
      detail = song_entry$detail,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }
  
  # Combine into single data frame and reorder columns
  result <- do.call(rbind, song_list)
  colnames(result) <- c("rank", "title", "artist", "weeks_at_no_1", "last_week", "peak_position", "weeks_on_chart", "detail")
  result <- result[order(result$rank), ]
  
  # Save to files if requested
  if (save_file && !is.null(file_dir)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    csv_path <- file.path(file_dir, paste0("hot100_", date, "_", range, "_", timestamp, ".csv"))
    rds_path <- file.path(file_dir, paste0("hot100_", date, "_", range, "_", timestamp, ".rds"))
    
    if (file.exists(csv_path)) file.remove(csv_path)
    if (file.exists(rds_path)) file.remove(rds_path)
    
    write.csv(result, csv_path, row.names = FALSE)
    saveRDS(result, rds_path)
    
    message(paste("Data saved to CSV:", csv_path))
    message(paste("Data saved to RDS:", rds_path))
  }
  
  return(result)
}
