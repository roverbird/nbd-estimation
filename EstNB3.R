# Load necessary libraries
library(nleqslv)

# Function to estimate NBD parameters using cumulative summation approach
EstNB3 <- function(X) {
  M <- mean(X)
  
  # Define function using cumulative summation to estimate 'k'
  f2 <- function(k) {
    mean(sapply(X, function(x) ifelse(x == 0, 0, sum(1 / (k + c(0:(x-1))))))) -
      log(k + mean(X)) + log(k)
  }
  
  # Solve for 'k' using numerical solver
  k. <- nleqslv(VarG(X), f2)$x
  p. <- k. / (k. + M)
  
  # Return estimated parameters
  c(p = p., k = k.)
}

# Read input data from CSV
input_file <- "input_file.csv"
data <- read.csv(input_file, header = TRUE)

# Extract the single column of values
X <- as.numeric(data[[1]])

# Estimate parameters using EstNB3
res3 <- EstNB3(X)
res3

# Plot the results
Graph(X, res3)

# Compare results from all three methods
cbind(res1, res2, res3)

