Introduction

Dataset Overview

We utilize the boxing_matches.csv dataset, which offers detailed records of boxing matches. Each entry encompasses:

Physical Attributes: Age, height, reach, and weight of both fighters.
Performance History: Total wins, losses, draws, and knockout (KO) victories prior to each match.
Match Outcomes: Results of the fight, including decision types (e.g., KO, TKO, unanimous decision) and judges' scores.
This rich combination of physical, historical, and match-level data provides a robust foundation for analyzing the multifaceted nature of boxing competitions.

Why This Dataset?
As a passionate practitioner of both classic boxing and Thai boxing, I have a deep personal and professional connection to the sport. This dataset allows me to merge my love for
boxing with my analytical skills, offering a unique opportunity to explore and understand the factors that influence fight outcomes. By analyzing this data, I aim to uncover insights that can
enhance strategic decision-making and performance in the ring. 

ipovided a deateiled explanation of each of the columns inside of the Data_process&cleaning. i also omited few of the columns and while merging others.
for exapme i omited the weight of the boxers becuase in clasical boxing usually the boxer weight the same. again all of the explanation are with in the project.
i only took rows i have all the information. i allowed myself to do so becuase even so i have 2455 observations.

afterwards i normalized all of the numerical columns for better understanding of the ration and the effects of the features.

Data Analysis Overview
The analysis process involves several key steps to explore and visualize the boxing matches data:

Data Preparation for Plotting

A custom function, prepare_data_for_plotting, was developed to restructure selected pairs of variables. This function combines the data for each pair and removes outliers beyond three standard deviations (|z| > 3), ensuring that the density plots accurately represent the underlying distributions without being skewed by extreme values.

Density Plots

Utilizing the ggplot2 library, density plots were generated for each pair of standardized variables. By restricting the x-axis to the range of [-3, 3], the plots exclude extreme outliers, revealing that most variables exhibit near-normal distributions. The exception is the drawn variable, which deviates from normality.

Stance Distribution Analysis

The dataset was transformed from a wide to a long format to compare the stances of Boxer A and Boxer B. A grouped bar chart was created to display the count of each stance type, illustrating that the orthodox stance is predominant. This aligns with the expectation that most fighters are right-handed, favoring the orthodox position.

Decision Outcomes Visualization

Match decisions were categorized into two groups: "KO" (including KO, TD, TKO) and "POINTS" (all other decisions). A pie chart was then plotted to show the distribution between these two categories. This visualization highlights the proportion of fights ending in knockouts versus those decided by judges' scores, providing insights into the nature and excitement level of the 

Research Question
Which factors best predict the type of decision in boxing matches?

This project aims to identify and analyze the key determinants that influence whether a fight concludes by knockout (KO) or proceeds to a judges' decision (POINTS). Specifically, we examine how variations in fighters' age, height, reach, fighting stance (Orthodox vs. Southpaw), and historical performance metrics (such as past knockout victories) contribute to the outcome of matches. By understanding these factors, we seek to uncover patterns and insights that can inform strategic decisions in the sport of boxing.

Our analysis identified age difference and prior knockout (KO) victories as the most significant predictors of fight decision types. Specifically, being older than an opponent reduces the likelihood of achieving a KO, while having a higher number of previous KOs increases the probability of securing a KO in a match. Despite these insights, the logistic regression model exhibited limited predictive performance, with an AUC of 0.55, indicating that additional factors may influence fight outcomes and warrant further investigation.

Our linear regression analysis identified age and total wins as significant positive predictors of Fighter A's knockout (KO) victories, suggesting that older fighters with more victories tend to secure more KOs. Conversely, being a southpaw fighter, along with having more losses and draws, negatively impacts the number of KO wins. Interestingly, height and reach did not show a statistically significant relationship with KO counts in this model. Overall, the model explains approximately 70% of the variability in Fighter A's KO wins, highlighting the crucial roles of experience and fighting stance in determining knockout success.

Conclusion
Our analysis reveals that certain factors significantly influence the type of decision in boxing matches, distinguishing between knockouts (KO) and points-based outcomes (POINTS). Key findings include:

Age Difference: Fighters who are older relative to their opponents are less likely to achieve a KO. This suggests that experience may contribute to more strategic and less aggressive fighting styles that favor going the distance.

Prior Knockout Victories: A higher number of previous KO wins strongly correlates with an increased likelihood of securing another KO. This indicates that fighters with a proven knockout history possess the necessary skills and power to finish matches decisively.

Fighting Stance: Southpaw fighters tend to have fewer KO wins compared to their orthodox counterparts. This may reflect differences in fighting dynamics and strategies associated with different stances.

Fight Record: An extensive record of wins positively impacts KO outcomes, while more losses and draws are associated with fewer KOs. This underscores the importance of a fighter's overall performance history in predicting match results.

Physical Attributes: Contrary to common expectations, height and reach do not show a significant relationship with KO victories in this model. This suggests that other factors, such as experience and fighting style, play a more crucial role in determining knockout success.

Model Performance:
The logistic regression model achieved an Area Under the Curve (AUC) of 0.55, indicating modest discriminative ability. While the model identifies key predictors, its limited performance suggests that additional factors may influence fight outcomes and should be explored in future analyses.

Implications for Selecting a Thrilling Boxing Match
If you're seeking a thrilling boxing match, consider the following based on our findings:

Experience and Age: Matches featuring younger fighters or those with fewer losses and draws are more likely to end in knockouts, offering the high-energy, decisive outcomes that many fans find exciting.

Fighter's KO History: Fighters with a strong history of knockout victories are prime candidates for thrilling matches, as their propensity to finish fights early adds to the excitement.

Fighting Stance: While stance alone may not determine the thrill level, understanding the dynamics between orthodox and southpaw fighters can provide insights into the fight's potential unpredictability and excitement.

By focusing on these factors, you can better predict and choose boxing matches that are more likely to deliver the dramatic and engaging outcomes that make the sport so captivating.
