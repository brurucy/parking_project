mixFeature: existing
  As a driver
  I am done driving
  Therefore I want to park my car

  Scenario: Visiting the website
    Given that I am near "Raatuse 23"
    And about to park
    Then I should go to the website first

  Scenario: Creating an account
    Given that I do not already have an account
    When I open the app
    Then I see the button "SIGN UP"
    When I click the button "SIGN UP"
    Then I see an empty registration form
    When I fill all the fields
    And click on "SUBMIT"
    Then I am shown a confirmation of registration

  Scenario: Logging in (with confirmation)
    Given that I have an account with the following credentials
      | name       | email           | license plate | password    |
      | Bruno Rucy | brunorucy@ut.ee | 666 ABC       | Banana1234! |
    When I open the app
    Then I see the button "Sign in"
    When I click on "Sign in"
    And enter the credentials
    And I triple double quadruple check their correctness
    Then I am logged into my account

  Scenario: Logging out
    Given that I am logged in
    And I have the application open
    And I see the button "Sign out"
    When I click on the button "Sign out"
    Then I am logged out of my account





