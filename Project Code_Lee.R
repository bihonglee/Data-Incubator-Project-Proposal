# Plot 2 (Code)
# Did minimal data cleaning in Excel 
UScounty_Commute <- read_excel("CountyCommutingFlow.xlsx", sheet = 1, na = "NA")


DCmetro <- UScounty_Commute %>%
  subset(County_Residence == "District of Columbia" | State_Residence == "Maryland" & County_Residence == "Calvert County" |
           State_Residence == "Maryland" & County_Residence == "Charles County" | State_Residence == "Maryland" & County_Residence == "Frederick County" |
           State_Residence == "Maryland" & County_Residence == "Montgomery County" | State_Residence == "Maryland" & County_Residence == "Prince George's County" |
           State_Residence == "Virginia" & County_Residence == "Arlington County" | State_Residence == "Virginia" & County_Residence == "Clarke County" |
           State_Residence == "Virginia" & County_Residence == "Fairfax County" | State_Residence == "Virginia" & County_Residence == "Fauquier County" |
           State_Residence == "Virginia" & County_Residence == "Loudoun County" | State_Residence == "Virginia" & County_Residence == "Prince William County" |
           State_Residence == "Virginia" & County_Residence == "Spotsylvania County" | State_Residence == "Virginia" & County_Residence == "Stafford County" |
           State_Residence == "Virginia" & County_Residence == "Warren County" | State_Residence == "Virginia" & County_Residence == "Alexandria city" |
           State_Residence == "Virginia" & County_Residence == "Fairfax city" | State_Residence == "Virginia" & County_Residence == "Falls Church city"|
           State_Residence == "Virginia" & County_Residence == "Fredericksburg city" | State_Residence == "Virginia" & County_Residence == "Manassas city" |
           State_Residence == "Virginia" & County_Residence == "Manassas Park city" | State_Residence == "Virginia" & County_Residence == "Culpeper County" |
           State_Residence == "Virginia" & County_Residence == "Rappahannock County" | State_Residence == "West Virginia" & County_Residence == "Jefferson County")

names(DCmetro) <- c("State_FIPS_Residence", "County_FIPS_Residence", "State_USisland_ForeignCode_Work", "County_FIPS_Work", "Number", "MOE", "State_Residence", "County_Residence", "State_Usisland_Foreign_Work", "County_Work")

table(DCmetro$County_Residence)

# Grouping: 1) Working & living in the same county, 2) Working in DC & living outside of DC, 3) working & living in different counties
DCmetro$workingliving <- ifelse(DCmetro$County_Residence == "District of Columbia" & DCmetro$County_Work == "District of Columbia", DCmetro$Number,
                                ifelse(DCmetro$County_Residence == "Calvert County" & DCmetro$County_Work == "Calvert County", DCmetro$Number, 
                                       ifelse(DCmetro$County_Residence == "Charles County" & DCmetro$County_Work == "Charles County", DCmetro$Number, 
                                              ifelse(DCmetro$County_Residence == "Frederick County" & DCmetro$County_Work == "Frederick County", DCmetro$Number, 
                                                     ifelse(DCmetro$County_Residence == "Montgomery County" & DCmetro$County_Work == "Montgomery County", DCmetro$Number, 
                                                            ifelse(DCmetro$County_Residence == "Prince George's County"& DCmetro$County_Work == "Prince George's County", DCmetro$Number, 
                                                                   ifelse(DCmetro$County_Residence == "Arlington County" & DCmetro$County_Work == "Arlington County", DCmetro$Number, 
                                                                          ifelse(DCmetro$County_Residence == "Clarke County" & DCmetro$County_Work == "Clarke County", DCmetro$Number, 
                                                                                 ifelse(DCmetro$County_Residence == "Fairfax County" & DCmetro$County_Work == "Fairfax County", DCmetro$Number, 
                                                                                        ifelse(DCmetro$County_Residence == "Fauquier County" & DCmetro$County_Work == "Fauquier County", DCmetro$Number, 
                                                                                               ifelse(DCmetro$County_Residence == "Loudoun County" & DCmetro$County_Work == "Loudoun County", DCmetro$Number, 
                                                                                                      ifelse(DCmetro$County_Residence == "Prince William County" & DCmetro$County_Work == "Prince William County", DCmetro$Number, 
                                                                                                             ifelse(DCmetro$County_Residence == "Spotsylvania County"& DCmetro$County_Work == "Spotsylvania County", DCmetro$Number, 
                                                                                                                    ifelse(DCmetro$County_Residence == "Stafford County"& DCmetro$County_Work == "Stafford County", DCmetro$Number, 
                                                                                                                           ifelse(DCmetro$County_Residence == "Warren County" & DCmetro$County_Work =="Warren County", DCmetro$Number, 
                                                                                                                                  ifelse(DCmetro$County_Residence == "Alexandria city"& DCmetro$County_Work == "Alexandria city", DCmetro$Number, 
                                                                                                                                         ifelse(DCmetro$County_Residence == "Fairfax city" & DCmetro$County_Work == "Fairfax city", DCmetro$Number,
                                                                                                                                                ifelse(DCmetro$County_Residence == "Falls Church city" & DCmetro$County_Work == "Falls Church city", DCmetro$Number, 
                                                                                                                                                       ifelse(DCmetro$County_Residence == "Fredericksburg city" & DCmetro$County_Work == "Fredericksburg city", DCmetro$Number,
                                                                                                                                                              ifelse(DCmetro$County_Residence == "Manassas city" & DCmetro$County_Work == "Manassas city", DCmetro$Number, 
                                                                                                                                                                     ifelse(DCmetro$County_Residence == "Manassas Park city" & DCmetro$County_Work == "Manassas Park city", DCmetro$Number, 
                                                                                                                                                                            ifelse(DCmetro$County_Residence == "Culpeper County" & DCmetro$County_Work == "Culpeper County", DCmetro$Number, 
                                                                                                                                                                                   ifelse(DCmetro$County_Residence == "Rappahannock County" & DCmetro$County_Work == "Rappahannock County", DCmetro$Number, 
                                                                                                                                                                                          ifelse(DCmetro$County_Residence == "Jefferson County" & DCmetro$County_Work == "Jefferson County", DCmetro$Number, 0
                                                                                                                                                                                          ))))))))))))))))))))))))

DCmetro$workingDC_fromOut <- ifelse(DCmetro$County_Residence != "District of Columbia" & DCmetro$County_Work == "District of Columbia", DCmetro$Number, 0)

DCmetro$working_OtherCounties <-
  ifelse(DCmetro$County_Residence != "Calvert County" & DCmetro$County_Work == "Calvert County", DCmetro$Number, 
         ifelse(DCmetro$County_Residence != "Charles County" & DCmetro$County_Work == "Charles County", DCmetro$Number, 
                ifelse(DCmetro$County_Residence != "Frederick County" & DCmetro$County_Work == "Frederick County", DCmetro$Number, 
                       ifelse(DCmetro$County_Residence != "Montgomery County" & DCmetro$County_Work == "Montgomery County", DCmetro$Number, 
                              ifelse(DCmetro$County_Residence != "Prince George's County"& DCmetro$County_Work == "Prince George's County", DCmetro$Number, 
                                     ifelse(DCmetro$County_Residence != "Arlington County" & DCmetro$County_Work == "Arlington County", DCmetro$Number, 
                                            ifelse(DCmetro$County_Residence != "Clarke County" & DCmetro$County_Work == "Clarke County", DCmetro$Number, 
                                                   ifelse(DCmetro$County_Residence != "Fairfax County" & DCmetro$County_Work == "Fairfax County", DCmetro$Number, 
                                                          ifelse(DCmetro$County_Residence != "Fauquier County" & DCmetro$County_Work == "Fauquier County", DCmetro$Number, 
                                                                 ifelse(DCmetro$County_Residence != "Loudoun County" & DCmetro$County_Work == "Loudoun County", DCmetro$Number, 
                                                                        ifelse(DCmetro$County_Residence != "Prince William County" & DCmetro$County_Work == "Prince William County", DCmetro$Number, 
                                                                               ifelse(DCmetro$County_Residence != "Spotsylvania County"& DCmetro$County_Work == "Spotsylvania County", DCmetro$Number, 
                                                                                      ifelse(DCmetro$County_Residence != "Stafford County"& DCmetro$County_Work == "Stafford County", DCmetro$Number, 
                                                                                             ifelse(DCmetro$County_Residence != "Warren County" & DCmetro$County_Work =="Warren County", DCmetro$Number, 
                                                                                                    ifelse(DCmetro$County_Residence != "Alexandria city"& DCmetro$County_Work == "Alexandria city", DCmetro$Number, 
                                                                                                           ifelse(DCmetro$County_Residence != "Fairfax city" & DCmetro$County_Work == "Fairfax city", DCmetro$Number,
                                                                                                                  ifelse(DCmetro$County_Residence != "Falls Church city" & DCmetro$County_Work == "Falls Church city", DCmetro$Number, 
                                                                                                                         ifelse(DCmetro$County_Residence != "Fredericksburg city" & DCmetro$County_Work == "Fredericksburg city", DCmetro$Number,
                                                                                                                                ifelse(DCmetro$County_Residence != "Manassas city" & DCmetro$County_Work == "Manassas city", DCmetro$Number, 
                                                                                                                                       ifelse(DCmetro$County_Residence != "Manassas Park city" & DCmetro$County_Work == "Manassas Park city", DCmetro$Number, 
                                                                                                                                              ifelse(DCmetro$County_Residence != "Culpeper County" & DCmetro$County_Work == "Culpeper County", DCmetro$Number, 
                                                                                                                                                     ifelse(DCmetro$County_Residence != "Rappahannock County" & DCmetro$County_Work == "Rappahannock County", DCmetro$Number, 
                                                                                                                                                            ifelse(DCmetro$County_Residence != "Jefferson County" & DCmetro$County_Work == "Jefferson County", DCmetro$Number, 0
                                                                                                                                                            )))))))))))))))))))))))

# Calculating County's Ratio between the number of residents working in the county and the number of non-resident working in the county
DCmetro <- DCmetro %>%
  subset(State_Usisland_Foreign_Work %in% c("District of Columbia", "Maryland", "Virginia"))

DCmetro_cleaned <- DCmetro %>%
  subset(workingliving != 0 | workingDC_fromOut != 0 | working_OtherCounties != 0)

typeof(DCmetro_cleaned$workingDC_fromOut)

DCmetro_cleaned$workingliving <- as.numeric(DCmetro_cleaned$workingliving) 
DCmetro_cleaned$workingDC_fromOut <- as.numeric(DCmetro_cleaned$workingDC_fromOut)
DCmetro_cleaned$working_OtherCounties <- as.numeric(DCmetro_cleaned$working_OtherCounties)

table(is.na(DCmetro_cleaned$workingliving))

DCmetro_cleaned$Residents_num <- apply(DCmetro_cleaned[, c("workingliving", "workingDC_fromOut", "working_OtherCounties")], 1, sum)

Myvars <- names(DCmetro_cleaned) %in% c ("State_FIPS_Residence", "County_FIPS_Residence", "State_USisland_ForeignCode_Work", "County_FIPS_Work", "Number", "MOE", "State_Residence", "County_Residence", "State_Usisland_Foreign_Work", "County_Work","workingliving", "workingDC_fromOut", "working_OtherCounties", "Residents_num")

DCmetro_cleaned2 <- DCmetro_cleaned[Myvars]

Total_residents <- DCmetro_cleaned2 %>%
  group_by(County_Residence) %>%
  summarize(County_total_residents = sum(Residents_num))

DCmetro_cleaned3 <- merge(x= DCmetro_cleaned2, y=Total_residents, by.x = "County_Residence", by.y= "County_Residence")

DCmetro_cleaned3$workingliving_differentcounty <- ifelse(DCmetro_cleaned3$workingliving != 0, DCmetro_cleaned3$County_total_residents - DCmetro_cleaned3$workingliving, NA)
DCmetro_cleaned3$Dependency_ratio <- ifelse(DCmetro_cleaned3$workingliving != 0, DCmetro_cleaned3$workingliving_differentcounty/DCmetro_cleaned3$County_total_residents, NA)

Summary <- DCmetro_cleaned3 %>%
  subset(Dependency_ratio != "NA")

ggplot(Summary) +
  geom_bar(mapping = aes(x = County_Residence, y = Dependency_ratio), stat = "identity", color = "steelblue", fill = "steelblue") +
  ggtitle("Dependency Ratio for the workforce in the Washington DC MSA") +
  labs(x = "counties with DC metro area", y = "Proportion of residents going to other counties") +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))