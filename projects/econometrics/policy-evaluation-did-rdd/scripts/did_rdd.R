# =============================================================================
# Policy evaluation: difference-in-differences and regression discontinuity
# Bipin Joshi — MSc Agricultural Economics, Humboldt-Universität zu Berlin
# Data: course datasets "ag_data.xlsx" and "rdd_data.xlsx" (not redistributed)
# =============================================================================

library(readxl)
library(dplyr)
library(ggplot2)
library(fixest)     # two-way fixed effects, event study
library(rdrobust)   # local-polynomial RD estimation
library(rddensity)  # manipulation (density) test

# ---------------------------------------------------------------------------
# PART A: Difference-in-differences (district panel, policy starts 2010)
# ---------------------------------------------------------------------------
ag_data <- read_excel("ag_data.xlsx", sheet = 1)

# Checks: one row per district-year; treatment status constant within district
ag_data %>% count(district, year) %>% summarise(max_n = max(n), min_n = min(n))
ag_data %>% group_by(district) %>% summarise(k = n_distinct(treated)) %>% count(k)
ag_data %>% count(year, post)

# TWFE DiD with district-clustered standard errors
did_twfe <- feols(yield ~ treated * post | district + year,
                  data = ag_data, cluster = ~ district)
summary(did_twfe)

# Parallel-trends check: average yield by group and year
ag_data %>%
  group_by(year, treated) %>%
  summarise(mean_yield = mean(yield), .groups = "drop") %>%
  ggplot(aes(year, mean_yield, colour = factor(treated))) +
  geom_line() + geom_point() + theme_minimal()

# Event study (reference year: 2009)
ag_data <- ag_data %>% mutate(rel_time = year - 2010)
es <- feols(yield ~ i(rel_time, treated, ref = -1) | district + year,
            data = ag_data, cluster = ~ district)
summary(es)
iplot(es, xlab = "Years relative to policy (2010 = 0)")

# ---------------------------------------------------------------------------
# PART B: Sharp RDD (fertiliser subsidy for farms of up to 2 hectares)
# ---------------------------------------------------------------------------
rdd <- read_excel("rdd_data.xlsx", sheet = "Sheet1")
C <- 2

rdplot(y = rdd$yield, x = rdd$land_size, c = C)

# Main estimate: MSE-optimal bandwidth, robust bias-corrected inference
rd_main <- rdrobust(y = rdd$yield, x = rdd$land_size, c = C)
summary(rd_main)

# Bandwidth sensitivity
rd_small <- rdrobust(y = rdd$yield, x = rdd$land_size, c = C, h = 0.25)
rd_large <- rdrobust(y = rdd$yield, x = rdd$land_size, c = C, h = 0.75)
summary(rd_small); summary(rd_large)

# Manipulation test: is there bunching of farms just below 2 ha?
dens <- rddensity(X = rdd$land_size, c = C)
summary(dens)
