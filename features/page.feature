Feature: Page
  Scenario: Show Home Page
    When I go to "/"
    Then I should see the following:
      """
      <!DOCTYPE html>
      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
          <title>Home</title>
          <link rel="stylesheet" href="/smeagol/main.css" type="text/css"/>
          <link rel="stylesheet" href="/smeagol/pygment.css" type="text/css"/>
        </head>
      
        <body>
          <div id="container">
      	    <h1>Home</h1>
      	    <div>
      	      <p>Welcome to the Home page!</p>
      
              <p>Go to the <a class="internal present" href="/Test-page">Test Page</a>.</p>
              <p>Go to the <a class="internal present" href="/Code-page">Code Page</a>.</p>
      	    </div>
          </div>
        </body>
      </html>
      """

  Scenario: Show Test Page
    When I go to "/Test-page"
    Then I should see the following content:
      """
      <h1>Test page</h1>
  	  <div>
        <p>This is the <strong>test</strong> <em>page</em>.</p>
      
        <p>Unordered list:</p>
      
        <ul><li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>
        </ul><p>Ordered list:</p>
      
        <ol><li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>
        </ol>
      </div>
      """

  Scenario: Show Code Page
    When I go to "/Code-page"
    Then I should see the following content:
      """
      <h1>Code page</h1>
  	  <div>
  	    <p>This is Ruby code:</p>
  	  
  	    <div class="highlight"><pre><span class="k">def</span> <span class="nf">hello</span>
  	      <span class="nb">puts</span> <span class="s2">"Hello, World!"</span>
  	    <span class="k">end</span>
  	    </pre>
  	    </div>
      </div>
      """