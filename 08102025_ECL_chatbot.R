## Set up
rm(list = ls())

library(vegan)
library(ellmer)
library(tidyverse)
library(rlang)
library(languageserver)
library(dplyr)
library(ggplot2)
library(readr)
library(httpgd)


## API key
openrouter_api_key <- Sys.getenv("YOURKEY")


## Build your own chatbot!

## More deterministic
chatbot <- chat_openrouter(
  system_prompt = "You're a helpful assistant.",
  model = "anthropic/claude-3.5-haiku",
  api_args = list(max_tokens = 50, temperature = 0, top_k = 1))

## Ask questions
chatbot$chat("What do ecologists like to eat?")

## Revised version - concise but creative!
chatbot_v2 <- chat_openrouter(
  system_prompt = "Complete the sentences the user provides you. Continue where the user left off. Provide one answer only. Don't provide any explanation. Be creative.",
  model = "anthropic/claude-3.5-haiku",
  api_args = list(max_tokens = 100, temperature = 2, top_k = 500))

## Ask questions
chatbot_v2$chat("What do ecologists like to eat?")

## Try!
chatbot$chat("What is the coolest lab retreat plan around Brisbane?")
chatbot_v2$chat("What is the coolest lab retreat plan around Brisbane?")


## Apply it to your research!

## Example: structured literature review
## Build your own chatbot
chat_lit_review <- chat_openrouter(
  system_prompt = "

Extract structured information for a literature review. Be concise and factual.

Include only studies that meet ALL of the following criteria:
1. Examined wild populations of terrestrial mammals (exclude bats/Chiroptera).
2. Assessed human-induced disturbances that altered wildlife from their natural states (explicitly mentioned by authors).
3. Focused on response variables related to group size changes, or provide sufficient info to infer these changes (social cohesion, temporal interactions, or spatial dispersal).

For each included study, output the following fields in CSV-like format:
- topic
- main_findings
- methods
- species
- terrestrial_mammal_or_not (TRUE/FALSE)
- has_group_size (TRUE/FALSE)
- has_human_disturbance (TRUE/FALSE)
- include_or_not (TRUE/FALSE): only when terrestrial_mammal_or_not, has_group_size, and has_human_disturbance are all TRUE.

If you cannot find an answer for a field, do NOT guess. Return 'NA' for that field instead.

",
  model = "anthropic/claude-3.5-haiku",
  api_args = list(max_tokens = 1000, temperature = 0.5, top_k = 10)
)

## Abstract 1
abstract1 <- "Ecological niche models (ENMs) are often used to predict species distribution patterns from datasets that describe abiotic and biotic factors at coarse spatial scales. Ground-truthing ENMs provide important information about how these factors relate to species-specific requirements at a scale that is biologically relevant for the species. Chimpanzees are territorial and have a predominantly frugivorous diet. The spatial and temporal variation in fruit availability for different chimpanzee populations is thus crucial, but rarely depicted in ENMs. The genetic and geographic distinction within Nigeria-Cameroon chimpanzee (Pan troglodytes ellioti) populations represents a unique opportunity to understand fine scale species-relevant ecological variation in relation to ENMs. In Cameroon, P.t.ellioti is composed of two genetically distinct populations that occupy different niches: rainforests in western Cameroon and forest-woodland-savanna mosaic (ecotone) in central Cameroon. We investigated habitat variation at three representative sites using chimpanzee-relevant environmental variables, including fruit availability, to assess how these variables distinguish these niches from one another. Contrary to the assumption of most ENM studies that intact forest is essential for the survival of chimpanzees, we hypothesized that the ecotone and human-modified habitats in Cameroon have sufficient resources to sustain large chimpanzee populations. Rainfall, and the diversity, density, and size of trees were higher at the rainforest. The ecotone had a higher density of terrestrial herbs and lianas. Fruit availability was higher at Ganga (ecotone) than at Bekob and Njuma. Seasonal variation in fruit availability was highest at Ganga, and periods of fruit scarcity were longer than at the rainforest sites. Introduced and secondary forest species linked with anthropogenic modification were common at Bekob, which reduced seasonality in fruit availability. Our findings highlight the value of incorporating fine scale species-relevant ecological data to create more realistic models, which have implications for local conservation planning efforts."

## Get structured information
result1 <- chat_lit_review$chat_structured(
  paste(
    "Respond ONLY with a valid JSON with these fields: topic, main_findings, methods, species, terrestrial_mammal_or_not, has_group_size, has_human_disturbance, include_or_not.
    Respond ONLY with a valid JSON object matching the schema. Do not include any explanation, note, or extra text—respond.", abstract1
  ),
  type = type_object(
    topic = type_string(),
    main_findings = type_string(),
    methods = type_string(),
    species = type_string(),
    terrestrial_mammal_or_not = type_boolean(),
    has_group_size = type_boolean(),
    has_human_disturbance = type_boolean(),
    include_or_not = type_boolean()
  )
)
print(result1)

## Abstract 2
abstract2 <- "Habitat loss and fragmentation affect the diversity and distribution of primates in a human-modified landscape. Ethiopia has a high diversity of primates, but increasing human pressure has negatively impacted their distribution and abundance across the country, primarily due to deforestation. To date, the diversity and distribution of primate species are poorly known in northwestern Ethiopia. From October 2020 until September 2021, we assessed the diversity and distribution of primate species in 26 forest patches in the Awi Zone, Northwestern Ethiopia using line transect surveys, and we examined the potential conservation threats to the survival of these taxa. Across transects, we encountered 459 groups of four primate taxa: olive baboons (Papio anubis), grivet monkeys (Chlorocebus aethiops), Boutourlini's blue monkeys (Cercopithecus mitis boutourlinii), and black-and-white colobus monkeys (Colobus guereza spp. guereza). The latter two are endemic to Ethiopia. We observed black-and-white colobus monkeys in all surveyed forest patches, while we observed Boutourlini's blue monkeys in 18 patches. Black-and-white colobus monkeys were the most frequently observed (n = 325 sighting; relative encounter frequency = 70.8%), while grivet monkeys (Chlorocebus aethiops) were the least (n = 34 sighting; relative encounter frequency = 7.4%) in the region. Similarly, the relative encounter frequency of olive baboons was 9.2% (n = 42 sighting). The overall mean group size for each species was: Boutourlini's blue monkeys (26.1 individuals), black-and-white colobus monkeys (8.8 individuals), grivet monkeys (34.1 individuals), and olive baboons (41.4 individuals). We identified agricultural expansions, exotic tree plantations, deforestations, firewood collections, livestock grazing, and killings over their crop-feeding behaviors as the main threats to primates and their habitats in the region. This study provides crucial information on an area likely to support primate species that we know very little about. Assigning protected connecting forest patches should be an urgent priority for the conservation of the primates in this region."

## Get structured information
result2 <- chat_lit_review$chat_structured(
  paste(
    "Respond ONLY with a valid JSON with these fields: topic, main_findings, methods, species, terrestrial_mammal_or_not, has_group_size, has_human_disturbance, include_or_not.
    Respond ONLY with a valid JSON object matching the schema. Do not include any explanation, note, or extra text—respond.", abstract2
  ),
  type = type_object(
    topic = type_string(),
    main_findings = type_string(),
    methods = type_string(),
    species = type_string(),
    terrestrial_mammal_or_not = type_boolean(),
    has_group_size = type_boolean(),
    has_human_disturbance = type_boolean(),
    include_or_not = type_boolean()
  )
)
print(result2)
