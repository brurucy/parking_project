Feature: Interactive search of parking space
  As a registered user
  I want to park my car
  So I go to the App
  to find a parking place
  near me


  Scenario: Searching for a parking space
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "park" button
    And it takes me to the parking form
    When I fill the form with "Raatuse 23"
    And submit it
    Then it should give me the closest parking space