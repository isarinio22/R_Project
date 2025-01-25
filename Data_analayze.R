#### libraries and installations -----
# load the df
df <- read.csv("df_saved.csv")

#libraries
install.packages(c("broom", "ggplot2"))
installed.packages("ggplot")
install.packages("glmnet")
install.packages("pROC")


# Load libraries
library(broom)
library(ggplot2)
library(dplyr)
library(glmnet)
library(pROC)


# adding the diffrences
df$age_diff    <- df$age_A    - df$age_B
df$height_diff <- df$height_A - df$height_B
df$reach_diff  <- df$reach_A  - df$reach_B
df$kos_diff    <- df$kos_A    - df$kos_B
df$dec_bin <- ifelse(df$decision_group == "KO", 1, 0)
#### Logistic regression ----
x <- model.matrix(dec_bin ~ age_diff + height_diff + reach_diff + kos_diff, data = df)[, -1]
y <- df$dec_bin

# Fit a logistic model with L1 penalty (lasso)
fit_lasso <- glmnet(x, y, family = "binomial", alpha = 1)

# Cross-validate to choose best lambda
cv_lasso <- cv.glmnet(x, y, family = "binomial", alpha = 1)

# Best lambda
best_lambda <- cv_lasso$lambda.min

# Final model at that lambda
final_lasso <- glmnet(x, y, family = "binomial", alpha = 1, lambda = best_lambda)
coef(final_lasso)

"intercept - The negative intercept (-0.393) indicates a below-50% baseline probability of KO
when both fighters are equal in age, height, reach, and KOs"

"The negative coefficient for age_diff (-0.718) shows that if Fighter A is older by one standard
deviation, the odds of a KO decrease."

"The small negative effect for height_diff (-0.129) suggests a slight drop in KO odds when Fighter
A is taller."

"The small positive coefficient for reach_diff (0.032) implies that a greater reach for
Fighter A very slightly raises the likelihood of a KO"

"Finally, kos_diff (0.118) is moderately positive, meaning that if Fighter A has more KO wins by one standard deviation, the odds of getting a KO
in this fight increase."

# transform lasso to logistic regression
lasso_coefs <- coef(final_lasso)

# Convert to numeric vector (they're in a sparse format)
coef_values <- as.numeric(lasso_coefs)

# Get row names for each coefficient (variable name)
coef_names <- rownames(lasso_coefs)

# Find which coefficients are nonzero
nonzero_idx <- which(coef_values != 0)

# Get the names, excluding the intercept
selected_vars <- coef_names[nonzero_idx]
selected_vars <- setdiff(selected_vars, "(Intercept)")

# Build a formula string like "dec_bin ~ age_diff + kos_diff" etc.
formula_str <- paste("dec_bin ~", paste(selected_vars, collapse = " + "))

# Convert that string to an R formula
model_formula <- as.formula(formula_str)

# Fit a standard logistic regression using glm()
model_selected <- glm(model_formula, data = df, family = binomial(link = "logit"))

# Check summary (includes p-values, standard errors, etc.)
summary(model_selected)


# Overall, age_diff and kos_diff show the strongest associations (both highly significant):
#   
# Being older than your opponent reduces KO probability,
# Having more previous KOs raises KO probability.


# visualization.
df$pred_prob <- predict(model_selected, type = "response")

# Create ROC object
roc_obj <- roc(df$dec_bin, df$pred_prob)

# Plot the ROC curve
plot(roc_obj, 
     main = "ROC Curve for Logistic Regression Model", 
     col = "blue", 
     lwd = 2)

# Calculate and add AUC to the plot
auc_value <- auc(roc_obj)
legend("bottomright", legend = paste("AUC =", round(auc_value, 3)), col = "blue", lwd = 2)

threshold <- 0.5
df$pred_class <- ifelse(df$pred_prob > threshold, 1, 0)

# Create confusion matrix
conf_matrix <- table(Actual = df$dec_bin, Predicted = df$pred_class)
print(conf_matrix)

# # Interpretation:
# # High Specificity (96.92%): Your model is very good at correctly identifying POINTS outcomes (Actual 0) as 0.
# # Low Recall (3.94%): The model struggles significantly to identify KO outcomes (Actual 1). Only about 4%
# of actual KOs are correctly predicted.  Moderate Precision (47.62%): When the model predicts a KO (1),
# it's correct about 48% of the time.   Overall Accuracy (58.47%): Slightly better than random guessing (50%)
# but not particularly strong.
# # F1-Score (7.36%): This low score indicates poor balance between precision and recall, especially for
# the positive class (KO).

####Linear regression ----

# 1) Ensure stance_A is a factor
df$stance_A <- as.factor(df$stance_A)

# 2) Fit a simple linear regression
model_kos_A <- lm(kos_A ~ age_A + height_A + reach_A + stance_A + won_A + lost_A + drawn_A,
                  data = df)

# 3) Inspect the summary
summary(model_kos_A)

# 4) Check residuals, diagnostic plots
par(mfrow = c(2, 2))
plot(model_kos_A)

# **(Intercept) = 0.044375 (p = 0.00118 )
# 
# Meaning: When all predictors are zero (i.e., Fighter A and Fighter B are identical in age, height, reach, stance, and fight record), the baseline number of KO wins for Fighter A is approximately 0.044.
# Interpretation: While the intercept has statistical significance, its practical interpretation should be cautious since having all predictors at zero may not be meaningful in the real-world context.
# **Age (age_A) = 0.769688 (p < 2e-16 *)
# 
# Meaning: For each one-unit increase in Fighter A's age (standardized), the number of KO wins increases by approximately 0.77, holding all other factors constant.
# Significance: Highly significant (***) indicating a strong positive relationship between age and KO wins.
# Height (height_A) = 0.001201 (p = 0.94791)
# 
# Meaning: For each one-unit increase in Fighter A's height (standardized), the number of KO wins increases by 0.0012, which is negligible.
# Significance: Not statistically significant, suggesting no meaningful relationship between height and KO wins in this model.
# Reach (reach_A) = 0.025360 (p = 0.26531)
# 
# Meaning: For each one-unit increase in Fighter A's reach (standardized), the number of KO wins increases by 0.025, holding other variables constant.
# Significance: Not statistically significant, indicating no strong evidence of a relationship between reach and KO wins.
# **Stance (stance_Asouthpaw) = -0.122879 (p = 6.54e-06 *)
# 
# Meaning: Being a southpaw fighter (as opposed to the reference category, typically orthodox) is associated with a decrease of approximately 0.123 KO wins.
# Significance: Highly significant (***) suggesting that stance type has a meaningful impact on KO wins.
# **Wins (won_A) = 0.865661 (p < 2e-16 *)
# 
# Meaning: For each one-unit increase in Fighter A's total wins, the number of KO wins increases by approximately 0.866, holding other factors constant.
# Significance: Highly significant (***) indicating a strong positive relationship between total wins and KO wins.
# **Losses (lost_A) = -0.121459 (p = 1.86e-08 *)
# 
# Meaning: For each one-unit increase in Fighter A's total losses, the number of KO wins decreases by approximately 0.121, holding other factors constant.
# Significance: Highly significant (***) suggesting that more losses are associated with fewer KO wins.
# **Draws (drawn_A) = -0.208203 (p < 2e-16 *)
# 
# Meaning: For each one-unit increase in Fighter A's total draws, the number of KO wins decreases by approximately 0.208, holding other factors constant.
# Significance: Highly significant (***) indicating that more draws are associated with fewer KO wins.
# 
# Multiple R-squared = 0.7031
# 
# Meaning: Approximately 70.31% of the variability in Fighter A's KO wins is explained by the model.

# Significant Positive Predictors:
#   
#   Age (age_A): Older fighters tend to have more KO wins.
# Wins (won_A): Fighters with more overall wins also accumulate more KO wins.
# Significant Negative Predictors:
#   
#   Stance (stance_Asouthpaw): Being a southpaw fighter is associated with fewer KO wins compared to the reference stance.
# Losses (lost_A) and Draws (drawn_A): More losses and draws are associated with fewer KO wins.
# Non-Significant Predictors:
#   
#   Height (height_A) and Reach (reach_A): These attributes do not have a statistically significant relationship with the number of KO wins in this model.
# Model Performance:
#   
#   The model explains a substantial portion (~70%) of the variance in Fighter A's KO wins, indicating it captures key factors influencing KO success.
# Implications
# Age and Experience Matter: Older fighters and those with more wins are more likely to have higher KO counts, suggesting experience and perhaps power accumulation play significant roles.
# 
# Stance Impact: Southpaw fighters have fewer KO wins compared to their counterparts, which could be due to various strategic or matchup-related factors.
# 
# Record Indicators: Losses and draws negatively impact KO counts, potentially reflecting overall skill or effectiveness in securing knockouts.
# 
# Physical Attributes Less Impactful: Contrary to some expectations, height and reach do not significantly predict KO wins in this model, indicating that other factors like experience and stance might be more crucial.


# Tidy the model to extract estimates and confidence intervals
tidy_model <- tidy(model_kos_A, conf.int = TRUE)
tidy_model_no_intercept <- tidy_model %>%
  filter(term != "(Intercept)")

ggplot(tidy_model_no_intercept, aes(x = estimate, y = term)) +
  geom_point(size = 3, color = "blue") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2, color = "gray") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Effect of Predictors on Fighter A's KO Wins",
    x = "Estimated Coefficient",
    y = "Predictor Variables"
  ) +
  theme_minimal()


