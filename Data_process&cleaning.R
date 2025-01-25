####libraries and instalations ----

install.packages("tidyverse")
install.packages("ggdist")
install.packages("ggplot2")
install.packages("patchwork")


library(tidyverse)
library(ggdist)
library(dplyr)
library(ggplot2)


set.seed(123)


#### short explanation on the dataset and why i chose it ----

# The boxing_matches.csv dataset provides a comprehensive record of boxing matches, focusing on the physical
# characteristics, performance history, and outcomes of the competitors.
# Each row represents a single match and includes details about the two boxers (A and B), the match results,
# and the judges' scores.
# This dataset combines physical, historical, and match-level data, making it a powerful resource for
# exploring the multifaceted world of boxing analytics
# As a passionate boxer who practices both classic boxing and thai boxing,
# I have a deep personal and professional connection to the world of boxing. This dataset allows me to
# merge my love for the sport with my analytical skills, offering a unique opportunity to explore the
# intricacies of boxing at a detailed level

# age_A / age_B: The age of Boxer A / Boxer B at the time of the match.
# height_A / height_B: The height of Boxer A / Boxer B, centimeters.
# reach_A / reach_B: The reach of Boxer A / Boxer B, typically the distance from fingertip to fingertip when arms are extended.
# stance_A / stance_B: The fighting stance of Boxer A / Boxer B (e.g., orthodox, southpaw).
# weight_A / weight_B: The weight of Boxer A / Boxer B at the time of the match, pounds.
# won_A / won_B: The total number of matches won by Boxer A / Boxer B before this fight.
# lost_A / lost_B: The total number of matches lost by Boxer A / Boxer B before this fight.
# drawn_A / drawn_B: The total number of matches that ended in a draw for Boxer A / Boxer B before this fight.
# kos_A / kos_B: The number of matches Boxer A / Boxer B has won by knockout before this fight.
# result: The result of the match, indicating which boxer won (e.g., "A", "B", or "draw").
# decision: The type of decision that determined the result (e.g., "KO", "TKO", "unanimous decision").
# judge_A / judge_B: The score given to Boxer A / Boxer B by the Judge, see we have 3 of them.

#### Data processing and cleaning ----
df <- read_csv("boxing_matches.csv")

# Drop all columns containing "judge"
df <- df %>% select(-matches("judge"))

# only taking observation when they weight the same, this is generally the case in professional boxing.
df <- df[df$weight_A == df$weight_B, ]
df <- df %>% select(-matches("weight"))

#omiting result
df <- df %>% select(-matches("result"))


# only taking rows i have all the information. i allowed myself to do so becuase even so i have 2455 observations.
df <- df[complete.cases(df), ]

# Normalize each pair of columns (e.g., height_A and height_B)
normalize_by_pair <- function(df, col_pair) {
  # Combine values from both columns
  combined_values <- c(df[[col_pair[1]]], df[[col_pair[2]]])
  
  # Calculate mean and standard deviation of the combined values
  combined_mean <- mean(combined_values)
  combined_sd <- sd(combined_values)
  
  # Normalize each column using the combined mean and standard deviation
  df[[col_pair[1]]] <- (df[[col_pair[1]]] - combined_mean) / combined_sd
  df[[col_pair[2]]] <- (df[[col_pair[2]]] - combined_mean) / combined_sd
  
  return(df)
}

# Specify the column pairs to normalize
column_pairs <- list(
  c("height_A", "height_B"),
  c("age_A",    "age_B"),
  c("reach_A", "reach_B"),
  c("won_A",    "won_B"),
  c("lost_A",   "lost_B"),
  c("drawn_A",  "drawn_B"),
  c("kos_A",    "kos_B")
  
)

# Apply normalization for each pair
for (pair in column_pairs) {
  df <- normalize_by_pair(df, pair)
}


# at the end of this stage ill have the normalized version of my dataset.


#### Data Preview ----

prepare_data_for_plotting <- function(df, column_pairs) {
  # Create an empty dataframe to store combined data
  combined_data <- data.frame(value = numeric(), 
                              group = character(), 
                              pair  = character())
  
  # Loop through each pair and add data
  for (pair in column_pairs) {
    # Combine data for the current pair
    data_to_add <- data.frame(
      value = c(df[[pair[1]]], df[[pair[2]]]),
      group = rep(pair, each = nrow(df)),
      pair  = paste(pair[1], "vs", pair[2])
    )
    # Append to the combined dataframe
    combined_data <- rbind(combined_data, data_to_add)
  }
  
  return(combined_data)
}

# 5. Prepare data for plotting
plot_data <- prepare_data_for_plotting(df, column_pairs)

# 6. Load libraries
library(ggplot2)
library(RColorBrewer)

# 7. Create a combined plot with facets for each pair
#    Restrict the x-axis to [-3, 3] using scale_x_continuous().
ggplot(plot_data, aes(x = value, fill = group)) +
  geom_density(alpha = 0.5) + 
  facet_wrap(~ pair, scales = "free") +
  labs(
    title = "Distributions of Variable Pairs (Standardized)",
    x = "Z-Score Value",
    y = "Density",
    fill = "Group"
  ) +
  scale_fill_brewer(palette = "Set2") +
  scale_x_continuous(limits = c(-3, 3)) +  # Exclude data outside [-3, 3]
  theme_minimal()

# after omitting the outliers (those that have |z| > 3 we can see that all the variables except the drawn are almost normal.)


# 1. Pivot df to long format
plot_data <- df %>%
  pivot_longer(
    cols = c("stance_A", "stance_B"),
    names_to = "stance_type",     # indicates whether it's 'stance_A' or 'stance_B'
    values_to = "stance"          # the actual stance value
  )

# 2. Count the number of occurrences of each stance in stance_A vs stance_B
plot_data_count <- plot_data %>%
  count(stance_type, stance)

# 3. Create a grouped bar chart
ggplot(plot_data_count, aes(x = stance, y = n, fill = stance_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Distribution of Stances for A vs. B",
    x = "Stance",
    y = "Count",
    fill = "Stance Type"
  ) +
  theme_minimal()

# we can see that there is no difference between them.
# orthodox is more common because most of people are right handed.

# now ide like to present the decisions.

# 1. Create a new column `decision_group` with two categories:
#    - "KO" (for original decisions KO, TD, TKO)
#    - "POINTS" (for all other decisions)
df <- df %>%
  mutate(
    decision_group = case_when(
      decision %in% c("KO", "TD", "TKO") ~ "KO",
      TRUE ~ "POINTS"
    )
  )

# 2. Count how many rows fall into each group
df_group_counts <- df %>% 
  count(decision_group)

# 3. Plot a pie chart showing the distribution of KO vs. POINTS
ggplot(df_group_counts, aes(x = "", y = n, fill = decision_group)) +
  geom_col(width = 1) +
  coord_polar("y", start = 0) +  # Converts the bar chart to a pie chart
  labs(
    title = "Distribution of Decision Groups (KO vs POINTS)",
    fill  = "Decision Group"
  ) +
  theme_void()  # Removes axes and adds a cleaner look for a pie chart

#explanatio of boxing decisions

# KO (Knockout): The loser is rendered unable to continue by strikes.
# TKO (Technical Knockout): The referee/corner stops the fight due to a fighter’s inability to safely continue.
# TD (Technical Draw / Decision): The fight ends early (often due to an accidental injury), and the outcome is decided on partial scorecards or ruled a draw.
# DQ (Disqualification): A fighter is disqualified for fouls or unsportsmanlike conduct.
# MD (Majority Decision): Two judges score the fight for one boxer, the third scores it a draw (2–0–1).
# SD (Split Decision): Two judges favor one boxer, the third favors the other (2–1).
# UD (Unanimous Decision): All judges favor the same boxer (3–0).
# PTS (Points): A fight decided by judges’ scores after going the distance (commonly used in some regions).
# RTD (Retired): A boxer (or their corner) chooses not to continue between rounds.
# NWS (Newspaper Decision): An older, unofficial scoring method used historically when official decisions weren’t rendered.


# I grouped KO, TD, and TKO together as "KO" because these all imply a
# stoppage or knockout-like outcome—this is often more dramatic and
# could be considered an “interesting” finish.
# Everything else is grouped into "POINTS", which generally indicates
# a fight decided by the judges (e.g., UD, SD, MD, PTS)—sometimes considered
# less “exciting” from a casual fan’s perspective than a knockout, but still
# a valid outcome.
# The goal is to see how many fights end in a knockout (KO) vs. go to
# the scorecards (POINTS), which can help gauge how “interesting” or
# explosive the fights might be.

write.csv(df, "df_saved.csv", row.names = FALSE)



#### Formulate the question ----

# Which factors best predict the type of decision?
  

# For example: “Are fights more likely to end by KO when one fighter’s height or reach is significantly greater than the other’s?”
# Does age difference influence the likelihood of a finish (KO) vs. going to the judges (POINTS)?
#   
# For example: “Are younger fighters more likely to win by KO, while older fighters go the distance more often?”
# How does stance (Orthodox vs. Southpaw) affect fight outcomes?
#   
# For example: “Is there an association between stance type and the type of decision (KO vs. POINTS)?”
# Do a fighter’s past KOs predict the fight’s outcome type?
#   
# For example: “Does a fighter with a higher number of KO wins have a significantly greater chance of achieving another KO?”

# and if i try to conclude all of them to one question - "Which factors best predict the type of decision" and this will be my question.



