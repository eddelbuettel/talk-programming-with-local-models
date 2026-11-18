# Tests for rbillboard package - using mock data from response.json
library(jsonlite)

context("rbillboard mock data tests")

# Load all test data once at context level
json_text <- paste(readLines("/home/edd/lab/rbillboard/response.json", warn = FALSE), collapse = "")
mock_response <- fromJSON(json_text)

test_that("mock response has correct structure", {
  expect_true(!is.null(mock_response$info))
  expect_true(!is.null(mock_response$content))
  expect_equal(mock_response$info$chart, "HOT 100")
})

test_that("song at rank 1 is Choosin' Texas", {
  song_list <- mock_response$content["1"]
  song <- song_list[[1]]
  expect_equal(song$rank, "1")
  expect_equal(song$title, "Choosin' Texas")
  expect_equal(song$artist, "Ella Langley")
})

test_that("song at rank 2 is Thriller by Michael Jackson", {
  song_list <- mock_response$content["2"]
  song <- song_list[[1]]
  expect_equal(song$rank, "2")
  expect_equal(song$title, "Thriller")
  expect_equal(song$artist, "Michael Jackson")
})

test_that("there are exactly 10 songs in the response", {
  # Access using numeric index since field names with spaces cause issues
  expect_equal(length(mock_response$content), 10)
})

test_that("all songs have rank field", {
  for (i in 1:10) {
    song_list <- mock_response$content[as.character(i)]
    song <- song_list[[1]]
    expect_true(!is.null(song$rank))
    expect_equal(as.character(song$rank), as.character(i))
  }
})

test_that("all songs have title and artist fields", {
  for (i in 1:10) {
    song_list <- mock_response$content[as.character(i)]
    song <- song_list[[1]]
    expect_true(!is.null(song$title))
    expect_true(!is.null(song$artist))
  }
})
