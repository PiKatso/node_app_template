require "fileutils"

class ProjectBuilder

  attr_accessor :project_name
  attr_accessor :project_path
  attr_accessor :lib_path
  attr_accessor :spec_path
  attr_accessor :views_path
  attr_accessor :css_path
  attr_accessor :img_path
  attr_accessor :js_path

  def initialize(project)
    self.project_name = project
    self.project_path = File.expand_path(File.join("~", "Desktop", project_name))
    self.lib_path = File.join(project_path, "lib")
    self.spec_path = File.join(project_path, "spec")
    self.views_path = File.join(project_path, "views")
    self.css_path = File.join(project_path, "public/css")
    self.img_path = File.join(project_path, "public/img")
    self.js_path = File.join(project_path, "public/js")
  end

  def build_folders
    [lib_path, spec_path, views_path, css_path, img_path, js_path].each do |folder|
      FileUtils.mkdir_p(folder)
    end
  end
  
  def write_contents(path, filename, contents = "")
    File.open(File.join(path, filename), "w") do |f|
      f.write(contents)
    end
  end

  def build_files
    write_contents project_path, "app.rb", <<-TEXT
require 'sinatra'
require 'sinatra/reloader'
require './lib/#{project_name}'
require 'pry'

also_reload('lib/**/*.rb')

get('/') do
  erb(:index)
end
TEXT

    write_contents project_path, "config.ru", <<-TEXT
require ('./app')
run Sinatra::Application
TEXT

    write_contents project_path, "Gemfile", <<-TEXT
source "https://rubygems.org"
# ruby "2.4.1"

gem "sinatra"
gem "sinatra-contrib"
gem "rspec"
gem "capybara"
gem "pry"
TEXT

    write_contents project_path, "README.md", <<-TEXT
# <!--PROJECT NAME HERE-->

<!--PROJECT DESCRIPTION HERE-->

### Prerequisites

Web browser with ES6 compatibility
Examples: Chrome, Safari

Ruby <!--VERSION HERE-->
Bundler

### Installing

Installation is quick and easy! First you can open this link <!--HEROKU LINK HERE--> to see the webpage in action live online. Or you can clone this repository to your machine, navigate to the file path in your terminal, and run 'app.rb' by typing '$ruby app.rb'. If you chose to clone the repository, after you run 'app.rb' you will need to copy the localhost path into your web browser. The standard localhost for Sinatra is port 4567

## Built With

* Ruby
* Sinatra
* HTML
* CSS
* Bootstrap https://getbootstrap.com/
* ES6
* Jquery https://jquery.com/

## Specifications

| behavior |  input   |  output  |
|----------|:--------:|:--------:|
<!--SPECS GO HERE-->
 
## Authors

* <!--YOUR NAME HERE-->

## License

Copyright © 2017 <!--YOUR NAME HERE-->
TEXT

    write_contents lib_path, "#{project_name}.rb", <<-TEXT
# example ruby code

# class Palindrome

#   def is_word?(user_input)
#     user_input.match?(/[aeiouy]+/i)
#   end

# end
TEXT

    write_contents spec_path, "#{project_name}_spec.rb", <<-TEXT
require "#{project_name}"
require "rspec"
require "pry"


# example project spec

# describe 'Palindrome#isWord?' do
#   let(:word) { Palindrome.new }

#   it "returns true if the word has at least one vowel" do
#     expect(word.is_word?("word")).to eq true
#   end

#   it "returns false if the word does not have a vowel" do
#     expect(word.is_word?("wrd")).to eq false
#   end

# end
TEXT

    write_contents spec_path, "#{project_name}_integration_spec.rb", <<-TEXT
require "capybara/rspec"
require "./app"

Capybara.app = Sinatra::Application
set(:show_exceptions, false)

# example integration test

# describe("the phrase parser path", {:type => :feature}) do
#   it("processes the user input and returns correct message if its a palindrome") do
#     visit("/")
#     fill_in("phrase1", :with => "madam")
#     fill_in("phrase2", :with => "anagram")
#     click_button("what am i?")
#     expect(page).to have_content("'madam' is a palindrome")
#   end
# end
TEXT

    write_contents views_path, "index.erb", <<-TEXT
<%= # sample index html
# <form action="/phrase_parser">
#   <div class="form-group">
#      <label for="title">gimme phrase or word!</label>
#      <input name="phrase1" class="form-control" type="text">
#      <label for="title">gimme another!</label>
#      <input name="phrase2" class="form-control" type="text">
#   </div>
#   <hr>
#   <button action="/" class="btn btn-success">what am i?</button>
# </form>
%>
TEXT

    write_contents views_path, "layout.erb", <<-TEXT
<!DOCTYPE html>
<html>
  <head>
    <title></title>
    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>
    <link  rel='stylesheet' href="/css/styles.css" >
    <script src="https://code.jquery.com/jquery-3.2.1.js" integrity="sha256-DZAnKJ/6XZ9si04Hgrsxu/8s717jcIzLy3oi35EouyE=" crossorigin="anonymous"></script>
    <script src="js/scripts.js"></script>
  </head>
  <body>
    <div class="container">
    <h1></h1>
    <hr>
      <%= yield %>
    </div>
  </body>
</html>
TEXT

    write_contents views_path, "output.erb", <<-TEXT
<%= # sample output html
# <h2><%= @message %></h2>
# <hr>
# <a href="/" class="btn btn-danger">reset</a>
%>
TEXT

    write_contents css_path, "styles.css"

    write_contents js_path, "scripts.js"

  end
  
end

puts "What is the name of your project?"

project_name = $stdin.gets.chomp
project_name.gsub!(/\s/, "_")
project_name.gsub!(/\W/, "")
project_name = "project" if project_name == ""

puts "Building #{project_name}........"

new_project = ProjectBuilder.new(project_name)

new_project.build_folders
new_project.build_files

puts "Running bundler........"

`BUNDLE_GEMFILE=#{new_project.project_path}/Gemfile bundle install`

puts "#{new_project.project_name} built at:"
puts new_project.project_path