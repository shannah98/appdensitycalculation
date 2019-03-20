library(dplyr)
population=read.csv("population.csv")
regionarea=read.csv("regionarea.csv")

#Area per City
distinct=distinct(select(population,Region,CityProvince))
by_region=group_by(distinct,Region)
citycount=summarise(by_region,count=n())
innerjoin=merge(citycount,regionarea,by.x=("Region"),by.y=("Region"))
Areapercity=mutate(innerjoin,AreaPerCity=Area/count)

#Population per CityProvince
distinct2=distinct(select(population,Region,CityProvince,Population))
by_CityProvince=group_by(distinct2,Region,CityProvince)
PopulationbyCityProvince=summarise(by_CityProvince,PopulationbyCity=sum(Population))

#Join Tables
innerjoin2 = inner_join(Areapercity,PopulationbyCityProvince, by = "Region", all.x=TRUE, all.y=TRUE)

#Final output Table
temptable = select(innerjoin2, Region, AreaPerCity, CityProvince, PopulationbyCity)
temptable = temptable[c(1,3,2,4)]

finaltable = mutate(temptable,PopDenCity = PopulationbyCity/AreaPerCity)

#Sorting for Top 5 cities
FinalTable = arrange(finaltable, desc(PopDenCity))
topfive=head(FinalTable, 5)

#Save to CSV
write.csv(topfive, file="Top_5_Cities")
