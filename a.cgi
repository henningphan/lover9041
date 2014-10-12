#!/usr/bin/perl -w

# written by andrewt@cse.unsw.edu.au September 2013
# as a starting point for COMP2041/9041 assignment 2
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/LOVE2041/

use CGI qw/:all/;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use Data::Dumper;  
use List::Util qw/min max/;
use Cwd 'abs_path';
use FindBin;
use My::Login qw(authenticate);
warningsToBrowser(1);

# Relative paths will be correct if we use the scripts location as working directory
chdir $FindBin::Bin;
# print start of HTML ASAP to assist debugging if there is an error in the script

# some globals used through the script
$debug = 1;
$students_dir = "./students";

$q = CGI->new;
$cook = cookie("username");
if($ENV{"QUERY_STRING"} eq "login"){
    $postUsername = param("username");
    $postPwd = param ("password");
    if( authenticate($postUsername, $postPwd)){
      $cookieUsername = cookie(
        -name => "username",
        -value=> "$postUsername");
      $cookiePwd = cookie(
        -name => "password",
        -value=> "$postPwd");
      print redirect(-url=>"love2041.cgi");
      exit 0;
      print page_header($cookieUsername, $cookiePwd);
      print browse_screen();
      print page_trailer();
    }
  }

login();

exit 0;	

sub login{
  print $q->header,
      $q->start_html("Love9041"),
      $q->h1("Meet people close to you with a single click"),
      $q->h2("Login"),
      start_form(
        -method =>"post",
        -action=>"a.cgi?login",
        -enctype=>'text/plain'
        -onsubmit=>"test"),
      $q->textfield(
        -name => "username",
        -placeholder => "username",
        -size => 20),
        "<br>",
      $q->textfield(
        -name => "password",
        -placeholder => "password",
        -size => 20),
        "<br>",
        "<input type='submit' value='Submit'>",
      end_form,
      $q->end_html;
}
sub browse_screen {
	my $n = param('n') || 0;
	my @students = glob("$students_dir/*");
	$n = min(max($n, 0), $#students);
	param('n', $n + 1);
	my $student_to_show  = $students[$n];
	my $profile_filename = "$student_to_show/profile.txt";
	open my $p, "$profile_filename" or die "can not open $profile_filename: $!";
	$profile = join '', <$p>;
	close $p;
	
	return p,
		start_form, "\n",
		pre($profile),"\n",
		hidden('n', $n + 1),"\n",
		submit('Next student'),"\n",
		end_form, "\n",
		p, "\n";
}

#
# HTML placed at bottom of every screen
#
sub page_header {
	return header( -cookie => [@_]),
   		start_html("-title"=>"LOVE9041", -bgcolor=>"#FEDCBA"),
 		center(h2(i("LOVE2041")));
}

#
# HTML placed at bottom of every screen
# It includes all supplied parameter values as a HTML comment
# if global variable $debug is set
#
sub page_trailer {
	my $html = "";
	$html .= join("", map("<!-- $_=".param($_)." -->\n", param())) if $debug;
	$html .= end_html;
	return $html;
}
