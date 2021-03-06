package My::Utility;
use strict;
use warnings;
use List::Util qw(first min);

use Exporter qw(import);

our @EXPORT_OK = qw(studentExist getXStudents getNextStudent getProfile getPartProfile attrMatch getPreference getPrevStudent match );

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
  my $idx = defined $username ? first{ $students[$_] eq "$username" }0..$#students: 0;
  $idx = ($idx  +1)% ($#students+1);
  return $students[$idx];

}
# getPrevStudent $username [ $offset ] 
# returns next user with a negative offset from $username
sub getPrevStudent{
  my($username, $offset) = @_;
  my @students = glob("./students/*");
  for my $stud (@students){
    $stud =~ s/^\.\/students\///;
  }
  my $idx= first{ $students[$_] eq "$username" }0..$#students;
  if( defined $offset){
    $idx = (($idx || 0)-$offset )% ($#students+1);
  }else{
    $idx = (($idx || 0)-1 )% ($#students+1);
  }
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

sub match($$){
  my($src, $targ) = @_;
  die if not studentExist($src);
  die if not studentExist($targ);
  my $score = 0;
  my %srcPro= %{getProfile($src)};
  my %srcPref= %{getPreference($src)};
  my %targPro= %{getProfile($targ)};
  my %targPref = %{getPreference($targ)};
  $score += 1000*like($srcPref{"gender"},$targPro{"gender"});
  $score += 1000*like($srcPref{"hair_colours"},$targPro{"hair_colours"});
  $score += interval( $srcPref{"weight"}, $targPro{"weight"} );
  $score += interval( $srcPref{"height"}, $targPro{"height"} );
  $score += interval( $srcPref{"age"}, $targPro{"age"} );
  my $srcWords = getWord($src);
  my $targWords = getWord($targ);
  foreach my $key (keys %{$srcWords}){
    if( exists ${$targWords}{ $key }){
      $score += 10 * min(${$srcWords}{$key}, ${$targWords}{$key});
    }
  }
  return $score;

}
sub like($$){ # Matches array1 to see if any attribute exist in array2
  my($srcRef, $targRef) = @_;
  foreach my $value (@$srcRef){
    if( grep {$_ eq $value } @$targRef){
      return 1;

    }
  }
  return 0;
}
# assume min is always before max
sub interval($$){
  my($srcRef, $targRef) = @_;
  my $boundLo = $$srcRef[1];
  my $boundHi = $$srcRef[3];
  my $value = $$targRef[0];
#if you dont care about the attribute return max value
  if( not defined $boundLo){
    return 1000;
  }
#if you care but doesnt know, return half max value
  if( not defined $value){
    return 500;
  }
  $boundLo=~ s/[^0-9]//g;
  $boundHi=~ s/[^0-9]//g;
  $value =~ s/[^0-9]//g;
  if( $boundLo < $value and $boundHi > $value ){
    return 1000;
  }
  my $diff = min(abs( $boundLo-$value),abs($value-$boundHi));
  if( $diff > 10){
    return 0;
  }
  return 1000-100* $diff;
  


}
sub getWord($){
  my ($username) = @_;
  my $p;
  open $p, "<", "./students/$username/profile.txt" or die "./$username/profile.txt";
  my %hash;
  while(  <$p>){
#    while( /(\w['\w-]*)/g){
      $hash{ lc $_}++;
#    }
  }
  close $p;
  return \%hash;
}

1;
