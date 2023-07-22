library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(tidyverse)
library(gridExtra)

# gets the z scores. 
get_z_scores <- function(col) {
  avg <- mean(col)
  sd <- sd(col)
  z_scores <- list()
  for(i in 1:length(col)) {
    z_scores[i] <- (col[i] - avg) / sd
  }
  return(unlist(z_scores))
}

# a list of cities to be analyzed
cities <- c("London", "Barcelona", "Madrid", "Amsterdam", "Geneva", "Lisbon",
            "Vancouver", "Toronto", "New York", "San Franscisco",
            "Singapore", "Wellington", "Auckland", "Sydney", "Melbournne",
            "Buenos Aires", "Bogota", "Rio de Janeiro", "Sao Paulo")


# a list of corresponding regions 
regions <- c(rep("Europe", 6), rep("North America", 4), rep("Asia", 5), rep("South America", 4))


# 1) Wikepedia - km2 - https://www.wikipedia.org/
population_density <- get_z_scores(c(5598, 16000, 5337, 4908, 12000, 5445.7,
                                     5749, 4427.8, 10194, 6655.4,
                                     7804, 900, 1210, 2037, 503.472,
                                     13680, 17755, 5377, 7216.3))

# 2) Numbeo - Average Monthly Net Salary (After Tax) USD - https://www.numbeo.com/cost-of-living/city_price_rankings?itemId=105
average_wage <- get_z_scores(c(4238.68, 2039.94, 2804.49, 4195.81, 6171.96, 1247,
                               3288.54, 3356.11, 6530.28, 6133.08,
                               5117.62, 2644.28, 3326.10, 4109.44, 3465.38,
                               403.17, 364.45, 399.80, 491.76))

# 3) Numbeo - Cost of Living Index - https://www.numbeo.com/cost-of-living/rankings_current.jsp
cost_of_living <- get_z_scores(c(85.5, 59.2, 53.9, 69.9, 116.4, 53.7,
                                 73.9, 73.0, 100.0, 97.7,
                                 87.3, 76.2, 79.2, 82.4, 80.3,
                                 30.0, 29.7, 42.3, 44.1))

# 4) HUGSI - global ranking - https://www.hugsi.green/ranking
green <- get_z_scores(c(91, 96, 239, 233, 53, 95,
                        105, 110, 242, 256,
                        213, 84, 188, 180, 203,
                        264, 267, 134, 211))

# 5) Worldwide Governance Indicators - 2020 Estimate - z scores - https://info.worldbank.org/governance/wgi/
government <- get_z_scores(c(1.38, 0.89, 0.89, 1.85, 2.02, 1.02,
                             1.64, 1.64, 1.32, 1.32,
                             2.34, 1.59, 1.59, 1.62, 1.62,
                             -0.22, 0.04,-0.447, -0.447))

# 6) Numbeo - Safety Index 2023 - https://www.numbeo.com/crime/rankings.jsp
saftey <- get_z_scores(c(46.1, 49.3, 72.5, 70.9, 69.4, 66.9,
                         59.1, 57.3, 50.5, 38.6,
                         76.9, 66.5, 50.7, 65.7, 56.0,
                         36.8, 33.8, 22.4, 29.4))

# 7) Numbeo - pollution index 2023 - https://www.numbeo.com/pollution/rankings.jsp
pollution <- get_z_scores(c(57.7, 65.2, 40.0, 25.1, 25.5, 27.7,
                            26.6, 37.2, 57.9, 50.2,
                            33.0, 22.8, 31.0, 30.5, 28.4,
                            52.4, 70.2, 67.4, 79.0))

# 8) Wikepedia - cities by sunshine duration - https://en.wikipedia.org/wiki/List_of_cities_by_sunshine_duration
sunshine <- get_z_scores(c(1633, 2591, 2769, 1662, 1887, 2806,
                           1937.6, 2066.4, 2534.7, 3061.7,
                           2022.4, 2058.7, 2003.1, 2468.1, 2362.6,
                           2525.2, 1328.0, 2187.3, 1893.5))

# 9) the global economy - Political stability index - https://www.theglobaleconomy.com/rankings/wb_political_stability/
stability <- get_z_scores(c(0.54, 0.58, 0.58, 0.92, 1.13, 0.95,
                            0.94, 0.94, 0, 0,
                            1.49, 1.44, 1.44, 0.85, 0.85,
                            -0.11, -0.91, -0.49, -0.49))


# make bad things negative
population_density <- -population_density
cost_of_living <- -cost_of_living
pollution <- -pollution


# times the most important (psychological/mental health based) factors by 3
adjusted_population_density <- population_density*3
adjusted_green <- green*3
adjusted_pollution <- pollution*3


# times the next most important factors by 2
adjusted_saftey <- saftey*2
adjusted_government <- government*2
adjusted_stability <- stability*2


# a list of non-adjusted indicators to be averaged for a total score (categories plots)
indicators <- c("population_density", "average_wage", "cost_of_living", 
                "green", "government", "saftey", 
                "pollution", "sunshine", "stability")


# a list of adjusted indicators to be averaged for a total score (total score and total score regions plots)
adjusted_indicators <- c("adjusted_population_density", "average_wage", "cost_of_living", 
                         "adjusted_green", "adjusted_government", "adjusted_saftey", 
                         "adjusted_pollution", "sunshine", "adjusted_stability")


# returns the row averages of multiple columns. 
get_avg <- function(z_scores) {
  measures = tibble(z_scores = character())
  for(i in 1:length(z_scores)) {
    measures[i,] = z_scores[i]
  }
  measure_length <- nrow(measures)
  row_length <- length(eval(parse(text=z_scores[1])))
  
  data <- tibble(city=cities)
  for(i in 1:measure_length) {
    data[,i+1] <- eval(parse(text=z_scores[i]))
  }
  avg <- list()
  for(i in 1:row_length) {
    avg[i] <- rowMeans(data[i,-1])
  }
  return(unlist(avg))
}


# creates a dataframe of the non-adjusted data. 
df <- tibble("City" = cities,
             "Region" = regions,
             "Population Density" = population_density,
             "Average Wage" = average_wage,
             "Cost of Living" = cost_of_living,
             "Green" = green,
             "Government" = government,
             "Saftey" = saftey,
             "Pollution" = pollution,
             "Sunishine" = sunshine,
             "Stability" = stability,
             "Total" = get_avg(indicators))


# creates a dataframe of the adjusted data. 
adjusted_df <- tibble("City" = cities,
                      "Region" = regions,
                      "Population Density" = adjusted_population_density,
                      "Average Wage" = average_wage,
                      "Cost of Living" = cost_of_living,
                      "Green" = adjusted_green,
                      "Government" = adjusted_government,
                      "Saftey" = adjusted_saftey,
                      "Pollution" = adjusted_pollution,
                      "Sunishine" = sunshine,
                      "Stability" = adjusted_stability,
                      "Total" = get_avg(adjusted_indicators))


# creates a personal theme for data visualization. 
my_theme <- theme_economist_white(gray_bg = FALSE) +
  theme(plot.title = element_text(hjust = 0.5,
                                  vjust = 10,
                                  size = 10,
                                  color = "#474747"),
        plot.margin = unit(c(1.5, 1, 1.5, 1), "cm"),
        axis.text = element_text(size = 9,
                                 color = "gray30"),
        axis.text.x=element_text(vjust = -2.5),
        axis.title.x = element_text(size = 9,
                                    color = "gray30",
                                    vjust = -10),
        axis.title.y = element_text(size = 9,
                                    color = "gray30",
                                    vjust = 10),
        legend.direction = "vertical", 
        legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 10,
                                   color = "gray20"),
        legend.margin=margin(0, 0, 0, 0),
        legend.spacing.x = unit(0.5, "cm"),
        legend.key.size = unit(0.25, "cm"), 
        legend.key.height = unit(0.25, "cm"),
        strip.text = element_text(hjust = 0.5,
                                  vjust = 1,
                                  size = 10,
                                  color = "#474747"),
        panel.spacing = unit(2, "lines"))


# total score 
adjusted_df %>%
  ggplot(aes(x = reorder(City, -Total), y=Total, fill = "red")) +
  geom_bar(stat = "identity", position = "dodge") +
  ggtitle("Overall score") +
  ylab("Standardized Score") +
  my_theme + 
  theme(axis.title.x=element_blank(),
        legend.position="none",
        axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))



# total score regions
adjusted_df %>%
  ggplot(aes(x = City, y = Total, fill = City)) +
  geom_bar(stat = "identity", position = "dodge") +
  ggtitle("Regions") +
  ylab("Standardized Score") +
  facet_wrap(~Region, scales = "free_x", ncol=1) +
  my_theme + 
  theme(axis.title.x=element_blank(),
        axis.text.x = element_blank())





# categories Asia 
p1 <- df %>%
  filter(Region == "Asia") %>%
  ggplot(aes(x = City, y = Total, fill = City)) +
  geom_bar(stat = "identity", position = "dodge") +
  ggtitle("Asia") +
  ylab("Standardized Score") +
  ylim(-2, 2) +
  my_theme + 
  theme(axis.title.x=element_blank(),
        axis.text.x = element_blank())
 

# categories Europe 
p2 <- df %>%
  filter(Region == "Europe") %>%
  ggplot(aes(x = City, y = Total, fill = City)) +
  geom_bar(stat = "identity", position = "dodge") +
  ggtitle("Europe") +
  ylab("Standardized Score") +
  ylim(-2, 2) +
  my_theme + 
  theme(axis.title.x=element_blank(),
        axis.text.x = element_blank())


# categories North America 
p3 <- df %>%
  filter(Region == "North America") %>%
  ggplot(aes(x = City, y = Total, fill = City)) +
  geom_bar(stat = "identity", position = "dodge") +
  ggtitle("North America ") +
  ylab("Standardized Score") +
  ylim(-2, 2) +
  my_theme + 
  theme(axis.title.x=element_blank(),
        axis.text.x = element_blank())


# categories South America 
p4 <- df %>%
  filter(Region == "South America") %>%
  ggplot(aes(x = City, y = Total, fill = City)) +
  geom_bar(stat = "identity", position = "dodge") +
  ggtitle("South America ") +
  ylab("Standardized Score") +
  ylim(-2, 2) +
  my_theme + 
  theme(axis.title.x=element_blank(),
        axis.text.x = element_blank())


grid.arrange(p1, p2, p3, p4)



