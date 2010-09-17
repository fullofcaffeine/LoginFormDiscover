require 'rubygems'
require 'net/http'
require 'mechanize'
require 'ruby-debug'

#first needs to search google for relevant websites. We need to decide
#what "relevant" is, maybe configuring keywords or a more intelligent
#algorithm would be needed. The GOAL is to, given the input (keywords,
#regexps or whatever) it finds the most relevant results and tries to
#create connectors for them.

#Crazy idea: A DSL that would abstract all Mechanize/spidering and any
#other complex algorithm could be nice, in a more declarative way

#Need to introduce some search smartness like scoring or something
#when serveral links are found that are similar, maybe keep a database
#of data to "learn" from it.

#Also need to deal with pages where the login for is not one level
#deep, but in the pages itself (like facebook.com)

#by querying google for certain keywords, let's parse the results


login_forms = {}


#a.get('http://google.com/') do |page|
#    search_result = page.form_with(:name => 'f') do |search|
#      search.q = 'onelogin'
#    end.submit


def check_has_form(page)
  inputs = page.search('input')
  inputs.each do |input|
    attrs = input.attributes.select { |k,v| v.value =~ /^name|login|password|username|^email$$/i } 
    go_ahead = (!attrs.compact.empty?)
    if go_ahead
      puts "I think I found the login url for  #{page.uri.to_s}"
      login_page = page
      puts ">> #{login_page.uri}\n\n"
      return true
    end

    
  end
  return false
end

def check_page(url)
a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mechanize'
}


  a.get(url) do |page|

  possible_links = []

 if check_has_form(page) 
   puts "#{page.uri.to_s} has the login form on this very same page!"
 else
  
  page.links.each do |plink|
    if plink.uri.to_s =~ /login|signin|signon|signup/i
      possible_links << plink
    end
  end
  #Let's see if we can guess if this is a login page or not
  possible_links.each do |plink|
    #dumb algorithm to try to see if this is a login form
    
    possible_login_page = plink.click
    
    break if check_has_form(possible_login_page)
    
    end
 end
end

end


File.open('sites.txt').read.each_line do |url|
  check_page(url)
end
  

