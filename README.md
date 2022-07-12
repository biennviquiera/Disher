# Bienn Viquiera Capstone Project

# Disher

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Disher is a recipe app that lets you search and save recipes in your own personal lists
### App Evaluation
- **Category:** Food & Drink
- **Mobile:** Mobile is convenient, but not necessary for this app. It could also be implemented through a web app but mobile provides portability in the kitchen.
- **Story:** This app will be useful in determining what to do with leftover ingredients 
- **Market:** Anyone with an interest in cooking and desire to not let their food go to waste will find this application useful
- **Habit:** Food is a daily necessity. There are often excess ingredients so users will oft use this to check what they are able to make.
- **Scope:** Split into milestones. V1 would be to create an application that allows querying and showing recipes. V2 will allow users to input ingredients they currently have. V3 will allow users to save lists and access them. V4 will return a list of dishes with the best matches of the current ingredients + others that will require the least additional ingredients.

## Product Spec

### 1. User Stories

**Required Must-have Stories**

* Users can log in and access their own accounts
* List of recipes appear in the home screen
* Users can search for a recipe and its ingredients and receive results from databases
* Users can save recipes to their lists

**Optional Nice-to-have Stories**

* Users can follow other users and see their lists
* Users can input their ingredients and select from a database of available choices
* Users can rearrange their list of saved dishes

### 2. Screen Archetypes

* Recipes Browser View
   * List of recipes appear in the home screen
   * Users can search for a recipe and receive results from databases
* Lists View
   * Users can save recipes to their lists
   * Users can rearrange their list of saved dishes

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Recipe Search
* List of Saved Recipes

**Flow Navigation** (Screen to Screen)

* Login 
   * Users can log in or sign up which will take them to the main navigation controller starting with Recipes

* Recipes (Table View Controller)
   * Table View containing recipes
   * Can press on Detail/Scroll View with more details


* Lists Tab (Table View Controller)
   * Shows current user's saved lists
   * Pressing on a list should reveal list of recipes saved which will each be clickable and reveal details similar to the recipes tab

## Wireframes
<img src="https://i.imgur.com/PzzBGfH.png" width=600>

## Schema 
[This section will be completed in Unit 9]
### Models
- List
--- Name of the list
--- Array of recipe IDs that the list has 
- Recipe
--- ID of recipe, Source of recipe to determine how to properly query the information once stored in Parse
--- Name of Recipe, Image of Recipe, Description/Instructions of Recipe can be retrieved from previous bullet for the detail view

### Networking
- Recipe View Controller: queries MealDB and Spoonacular API. Saving to List saves to parse
-- [self.passedRecipe saveInBackground];
- Other API Endpoints
-- Spoonacular: GET https://api.spoonacular.com/recipes/complexSearch
-- MealDB: https://www.themealdb.com/api/json/v1/1/search.php
