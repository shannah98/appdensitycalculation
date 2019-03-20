---
title: "Data Science Toolbox Discussion Exercise"
author: Shannah Therese Aberin, Andrea Isabel Alcala, John Christopher Galleon, Janrey
  Nevado, and Ma. Laia Valencia
date: "March 20, 2019"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Population Density per Barangay
To calculate the population density of every barangay in the Philippines, we wrote the following code with the following explanation:

## Loading the dplyr library
First, we load the dplyr package which we would use in the entire process.

```{r dplyr}
library(dplyr)
```

## Reading the needed CSV files
Second, we load the needed CSV files: "population.csv" and "regionarea.csv"

```{r population}
populationdata = read.csv("population.csv")

```

```{r regionarea}
regionareadata = read.csv("regionarea.csv")
```

## Calculating the number of barangay per region
Third, we calculate the number of barangay per region. To do this, we grouped the regiondata and populationdata data frame using group_by function. Then, we summarized the resulting data frame using all the columns from the populationdata data frame and the count of barangays per region using summarize function. We calculated the number of barangay using n() function.

```{r brgyperregioncount}
regionareagrouped = group_by(regionareadata, Region)
brgyperregiongrouped = group_by(populationdata, Region)
brgyperregioncount = summarize(brgyperregiongrouped, NumberOfBarangays=n())

```
## Merging regiondata data frame and number of barangay per region
Fourth, we merged the regionareadata data frame with the data frame (brgyperregioncount) we generated in the previous step using the "Region"" column with merge function.

```{r BrgyCount}
BrgyCount = merge(regionareadata, brgyperregioncount, by="Region")
```

## Calculating the average area of barangay per region
Fifth, we calculated the average area of barangay by dividing the values of the area column of the combined data frame (BrgyCount) from the previous step by the number of barangay per region we calculated from the third step.

```{r brgyArea}
brgyArea = BrgyCount$Area / BrgyCount$NumberOfBarangays
```
## Combining the Region, Area, number of barangay per region, and the average area of barangay per region in a single data frame
Sixth, we combined the data frame we generated from the fourth step (BrgyCount) and average area of barangay per region with data.frame function.

```{r RegionArea}
RegionArea=data.frame(BrgyCount,brgyArea)
```

## Merging populationdata data frame and the data frame generated from previous step
Seventh, we merged (esssentially a left join) the populationdata data frame with the data frame that we generated from the previous step (RegionArea) using the "Region" column with merge function.

```{rPopWithAveArea}
PopWithAveArea=merge(populationdata,RegionArea,by="Region",all.populationdata=TRUE)
```
## Calculating the population density per barangay
Eighth, we calculated the population density per barangay by dividing the values of the "Population" column from the recently combined data frame (PopAveArea) from the previous step by the values of "brgyArea" column from the same data frame.

```{r PopDens}
PopDens=PopWithAveArea$Population/PopWithAveArea$brgyArea
```

## Combining the data frame generated from the seventh step and the calculated population density from the previous step.
Ninth, we combined the "PopWithAveArea" data frame and the population density calculated from the previous step using data.frame function.

```{r PopDensData}
PopDensData=data.frame(PopWithAveArea,PopDens)
```

## Sorting the final data frame in descending order
Tenth, we arranged the final data frame in descending order using arrange function to easily display the top five barangays in the next step.

```{r top5}
top5=arrange(PopDensData,desc(PopDensData$PopDens))
```

## Displaying the top five rows from the output of the previous code
Eleventh, we used head function to display the top five rows of the output from the previous code.

```{r final}
final=head(top5,5)
```

## Displaying the final data frame
Twelfth, we used the values of "Barangay" column from the data frame generated from the previous step and the values "PopDens" column from the same data frame that contains the population density per barangay to generate the final data frame to be displayed.

```{r Top5Brgy}
Top5Brgy=data.frame(Brgy=final$Barangay,PopDensity=final$PopDens)
Top5Brgy
```

## Saving the final output as comma separated values (CSV) file
Finally, we used the write.csv function to save the final data frame (Top5Brgy) as a CSV file with the title "Top5BarangayDensity"

```{r Top5Brgy CSV}
write.csv(Top5Brgy,'Top5BarangayDensity.csv')
```


# Acquiring the Population Density of each City in the Philippines

## Extracting Data
### In order to acquire the answer to the problem, the package **dplyr** is needed. After running the package, we read the csv files in order to access the data frames provided.

```{r Extraction}
library(dplyr)
population=read.csv("population.csv")
regionarea=read.csv("regionarea.csv")
```

## Area per City
### Area per City was estimated by dividing the area per region by the number of cities for that region. First, the number of cities per region was calculated. Then, tables containing city count and area per region were **merged**. Lastly, area per region was divided by city count.

```{r AreaperCity}
distinct=distinct(select(population,Region,CityProvince))
by_region=group_by(distinct,Region)
citycount=summarise(by_region,count=n())
innerjoin=merge(citycount,regionarea,by.x=("Region"),by.y=("Region"))
Areapercity=mutate(innerjoin,AreaPerCity=Area/count)
```

## Population per CityProvince
### Population per CityProvince was computed by **grouping** the population table by Region and CityProvince. Then, the sum of population was taken.

```{r PopulationbyCityProvince}
distinct2=distinct(select(population,Region,CityProvince,Population))
by_CityProvince=group_by(distinct2,Region,CityProvince)
PopulationbyCityProvince=summarise(by_CityProvince,PopulationbyCity=sum(Population))
```

## Join Tables
### To make a more informative dataframe, the table from Step 2 has been combined with the table from Step 3, **Areapercity + PopulationbyCityProvince**, using the **inner_join** function where their common column is the **Region**.

```{r Joins}
innerjoin2 = inner_join(Areapercity,PopulationbyCityProvince, by = "Region", all.x=TRUE, all.y=TRUE)
```

## Final output Table
### A new column for population density was created which **divides** the Population by City by the Area Per City.

```{r FinalTable}
temptable = select(innerjoin2, Region, AreaPerCity, CityProvince, PopulationbyCity)
temptable = temptable[c(1,3,2,4)]
finaltable = mutate(temptable,PopDenCity = PopulationbyCity/AreaPerCity)
```

## Sorting for Top 5 cities
### The Population density was arranged from **highest to lowest** population density. Then the first 5 rows were selected.

```{r Top5}
FinalTable = arrange(finaltable, desc(PopDenCity))
topfive=head(FinalTable, 5)
```

## Save to CSV
### After acquiring the cities with the highest population density in the country, we’ve created a separate data frame for only the **top 5 cities** and extracting it into a ‘csv’ file using the **write.csv** function.

```{r CSVFile}
write.csv(topfive, file="Top_5_Cities")
```

### End
