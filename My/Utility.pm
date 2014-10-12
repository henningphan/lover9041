package My::Utility;
use strict;
use warnings;
use List::Util qw(first min);

use Exporter qw(import);

our @EXPORT_OK = qw(findStudent findNextStudent getProfile getPartProfile attrMatch getPreference);

sub findStudent($){  # Returns bool if found
  my($username) =@_;
  my $path = "./students/$username";
  if( -e $path ){
    return 1;
  }
  return 0;
}

sub findNextStudent($$){ # Returns list of username if found else empty string
  my($username,$count) = @_;
  my $usernameNext ="";
  my @students = glob("./students/*");
  for my $stud (@students){
    $stud =~ s/^\.\/students\///;
  }
  my $idx = first{ $students[$_] eq "$username" }0..$#students;
  $idx = $idx+1;
  print "$idx $#students\n";
  if( not defined $idx or $idx > $#students ){
    my @temp = @students[0..$count-1];
    return \@temp;
  }
  my $idxEnd = min($idx+$count-1, $#students);
  my @temp = @students[$idx..$idxEnd];
  return \@temp;

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
