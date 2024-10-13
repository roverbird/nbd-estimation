# Load necessary libraries
library(nleqslv)

# Function to estimate NBD parameters using digamma functions
EstNB2 <- function(X) {
  M <- mean(X)
  
  # Define function for digamma-based estimation of 'k'
  f1 <- function(k) {
    sum(digamma(k + X)) / length(X) - digamma(k) + log(k) - log(k + mean(X))
  }
  
  # Solve for 'k' using numerical solver and digamma function
  k. <- nleqslv(VarG(X), f1)$x
  p. <- k. / (k. + M)
  
  # Return estimated parameters
  c(p = p., k = k.)
}

# Read input data from CSV
input_file <- "input_file.csv"
data <- read.csv(input_file, header = TRUE)

# Extract the single column of values
X <- as.numeric(data[[1]])

# Estimate parameters using EstNB2
res2 <- EstNB2(X)
res2

# Plot the results
Graph(X, res2)

