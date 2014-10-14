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
use My::Utility qw(getProfile getPartProfile getNextStudent getXStudents getPrevStudent match);
warningsToBrowser(1);

# Relative paths will be correct if we use the scripts location as working directory
chdir $FindBin::Bin;
# print start of HTML ASAP to assist debugging if there is an error in the script

# some globals used through the script
$debug = 1;
$students_dir = "./students";

$q = CGI->new;
$cookieUser = $q->cookie("username");
$cookiePwd = $q->cookie("password");

# First time logging in?
if( not defined $cookieUser ){
    $postUsername = param("username");
    $postPwd = param ("password");
    if( authenticate($postUsername, $postPwd)){
      $cookieUser = cookie(
        -name => "username",
        -value=> "$postUsername");
      $cookiePwd = cookie(
        -name => "password",
        -value=> "$postPwd");
      print page_header($cookieUser, $cookiePwd);
      print "\n",menu();
      print myProfile("$postUsername");
      print page_trailer();
      exit 0;
  }
  print login();
  exit 0;
}
# Do you have a valid cookie?
if( not authenticate($cookieUser, $cookiePwd) ){
  print logout();
  exit 0;
}
if(param("view") eq "myprofile"){
  print header,
   		start_html("-title"=>"LOVE9041", -bgcolor=>"#FEDCBA"),
 		center(h2(i("LOVE2041")));
  print "\n",menu();  
  print myProfile($cookieUser);
  print page_trailer();
  exit 0;
} elsif (param("view") eq "logout"){
  print logout();
  exit 0;

} elsif( param("view") eq "partprofile" ){
  print page_header();
  print menu();
  print partProfile($cookieUser);
  print page_trailer();

} elsif( param("view") eq "multipartprofile"){
  my $name = param("name");
  my $names = getXStudents($name,10);
  param("name",$$names[$#$names]);
  print page_header();
  print menu($nameNext);
  foreach $item (@$names){
    print partProfile($item);
  }
  print page_trailer();

} elsif( param("view") eq "search"){
  @students = glob("$students_dir/*");
  my $chosen;
  my $searchparam = param("searchparam");
  foreach my $student (@students){
    $student =~s/^\.\/students\///;
    $chosen = $student;
    if ( $student =~/.*$searchparam.*/ ){
      last;
    }
  }

  print page_header(),
    start_html,
    menu(),
    partProfile($chosen),
    end_html;

}
 elsif( param("view") eq "bestfit"){
  @students = glob("$students_dir/*");
  my %hash;
  foreach my $stud (@students){
    $stud =~s/^\.\/students\///;
    $hash{$stud} = match( $cookieUser, $stud) + match( $stud, $cookieUser);
  }
  my $output;
  foreach $key (sort { $hash{$b} <=> $hash{$a} } keys %hash){
    $output = $output . "key=($key)\t $hash{$key}\n";
  }
  print header, start_html, pre($output);
  print  end_html;
  exit 0;
}


sub login{
  return $q->header,
      $q->start_html("Love9041"),
      $q->h1("Meet people close to you with a single click"),
      $q->h2("Login"),
      $q->start_form(
        -method =>"post",
        -action=>"a.cgi?view=myprofile",
        -enctype=>'text/plain'
        -onsubmit=>"test"),
      $q->textfield(
        -name => "username",
        -placeholder => "username",
        -value => "AwesomeWoman76",
        -size => 20),
        "<br>",
      $q->textfield(
        -name => "password",
        -placeholder => "password",
        -value => "florida",
        -size => 20),
        "<br>",
        "<input type='submit' value='Submit'>",
      $q->end_form,
      $q->end_html;
}
sub logout{
  $cookieUser = cookie( 
    -name =>"username",
    -value => "",
    -expires => "now");
  $cookiePwd = cookie( 
    -name =>"password",
    -value => "",
    -expires => "now");
  return $q->header( -cookie => [$cookieUser, $cookiePwd]),
      $q->start_html("Love9041"),
      $q->h1("Meet people close to you with a single click"),
      $q->h2("Login -> Invalid cookie"),
      $q->start_form(
        -method =>"post",
        -action=>"a.cgi?view=myprofile",
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
      $q->end_form,
      $q->end_html;

}
sub myProfile($){
  my ($username) = @_;
  $profileRef = getProfile($username);
  my $profileText;
  foreach $key (sort keys %$profileRef){
    $profileText = $profileText . "$key:\n";
    foreach $item (@{${$profileRef}{$key}}){
      $profileText = $profileText . "  $item\n";
    }
  }
  return 
  "<hr>",
  "<img src=\"./students/$username/profile.jpg\">",
  pre($profileText), "\n",
  "<hr>",


}
sub partProfile($){
  my ($username) = @_;
  my $profileRef = getPartProfile( $username);
  my $profileText;
  foreach $key (sort keys %$profileRef){
    $profileText = $profileText . "$key:\n";
    foreach $item (@{${$profileRef}{$key}}){
      $profileText = $profileText . "  $item\n";
    }
  }
  return
  "<hr>",
  "<img src=\"./students/$username/profile.jpg\">",
  pre($profileText), "\n",
  "<hr>";


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
sub menu {
  my($name) = getNextStudent("");
  my $nameNext = getNextStudent(param("name"));
  my $namePrev = getPrevStudent(param("name"),19);
  param("view","search");
  return "<style>
  ul {
        list-style-type: none;
            margin: 0;
                padding: 0;
  }

  li {
        display: inline;
  }
  </style>\n" . 
  "<ul>
  <li><a href='a.cgi?view=myprofile'>MyProfile</a><li>
  <li><a href='a.cgi?view=partprofile'>partProfile</a><li>
  <li><a href='a.cgi?view=multipartprofile&name=$namePrev'>Prev</a><li>
  <li><a href='a.cgi?view=multipartprofile&name=$name'>browse</a><li>
  <li><a href='a.cgi?view=multipartprofile&name=$nameNext'>Next</a><li>","\n",
  "<li>",
  start_form( -method=>"get", -action=>"./a.cgi?"),
  hidden("view" ),
  textfield( -name=>"searchparam",-placeholder=>"search username"),
  end_form, "<li>",
  "<li><a href='a.cgi?view=logout'>Logout</a><li>",
  "</ul>";
} 
