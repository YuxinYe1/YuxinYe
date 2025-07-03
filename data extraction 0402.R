install.packages("XML")
library(XML)
install.packages("xml2")  # 安装xml2包（如果尚未安装）
library(xml2) 

file_path <- "D:/Cornell University/Capstone/DATA/WCM_2025_Capstone_AdjustedD20250328235201+0000.xml"
xml_data <- read_xml(file_path)

#Use XPath to extract specific data
studies <- xml_find_all (xml_data, ".//Study")

#Getting the root node
root_node <- xml_root (xml_data)
print(xml_name(root_node))

#Retrieve all namespaces
namespaces <- xml_ns(xml_data)

#Use namespaces to query the ClinicalData node
ClinicalData_node <- xml_find_all(root_node, ".//d1:ClinicalData", ns=namespaces)

# Initialize a list to collect data
extracted_data_list <- list()
index <- 1

# Loop through all SubjectData nodes
subject_data_nodes <- xml_find_all(ClinicalData_node, ".//d1:SubjectData", ns = namespaces)
for (subject_node in subject_data_nodes) {
  subject_key <- xml_attr(subject_node, "SubjectKey", default = NA)
  sex <- xml_attr(subject_node, "Sex", default = NA)
  
  # Debug: Check if subject_key and sex are correctly assigned
  print(paste("SubjectKey:", subject_key, "Sex:", sex))
  
  # Loop through each SubjectData's StudyEventData nodes
  study_event_data_nodes <- xml_find_all(subject_node, ".//d1:StudyEventData", ns = namespaces)
  for (event_node in study_event_data_nodes) {
    subject_age_at_event <- xml_attr(event_node, "SubjectAgeAtEvent", default = NA)
    study_event_repeat_key <- xml_attr(event_node, "StudyEventRepeatKey", default = NA)
    start_date <- xml_attr(event_node, "StartDate", default = NA)
    
    # Debug: Check if event-related variables are correctly assigned
    print(paste("SubjectAgeAtEvent:", subject_age_at_event, "StartDate:", start_date))
    
    # Loop through each StudyEventData's FormData nodes
    form_data_nodes <- xml_find_all(event_node, ".//d1:FormData", ns = namespaces)
    for (form_node in form_data_nodes) {
      # Loop through each FormData's ItemGroupData nodes
      item_group_data_nodes <- xml_find_all(form_node, ".//d1:ItemGroupData", ns = namespaces)
      for (item_group_node in item_group_data_nodes) {
        # Loop through each ItemGroupData’s ItemData nodes
        item_data_nodes <- xml_find_all(item_group_node, ".//d1:ItemData", ns = namespaces)
        for (item_node in item_data_nodes) {
          item_oid <- xml_attr(item_node, "ItemOID", default = NA)
          value <- xml_attr(item_node, "Value", default = NA)
          
          # Add the extracted information to the list
          extracted_data_list[[index]] <- list(
            SubjectKey = subject_key,
            Sex = sex,
            SubjectAgeAtEvent = subject_age_at_event,
            StudyEventRepeatKey = study_event_repeat_key,
            StartDate = start_date,
            ItemOID = item_oid,
            Value = value
          )
          index <- index + 1
        }
      }
    }
  }
}



# Convert the list to a data frame using dplyr::bind_rows()
extracted_data <- do.call(rbind, lapply(extracted_data_list , function(x) data.frame(t(unlist(x)) , stringsAsFactors = FALSE)))

# View the extracted data
head(extracted_data)

# Write the data to a CSV file
write.csv(extracted_data, "D:/Cornell University/Capstone/DATA/extracted_data_0402.csv", row.names = FALSE)
