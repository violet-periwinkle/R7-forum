We are going to create a Rails application from scratch, explaining all of the parts.  We are not going to explain Rails at the start.  We're just going to plow in, creating the application, and explaining the meaning of each step.  When you start the Rails server, it runs the application, listening and responding to HTTP requests, which often originate from a browser.

Because the lesson is organized in this way, there is no separate materials page.  All the information is presented in the course of the assignment.

To begin, fork [this repository.](https://github.com/Code-the-Dream-School/R7-forum.git)  Then clone your fork.  As usual, be sure not to clone into an existing git repository.  Then, cd to the directory where you cloned, and create a new branch called lesson6.  This is where you will do your work. Then do:
```bash
bin/bundle install
```
This is necessary so that you install all the gems needed for this application.  You may get a message that the version of bundler doesn't match the version in Gemfile.lock.  You can ignore this.

Before you go further, have a look at the files and directory tree comprising this repository.  As you can see, there are a heap and a pile of files.  It will take some time to understand what each of these is for.  You will do most of your work in the app directory, but you also will make changes to the config and db folders.

Now, start the server as follows:
```bash
bin/rails server
```
You will see a message that the Rails server is listening on http://localhost:3000.  So open that URL in your browser.  You will see a basic Rails page.  **If you do not see this page, you have not installed Rails correctly, so ask for help.**  Now, stop the server by typing Ctrl-C in your terminal.  

## Step 1: Generate a Basic Application Using Scaffolding

Enter the following in your terminal:
```bash
bin/rails generate scaffold forum forum_name:string
```
Have a look at the messages that come back in your terminal.  Quite a few things are generated for you:

- A migration.  This creates a table in the database for forum records.
- A model. This is the Active Record class for the forum records.  Active Record is an object relational mapper, which converts operations on Active Record objects into SQL.
- A route is added.
- A controller is created.
- Views are created.
- And some other stuff as well, having to do with testing and the like -- you can ignore this for now.

So, let's look at each.  

- First, the migration file.  It is in the db/migrate directory.  The name is a timestamp, plus a descriptive name saying what it does.  Open it up.  You'll see that it creates the table in the database.
- Second, the model.  This is app/models/Forum.rb.  If you have a look, you'll see that there isn't any code there.  The model gets all of its behavior at this point from the parent class and the schema in the database.  We'll modify model files in a later lesson.
- Third, the route. This is in config/routes.rb, for the forums resource.  As we'll see, this line generates a number of routes.
- Fourth, the controller.  This is app/controllers/forums_controller.rb.  There are methods in this file to handle each of the actions coming out of the routes.  The methods are very short, meaning that default behavior is used throughout.  However, have a look at the index method.  It starts with:
    ```ruby
    @forums = Forum.all
    ```
    This invokes the model to get the list of forum records.  This is stored in an instance variable.
- Finally, let's look at a view, specifically app/views/forums/index.html.erb.  An erb file is an html file with embedded Ruby code, which is always surrounded by:
    ```
    <% %>
    ```

Now restart the server, and go to http://localhost:3000 again.  You get an error.  Whenever you generate a migration, you have to run the migration or the server won't work.  So, stop the server and type:
```bash
bin/rails db:migrate
```
You'll see that a table is created.  You now have two more files: db/schema.rb and db/development.sqlite3.  The schema file shows the state of tables in the database, and it is helpful to refer to it, but you should never edit it.  The sqlite3 file is not readable.  This is the database itself.  This file is in the .gitignore, so that it is never sent to github.

Ok, now restart the server.  Go to http://localhost:3000/forums.  You'll see the list of forums, but of course, at this point, there aren't any.

Take a look at the terminal where the server is running.  What you see there is the server log.  The log is useful to see what the server does in response to each request.  It is also persisted in log/development.log (you are running, by default, in development mode), and for production applications, it's important to review the log to see if there are errors in the application or possible misuse.  As we'll see, you can also put in code statements to write to the log.  The contents of the log directory are not sent to github.  

Anyway, back to what you see in the log: You see that a GET request came from your browser for the "/forums" path.  You see that the ForumsController index method was invoked to handle the request.  You see the views that were rendered, and the SQL operation that occurred in order to render the views.  So, we see all the parts of a Model-View-Controller (MVC) structured application.  Stop the server for the next steps.

Now would be a good time to get an understanding of MVC.  [This short video](https://www.youtube.com/watch?v=FCkDEHWDATI) may be helpful.

## Step 2: Fixing the Schema

We haven't created any forum entries yet, and there's something we need to fix first.  We want a description for each forum.  This is another column in the schema.  So, enter the following:
```bash
bin/rails generate migration AddDescriptionToForums description:string
bin/rails db:migrate
```
As we generated a new migration, we had to do the migrate.  If you check db/schema.rb, you see that the description column has been added to the forums table.

We can now use the Rails console to add entries to the database without starting the server.  The Rails console is a very important tool.  You can do all the operations that you can do in the IRB environment, such as calling functions and displaying the value of variables, but you can also use Rails classes, including the Active Record Model classes that access the database.  Enter the following:
```ruby
bin/rails console
forum = Forum.new
forum.forum_name = "Ruby"
forum.description = "Ruby programming tips."
forum.save
Forum.all
```
Please note when we capitalize.  Forum.new and Forum.all are class methods of the Forum model class.  We create an instance of this class called "forum" (lower case!), and then do some operations on that instance, including save, which is an instance method.  The save is what writes the entry to the database.  We then see that it is added to the list returned by Forum.all.  You could add more forum entries now if you like.  Note also that the Rails console shows the SQL that it is executing.  When you do ```forum.save``` it does an SQL Insert. You are using the Active Record ORM (Object Relational Mapper) to do the SQL for you.

Start the server, and go to http://localhost/3000/forums . ITake a look at your server console after you do this.  You will see that the server has performed a SELECT statement on the forums table.

In your browser, you see the list of forums -- but no descriptions.  This is because the views were generated when the forums table did not have a description column.  We now need to fix those views.

Edit app/views/forums/index.html.erb.  Again, you see those ```<% %>``` brackets that indicate embedded Ruby.  Now, the first thing to understand about those sections is that no Ruby code is sent to the browser.  The browser can do nothing with Ruby.  The Ruby code is executed on the server side to generate plain HTML, which is what is sent to the browser.  If you go into developer tools in your browser, that's what you'll see, plain HTML.  An erb file is a template, with dynamic contents that are populated on the server side.  This is called "server side rendering".

There are only two kinds of embedded Ruby blocks in an erb file.  The ones that start ```<% ``` are executed, but do not result in anything added to the HTML.  These are for conditional statements and loops.  The blocks that start ```<%= ``` do generate output.  The result of the Ruby expression is inserted into the HTML. You can put all kinds of Ruby code into an erb file, but this is unwise.  You want to keep your logic in the controller or model, except for a minimum as needed to customize the view.  

Note the line that says
```
<% @forums.each do |forum| %>
```
This is Ruby code that generates no output -- except the other statements in the loop may generate output.  The @forums is the instance variable from the index method of the forums controller.  The views you render have access to instance variables from the controller.

So, let's try modifying the index.html.erb line.  Right below the forums div, add the following code:
```html
<div>
  <% 5.times do |i| %>
  <p><%= "iteration #{i}" %></p>
  <% end %>
</div>
```
Here we use both kinds of embedded Ruby blocks.  What do you think it will display?  Refresh your browser page to find out.  There is no need to restart the server.

You can take that div back out, as it was just for experimentation.  We need to get back to adding the forum description.  You see the line that says
```
    <%= render forum %>
```
This is loading a partial.  A view partial is a view component that is used in several views, in this case the index and show views.  The partial that is being rendered is app/views/forums/_forum.html.erb.  You only have to specify "forum", not the full name of the partial.  So edit that file.  There you see the problem:
```html
  <p>
    <strong>Forum name:</strong>
    <%= forum.forum_name %>
  </p>
```
There is a paragraph for the forum_name attribute, but nothing for the description attribute.  So, duplicate the paragraph above. Then, in the duplicated part, change `Forum name` to `Forum description`, and `forum.forum_name` to `forum.description`.  Save the file and refresh your browser. Now you see the descriptions.  But, if you click on "new forum" you only can enter the title.  You need to edit another partial.  You can see in the console log of the Rails server that it is forums/_form.html.erb.  This partial is used by both edit and new.

When you edit the partial, you see a form_with statement.  This is a helper method for use with erb files.  What it generates is a normal HTML form, with a few hidden fields to facilitate Rails processing.  On the next lines, you see some stuff that has to do with error reporting.  The section we are interested in is below that.  You need to duplicate the div that currently handles input for the forum_name.  Then change the new section as needed to handle the description.  Experiment so that you can see how this is done.  There are several additional helper methods used: form.label and form.text_field.  You can find the Rails form helpers documented [here.](https://guides.rubyonrails.org/form_helpers.html)  Verify that when you click on "new forum" you get a correct form, with a description field.  Check it out with your browser developer tools.

Now try to create a forum with a description.  You'll see that the forum entry gets created, but, hmm, no description.  There is one change to make to the controller.  To figure this out, we have to understand what happens when you click the "Create Forum" button.  In HTML, when a form is submitted, a POST request is sent from the browser to the server.  The body of the post request contains the data from the form.  Stop the server for the moment.  Then, in your terminal, type:
```bash
bin/rails routes
```
You'll see a bunch of routes, most used internally by Rails.  If you scroll to the top, you'll see the ones having to do with forums.  All of these routes are created by the ```resources :forums``` line in config\routes.rb.  Each route has a verb (GET, POST, PATCH, PUT, DELETE) and a URI pattern, which is the path part of the URL.  Then there is a column for the controller action.  There is also a prefix column, which we'll describe later.  When Rails gets a request from the browser, it tries to find a route that matches both the verb and the URI pattern.  In this case, the form sends a POST for /forums.  And the controller action is forums#create, which is the create method in app/controllers/forums_controller.rb.  So that's where we look next.

In the create method, we see the line:
```ruby
    @forum = Forum.new(forum_params)
```
Now forum_params is a private method near the bottom of the class.  It looks like this:
```ruby
    # Only allow a list of trusted parameters through.
    def forum_params
      params.require(:forum).permit(:forum_name)
    end
```
With each method in the controller, you get a params hash, which contains, in this case, the contents of the body of the POST request coming from the browser.  Rails has a security protection here.  You can't create an Active Record entry unless you flag (with the permit method) that the given attribute is trusted.  This is to block hackers from adding parameters you don't want.  Here we trust :forum_name only.  So, we need to change that to ```permit(:forum_name, :description)```.  Make that change, start the server again, and then try creating a forum with a description.  Now it works.  You can also edit a forum to change the description.  (By the way, you don't usually have to restart the server after a code change.  I find that if you change the routes or any of the models, you may need to restart the server.  Oh, and another shortcut: You can type just bin/rails s or c or g for the bin/rails server, console, and generator commands.)

## Step 3: The User Model

Usually applications have logons, typically with passwords.  We'll do that later in the course.  But, for the moment, we'll just simulate the logon.  We want users to be able to subscribe to forums and to post entries.  So, we need a User model.  As we have a lot to do in this couple of lessons, once again we will be lazy and use the scaffold.  Stop the server.  Then do:
```bash
bin/rails generate scaffold user name:string skill_level:string
bin/rails db:migrate
```
We could start the server and create some users, but the skill_level business could be used to store all sorts of things.  We just want the values beginner, intermediate, or expert.  How do we do this?  First, we edit the User model, and add the following line before the end statement:
```ruby
   validates :skill_level, inclusion: { in: %w(beginner intermediate expert) }
```
We'll learn more about validations in a later lesson.  We need to change the form to match.  this is app/views/users/_form.html.erb.  We'll put in a radio button.  We look in the form helper documentation, and indeed there is a helper for radio buttons.  So change the div for skill_level to read as follows:
```html
  <div>
    <%= form.radio_button :skill_level, "beginner" %>
    <%= form.label :beginner, "beginner" %>
    <%= form.radio_button :skill_level, "intermediate" %>
    <%= form.label :intermediate, "intermediate" %>
    <%= form.radio_button :skill_level, "expert" %>
    <%= form.label :expert, "expert" %>
  </div>
```
Then try it out.  

Next, let's do some experiments to understand how everything works. We also want to see some sample error messages so that we learn how to debug problems.  

Stop the server.  Edit the config/routes.rb.  Comment out the line that says `resources :users`.  Add, in its place, the following lines:
```ruby
  get '/users', to: 'users#index', as: 'users'
  get '/users/new', to: 'users#new', as: 'new_user'
  get '/users/:id', to: 'users#show', as: 'user'
  get '/users/:id/edit', to: 'users#edit', as: 'edit_user'
  post '/users', to: 'users#create'
  patch '/users/:id', to: 'users#update'
  delete '/users/:id', to: 'users#delete'
```
Then do bin/rails routes.  You'll see you have all the same routes as before, except the PUT route for users, as that one is not needed.  These all consist of a verb, a path, and a to: which is the method to invoke in the controller.  Note the ```:id``` in some of these routes.  That's a route parameter.  It specifies which user you want to show or edit or update or delete.  If a request comes in for a GET on /users/17, that means that the user with an id of 17 is to be shown.  You have to put the route for /users/new before the route for /users/:id, or else Rails would attempt to show the user with an id of "new".  This is because Rails attempts to match routes in the order they appear.  OK, so how about the `as:` part?  This creates a method name with that prefix.  You add ```_path``` to the end of that to have the matching URL path, which is then available to you as a variable.  Within controllers and views, you can refer to the variables users_path, user_path, edit_user_path, and so on.  You don't have the `as:` on each line, because you don't need it.  For the create, you use the same path as for the `get /users`, except that the create is a post instead of a get.

Now for some experiments.  Restart the server.  What happens if you comment out the route for get /rails?  Do that and try to go to http://localhost:3000/users.  Of course, you get an error.  By the way, in production, the user would not see this error screen.  They'd just get a 404 message.  You see the error message because Rails is running in development mode.  Take note of the error message that you see, so you know what to fix if this happens.  Also, take a look at the server log.  The log and the error message often point to the cause of problems.  

Next, uncomment that route, and edit the users controller.  Comment out the index method.  Then try refreshing the browser.  Again you get an error, in this case in the view.  Because the controller does not have an index method, the index method of the parent class is run, and it doesn't set the value of @users, so that is nil when the view is rendered.  The failing line from the view is shown in the error message, and that tells you what the problem is, but in this case, it doesn't point to the cause of the problem, which is in the controllere.  Remember about Ruby classes? ForumsController is a class, and @users is an instance variable set by the index method.  All instance variables in the controller can be used in the views.  

Uncomment the index method, and put a syntax error into it, a line that says ```baloney``` or something like that.  Again you get an error, and it shows you exactly the line that is failing.  OK, take that line back out.  Now, rename app/views/users/index.html.erb to index.html.erb.not.  Then once again, try http://localhost:3000/users. Again an error, but a different one.  Each of these error messages is pretty descriptive, in some cases even pointing to the failing line.  Rename the file back to index.html.erb.  Then refresh your browser window to make sure all is working again.

So now, for some user, click on "Show this User".  Then look at the terminal where the Rails server is running.  You will see a GET for "/users/x" where x is the id of that user.  You will also see the parameters hash that is passed to the show method, and is accessible as "params" within that method.  Edit the user, and then do an update.  Again, look at the server log.  You will see a PATCH for "/users/x" and then parameters hash, which include the id and the body of the PATCH request.

Take a look at the top of users_controller.rb.  You'll see this line:
```ruby
  before_action :set_user, only: %i[ show edit update destroy ]
```
The before_action sets up a method to be called before certain actions, in this case show, edit, update, and destroy.  It calls the method set_user, which is a private method near the bottom of the file.  The set_user method sets the value of the instance variable @user, based on the id that was passed in the params.  This way, you can have the value of @user set in only one place in the code, instead of having to do it for each of show, edit, update, and destroy.  This is not done for the index or new or create actions, because when these are called, there is no id for a user record.

Is it becoming clearer how Rails works?

## Step 4: Simulating Logon

We want to simulate a logon, so that we can associate specific forums and posts with a user.  So, how? In the general case, we'd use a gem called Devise.  But that's too complicated for now. We'll do something simpler, without any passwords.  Rails can store information in a session.  This is kept in a cookie that the server sets and the browser keeps.  Add the following methods to the users controller:
```ruby
def logon
  session[:current_user] = @user.id
  redirect_to users_path, notice: "Welcome #{@user.name}. You are logged in."
end

def logoff
  session.delete(:current_user)
  redirect_to users_path, notice: "You have logged off."
end
```
Do not put these methods in the private section.  You can't put action methods there.  Also, add logon to the list of methods in the before_action line for set_user, so that @user gets set.  You also need to change the 'before_action' at the top of the file to add the `logon` action, so that you know which user is being logged on.

Ok, pretty simple so far.  

Note somthing about controller actions: We have to do either a render or a redirect in each action.  Otherwise the user, in their browser session, would just wait and not get a response.  Because we are doing a redirect, we don't need to render a view.  Actually, you can't do both a render and a redirect for the same HTTP request.  You have to do exactly one of these.  Now we need to add these routes to config/routes.rb:
```ruby
  post '/users/:id/logon', to: 'users#logon', as: 'user_logon'
  delete '/users/logoff', to: 'users#logoff', as: 'user_logoff'
```
We could do these operations with a GET -- but that's a bad practice.  You do not want to change state on the server with a GET.  It leads to security vulnerabilities.  Also, please note: This delete route has to be *before* the other delete route, the one that actually deletes the user.  Otherwise, the other route would be matched and the code would attempt to delete a user with id = logoff.

We need a way to invoke these routes from the pages.  We also need to be able pick which user that we want to logon as.  We'll add a button to app/views/users/show.html.erb.  Add the following line just above the line for the destroy button:
```
  <%= button_to "Logon as this user", user_logon_path(@user), method: :post %>
```
A couple points to notice: First, we can use user_logon_path, because we put ```as: user_logon``` into the route.  And the route takes a post.  But user_logon_path has a parameter, so we have to pass @user when we use it.  But, what in the world does button_to actually do? You can find out by going into developer tools in your browser to display the elements of the show page.  You'll see that button_to actually creates a complete form masquerading as a button.  It has a hidden field with an authenticity_token, which token is for security purposes, and another hidden field with a _method, so that the action (which really is always a POST), can be handled as a POST or a PATCH or a DELETE.

Now, we need to add a button for for logoff.   But wait! It only makes sense to have a button for logoff if someone is logged on.  We need to change the controller to pass information about the logged on user to the view.  Add the following line to the index method of the user controller:
```ruby
    if (session[:current_user])
      @current_user = User.find(session[:current_user])
    else
      @current_user = nil
    end
```
The view has access to all of the controller's instance variables, so now one can reference `@current_user` in the view.  Possibly no user is logged in, and in that case @current_user would be set to nil by the line above.

We'll add the logoff button, for the moment, to the `app\views\user\user\index.html.erb`.  Just below the link_to line for "New User", add these lines:
```html
<%= link_to "New user", new_user_path %>
<div>
  <% if @current_user %>
    <%= "#{@current_user.name} is logged on." %>
    <%= button_to "Log Off", user_logoff_path, method: :delete %>
  <% else %>
    No one is logged in.
  <% end %>
  </div>
```
If you open your browser developer tools, under the application tab, you'll see the cookie that is set to store session information.  This is where the id of the current user, if any is logged in.  You can't read the cookie, though, because it's encrypted.  Why is this stored in a cookie? Well, if we store it in an instance variable, it's not available with the next request, because the instance of the user controller class only lasts for one instance.  While the instance of controller class doesn't last, the controller class itself is persistent, though.  So we could store the user id in a class variable or global.  But this would be a bad idea!  If you have several users accessing the application from different browsers, they would have the same user id, and you don't want that.  That's why the cookie is used.

## What we'll do Next

We have created a basic application (with a lot of help from the  generated scaffolds).  We added our own routes for logon and logoff.  We have two models, Forum and Post.  But, hmm, we have forums with no way to post.  We want to be able to add posts to a forum, and those posts should belong to a particular user.  We also want a way for a user to be able to subscribe to forums.  In the next lesson, we'll create two more models, one for posts, and another for subscriptions.  These will involve associations: a post is associated both with a forum and with a user, and so is a subscription.  Users are associated with various forums through their subscriptions.  So the data model is is more complicated, and we can't just use scaffolds.

## Check for Understanding

This assignment is pretty much cut and paste. You need to check to see if you understand what was done.  So, edit lesson6-questions.txt.  There are a series of questions there.  Put in your answers, and be prepared to discuss them with your mentors.

## Submitting Your Work

As usual, you add and commit the changes, in this case to the lesson6 branch, and then push that branch to github.  Then create a pull request and submit a link to the pull request in the homework submission form.
