# Introduction to Rails

# Lesson 6: Rails Basics

We are going to create a Rails application from scratch, explaining all of the parts.  We are not going to explain Rails at the start.  We're just going to plow in, creating the application, and explaining the meaning of each step.  When you start the Rails server, it runs the application, listening and responding to HTTP requests, which often originate from a browser.

Because the lesson is organized in this way, there is no separate materials page.  All the information is presented in the course of the assignment.

To begin, fork [this repository.](https://github.com/Code-the-Dream-School/R7-forum.git)  Then clone your fork.  As usual, be sure not to clone into an existing git repository.  Then, cd to the directory where you cloned, and create a new branch called rails_basics.  This is where you will do your work. Then do:
```
bin/bundle install
```
This is necessary so that you install all the gems needed for this application.

Before you go further, have a look at the files and directory tree comprising this repository.  As you can see, there are a heap and a pile of files.  It will take some time to understand what each of these is for.  You will do most of your work in the app directory, but you also will make changes to the config and db folders.

Now, start the server as follows:
```
bin/rails server
```
You will see a message that the Rails server is listening on http://localhost:3000.  So open that URL in your browser.  You will see a basic Rails page.  **If you do not see this page, you have not installed Rails correctly, so ask for help.**  Now, stop the server by typing Ctrl-C in your terminal.  

## Step 1: Generate a Basic Application Using Scaffolding

Enter the following in your terminal:
```
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
    ```
    @forums = Forum.all
    ```
    This invokes the model to get the list of forum records.  This is stored in an instance variable.
- Finally, let's look at a view, specifically app/views/forums/index.html.erb.  An erb file is an html file with embedded Ruby code, which is always surrounded by:
    ```
    <% %>
    ```

Now restart the server, and go to http://localhost:3000 again.  You get an error.  Whenever you generate a migration, you have to run the migration or the server won't work.  So, stop the server and type:
```
bin/rails db:migrate
```
You'll see that a table is created.  You now have two more files: db/schema.rb and db/development.sqlite3.  The schema file shows the state of tables in the database, and it is helpful to refer to it, but you should never edit it.  The sqlite3 file is not readable.  This is the database itself.  This file is in the .gitignore, so that it is never sent to github.

Ok, now restart the server.  Go to http://localhost:3000/forums.  You'll see the list of forums, but of course, at this point, there aren't any.

Take a look at the terminal where the server is running.  What you see there is the server log.  The log is useful to see what the server does in response to each request.  It is also persisted in log/development.log (you are running, by default, in development mode), and for production applications, it's important to review the log to see if there are errors in the application or possible misuse.  As we'll see, you can also put in code statements to write to the log.  The contents of the log directory are not sent to github.  

Anyway, back to what you see in the log: You see that a GET request came from your browser for the "/forums" path.  You see that the ForumsController index method was invoked to handle the request.  You see the views that were rendered, and the SQL operation that occurred in order to render the views.  So, we see all the parts of a Model-View-Controller (MVC) structured application.  Stop the server for the next steps.

Now would be a good time to get an understanding of MVC.  [This short video](https://www.youtube.com/watch?v=FCkDEHWDATI) may be helpful.

## Step 2: Fixing the Schema

We haven't created any forum entries yet, and there's something we need to fix first.  We want a description for each forum.  This is another column in the schema.  So, enter the following:
```
bin/rails generate migration AddDescriptionToForums description:string
bin/rails db:migrate
```
As we generated a new migration, we had to do the migrate.  If you check db/schema.rb, you see that the description column has been added to the forums table.

We can now use the Rails console to add entries to the database without starting the server.  The Rails console is a very important tool.  You can do all the operations that you can do in the IRB environment, such as calling functions and displaying the value of variables, but you can also use Rails classes, including the Active Record Model classes that access the database.  Enter the following:
```
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
```
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
This is loading a partial.  A view partial is a view component that is used in several views, in this case the index and show views.  The partial that is being rendered is app/views/forums/_forum.html.erb.  You only have to specify "forum", not the full name of the partial.  So edit that file.  There you see the problem.  There is a paragraph for the title, but nothing for the description.  So, duplicate the paragraph for the title. Then, in the duplicated part, change "Forum name" to "Forum description, and forum.forum_name to forum.description.  Save the file and refresh your browser. Now you see the descriptions.  But, if you click on "new forum" you only can enter the title.  You need to edit another partial.  You can see in the console of the Rails server that it is forums/_form.html.erb.  This partial is used by both edit and new.

When you edit the partial, you see a form_with statement.  This is a helper method for use with erb files.  What it generates is a normal HTML form, with a few hidden fields to facilitate Rails processing.  On the next lines, you see some stuff that has to do with error reporting.  The section we are interested in is below that.  You need to duplicate the div that currently handles input for the forum_name.  Then change the new section as needed to handle the description.  Experiment so that you can see how this is done.  There are several additional helper methods used: form.label and form.text_field.  You can find the Rails form helpers documented [here.](https://guides.rubyonrails.org/form_helpers.html)  Verify that when you click on "new forum" you get a correct form, with a description field.  Check it out with your browser developer tools.

Now try to create a forum with a description.  You'll see that the forum entry gets created, but, hmm, no description.  There is one change to make to the controller.  To figure this out, we have to understand what happens when you click the "Create Forum" button.  In HTML, when a form is submitted, a POST request is sent from the browser to the server.  The body of the post request contains the data from the form.  Stop the server for the moment.  Then, in your terminal, type:
```
bin/rails routes
```
You'll see a bunch of routes, most used internally by Rails.  If you scroll to the top, you'll see the ones having to do with forums.  All of these routes are created by the ```resources :forums``` line in config\routes.rb.  Each route has a verb (GET, POST, PATCH, PUT, DELETE) and a URI pattern, which is the path part of the URL.  Then there is a column for the controller action.  There is also a prefix column, which we'll describe later.  When Rails gets a request from the browser, it tries to find a route that matches both the verb and the URI pattern.  In this case, the form sends a POST for /forums.  And the controller action is forums#create, which is the create method in app/controllers/forums_controller.rb.  So that's where we look next.

In the create method, we see the line:
```
    @forum = Forum.new(forum_params)
```
Now forum_params is a private method near the bottom of the class.  It looks like this:
```
    # Only allow a list of trusted parameters through.
    def forum_params
      params.require(:forum).permit(:forum_name)
    end
```
With each method in the controller, you get a params hash, which contains, in this case, the contents of the body of the POST request coming from the browser.  Rails has a security protection here.  You can't create an Active Record entry unless you flag that the given attribute is trusted.  Here we trust :forum_name only.  So, we need to change that to ```permit(:forum_name, :description)```.  Make that change, start the server again, and then try creating a forum with a description.  Now it works.  You can also edit a forum to change the description.  (By the way, you don't usually have to restart the server after a code change.  I find that if you change the routes or any of the models, you may need to restart the server.  Oh, and another shortcut: You can type just bin/rails s or c or g for the bin/rails server, console, and generator commands.)

## Step 3: The User Model

Usually applications have logons, typically with passwords.  We'll do that later in the course.  But, for the moment, we'll just simulate the logon.  We want users to be able to subscribe to forums and to post entries.  So, we need a User model.  As we have a lot to do in this couple of lessons, once again we will be lazy and use the scaffold.  Stop the server.  Then do:
```
bin/rails generate scaffold user name:string skill_level:string
bin/rails db:migrate
```
We could start the server and create some users, but the skill_level business could be used to store all sorts of things.  We just want the values beginner, intermediate, or expert.  How do we do this?  First, we edit the User model, and add the following line before the end statement:
```
   validates :skill_level, inclusion: { in: %w(beginner intermediate expert) }
```
We'll learn more about validations in a later lesson.  We need to change the form to match.  this is app/views/users/_form.html.erb.  We'll put in a radio button.  We look in the form helper documentation, and indeed there is a helper for radio buttons.  So change the div for skill_level to read as follows:
```
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

Stop the server.  Edit the config/routes.rb.  Comment out the line resources :users.  Add the following lines:
```
  get '/users', to: 'users#index', as: 'users'
  get '/users/new', to: 'users#new', as: 'new_user'
  get '/users/:id', to: 'users#show', as: 'user'
  get '/users/:id/edit', to: 'users#edit', as: 'edit_user'
  post '/users', to: 'users#create'
  patch '/users/:id', to: 'users#update'
  delete '/users/:id', to: 'users#delete'
```
Then do bin/rails routes.  You'll see you have all the same routes as before, except the PUT route for users, as that one is not needed.  These all consist of a verb, a path, and a to: which is the method to invoke in the controller.  Note the ```:id``` in some of these routes.  That's a route parameter.  It specifies which user you want to show or edit or update or delete.  If a request comes in for a GET on /users/17, that means that the user with an id of 17 is to be shown.  You have to put the route for /users/new before the route for /users/:id, or else Rails would attempt to show the user with an id of "new".  This is because Rails attempts to match routes in the order they appear.  OK, so how about the as: part?  This creates a method name with that prefix.  You add ```_path``` to the end of that to have the matching URL path, which is then available to you as a variable.  Within controllers and views, you can refer to the variables users_path, user_path, edit_user_path, and so on.

Now for some experiments.  Restart the server.  What happens if you comment out the route for get /rails?  Do that and try to go to http://localhost:3000/users.  Of course, you get an error.  By the way, in production, the user would not see this error screen.  They'd just get a 404 message.  You see the error message because Rails is running in development mode.  Take note of the error message that you see, so you know what to fix if this happens.  Also, take a look at the server log.  The log and the error message often point to the cause of problems.  

Next, uncomment that route, and edit the users controller.  Comment out the index method.  Then try refreshing the browser.  Again you get an error, in this case in the view.  Because the controller does not have an index method, the index method of the parent class is run, and it doesn't set the value of @users, so that is nil when the view is rendered.  The failing line from the view is shown in the error message, and that tells you what the problem is, but in this case, it doesn't point to the cause of the problem, which is in the controllere.  Remember about Ruby classes? ForumsController is a class, and @users is an instance variable set by the index method.  All instance variables in the controller can be used in the views.  

Uncomment the index method, and put a syntax error into it, a line that says ```baloney``` or something like that.  Again you get an error, and it shows you exactly the line that is failing.  OK, take that line back out.  Now, rename app/views/users/index.html.erb to index.html.erb.not.  Then once again, try http://localhost:3000/users. Again an error, but a different one.  Each of these error messages is pretty descriptive, in some cases even pointing to the failing line.  Rename the file back to index.html.erb.  Then refresh your browser window to make sure all is working again.

So now, for some user, click on "Show this User".  Then look at the terminal where the Rails server is running.  You will see a GET for "/users/x" where x is the id of that user.  You will also see the parameters hash that is passed to the show method, and is accessible as "params" within that method.  Edit the user, and then do an update.  Again, look at the server log.  You will see a PATCH for "/users/x" and then parameters hash, which include the id and the body of the PATCH request.

Take a look at the top of users_controller.rb.  You'll see this line:
```
  before_action :set_user, only: %i[ show edit update destroy ]
```
The before_action sets up a method to be called before certain actions, in this case show, edit, update, and destroy.  It calls the method set_user, which is a private method near the bottom of the file.  The set_user method sets the value of the instance variable @user, based on the id that was passed in the params.  This way, you can have the value of @user set in only one place in the code, instead of having to do it for each of show, edit, update, and destroy.  This is not done for the index or new or create actions, because when these are called, there is no id for a user record.

Is it becoming clearer how Rails works?

## Step 4: Simulating Logon

We want to simulate a logon, so that we can associate specific forums and posts with a user.  So, how? In the general case, we'd use a gem called Devise.  But that's too complicated for now. We'll do something simpler, without any passwords.  Rails can store information in a session.  This is kept in a cookie that the server sets and the browser keeps.  Add the following methods to the users controller:
```
def logon
  session[:current_user] = @user
  redirect_to users_path, notice: "Welcome #{@user.name}. You are logged in."
end

def logoff
  session.delete(:current_user)
  redirect_to users_path, notice: "You have logged off."
end
```
Do not put these methods in the private section.  You can't put action methods there.  Also, add logon to the list of methods in the before_action line for set_user, so that @user gets set.  Ok, pretty simple so far.  

Note somthing about controller actions: We have to do either a render or a redirect in each action.  Otherwise the user would just wait and not get a response.  Because we are doing a redirect, we don't need to render a view.  Actually, you can't do both a render and a redirect for the same HTTP request.  You have to do exactly one of these.  Now we need to add these routes to config/routes.rb:
```
  post '/users/:id/logon', to: 'users#logon', as: 'user_logon'
  delete '/users/logoff', to: 'users#logoff', as: 'user_logoff'
```
We could do these operations with a GET -- but that's a bad practice.  You do not want to change state on the server with a GET.  It leads to security vulnerabilities.  Also, please note: This delete route has to be *before* the other delete route, the one that actually deletes the user.  Otherwise, the other route would be matched and the code would attempt to delete a user with id = logoff.

We need a way to invoke these routes from the pages.  We also need to be able pick which user that we want to logon as.  We'll add a button to app/views/users/show.html.erb.  Add the following line just above the line for the destroy button:
```
  <%= button_to "Logon as this user", user_logon_path(@user), method: :post %>
```
A couple points to notice: First, we can use user_logon_path, because we put ```as: user_logon``` into the route.  And the route takes a post.  But user_logon_path has a parameter, so we have to pass @user when we use it.  But, what in the world does button_to actually do? You can find out by going into developer tools to display the elements of the show page.  You'll see that button_to actually creates a complete form masquerading as a button.  It has a hidden field with an authenticity_token, which token is for security purposes, and another hidden field with a _method, so that the action (which really is always a POST), can be handled as a POST or a PATCH or a DELETE.

Now, we need to add a button for for logoff.  We'll add that, for the moment, to the user index view.  It only makes sense to log off if someone is logged on.  We need to change the controller to pass this information.  Add the following line to the index method of the user controller:
```
    @current_user = session[:current_user]
```
Then, just below the link_to line for "New User", add these lines:
```
<%= link_to "New user", new_user_path %>
<div>
  <% if @current_user %>
  <%= "#{@current_user["name"]} is logged on." %>
  <%= button_to "Log Off", user_logoff_path, method: :delete %>
  <% else %>
  No one is logged in.
  <% end %>
  </div>
```
If you try to do @current_user.name, you get an error.  What is stored in @currrent_user is just a hash, not the actual User instance, so that you can't invoke methods of the User object such as @current_user.name.  So we have to get the value with ```@current_user["name"]```.  If you open your browser developer tools, under the application tab, you'll see the cookie that is set to store session information.  You can't read it, though, because it's encrypted.  All that is being stored right now is the current user.

## What we'll do Next

We have created a basic application (with a lot of help from the  generated scaffolds).  We added our own routes for logon and logoff.  We have two models, Forum and Post.  But, hmm, we have forums with no way to post.  We want to be able to add posts to a forum, and those posts should belong to a particular user.  We also want a way for a user to be able to subscribe to forums.  In the next lesson, we'll create two more models, one for posts, and another for subscriptions.  These will involve associations: a post is associated both with a forum and with a user, and so is a subscription.  Users are associated with various forums through their subscriptions.  So the data model is is more complicated, and we can't just use scaffolds.

## Submitting Your Work

As usual, you add and commit the changes, in this case to the rails_basics branch, and then push that branch to github.  Then create a pull request and submit a link to the pull request in the homework submission form.

# Lesson 7: Active Record Associations

Apologies in advance: This is a *tough* lesson.  The code you need is below.  But, there is a lot of it, and you need not only to paste the code in correctly, you also need to *understand* what each line does.  Take your time with this lesson, and try to understand each part.  We'll schedule a catch up week to give you time to digest this information.

Associations in a database associate the records from different tables.  We want a forum to have many posts, so there is a one-to-many association between forums and posts.  (Remember one-to-many associations from the SQL lessons?  That's what is being done here, but using the Active Record ORM.)  A one-to-many association is created by putting a pointer called a foreign key into the posts table. The foreign key in each post record is the id of the forum record in the forums table.  Of course, there can be many posts with the same foreign key.

We also want to associate users with forums.  A user may subscribe to many forums, and a forum may have many users subscribed.  So, where do we put the foreign keys?  If we put one in the user record, that user could only subscribe to one forum.  If we put one in the forum record, that forum could only have one subscriber.  So, we use a separate table, called a join table, in which each record has two foreign keys, one for the user and one for the forum.  We'll call this table subscriptions.  We'll also put another column in, a numeric priority, so that the user can see the forums in the order of importance.  This is called a many-to-many-through association, because a user has many forums through subscriptions.

We'll also have a one to many association between user and posts, so that we know who created the post and who can edit it.  This means that the posts table will have another column with foreign keys.

Create a new branch called associations from the rails_basics branch.  This is where you'll put your work for this lesson. Important: There is quite a bit of work here!  It is easy to make a mistake that you can't find and that breaks what you've done so far.  **So, after you get each step working, git add and commit your work.**  That way, if something breaks, you can go back to the previous commit.

## Step 1: Some Adjustments to Appearance

Once we add these new models and the controllers and routes to manage them, the application will get messy to navigate.  So we'll add a nav bar.  We'll also change the default page, so that it shows the forums view.
Add this line to the top of the list of routes in config/routes.rb:
```
  root 'forums#index'
```
Then start the server and verify that http://localhost:3000 takes you straight to the forums page.  For the navbar, we'll do a little very crude styling. Don't pay much attention to this section! We'll do serious styling in a later lesson, so right now, just copy/paste. Add the following lines to app/assets/stylesheets/application.css:
```
 .ul-bar {
   list-style-type: none;
   margin: 5;
   padding: 5;
   background-color: lightblue;
 }
.dropdown {
  position: relative;
  display: inline-block;
}
.dropdown-li {
  position: relative;
  display: inline-block;
}
.dropdown-content {
    display: none;
    position: absolute;
    background-color: #f9f9f9;
    min-width: 160px;
    box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
    padding: 12px 16px;
    z-index: 1;
}
.dropdown:hover .dropdown-content {
    display: block;
}
```
And then add the following navigation bar.  We add this to the app/views/layouts/application.html.erb, so that it is always shown.  This should be added right above the yield statement:
```
 <% if session[:current_user] %>
  <%= "#{session[:current_user]["name"]} is logged on." %>
  <% else %>
  No one is logged on.
  <% end %>
    <ul class="ul-bar">
      <li class="dropdown"><span>Forums</span>
          <ul class="dropdown-content ul-bar">
            <li><a href="/forums">All forums </a></li>
            <li><a href="/forums/new">New forum </a></li>
          </ul>
      </li>
      <li class="dropdown"><span>Users</span>
          <ul class="dropdown-content ul-bar">
            <li><a href="/users">All Users</a></li>
            <li><a href="/users/new">New User</a></li>
            <li><%= button_to "Log Off", user_logoff_path, method: :delete %></li>
          </ul>
      </li>              
      <li class="dropdown"><span>Subscriptions</span>
          <ul class="dropdown-content ul-bar">
            <li><a href="/subscriptions">My subscriptions</a></li>
          </ul>
      </li>
    </ul>
```
This way, we always have navigation.  We also have an indication of who is logged on. We are accessing the session hash directly from the layout.  You can have a look at the revised appearance.  Well, it ain't beautiful, but it will do for now.

## Step 2: Creating the Models

We aren't using scaffolding for this part.  We have to do too much customization for scaffolding to be helpful, and in any case, you need to understand how to do each step.  We'll create first the models, then the routes, then the controllers, and the views.  A tip: When you do your own projects, give careful thought to the data model up front.  Fixing the data model afterwards is more difficult, because so many things depend on the model.

Stop the server and enter the following:
```
bin/rails generate model post title:string content:text forum:references user:references
bin/rails generate model subscription forum:references user:references priority:integer
bin/rails db:migrate
```
This sets up the tables as we want. The text datatype is for longer string input, for the content attribute. The references cause foreign keys to be added to the tables.  We create the post table to have two foreign keys: a user_id column, with the id of the user making the post, and a forum_id column, with the id of the forum for the post.  

We also want to make additions to the models.  Remember the model file you looked at before?  There was nothing in it.  By adding lines to the model files, you create methods to interact with post, subscription, forum, and user objects. Add the following:
```
# add in app/models/forum.rb (inside the class)
has_many :posts
has_many :subscriptions
has_many :users, through: :subscriptions

# You already have, in app/models/post.rb
belongs_to :user
belongs_to :forum

# You already have, in app/models/subscription.rb
belongs_to :user
belongs_to :forum

# add in app/models/user.rb
has_many :subscriptions
has_many :posts
has_many :forums, through: :subscriptions
```
None of these model entries affect the data in any way.  What they do is to give us access to *additional methods* to access data using the models.  We'll do that now.  Start the rails console, and then create entries as follows:
```
user = User.create(name: "Fred Smith", skill_level: "expert")
forum = Forum.create(forum_name: "HTMLTips", description: "some HTML clever ideas")
post = user.posts.create(forum: forum, title: "indentation", content: "I find that it is always helpful to indent correctly")
subscription = user.subscriptions.create(forum: forum, priority: 5)
user.subscriptions
user.posts
user.forums
forum.users
forum.posts
subscription.user
subscription.forum.forum_name
post.user.name
```
As you can see, whenever you have an association between records in one table and those in another, you can traverse that association to get all the relevant data, using the additional methods added to the model.  We'll use these methods in the controllers.  You could play with them further now, as much as you need to understand what they do.

## Step 3: Creating Routes and the Post Controller

We need routes for the CRUD operations on these new models.  (Remember CRUD: create, read, update, delete.)  For subscriptions and posts, we want routes that convey which forum we are subscribing or posting to.  One quick way to do that is as follows.  Change the statement for forum routes in config/routes.rb as follows:
```
  resources :forums do
    resources :posts, shallow: true, except: [:index]
    resources :subscriptions, shallow: true, except: [:index]
  end
  get '/subscriptions', to: 'subscriptions#index', as: 'subscriptions'
```
Then do ```bin/rails routes``` to see which routes you have created.  For posts, the route for a new forum post is get /forums/:forum_id/posts/new.  This causes the id of the forum to be included as a path parameter in the url.  On the other hand, get /posts/:id does not include the forum id to be included.  You don't need the forum id if you already have an existing post, because that post has a foreign key for the forum id. We chose ```shallow: true``` because we only wanted to include the forum id when it was needed.  We don't need the index action for posts, because we'll change the forum show view instead.  Review the other routes for posts and subscriptions to see what they do.  

We did not want the index action for subscriptions to be nested, for the following reason: If a user asks for a list of subscriptions, they want all of their own subscriptions, not all the subscriptions to a particular forum.

Now we create the posts controller.  Type the following:
```
bin/rails g controller posts create new edit show update destroy
```
This step also creates views.  However, when we don't use the scaffold, as we'll see, the controller methods are empty -- you have to write the code yourself -- and the created views aren't useful, so there is more work todo.  We'll start by editing the new posts controller.  We'll implement a policy that unless a user is logged in, access to the forum is read-only, and also that a user can only update or delete their own posts.  We'll also set some instance variables we need.

Note the use of percent notation below to create arrays.  Review percent notation from lesson 3 if you have forgotten.
```
# at the top of the PostsController class
  before_action :check_logon, except: %w[show]
  before_action :set_forum, only: %w[create new]
  before_action :set_post, only: %w[show edit update destroy]
  before_action :check_access, only: %w[edit update delete] # access control!! a user can only
                                       # edit or update or delete their own posts

# at the bottom
private

  def check_logon 
    if !session[:current_user]
      redirect_to forums_path, notice: "You can't add, modify, or delete posts before logon."
    end
  end

  def set_forum
    @forum = Forum.find(params[:forum_id])  # If you check the routes for posts, you see that this is the 
  end                                         # forum parameter

  def set_post
    @post = Post.find(params[:id])
  end

  def check_access
    if @post.user_id != session[:current_user][:id]
      redirect_to forums_path, notice: "That's not your post, so you can't change it."
    end
  end

  def post_params   # security check, also known as "strong parameters"
    params[:post][:user_id] = session[:current_user]["id"] 
       # here we have to add a parameter so that the post is associated with the current user
    params.require(:post).permit(:title,:content,:user_id)
  end
```
Having copied all this in, pause for a minute.  Do you understand what each part does?  If not logged on,  a user can do the post operation only -- for all the others, the user gets redirectted back to the main forums screen, with an error message.  As we need to know which forum is associated with the post, a private method is used to set the @forum instance variable.  (The methods in the private section can't be invoked except from within the class.) If we are showing or editing or updating or deleting a post, we need to know which post, so the @post instance variable has to be set too.

The controller methods for check_logon and check_access implement a security policy.  We could change the views so that various controls are disabled or hidden if the user is not logged in, or if that user is not authorized to change a post.  This would make the user interface more sensible, but it *would not suffice* to implement security!  It is very easy for someone to bypass the views by sending GET/POST/PUT/PATCH/DELETE methods directly to the controller.  Security must be implemented in the controller for security policies to hold.

When doing a create or update, we use the post_params, and this provides the "strong parameters" security check.  We also have to add the id for the logged on user to the params, and make it permitted.  The forms to create or update an entry do not contain the user_id, but it is a required part of the post record.

Ok, now we fill in the methods, one at a time.  Note that for some of them, nothing is needed.  Default behavior does what we want.
```
def create
  @post = @forum.posts.new(post_params)  # we create a new post for the current forum
  @post.save
  redirect_to @post, notice: "Your post was created."
end

def new
  @post = @forum.posts.new  
end

def edit    # nothing to do here
end

def show    # nothing to do here
end

def update
  @post = Post.new(post_params)
  @post.save
  redirect_to @post, notice: "Your post was updated."
end

def destroy
  @forum = @post.forum # we need to save this, so we can redirect to the forum after the destroy
  @post.destroy
  redirect_to @forum, notice: "Your post was deleted."
end
```
## Step 4: Posts Views

Have a look at app/views/posts/show.html.erb.  Well, that's disappointing!  Nothing there but boilerplate. So, delete all of the files in this directory! We have to start over.  Let's see: In the context of a forum, we just want to see the author and title of the post.  We'd also want to see those things when displaying the post itself, and also the content of the post.  So, we'll start with a partial, _post.html.erb:
```
<div id="<%= dom_id post %>">
  <p><%= "From #{post.user.name}:" %>
    <%= post.title %>
    <%= link_to "Show this post", post %>
  </p>
</div>
```
In show.html.erb, we need to display this same information plus the content and display the content, and add edit, delete, and back buttons:
```
<p style="color: green"><%= notice %></p>

 <p><%= "From #{@post.user.name}:" %>
    <%= @post.title %>
  </p><p>
    <%= @post.content %>
  </p>


<div>
  <%= link_to "Edit this post", edit_post_path(@post) %> |
  <%= link_to "Back to the forum", @post.forum %>

  <%= button_to "Destroy this post", @post, method: :delete %>
</div>
```
If you have sharp eyes, you'll note that we repeated some stuff that is also in the partial.  We do this so we can get the button in the partial to be on the same line as the author and title.  We know which forum to return to, because of the method we added to the Post model. The _post partial is to be used only by the show view for the forum.

We need another partial, a form for editing or creating a post, _form.html.erb.  A partial for a form starts with error handling, in case a user attempts to create a post that does not conform to validation rules.  This error processing doesn't do anything yet.  No errors will occur when creating or updating a post, because we are not validating entries.  In the next lesson, we'll learn how to do validations by adding to the models.
```
<%= form_with(model: post) do |form| %>
  <% if post.errors.any? %>
    <div style="color: red">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
        <% post.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :title, style: "display: block" %>
    <%= form.text_field : %>title
  </div>

  <div>
    <%= form.label :content, style: "display: block" %>
    <%= form.text_area :content,  size: "50x20" %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
The content of the post is a text_area, because the user will need room to type a long post.  Next is the new.html.erb:
```
<h1>New post</h1>

<%= render "form", post: @post %>

<br>

<div>
  <%= link_to "Back to the forum", @forum %>
</div>
```
For the new operation, remember, we set the @forum instance variable.  THe edit.html.erb view is similar:
```
<h1>Editing post</h1>

<%= render "form", post: @post %>

<br>

<div>
  <%= link_to "Show this post", @post %> |
  <%= link_to "Back to the forum", @post.forum %>
</div>
```
For the edit operation, we do not set the @forum variable, because the route is shallow, and does not have that parameter.  But the post already exists in this case, and the forum is associated with the post, so the back link uses @post.forum.  Wait -- where did that method, @post.forum, come from?  When you added the ```belongs_to :forum``` line in the post model, you told Active Record to add that method to the Post class.

These are all the views we need for posts.  But we do need to show the list of post authors and titles in the context of the forum, and also to add a link to create a new post.  This is done by adding the following lines to app/views/forums/show.html.erb, right after the line that says render @forum:
```
<%= render @forum.posts.order(updated_at: :desc) %>
<%= link_to "Create a new post", new_forum_post_path(@forum) %>
```
Note the use of the order method.  We want the newest posts to be on the top.  Active Record has many methods.  In fact, we could even specify exactly the SQL we want.  The reference for Active Record is [here.](https://www.rubydoc.info/gems/activerecord)

Ok, let's try everything out.  We can display the forums, and for those that have posts, we can see those posts, display them, and edit or delete them, but these latter operations only work if a user is logged on and is the originator of the post.  So far so good.  Now try adding a post.  Ouch!  That's a strange error: "undefined method posts_path".  Ok, this is tricky, so pay attention.  Rails is organized to use convention over configuration.  This means that there are always default behaviors. *But sometimes the default behaviors are wrong, and this can be difficult to figure out.* Have a look again at the routes for posts.  (One way to do this is to go to http://localhost:3000/routes .  You get an error message in your browser, but the error message shows all the routes.) You see that the route for updating a post is a PATCH for post_path(post).  That much would work -- if you could somehow get a post created, you could update it with the PATCH.  But the one for creating a post is a POST for forum_posts_path(post.forum).  Rails defaults to posts_path for the create, and that doesn't work because the route is nested.  We have to override the URL used by the form.

If @post.id is nil, that means the form is doing a create.  If @post.id is not nil, it is doing an update.  So we need logic as follows:
```
<% if post.id
  url = post_path
  else 
  url = forum_posts_path(post.forum)
  end %>
<%= form_with(model: post, url: url) do |form| %>
```
You'll find other cases where the Rails default behavior is not what you want, and some of these can be tricky to figure out.

Test each of the post operations and make sure they work.

## Step 5: Subscription Controller and Views

Whew, that was quite a bit of work! As this is becoming a long lesson, we'll try to take a shortcut.  The idea is to use the scaffold and fix what needs to change.  Enter the following:
```
bin/rails g scaffold subscription forum:references user:references priority:integer --skip-collision-check --skip-routes --no-migration
```
We tell the generate scaffold command to skip some steps because we already have the model, migration, and routes we need.  For some reason, ```--skip-routes``` doesn't work, **so you need to take ```resources :subscriptions``` out of the config/routes.rb.**  We didn't generate a migration, so there is no need to do a db:migrate.

Next, let's edit the subscriptions controller.  Subscriptions always belong to a user.  So, it doesn't make sense to do any subscription operations unless a user is logged on.  Also, for new and create operations, we need to know which forum the subscription is for.  So we need the following before_action statements and private methods.
```
before_action :check_logon
before_action :set_forum, only: %w[new create]


# in the private section
def check_logon 
  if !session[:current_user]
    redirect_to forums_path, notice: "You can't access subscriptions unless you are logged in."
  end
  @user = User.find(session[:current_user]["id"])  # we'll need this!
end

def set_forum
  @forum = Forum.find params[:forum_id]
end    

def set_subscription
  @subscription = Subscription.find_by(id: params[:id], user_id: @user.id)
end
```
Note the change to set_subscription!  We not only search on ```params[:id]```, but also on the ```@user.id```, and only return a value if BOTH of these SQL WHERE conditions match. This is authorization checking.  We do not want one user to be able to change or delete another user's subscriptions, so we make sure that the subscription is for the currently logged on user.

Next we modify the methods one by one.  As you see below, there are only four changed lines.  However, one of them is, hmm, interesting.  What do we want to do when displaying the subscriptions?  Here the idea is that we render a list of forums to which the user has subscribed.  Not too bad.  However, we want to render them in ascending order of the priority of the subscription.  That's not so easy.  To do that, we need to join several tables: i.e. SQL! THere are two ways to do this.  One is to figure out Active Record semantics, and you end up with a statement like this:
```
  Forum.joins(:subscriptions).where(subscriptions: {user_id: @user.id}).order(:priority)
```
One could instead specify the SQL that is wanted:
```
  Forum.find_by_sql("SELECT forums.* from forums JOIN subscriptions ON forums.id = forum_id WHERE user_id = $1 ORDER BY priority",[@user.id])
```
However, dropping into SQL is considered a bad practice, if you can instead use the Active Record methods.  You'll note that the Active Record way of doing things is more compact.  SQL!  Back end programmers can't get away from it.  Here are our revised controller methods:
```
  # GET /subscriptions or /subscriptions.json
  def index
   @forums = Forum.joins(:subscriptions).where(subscriptions: {user_id: @user.id}).order(:priority)
  end

  # GET /subscriptions/1 or /subscriptions/1.json
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = @user.subscriptions.new # change
    @subscription.forum_id = @forum.id      # change
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions or /subscriptions.json
  def create
    @subscription = @user.subscriptions.new(subscription_params) # change

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to subscription_url(@subscription), notice: "Subscription was successfully created." }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscriptions/1 or /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to subscription_url(@subscription), notice: "Subscription was successfully updated." }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1 or /subscriptions/1.json
  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to subscriptions_url, notice: "Subscription was successfully destroyed." }
      format.json { head :no_content }
    end
  end
```
The use of the scaffold saved some work, but we're not done yet.  Let's look at the views, starting with app/views/subscriptions/_form.html.erb.  Right off the bat, we see that we have the same problem with the form_with.  The code should look like:
```
<% if subscription.id
  url = subscription_path
  else 
  url = forum_subscriptions_path(subscription.forum)
  end %>
<%= form_with(model: subscription, url: url) do |form| %>
```
We don't need input fields for forum_id or user_id, because those values come out of the context.  We can take those sections out -- but we should replace them with an indicator of the forum for the subscription:
```
<h2><%= "Subscription for forum #{subscription.forum.forum_name}." %></h2>
```
Also for the priority number_field, we add the option ```in: 1..10``` so that the user can set a priority from 1 to 10.   That completes the work on the form. Next, in _subscription.html.erb, we make a change to display subscription.forum.forum_name instead of the forum_id, and we don't need to display the user_id so that part is taken out.

We don't have to change the other forms except for index.html.erb.  We want this one to render the list of forums, as retrieved and ordered by the SQL, and we also want the user to be able to edit and delete the subscription for each.  As follows:
```
<h1>Subscriptions</h1>

<div id="subscriptions">
  <% @forums.each do |forum| %>
 <%= render partial: "forums/forum",  locals: {forum: forum} %>
<%= render forum.posts.order(updated_at: :desc) %>
<%= link_to "Create a new post", new_forum_post_path(forum) %>
      <% subscription = Subscription.find_by(forum_id: forum.id, user_id: @user.id) %>
      <%= link_to "Show this subscription", subscription_path(subscription) %>
  <% end %>
</div>

```
We don't need the "new subscription" link.  We instead add a Subscribe link to the index view for forums:
```
<%= link_to "Subscribe", new_forum_subscription_path(forum) %>
```
This line should be right after the "show this forum" link.  Now, there's one other thing we ought to check.  It does not make sense for a user to subscribe to a forum they have already subscribed to.  So we add this check to the start of the new method in the subscriptions controller:
```
    if @forum.subscriptions.where(user_id: @user.id).any?
      redirect_to forums_path, notice: "You are already subscribed to that forum."
    end
```
This completes the work on subscriptions.

## Step 6: Test

Try each of the functions of the application to verify that everything works.

## Appearance and Human Factors

The focus here has been on concepts and in particular on associations within Active Record.  When creating a real application, you must consider other things.  Frankly, this application is ugly.  Also, it doesn't have good human factors.  There are many cases where a user can try something and be told that it isn't allowed.  It would be better to hide such controls if the user is not logged in or not authorized.  Also, there is no validation of what is entered.  There is no exception handling, so that, for example, if you try to delete a forum with posts, you get an error message about a foreign key constraint. (Try this.) For a more serious project, one would do quite a bit of storyboarding to see what the appearance should be.

## Other Types of Associations

We have implemented a one-to-many association (a user has many subscriptions) and a many-to-many association (a user can subscribe to many forums, and many users can subscribe to a given forum).  This is really a many-to-many-through association, because the subscriptions table acts as a join table for users and forums, but the subscriptions table also has its own attributes, in this case the priority column.  Be aware that there are other kinds of associations enabled by Active Record, such as has_one associations and polymorphic associations.  So ... there's always more to learn.

## Submitting Your Work

Pat yourself on the back, this was a big one. As usual, you add and commit your changes to the associations branch, push that branch to github, create the pull request, and submit a link to the PR in your homework submission form.