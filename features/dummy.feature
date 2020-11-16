Feature: existing
  As a driver
  I am done driving
  Therefore I want to park my car

  Scenario: Visiting the website
    Given that I am near "Raatuse 23"
    And about to park
    Then I should go to the website first

  Scenario: