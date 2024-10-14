#!/usr/local/bin/Rscript

# This script performs the Cramér-von Mises goodness-of-fit test to assess how well
# a sample of values fits a specified negative binomial distribution. 
# It takes input values as a comma-separated string, along with estimated parameters
# (n and p) of the negative binomial distribution, and outputs the p-value of the test.
# A p-value greater than a specified significance level (typically 0.05) indicates
# that the sample does not significantly differ from the fitted distribution.

library("optparse")
library("dgof", warn.conflicts = FALSE)

# Create an option parser to handle command line arguments
options_parser = OptionParser(
    option_list=list(
        make_option("--values", default=NULL),  # Comma-separated values to be tested
        make_option("--n", default=NULL),       # Estimated parameter n of negative binomial
        make_option("--p", default=NULL)        # Estimated parameter p of negative binomial
    )
)

# Parse the command line arguments
options = parse_args(options_parser)

# Split the comma-separated values, convert them to numeric
values <- strsplit(options$values, split=",")
values <- as.numeric(unlist(values))

# Convert estimated parameters n and p to numeric
n_est <- as.numeric(options$n)
p_est <- as.numeric(options$p)

# Perform the Cramér-von Mises test
# The test compares the empirical distribution of the input values to the fitted
# negative binomial distribution specified by parameters n_est and p_est.
cvm_output <- invisible(cvm.test(values, ecdf(rnbinom(1000, prob=p_est, size=n_est)), type="W2"))

# Output the p-value of the goodness-of-fit test
cat(cvm_output$p.value)

