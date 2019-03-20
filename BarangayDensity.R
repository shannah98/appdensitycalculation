library(dplyr)

populationdata = read.csv("population.csv")
regionareadata = read.csv("regionarea.csv")

#Number of Barangays Per Region
regionareagrouped = group_by(regionareadata, Region)
brgyperregiongrouped = group_by(populationdata, Region)
brgyperregioncount = summarize(brgyperregiongrouped, NumberOfBarangays=n())
brgyperregioncount

#Combine Region, Area, and Number of Barangays
BrgyCount = merge(regionareadata, brgyperregioncount, by="Region")

#Region and Average Area of Barangay
brgyArea = BrgyCount$Area / BrgyCount$NumberOfBarangays
RegionArea=data.frame(BrgyCount,brgyArea)

#Population Data with Average Barangay Area
PopWithAveArea=merge(populationdata,RegionArea,by="Region",all.populationdata=TRUE)


#Population Density per Barangay
PopDens=PopWithAveArea$Population/PopWithAveArea$brgyArea
PopDensData=data.frame(PopWithAveArea,PopDens)

#Top 5 Population Density per Barangay
top5=arrange(PopDensData,desc(PopDensData$PopDens))
final=head(top5,5)
Top5Brgy=data.frame(Brgy=final$Barangay,PopDensity=final$PopDens)
Top5Brgy

#Saving as .CSV file
write.csv(Top5Brgy,'Top5BarangayDensity.csv')

