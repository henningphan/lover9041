package My::Utility;
use strict;
use warnings;
use List::Util qw(first min);

use Exporter qw(import);

our @EXPORT_OK = qw(studentExist getXStudents getNextStudent getProfile getPartProfile attrMatch getPreference);

sub studentExist($){  # Returns bool if found
  my($username) =@_;
  if( $username eq "" ){ return 0;}
  my $path = "./students/$username";
  if( -e $path ){
    return 1;
  }
  return 0;
}
# Returns @array_ref of students
# starting from $username
# if $username is equal to start with the first username of the list
sub getXStudents($$){
  my($username,$count) = @_;
  my @array;
  if( $username eq ""){
    push @array, getNextStudent($username);
  }else{
    push @array, $username;
  }
  while (--$count ){
    $username = getNextStudent($username);
    push @array, $username;
  }
  return \@array;

}
# Returns next student after $username
# if $username is empty string returns first student
sub getNextStudent($){ 
  my($username) = @_;
  my $usernameNext ="";
  my @students = glob("./students/*");
  for my $stud (@students){
    $stud =~ s/^\.\/students\///;
  }
  my $idx = first{ $students[$_] eq "$username" }0..$#students;
  $idx = ($idx+1)% ($#students+1);
  return $students[$idx];

}
sub getProfile($){ # Returns a hash<string, \@>
  my($username) = @_;
  open F,"<","./students/$username/profile.txt" or
    die "cant open file ./students/$username/profile.txt\n";

  my @profileArr;
  while( my $line = <F> ){
      chomp $line;
      push @profileArr, $line;
  }
  close F;

  my %profile;
  my $idx = 0;
  while ($idx < @profileArr){
    my $key = $profileArr[$idx];
    $key =~ s/:$//;
    my @values;
    $idx = $idx+1;
    while($idx < @profileArr){
      if( $profileArr[$idx] =~ /^\w/){ last;}
      $profileArr[$idx] =~ s/^\s*//;
      push @values, $profileArr[$idx];
      $idx = $idx+1;
    }
    $profile{$key} = \@values;
  }
  return \%profile;
}

sub getPartProfile($){
  my($username) = @_;
  my $hashRef = getProfile($username);
  delete $$hashRef{"name"};
  delete $$hashRef{"password"};
  delete $$hashRef{"email"};
  delete $$hashRef{"courses"};
  return $hashRef;

}
# Returns bool if key found with correct value in the hashref
sub attrMatch($$$){ 
  my($attr,$value,$hashRef) = @_;
  my @valueList = @{${$hashRef}{$attr}};
  foreach my $v (@valueList){
    if( $v eq $value){ return 1; }
  }
  return 0;
}
sub getPreference($){
  my($username) = @_;
  open F, "<", "./students/$username/preferences.txt" or
    die "can't open file ./students/$username/preferences.txt\n";
  my %pref;
  my @prefArr;
  while( my $line = <F> ){
      chomp $line;
      push @prefArr, $line;
  }
  close F;

  my %preference;
  my $idx = 0;
  while ($idx < @prefArr){
    my $key = $prefArr[$idx];
    $key =~ s/:$//;
    my @values;
    $idx = $idx+1;
    while($idx < @prefArr){
      if( $prefArr[$idx] =~ /^\w/){ last;}
      $prefArr[$idx] =~ s/^\s*//;
      push @values, $prefArr[$idx];
      $idx = $idx+1;
    }
    $preference{$key} = \@values;
  }
  return \%preference;



}

1;
