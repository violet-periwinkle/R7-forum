In Assignment 7.1, you built most of the application, but there is one more significant step.  You need to build a way for a user to subscribe to the various forums.  Create a new branch, lesson7_2, for this work.

## Step 5: Subscription Controller and Views

To complete the application, we'll try to take a shortcut.  The idea is to use the scaffold and fix what needs to change.  Enter the following:
```
bin/rails g scaffold subscription forum:references user:references priority:integer --skip-collision-check --skip-routes --no-migration
```
We tell the generate scaffold command to skip some steps because we already have the model, migration, and routes we need.  For some reason, ```--skip-routes``` doesn't work, **so you need to take ```resources :subscriptions``` out of the config/routes.rb.**  We didn't generate a migration, so there is no need to do a db:migrate.

Next, let's edit the subscriptions controller.  Subscriptions always belong to a user.  So, it doesn't make sense to do any subscription operations unless a user is logged on.  Also, for new and create operations, we need to know which forum the subscription is for.  So we need the following before_action statements and private methods.
```ruby
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
```ruby
  Forum.joins(:subscriptions).where(subscriptions: {user_id: @user.id}).order(:priority)
```
One could instead specify the SQL that is wanted:
```ruby
  Forum.find_by_sql("SELECT forums.* from forums JOIN subscriptions ON forums.id = forum_id WHERE user_id = $1 ORDER BY priority",[@user.id])
```
However, dropping into SQL is considered a bad practice, if you can instead use the Active Record methods.  You'll note that the Active Record way of doing things is more compact.  SQL!  Back end programmers can't get away from it.

By the way, if we didn't care about the priority order, we could just get the list of forums with:
```ruby
@current_user.forums
```
Here are our revised controller methods:
```ruby
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
```ruby
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

As usual, add, commit, and push your changes for the lesson7_2 branch, and then create the pull request.  This completes your work for this repository.  Next week we'll start on something new.
