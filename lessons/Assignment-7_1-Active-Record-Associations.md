Apologies in advance: This is a *tough* lesson.  The code you need is below.  But, there is a lot of it, and you need not only to paste the code in correctly, you also need to *understand* what each line does.  Take your time with this lesson, and try to understand each part.  We'll schedule a catch up week to give you time to digest this information.

Associations in a database associate the records from different tables.  We want a forum to have many posts, so there is a one-to-many association between forums and posts.  (Remember one-to-many associations from the SQL lessons?  That's what is being done here, but using the Active Record ORM.)  A one-to-many association is created by putting a pointer called a foreign key into the posts table. The foreign key in each post record is the id of the forum record in the forums table.  Of course, there can be many posts with the same foreign key.

We also want to associate users with forums.  A user may subscribe to many forums, and a forum may have many users subscribed.  So, where do we put the foreign keys?  If we put one in the user record, that user could only subscribe to one forum.  If we put one in the forum record, that forum could only have one subscriber.  So, we use a separate table, called a join table, in which each record has two foreign keys, one for the user and one for the forum.  We'll give this join table the name subscriptions.  We'll also put another column into subscriptions, a numeric priority, so that the user can see the forums in the order of importance.  This is called a many-to-many-through association, because a user has many forums, and each forum has many users, connected through subscriptions.

We'll also have a one to many association between user and posts, so that we know who created the post and who can edit it.  This means that the posts table will have another column with foreign keys: A user has many posts.

Create a new branch called lesson7_1 from the lesson6 branch.  This is where you'll put your work for this lesson. Important: There is quite a bit of work here!  It is easy to make a mistake that you can't find and that breaks what you've done so far.  **So, after you get each step working, git add and commit your work.**  That way, if something breaks, you can go back to the previous commit.

## Step 1: Some Adjustments to Appearance

Once we add these new models and the controllers and routes to manage them, the application will get messy to navigate.  So we'll add a nav bar.  We'll also change the default page, so that it shows the forums view.
Add this line to the top of the list of routes in config/routes.rb:
```ruby
  root 'forums#index'
```
Then start the server and verify that http://localhost:3000 takes you straight to the forums page.

For each of the controllers and views, we need to know whether there is a logged on user.  We want to do this in one place only.  So, change `app/controllers/application_controller.rb`.  This controller is the superclass of all the others, so that code here runs for every request.  Change it as follows:
```ruby
class ApplicationController < ActionController::Base
  before_action :set_current_user

private
  def set_current_user
    if session[:current_user]
      @current_user = User.find(session[:current_user])
    else
      @current_user = nil
    end
  end
end
```
This same code is duplicated in the index method of `app\controllers\user.rb`.  You don't want to repeat yourself, so take it out of the there.  (By the way, the before_action in application_controller.rb is done before any of the before_action methods in the other controllers.)

For the navbar, we'll do a little very crude styling. Don't pay much attention to this section! We'll do serious styling in a later lesson, so right now, just copy/paste. Add the following lines to app/assets/stylesheets/application.css:
```css
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
```html
 <% if @current_user %>
  <%= "#{@current_user.name} is logged on." %>
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
This way, we always have navigation.  We also have an indication of who is logged on.  You can have a look at the revised appearance.  Well, it ain't beautiful, but it will do for now.

## Step 2: Creating the Models

We aren't using scaffolding for this part.  We have to do too much customization for scaffolding to be helpful, and in any case, you need to understand how to do each step.  We'll create first the models, then the routes, then the controllers, and then the views.  A tip: When you do your own projects, give careful thought to the data model up front.  Fixing the data model afterwards is more difficult, because so many things depend on the model.

Stop the server and enter the following:
```bash
bin/rails generate model post title:string content:text forum:references user:references
bin/rails generate model subscription forum:references user:references priority:integer
bin/rails db:migrate
```
This sets up the tables as we want. The text datatype is for longer string input, for the content attribute. The references cause foreign keys to be added to the tables.  We create the post table to have two foreign keys: a user_id column, with the id of the user making the post, and a forum_id column, with the id of the forum for the post.  

We also want to make additions to the models.  Remember the model file you looked at before?  There was nothing in it.  By adding lines to the model files, you create methods to interact with post, subscription, forum, and user objects. Add the following:
```ruby
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
```ruby
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
```ruby
  resources :forums do
    resources :posts, shallow: true, except: [:index]
    resources :subscriptions, shallow: true, except: [:index]
  end
  get '/subscriptions', to: 'subscriptions#index', as: 'subscriptions'
```
Then do ```bin/rails routes``` to see which routes you have created.  For posts, the route for a new forum post is get /forums/:forum_id/posts/new.  This causes the id of the forum to be included as a path parameter in the url.  On the other hand, get /posts/:id does not include the forum id to be included.  You don't need the forum id if you already have an existing post, because that post has a foreign key for the forum id. We chose ```shallow: true``` because we only wanted to include the forum id when it was needed.  We don't need the index action for the posts controller at all, because we'll show the posts in the forum show view instead.  Review the other routes for posts and subscriptions to see what they do.  

We did not want the index action for subscriptions to be nested, for the following reason: If a user asks for a list of subscriptions, they want all of their own subscriptions, not all the subscriptions to a particular forum.

Now we create the posts controller.  Type the following:
```bash
bin/rails g controller posts create new edit show update destroy
```
This step also creates views.  However, when we don't use the scaffold, as we'll see, the controller methods are empty -- you have to write the code yourself -- and the created views aren't useful, so there is more work to do.  We'll start by editing the new posts controller.  We'll implement a policy that unless a user is logged in, access to the forum is read-only, and also that a user can only update or delete their own posts.  We'll also set some instance variables we need.

Note the use of percent notation below to create arrays.  Review percent notation from lesson 3 if you have forgotten.
```ruby
# at the top of the PostsController class
  before_action :check_logon, except: %w[show]
  before_action :set_forum, only: %w[create new]
  before_action :set_post, only: %w[show edit update destroy]
  before_action :check_access, only: %w[edit update delete] # access control!! a user can only
                                       # edit or update or delete their own posts

# at the bottom
private

  def check_logon 
    if !@current_user
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
Having copied all this in, pause for a minute.  Do you understand what each part does?  If not logged on,  a user can do the post operation only -- for all the others, the user gets redirected back to the main forums screen, with an error message.  As we need to know which forum is associated with the post, a private method is used to set the @forum instance variable.  (The methods in the private section can't be invoked except from within the class.) If we are showing or editing or updating or deleting a post, we need to know which post, so the @post instance variable has to be set too.

The controller methods for check_logon and check_access implement a security policy.  We could change the views so that various controls are disabled or hidden if the user is not logged in, or if that user is not authorized to change a post.  This would make the user interface more sensible, but it *would not suffice* to implement security!  It is very easy for someone to bypass the views by sending GET/POST/PUT/PATCH/DELETE methods directly to the controller.  Security must be implemented in the controller for security policies to hold.  So, in the controller, we make sure that the user can only edit, delete, or update their own posts.  They can show other people's posts, but they can't change them.

When doing a create or update, we use the post_params, and this provides the "strong parameters" security check.  We also have to add the id for the logged on user to the params, and make it permitted.  The forms to create or update an entry do not contain the user_id, but it is a required part of the post record.

Ok, now we fill in the methods, one at a time.  Note that for some of them, nothing is needed.  Default behavior does what we want.
```ruby
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
```html
<div id="<%= dom_id post %>">
  <p><%= "From #{post.user.name}:" %>
    <%= post.title %>
    <%= link_to "Show this post", post %>
  </p>
</div>
```
In show.html.erb, we need to display this same information plus the content and display the content, and add edit, delete, and back buttons:
```html
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
If you have sharp eyes, you'll note that we repeated some stuff that is also in the partial.  We do this so we can get the button in the partial to be on the same line as the author and title.  We know which forum to return to, because of the post.forum method we added to the Post model. The _post partial is to be used only by the show view for the forum.

We need another partial, a form for editing or creating a post, _form.html.erb.  A partial for a form starts with error handling, in case a user attempts to create a post that does not conform to validation rules.  This error processing doesn't do anything yet.  No errors will occur when creating or updating a post, because we are not validating entries.  In a later lesson, we'll learn how to do validations by adding to the models.
```html
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
    <%= form.text_field :title %>
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
```html
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

If @post.id is nil, that means the form is doing a create.  If @post.id is not nil, it is doing an update.  So we need the following logic, at the top of `app/views/posts/_form.html.erb` (and the form_with line is changed):
```
<% if post.id
  url = post_path
  else 
  url = forum_posts_path(post.forum)
  end %>
<%= form_with(model: post, url: url) do |form| %>
```
You'll find other cases where the Rails default behavior is not what you want, and some of these can be tricky to figure out.

Test each of the create, show, edit, update, and delete operations to make sure everything works.

## Checking for Understanding

Again there are some questions to answer, in lesson7-questions-txt. You need to edit this file and put in the answers.  Feel free to discuss possible answers or confusion points on Slack.

## Submitting Your Work

Pat yourself on the back, this was a big one. As usual, you add and commit your changes to the lesson7_1 branch, push that branch to github, create the pull request, and submit a link to the PR in your homework submission form.
