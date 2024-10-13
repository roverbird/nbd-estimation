# 1. Estimate the NBD parameters using EstNB3.
# 2. Perform the Chi-Square Goodness-of-Fit test to compare the observed frequencies of the data with the expected frequencies under the fitted NBD.
# 3. Interpret the results: A high p-value suggests the data fits the NBD well, while a low p-value (below a significance level like 0.05) suggests the data does not follow the NBD.

# Load necessary libraries
library(nleqslv)

# Function for NBD estimation using the Cumulative Sum approach
EstNB3 <- function(X) {
  M <- mean(X) # Calculate mean of the input data
  # Define the equation to estimate k parameter using cumulative summation
  f2 <- function(k) {
    mean(sapply(X, function(x) ifelse(x == 0, 0, sum(1 / (k + c(0:(x - 1))))))) - log(k + mean(X)) + log(k)
  }
  # Solve for k using non-linear equation solver
  k_est <- nleqslv(VarG(X), f2)$x
  # Estimate p parameter
  p_est <- k_est / (k_est + M)
  # Return estimated parameters in a named vector
  c(p = p_est, k = k_est)
}

# Helper function to compute initial variance guess
VarG <- function(X) {
  M <- mean(X)
  p <- M / var(X)
  return(p / (1 - p) * M)
}

# Chi-Square Goodness-of-Fit Test for NBD
ChiSquareTest_NBD <- function(X, res) {
  # Observed frequencies
  observed <- table(X)
  total <- sum(observed)
  
  # Expected frequencies under the fitted NBD
  expected <- sapply(as.numeric(names(observed)), function(j) {
    total * dnbinom(j, size = res["k"], prob = res["p"])
  })
  
  # Chi-Square test statistic
  chisq_stat <- sum((observed - expected)^2 / expected)
  
  # Degrees of freedom: (number of bins - 1 - number of parameters estimated)
  df <- length(observed) - 2
  
  # p-value from chi-square distribution
  p_value <- pchisq(chisq_stat, df, lower.tail = FALSE)
  
  # Return the test statistic and p-value
  return(list(chisq_stat = chisq_stat, p_value = p_value))
}

# Read input data from input_file.csv
input_file <- "input_file.csv"
X <- as.numeric(read.csv(input_file)$X) # Assuming the column is named 'X'

# Estimate NBD parameters using the Cumulative Sum approach (EstNB3)
res3 <- EstNB3(X)
print(paste("Estimated parameters:", "p =", res3["p"], ", k =", res3["k"]))

# Perform Chi-Square Goodness-of-Fit test
test_result <- ChiSquareTest_NBD(X, res3)
print(paste("Chi-Square Statistic:", test_result$chisq_stat))
print(paste("p-value:", test_result$p_value))

# Interpretation: If p-value > 0.05, data fits the NBD well.
if (test_result$p_value > 0.05) {
  print("The data fits the NBD distribution well (fail to reject H0).")
} else {
  print("The data does not fit the NBD distribution (reject H0).")
}

