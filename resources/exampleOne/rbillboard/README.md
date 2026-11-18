# rbillboard

An R package for accessing the Billboard Music API via RapidAPI.

## Installation

```r
install.packages("rbillboard")  # From CRAN if available
```

Or install from source:

```r
devtools::install_local("/path/to/rbillboard")
```

## Usage

```r
library(rbillboard)

# Get top 10 songs (requires RAPIDAPI_KEY environment variable)
data <- get_hot_100(date = "2026-11-14", range = "1-10")
head(data)

# Export to files
export_hot_100(data, date = "2026-11-14", range = "1-10", file_dir = ".")
```

## License

GPL (>= 2)
