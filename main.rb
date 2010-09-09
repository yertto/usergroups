#!/usr/local/bin/ruby -rrubygems
require 'sinatra'

require 'roady'
require 'db'


enable :sessions


def get_user
  User.first({ :id => session[:user_id] })
end

def set_user
  pin = rand(1000)
  user = User.create({ :pin => pin })
  session[:user_id] = user.id
  user
end


get '/' do
  haml :index
end

get '/signup' do
  set_user
  redirect '/'
end

get '/signout' do
  session.delete(:user_id)
  redirect '/'
end

get '/users/:id/:pin/private' do
  user = User.first(params)
  if user
    session[:user_id] = user.id
    redirect '/'
  else
    haml :notfound, :locals => params
  end
end

get '/users/:id/:pin/create_new_group' do
  user = User.first(params)
  if user
    group = user.groups.create()
    redirect env['HTTP_REFERER']
  else
    haml :notfound, :locals => params
  end
end

get '/groups/:id/join' do
  group = Group.first(params)
  if group
    user = get_user
    if user
      user.groups << group if group
      user.save
      redirect env['HTTP_REFERER']
    else
      redirect '/'  # not logged in
    end
  else
    "group doesn't exist"
  end
end

create_get '/users'        , User
create_get '/groups'       , Group
create_get '/users/:id'    , User
create_get '/groups/:id'   , Group

__END__

@@ _header
%div
  %small
    = haml :_all_users_a
    = haml :_all_groups_a
    - if user
      Logged in as:
      = haml :_user_a , :locals => { :user => user }
      = haml :_signout_a
    - else
      = haml :_signup_a


@@ _signup_a
(
%a(href='/signup') signup
)

@@ _signout_a
(
%a(href='/signout') signout
)


@@ _all_users_a
(
%a(href='/users') All users
)


@@ _all_groups_a
(
%a(href='/groups') All groups
)


@@ _user_private
%a(href="/users/#{user.id}/#{user.pin}/private")= "http://#{env['HTTP_HOST']}/users/#{user.id}/#{user.pin}/private"


@@ _group_users
%small
  ( Join this group with:
  %a(href="/groups/#{group.id}/join")= "http://#{env['HTTP_HOST']}/groups/#{group.id}/join"
  )
%h4 has users:
%ul
  - group.users.each do |user|
    %li= haml :_user_a, :locals => { :user => user }


@@ _user
%small
- if user.id == session[:user_id]
  Logged in as:
  = user.inspect.gsub('<', '&lt;').gsub('>', '&gt;')
- else
  %small
    ( Login as this user with:
    = haml :_user_private , :locals => { :user => user }
    )
%div
  = haml :_user_groups , :locals => { :user => user }


@@ _user_groups
%h4 belongs to groups:
%ul
  - user.groups.each do |group|
    %li
      = haml :_group_a , :locals => { :group => group }
  - if user.id == session[:user_id]
    %li
      %a(href="/users/#{user.id}/#{user.pin}/create_new_group") create new group




@@ user
%h3= user
= haml :_user, :locals => { :user => user }
  

@@ users
- users.each do |user|
  %h3= haml :_user_a , :locals => { :user => user }
  = haml :_user, :locals => { :user => user }
  %hr


@@ group
%h3= group
= haml :_group_users, :locals => { :group => group }


@@ groups
- groups.each do |group|
  %h3= haml :_group_a , :locals => { :group => group }
  = haml :_group_users, :locals => { :group => group }
  %hr


@@ notfound
= "User id/pin not found: #{id}/#{pin}"
This private entrance doesn't exist.
You need to rejoin
%a(href='/') here


@@ index
%h3 Hello World!


@@ layout
%html
  %head
    %title UserGroups
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/css/main.css'}
  %body
    = haml :_header , :locals => { :user => get_user }
    = yield
