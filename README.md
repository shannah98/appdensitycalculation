# appdensitycalculation
## R Markdown

#Acquiring the Population Density of each City in the Philippines

##Extracting Data
###In order to acquire the answer to the problem, the package **dplyr** is needed. After running the package, we read the csv files in order to access the data frames provided.

```{r Extraction}
library(dplyr)
population=read.csv("population.csv")
regionarea=read.csv("regionarea.csv")
```

##Area per City
###Area per City was estimated by dividing the area per region by the number of cities for that region. First, the number of cities per region was calculated. Then, tables containing city count and area per region were **merged**. Lastly, area per region was divided by city count.

```{r AreaperCity}
distinct=distinct(select(population,Region,CityProvince))
by_region=group_by(distinct,Region)
citycount=summarise(by_region,count=n())
innerjoin=merge(citycount,regionarea,by.x=("Region"),by.y=("Region"))
Areapercity=mutate(innerjoin,AreaPerCity=Area/count)
```

##Population per CityProvince
###Population per CityProvince was computed by **grouping** the population table by Region and CityProvince. Then, the sum of population was taken.

```{r PopulationbyCityProvince}
distinct2=distinct(select(population,Region,CityProvince,Population))
by_CityProvince=group_by(distinct2,Region,CityProvince)
PopulationbyCityProvince=summarise(by_CityProvince,PopulationbyCity=sum(Population))
```

##Join Tables
###To make a more informative dataframe, the table from Step 2 has been combined with the table from Step 3, **Areapercity + PopulationbyCityProvince**, using the **inner_join** function where their common column is the **Region**.

```{r Joins}
innerjoin2 = inner_join(Areapercity,PopulationbyCityProvince, by = "Region", all.x=TRUE, all.y=TRUE)
```

##Final output Table
###A new column for population density was created which **divides** the Population by City by the Area Per City.

```{r FinalTable}
temptable = select(innerjoin2, Region, AreaPerCity, CityProvince, PopulationbyCity)
temptable = temptable[c(1,3,2,4)]
finaltable = mutate(temptable,PopDenCity = PopulationbyCity/AreaPerCity)
```

##Sorting for Top 5 cities
###The Population density was arranged from **highest to lowest** population density. Then the first 5 rows were selected.

```{r Top5}
FinalTable = arrange(finaltable, desc(PopDenCity))
topfive=head(FinalTable, 5)
```

##Save to CSV
###After acquiring the cities with the highest population density in the country, we’ve created a separate data frame for only the **top 5 cities** and extracting it into a ‘csv’ file using the **write.csv** function.

```{r CSVFile}
write.csv(topfive, file="Top_5_Cities")
```

###End
