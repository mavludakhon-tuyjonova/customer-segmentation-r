# customer-segmentation-r
Customer segmentation analysis using K-Means and hierarchical clustering in R.
# Customer Segmentation Using Clustering in R

## Project Overview

This project applies unsupervised machine learning techniques to identify customer segments based on demographic and spending characteristics.

The analysis was completed as part of my Data Analytics coursework as a third-year Economics with Data Science student at the University of Cassino and Southern Lazio.

## Dataset

The analysis uses the **Customer Segmentation** dataset from Kaggle.

The main variables used for clustering are:

* Age
* Annual Income
* Spending Score

Non-numerical variables were excluded from the clustering analysis.

## Methodology

The project includes the following steps:

1. Data import and exploratory analysis
2. Missing-value checking
3. Selection of numerical variables
4. Outlier detection
5. Correlation analysis
6. Feature standardization
7. Evaluation of the number of clusters using the Elbow and Silhouette methods
8. K-Means clustering
9. Hierarchical clustering using Ward's method
10. PCA visualization
11. Comparison of clustering results
12. Interpretation of customer segments

## Methods & Tools

* R
* RStudio
* K-Means Clustering
* Hierarchical Clustering
* Principal Component Analysis (PCA)
* Data Cleaning
* Exploratory Data Analysis
* Statistical Analysis
* Data Visualization

### R Packages

* `dplyr`
* `ggplot2`
* `factoextra`
* `cluster`
* `corrplot`
* `PerformanceAnalytics`
* `tidyr`
* `NbClust`

## Project Files

* `customer_segmentation.R` — R script containing the complete analysis

## Key Learning Outcomes

This project provided practical experience in preparing data for unsupervised learning, applying different clustering techniques, visualizing clusters, comparing clustering approaches, and interpreting customer segments using R.
