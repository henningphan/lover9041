package My::Utility;
use strict;
use warnings;
use List::Util qw(first min);

use Exporter qw(import);

our @EXPORT_OK = qw(findStudent findNextStudent getProfile);

sub findStudent($){  # Returns bool if found
  my($username) =@_;
  my $path = "./students/$username";
  if( -e $path ){
    return 1;
  }
  return 0;
}

sub findNextStudent($$){ # Returns username if found else empty string
  my($username,$count) = @_;
  my $usernameNext ="";
  my @students = glob("./students/*");
  for my $stud (@students){
    $stud =~ s/^\.\/students\///;
  }
  my $idx = first{ $students[$_] eq "$username" }0..$#students;
  $idx = $idx+1;
  if( not defined $idx or $idx > $#students ){
    return @students[0..9];
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

1;
