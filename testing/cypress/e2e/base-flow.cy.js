describe('Base Application Flow', () => {

  beforeEach(() => {
    // Ignore unhandled errors from Nuxt/Vue that might not affect test flow
    cy.on('uncaught:exception', (err, runnable) => {
      // Return false to prevent the error from failing the test
      return false;
    });

    // Ignore unhandled promise rejections
    cy.on('unhandled:rejection', (reason, promise) => {
      // Return false to prevent the rejection from failing the test
      return false;
    });

    cy.visit("/");
  })

  it('should navigate through the main user journey', () => {
    // Verify we're on the home page
    cy.contains('SPECIALZ').should('be.visible');
    cy.contains('és un servei orientat a facilitar la mobilitat educativa').should('be.visible');
  });

  it("Should be able to get to the areaPrivada", () => {
    cy.visit("/areaPrivada")
  })

  it("Should be able to get to the login of the student", () => {
    cy.visit("/areaPrivada")
    cy.contains('Accés').should('be.visible');
    cy.contains('Soc estudiant').should('be.visible');
    cy.contains('Soc estudiant').click();
  })

  it("Should be able to access as the student", () => {
    // Use Cypress session to cache authentication state
    cy.session('student-session', () => {
      // Visit frontend first to establish browser context
      cy.visit('/');

      // Authenticate via API request from browser context to set cookies properly
      cy.window().then((win) => {
        return win.fetch('http://localhost:3000/login', {
          method: 'POST',
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            password: 'password123',
            username: 'gigapigga'
          })
        }).then(response => {
          cy.log('Login response status:', response.status);
          return response.text().then(text => {
            cy.log('Login response body:', text);
            if (!response.ok) {
              throw new Error(`Login failed with status ${response.status}: ${text}`);
            }
            try {
              return JSON.parse(text);
            } catch (e) {
              return text;
            }
          });
        });
      });

      // Now visit private area to verify authentication works
      cy.visit('/private');
      cy.url().should('include', '/private');
    });

    // Session restored - visit private area
    cy.visit('/private');

    // Verify private area loaded with authenticated session
    cy.contains('Greetings, our unique and special').should('be.visible');
    cy.contains('Document').should('be.visible');
    cy.contains('Description').should('be.visible');
    cy.contains('Observations').should('be.visible');
    cy.contains('Medical record').should('be.visible');
  })

  it("Should be able to access as the teacher", () => {
    // Use Cypress session to cache authentication state
    cy.session('teacher-session', () => {
      // Visit frontend first to establish browser context
      cy.visit('/');

      // Authenticate via API request from browser context to set cookies properly
      cy.window().then((win) => {
        return win.fetch('http://localhost:3000/login', {
          method: 'POST',
          credentials: 'include',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            username: 'Teacher One',
            password: 'password123'
          })
        }).then(response => {
          cy.log('Teacher login response status:', response.status);
          return response.text().then(text => {
            cy.log('Teacher login response body:', text);
            if (!response.ok) {
              throw new Error(`Teacher login failed with status ${response.status}: ${text}`);
            }
            try {
              return JSON.parse(text);
            } catch (e) {
              return text;
            }
          });
        });
      });

      // Now visit teacher area to verify authentication works
      cy.visit('/teacher');
      cy.url().should('include', '/teacher');
    });

    // Session restored - visit teacher area
    cy.visit('/teacher');

    // Verify teacher area loaded with authenticated session
    cy.contains('Teacher Area').should('be.visible');
    cy.contains('Your Students').should('be.visible');

    // Check if students are loaded (assuming at least one student exists)
    cy.get('aside').should('contain', 'Your Students');

    // Click on "gigapigga" student to load their document
    cy.contains('button', 'gigapigga').click();

    // Verify the selected student is displayed
    cy.contains('Selected student: gigapigga').should('be.visible');

    // Verify document sections are loaded
    cy.contains('Description').should('be.visible');
    cy.contains('Observations').should('be.visible');
    cy.contains('Tutor Interaction').should('be.visible');
  })
});
