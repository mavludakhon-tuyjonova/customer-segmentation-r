# ***********************************************************
# Clustering Analysis – Customer Segmentation
# 0097921_Tuyjonova.R
# Dataset: vjchoudhary7/customer-segmentation-tutorial-in-python
# ***********************************************************



# 0: Listed of required packages ----------------------------------------------
#  Installed the RKaggle package
install.packages("RKaggle")
library(RKaggle)
packages <- c(
  "ggplot2",              # Visualization
  "factoextra",           # PCA and clustering visualization
  "dplyr",                # Data manipulation
  "corrplot",             # Correlation plots
  "PerformanceAnalytics", # Correlograms
  "cluster",              # Clustering algorithms & silhouette
  "tidyr",                # Data cleaning (if needed)
  "scales",               # Scaling and normalization utilities
  "NbClust"               # To determine optimal number of clusters
)

# Installed missing packages
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Loaded necessary libraries
library("ggplot2")
library("factoextra")
library("dplyr")
library("corrplot")
library("PerformanceAnalytics")
library("cluster")
library("tidyr")
library("scales")
library("NbClust")
#----------------------------------------------------------------------------




# 1: Dataset imported using RKaggle ------------------------------------ 
dataset_id <- "vjchoudhary7/customer-segmentation-tutorial-in-python" 
df <- get_dataset(dataset_id)                                         
#--------------------------------------------------------------------




# 2: Provided a summary and showed the first 10 observations-------------- 
str(df)
colnames(df)
summary(df)
head(df, 10)
#---------------------------------------------------------------------




# 3: Check for missing values and impute or delete if necessary-------- 
colSums(is.na(df)) #no missing values 
#---------------------------------------------------------------------





# 4: Select only numerical variables and exclude non-numeric ones----------
# Remove non-numeric columns (CustomerID, Gender)
df_num <- df %>%select(-CustomerID, -Gender)
str(df_num)

# 4.1: Detected potential outliers 
#Identified outliers numerically using the IQR method
outlier_detection <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  sum(x < lower_bound | x > upper_bound)
}

sapply(df_num, outlier_detection)

# Checked for outliers using boxplots for each numeric variable
boxplot(df_num, main = "Boxplots for Numeric Features", col = c("pink", "purple", "yellow"))

# Checked correlation between numeric variables
cor_matrix <- cor(df_num)
corrplot(cor_matrix, method = "color", type = "upper",
         tl.col = "purple", tl.srt = 45,
         title = "Correlation Matrix of Numeric Variables")

# correlogram
chart.Correlation(df_num, histogram = TRUE, pch = 19)
#--------------------------------------------------------------------------





# 5: Normalize / Scale numeric data -------------------------
df_scaled <- scale(df_num)
# Check new summary
summary(df_scaled)
#-------------------------------------------------------------





# 6: Determined the optimal number of clusters using the ELBOW method---------
set.seed(67)
wss <- numeric(10)
for (k in 1:10) {
  kmeans_result <- kmeans(df_scaled, centers = k, nstart = 10)
  wss[k] <- sum(kmeans_result$withinss)
}

# Basic Elbow Plot
plot(1:10, wss, type = "b", pch = 12, frame = FALSE,
     xlab = "Number of Clusters (k)",
     ylab = "Within-Cluster Sum of Squares (WSS)",
     main = "Elbow Method for Optimal k")

# Version with ggplot just in case
ggplot(data.frame(k = 1:10, wss = wss), aes(x = k, y = wss)) +
  geom_line(color = "blue") +
  geom_point(size = 3, color = "red") +
  labs(title = "Elbow Method for Optimal Clusters",
       x = "Number of Clusters (k)",
       y = "Within-Cluster Sum of Squares") +
  theme_minimal()


# SILHOUETTE Method
fviz_nbclust(df_scaled, kmeans, method = "silhouette") +
  labs(subtitle = "Silhouette Method for Optimal k")
#--------------------------------------------------------------------------






# 7: Applied K-Means Clustering ---------------------------------------------
# Choosed the number of clusters from my Elbow result
k_optimal <- 5  

# Runned K-means
set.seed(67)  # ensures reproducibility
final_kmeans <- kmeans(df_scaled, centers = k_optimal, nstart = 25)

# Added cluster labels to my original (unscaled) data
df$Cluster <- as.factor(final_kmeans$cluster)

# Viewed first few rows to confirm cluster assignment
head(df)

# Checked how many customers belong to each cluster
table(df$Cluster)

#PCA visualization for K-MEANS clusters
fviz_pca_biplot(prcomp(df_scaled),
                geom = "point",
                habillage = df$Cluster,
                addEllipses = TRUE,
                ellipse.level = 0.95)
#--------------------------------------------------------------------------






# 8: Hierarchical Clustering -----------------------------------------------
#  Computed distance matrix
dist_matrix <- dist(df_scaled, method = "euclidean")

#  Performed hierarchical clustering
hc <- hclust(dist_matrix, method = "ward.D2")

#  Plotted the dendrogram
plot(hc,
     main = "Hierarchical Clustering Dendrogram",
     xlab = "",
     sub = "",
     cex = 0.6)

#  Added colored rectangles to show 5 clusters
rect.hclust(hc, k = 5, border = c("red", "blue", "green", "purple", "orange"))

#   Cutted the tree into the same number of clusters as K-means (e.g. 5)
hc_clusters <- cutree(hc, k = 5)

#   Added cluster info to my dataframe
df$HC_Cluster <- as.factor(hc_clusters)

#   PCA visualization for Hierarchical Clusters
fviz_pca_biplot(prcomp(df_scaled),
                geom = "point",
                habillage = df$HC_Cluster,
                addEllipses = TRUE,
                ellipse.level = 0.95,
                title = "PCA Biplot – Hierarchical Clusters")
#----------------------------------------------------------------------------







# 9:Compared clustering results using a contingency table --------------------
comparison_table <- table(KMeans = df$Cluster, Hierarchical = df$HC_Cluster)
print(comparison_table)
#---------------------------------------------------------------------------








# 10: Interpreted the Clusters (Main Characteristics) ------------------------
aggregate(df[, c("Age", "Annual Income (k$)", "Spending Score (1-100)")],
          by = list(Cluster = df$Cluster),
          mean)

# Create a summary for ggplot visualization
cluster_summary <- df %>%
  group_by(Cluster) %>%
  summarise(
    Age = mean(Age),
    Annual_Income = mean(`Annual Income (k$)`),
    Spending_Score = mean(`Spending Score (1-100)`)
  )

# Visualize feature means per cluster
cluster_summary_long <- cluster_summary %>%
  pivot_longer(cols = -Cluster, names_to = "Variable", values_to = "Mean_Value")

ggplot(cluster_summary_long, aes(x = Variable, y = Mean_Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  coord_flip() +
  labs(
    title = "Average Values per Cluster",
    x = "",
    y = "Mean (Original Scale)"
  ) +
  theme(legend.position = "bottom")
#---------------------------------------------------------------------------


