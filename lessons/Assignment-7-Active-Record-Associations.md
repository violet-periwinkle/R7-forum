Apologies in advance: This is a *tough* lesson.  The code you need is below.  But, there is a lot of it, and you need not only to paste the code in correctly, you also need to *understand* what each line does.  Take your time with this lesson, and try to understand each part.  We'll schedule a catch up week to give you time to digest this information.

Associations in a database associate the records from different tables.  We want a forum to have many posts, so there is a one-to-many association between forums and posts.  (Remember one-to-many associations from the SQL lessons?  That's what is being done here, but using the Active Record ORM.)  A one-to-many association is created by putting a pointer called a foreign key into the posts table. The foreign key in each post record is the id of the forum record in the forums table.  Of course, there can be many posts with the same foreign key.

We also want to associate users with forums.  A user may subscribe to many forums, and a forum may have many users subscribed.  So, where do we put the foreign keys?  If we put one in the user record, that user could only subscribe to one forum.  If we put one in the forum record, that forum could only have one subscriber.  So, we use a separate table, called a join table, in which each record has two foreign keys, one for the user and one for the forum.  We'll give this join table the name subscriptions.  We'll also put another column into subscriptions, a numeric priority, so that the user can see the forums in the order of importance.  This is called a many-to-many-through association, because a user has many forums, and each forum has many users, connected through subscriptions.

We'll also have a one to many association between user and posts, so that we know who created the post and who can edit it.  This means that the posts table will have another column with foreign keys: A user has many posts.

Create a new branch called lesson7 from the lesson6 branch.  This is where you'll put your work for this lesson. Important: There is quite a bit of work here!  It is easy to make a mistake that you can't find and that breaks what you've done so far.  **So, after you get each step working, git add and commit your work.**  That way, if something breaks, you can go back to the previous commit.

## Step 1: Some Adjustments to Appearance

Once we add these new models and the controllers and routes to manage them, the application will get messy to navigate.  So we'll add a nav bar.  We'll also change the default page, so that it shows the forums view.
Add this line to the top of the list of routes in config/routes.rb:
```
  root 'forums#index'
```
Then start the server and verify that http://localhost:3000 takes you straight to the forums page.

For each of the controllers and views, we need to know whether there is a logged on user.  We want to do this in one place only.  So, change `app/controllers/application_controller.rb`.  This controller is the superclass of all the others, so that code here runs for every request.  Change it as follows:
```
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
Then do ```bin/rails routes``` to see which routes you have created.  For posts, the route for a new forum post is get /forums/:forum_id/posts/new.  This causes the id of the forum to be included as a path parameter in the url.  On the other hand, get /posts/:id does not include the forum id to be included.  You don't need the forum id if you already have an existing post, because that post has a foreign key for the forum id. We chose ```shallow: true``` because we only wanted to include the forum id when it was needed.  We don't need the index action for the posts controller at all, because we'll show the posts in the forum show view instead.  Review the other routes for posts and subscriptions to see what they do.  

We did not want the index action for subscriptions to be nested, for the following reason: If a user asks for a list of subscriptions, they want all of their own subscriptions, not all the subscriptions to a particular forum.

Now we create the posts controller.  Type the following:
```
bin/rails g controller posts create new edit show update destroy
```
This step also creates views.  However, when we don't use the scaffold, as we'll see, the controller methods are empty -- you have to write the code yourself -- and the created views aren't useful, so there is more work to do.  We'll start by editing the new posts controller.  We'll implement a policy that unless a user is logged in, access to the forum is read-only, and also that a user can only update or delete their own posts.  We'll also set some instance variables we need.

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
If you have sharp eyes, you'll note that we repeated some stuff that is also in the partial.  We do this so we can get the button in the partial to be on the same line as the author and title.  We know which forum to return to, because of the post.forum method we added to the Post model. The _post partial is to be used only by the show view for the forum.

We need another partial, a form for editing or creating a post, _form.html.erb.  A partial for a form starts with error handling, in case a user attempts to create a post that does not conform to validation rules.  This error processing doesn't do anything yet.  No errors will occur when creating or updating a post, because we are not validating entries.  In a later lesson, we'll learn how to do validations by adding to the models.
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
  if !@current_user
    redirect_to forums_path, notice: "You can't access subscriptions unless you are logged in."
  end
end

def set_forum
  @forum = Forum.find params[:forum_id]
end    

def set_subscription
  @subscription = Subscription.find_by(id: params[:id], user_id: @current_user.id)
end
```
Note the change to set_subscription!  We not only search on ```params[:id]```, but also on the ```@current_user.id```, and only return a value if BOTH of these SQL WHERE conditions match. This is authorization checking.  We do not want one user to be able to change or delete another user's subscriptions, so we make sure that the subscription is for the currently logged on user.

Next we modify the methods one by one.  As you see below, there are only four changed lines.  However, one of them is, hmm, interesting.  What do we want to do when displaying the subscriptions?  Here the idea is that we render a list of forums to which the user has subscribed.  Not too bad.  However, we want to render them in ascending order of the priority of the subscription.  That's not so easy.  To do that, we need to join several tables: i.e. SQL! THere are two ways to do this.  One is to figure out Active Record semantics, and you end up with a statement like this:
```
  Forum.joins(:subscriptions).where(subscriptions: {user_id: @user.id}).order(:priority)
```
One could instead specify the SQL that is wanted:
```
  Forum.find_by_sql("SELECT forums.* from forums JOIN subscriptions ON forums.id = forum_id WHERE user_id = $1 ORDER BY priority",[@user.id])
```
However, dropping into SQL is considered a bad practice, if you can instead use the Active Record methods.  You'll note that the Active Record way of doing things is more compact.  SQL!  Back end programmers can't get away from it.

By the way, if we didn't care about the priority order, we could just get the list of forums with:
```
@current_user.forums
```
Here are our revised controller methods:
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
We don't need the "new subscription" link.  It would be clumsy here, because we'd have to include something in the form so that the user could specify which forum they want to subscribe to.  So remove this line:
```
<%= link_to "Subscribe", new_forum_subscription_path(forum) %>
```
We instead add a Subscribe link to the index view for forums:
```
<%= link_to "Subscribe", new_forum_subscription_path(forum) %>
```
This line should be right after the "show this forum" link.  Now, there's one other thing we ought to check.  It does not make sense for a user to subscribe to a forum that they have already subscribed to.  So we add this check to the start of the new method in the subscriptions controller:
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

Pat yourself on the back, this was a big one. As usual, you add and commit your changes to the lesson7 branch, push that branch to github, create the pull request, and submit a link to the PR in your homework submission form.