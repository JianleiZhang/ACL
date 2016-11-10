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

  # 权限缓存
  $self->attr('permission');

  # 更新缓存的Helper
  $self->helper(
    update_permission_cache => sub {
      Mojo::IOLoop->delay(
	sub {
	  my $delay = shift;
	  my $sql   = "SELECT roles.id,key FROM roles " .
	              "JOIN permissions ON permissions.id = ANY(roles.permissions)";
	  $self->pg->db->query($sql, $delay->begin);
	},
	sub {
	  my ($delay, $err, $result) = @_;
	  if ($err or not $result->rows){
	    # 考虑数据库错误
	  }else{
            $self->{permission} = {};
            $self->{permission}->{$_->{key}}->{$_->{id}} = 1 for $result->hashes->each;
          }
	});
    });

  Mojo::IOLoop->next_tick(
    sub {
      $self->update_permission_cache;
      # 订阅更新权限的频道
      $self->pg->pubsub->listen(
        permission => sub {
          my ($pubsub, $payload) = @_;
          $self->update_permission_cache;
        });
    });


  # 权限验证
  my $a = $self->routes->under(
    '/' => sub {
      my $self = shift;
      if(not exists $self->session->{roles}){
	$self->render(json => {result => 'failed', failed => 'login'});
	return undef;
      }
      foreach (@{$self->session->{roles}}){
	if ($self->app->{permission}->{$self->current_route}->{$_}){
	  return 1;
	}
      }
      $self->render(json => {result => 'failed', failed => 'permission'});
      return undef;
    });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  $r->get('/user/login')->to('user#login_page');
  $r->post('/user/login')->to('user#login');
  $a->get('/test1')->to('example#welcome')->name('route_name_1');
  $a->get('/test2')->to('example#welcome')->name('route_name_2');
  $a->get('/test3')->to('example#welcome')->name('route_name_3');
  $a->get('/test4')->to('example#welcome')->name('route_name_4');
}

1;
