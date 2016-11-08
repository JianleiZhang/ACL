package ACL;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # PostgreSQL
  $self->helper(pg => sub {
		  state $pg = Mojo::Pg->new('postgresql:///db')});


  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

1;
