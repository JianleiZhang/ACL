package ACL::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

sub login {
  my $self = shift;

  my $username = $self->param('username');
  my $password = $self->param('password');

  $self->render_later;

  Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      my $sql   = "SELECT roles,password FROM users WHERE username = '$username'";
      $self->pg->db->query($sql, $delay->begin);
    },
    sub {
      my ($delay, $err, $result) = @_;

      if($result->rows == 0){
	return $self->render(text => 'username error!');
      }

      my $user = $result->hash;

      if($password eq $user->{password}){
	$self->session(roles => $user->{roles});
	return $self->render(text => 'success!');
      }else{
	return $self->render(text => 'password error!');
      }
    });
}

1;
