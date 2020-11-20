Feature: User Management
  As a User
  I am done driving
  Therefore I want to park my car
  Hence I have to register myself in the App
  So I can log-in

  Scenario: Visiting the website
    Given that I am near "Raatuse 23"
    And about to park
    Then I should go to the website first

  Scenario: Creating an account
    Given that I do not already have an account with email "brunorucy@ut.ee"
    When I open the app
    Then I see the button "SIGN UP"
    When I click on sign up
    Then I see an empty registration form
    And my name is "Bruno Rucy", email "brunorucy@ut.ee", license plate "666 ABC" and desired password "Banana1234!"
    And I fill the form with my information
    And click on "Submit"
    Then I am shown a confirmation of registration

  Scenario: Logging in
    Given that I have an account with the following credentials: email "bruno98@ut.ee" and password "parool"
    When I open the app
    Then I see the button "Sign in"
    When I click on sign in
    And enter the credentials
    And I triple double quadruple check their correctness
    And click on "Submit"
    Then I am logged into my account

  Scenario: Logging out
    Given that I am logged in
    And I have the application open
    And I see the button Log out
    When I click on the button Log out
    Then I am logged out of my account