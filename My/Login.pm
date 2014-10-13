package My::Login;
use strict;
use warnings;
use My::Utility qw(studentExist getProfile attrMatch);

use Exporter qw(import);

our @EXPORT_OK = qw(authenticate);
sub authenticate($$){
  my( $username, $pwd ) =@_;
  my $path = "./students/$username";
# Does user exist?
  if( studentExist($username) ){
    my $hashRef = getProfile($username);
    if(attrMatch("password",$pwd, $hashRef)){
      return 1;
    }
  }
  return 0;
}

1;
