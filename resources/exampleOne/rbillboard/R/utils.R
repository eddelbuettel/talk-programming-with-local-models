#' Export Billboard Hot 100 Chart Data to Files
#'
#' @description
#' Saves chart data to CSV and/or RDS files with timestamps in filenames.
#' Useful for storing retrieved chart data for later use or sharing.
#'
#' @param data A data frame containing chart data (from `get_hot_100()`).
#' @param date Character string in "YYYY-MM-DD" format, used for filename.
#' @param range Character string specifying the rank range used.
#' @param file_dir Directory path where files will be saved. Default NULL means no saving.
#'
#' @return An invisible value; returns the original data frame if successful.
#'
#' @export

export_hot_100 <- function(data, date, range, file_dir = NULL) {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  
  csv_path <- NULL
  rds_path <- NULL
  
  if (!is.null(file_dir)) {
    csv_path <- file.path(file_dir, paste0("hot100_", date, "_", range, "_", timestamp, ".csv"))
    rds_path <- file.path(file_dir, paste0("hot100_", date, "_", range, "_", timestamp, ".rds"))
  }
  
  # Clear old files before writing
  if (!is.null(csv_path) && file.exists(csv_path)) {
    file.remove(csv_path)
  }
  if (!is.null(rds_path) && file.exists(rds_path)) {
    file.remove(rds_path)
  }
  
  if (!is.null(csv_path)) {
    write.csv(data, csv_path, row.names = FALSE)
    message(paste("Saved CSV to:", csv_path))
  }
  
  if (!is.null(rds_path)) {
    saveRDS(data, rds_path)
    message(paste("Saved RDS to:", rds_path))
  }
  
  invisible(data)
}

