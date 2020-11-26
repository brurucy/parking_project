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
    And the following parking spaces are available
      | Spot    | Category | Places | Latitude  | Longitude |
      | Vabriku, Tartu |  B       | 3      | 58.37681  | 26.70399  |
      | Lossi, Tartu   |  A       | 30     | 58.37927  | 26.71754  |
      | Jakobi, Tartu  |  A       | 50     | 58.38237  | 26.71489  |
    When I fill the form with "Raatuse 23" as the destination and "50" as duration
    And submit it
    Then it should give me the closest parking space