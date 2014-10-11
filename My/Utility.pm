package My::Utility;
use strict;
use warnings;
use List::Util qw(first min);

use Exporter qw(import);

our @EXPORT_OK = qw(findStudent findNextStudent);

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
  print "$idx $students[$idx]\n";
  my $idxEnd = min($idx+$count-1, $#students);
  my @temp = @students[$idx..$idxEnd];
  return \@temp;

}


1;
